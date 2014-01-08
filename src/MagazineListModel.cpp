
#include "MagazineListModel.h"
#include "ApplicationInfo.h"

// class ApplicationInfo;

MagazineListModel::MagazineListModel(QObject *parent) :
    QAbstractListModel(parent),
    _currentDownloadNetworkReply(0),
    _refreshUrl("http://fil.php-tr.com/mobile.php?type=pdf_list&token=iyeO0/tpdSKkpelwO1l1Jd01t2Qvr4nMek3TC43xEYw=")
{
    this->_networkAccessManager = new QNetworkAccessManager(this);
    connect(this->_networkAccessManager, SIGNAL(finished(QNetworkReply *)), this, SLOT(handleNetworkReply(QNetworkReply *)));

    this->_pdfNetworkAccess = new QNetworkAccessManager(this);
    connect(this->_pdfNetworkAccess, SIGNAL(finished(QNetworkReply *)), this, SLOT(handlePdfDownload(QNetworkReply *)));

    this->_saveFilePath = QString("%1magazine.setting").arg(ApplicationInfo::getSettingPath());
    this->loadFromDb();

    this->retrieveDataFromApi();
}

void MagazineListModel::handleNetworkReply(QNetworkReply *reply)
{
    QString replyUrl = reply->url().toString();
    if (reply->error() != QNetworkReply::NoError)
    {
        if (replyUrl == this->_refreshUrl)
        {
            emit this->refreshError(tr("Network Error: Could not establish a connection."));
        }
        else
        {
            this->setError(tr("Network Error: Could not establish a connection."));
        }
    }
    else if (replyUrl.endsWith(".png"))
    {
        QString fileName = replyUrl.right(replyUrl.length() - replyUrl.lastIndexOf("/") - 1);
        QString filePath = this->getImageFilePath(fileName);

        QFile file(filePath);
        if (!file.exists() && file.open(QIODevice::WriteOnly))
        {
            file.write(reply->readAll());
            file.close();
        }
    }
    else
    {
        QJsonParseError error;
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll(), &error);
        QString errorString = 0;

        if (error.error != QJsonParseError::NoError)
        {
            errorString = error.errorString();
        }

        // qDebug(document.toJson().data());

        bool errorOccured = true;
        if (error.error == QJsonParseError::NoError && document.isObject())
        {
            QJsonObject data = document.object();
            if (data["success"].isBool() && data["success"].toBool())
            {
                this->loadData(data["response"].toArray(), true);
                errorOccured = false;
            }
            else
            {
                errorString = data["message"].toString();
            }
        }

        if (errorOccured)
        {
            if (!errorString.isEmpty())
            {
                // qWarning(errorString.toLocal8Bit().data());
                // qWarning() << errorString;
            }

            this->setError(tr("Could not retrieved data from server"));
        }
        else
        {
            if (replyUrl == this->_refreshUrl)
            {
                emit this->refreshed();
            }
        }
    }
}

void MagazineListModel::handlePdfDownload(QNetworkReply *reply)
{
    this->_currentDownloadNetworkReply = 0;
    this->_currentDownloadableMagazineModel = 0;

    if (reply->error() != QNetworkReply::NoError)
    {
        qWarning() << "Error: " << reply->errorString();
        emit this->downloadError();
        return;
    }

    QUrlQuery query(reply->url().query());
    int id = query.queryItemValue("sayi").toInt();

    QString fileName = QString("%1.pdf").arg(id);
    QString filePath = QString("%1%2").arg(ApplicationInfo::getSettingPath()).arg(fileName);

    qWarning() << "Downloaded file " << filePath;

    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly))
    {
        file.write(reply->readAll());
        file.close();
    }

    // mark as downloaded
    this->getMagazineModelById(id)->setPdfPath(fileName);
    this->saveToDb();

    emit this->downloadCompleted(id);

    int rowCount = this->getIndexById(id);
    qWarning() << "Row Count: " << rowCount;
    if (rowCount > -1)
    {
        this->setData(this->index(0, 0), true);
    }
}

void MagazineListModel::handlePdfDownloadProgress(qint64 readed, qint64 total)
{
    qWarning() << "Downloading: " << readed << " -> " << total;
    emit this->downloadProgress(readed, total);
}

void MagazineListModel::setError(QString errorString)
{
   emit error(errorString);
}

void MagazineListModel::open(int id)
{
    ApplicationInfo *applicationInfo = static_cast<ApplicationInfo *>(this->parent());

    QString pdfFullPath = QString("%1%2").arg(ApplicationInfo::getSettingPath()).arg(this->getMagazineModelById(id)->getData("pdfPath").toString());
    applicationInfo->pdfReader()->openPdf(pdfFullPath);
}

void MagazineListModel::retrieveDataFromApi()
{
    this->_networkAccessManager->get(QNetworkRequest(QUrl("http://fil.php-tr.com/mobile.php?type=pdf_list&token=iyeO0/tpdSKkpelwO1l1Jd01t2Qvr4nMek3TC43xEYw=")));
}

int MagazineListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return this->_data.count();
}

void MagazineListModel::loadData(QJsonArray data, bool checkUpdatedOnces)
{
    int i, len = data.count(), id;
    bool startedAddingIndex = false;
    MagazineModel *magazineModel;
    QJsonObject currentObject;

    for (i = 0; i < len; i++)
    {
        magazineModel = new MagazineModel(this);
        currentObject = data.at(i).toObject();

        id = currentObject["id"].isString() ? currentObject["id"].toString().toInt() : currentObject["id"].toInt();
        if (checkUpdatedOnces && this->getMagazineModelById(id))
        {
            continue;
        }

        magazineModel->setData(
            id,
            currentObject["ad"].toString(),
            currentObject["image"].toString(),
            currentObject["pdf"].toString(),
            currentObject["boyut"].toString().toLongLong(),
            QDateTime::fromString(currentObject["tarih"].toString(), "yyyy-MM-dd hh:mm:ss"),
            currentObject.contains("isNew") ? currentObject["isNew"].toBool() : false,
            currentObject.contains("pdfPath") ? currentObject["pdfPath"].toString() : QString()
        );

        this->downloadImage(magazineModel->getData("imageUrl").toString());
        this->addMagazineModel(magazineModel);
        // qDebug() << QString("Added magazine model: %1").arg(currentObject["ad"].toString());

        if (checkUpdatedOnces)
        {
            beginInsertRows(QModelIndex(), 0, this->rowCount() - 1);
            startedAddingIndex = true;
        }
    }

    if (startedAddingIndex)
    {
        endInsertRows();
    }
}

QHash<int, QByteArray> MagazineListModel::roleNames() const
{
    QHash<int, QByteArray> _rollNames;
    _rollNames[MagazineDisplayRole] = "magazine";
    _rollNames[ImageDisplayRole] = "imageUrl";
    _rollNames[IsPdfDownloadedDisplayRole] = "isPdfDownloaded";
    _rollNames[IdDisplayRole] = "magazineId";
    _rollNames[PdfPathDisplayRole] = "pdfPath";

    return _rollNames;
}

QVariant MagazineListModel::data(const QModelIndex &index, int role) const
{
    MagazineModel *model = this->_data.at(index.row());
    if (model)
    {
        if (role == MagazineDisplayRole)
        {
            return model->getData("name");
        }
        else if (role == ImageDisplayRole)
        {
            return model->getData("imageUrl");
        }
        else if (role == IsPdfDownloadedDisplayRole)
        {
            return model->getData("isPdfDownloaded");
        }
        else if (role == IdDisplayRole)
        {
            return model->getData("id");
        }
        else if (role == PdfPathDisplayRole)
        {
            return model->getData("pdfPath");
        }
    }

    return QVariant();
}

bool MagazineListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.isValid() && role == Qt::EditRole)
    {
        qWarning() << "Data Changed";
        emit this->dataChanged(index, index);
        return true;
    }
    return false;
}

void MagazineListModel::addMagazineModel(MagazineModel *magazineModel)
{
    this->_data.append(magazineModel);
}

bool MagazineListModel::hasMagazineModel(MagazineModel *magazineModel)
{
    return this->_data.indexOf(magazineModel) == -1;
}

void MagazineListModel::loadFromDb()
{
    QFile file(this->_saveFilePath);
    if (file.exists() && file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        this->loadData(QJsonDocument::fromJson(file.readAll()).array());
        file.close();
    }
}

void MagazineListModel::saveToDb()
{
    qWarning() << "Saving to database";

    QFile file(this->_saveFilePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        QJsonDocument doc;
        QJsonArray response;
        MagazineModel *model;

        QTextStream out(&file);
        for (int i = 0; i < this->_data.length(); i++)
        {
            model = this->_data.at(i);
            QJsonObject obj;
            obj.insert("id", model->getId());
            obj.insert("ad", model->getData("name").toString());
            obj.insert("image", model->getData("imageUrl").toString());
            obj.insert("pdf", model->getData("pdfUrl").toString());
            obj.insert("boyut", model->getData("fileSize").toLongLong());
            obj.insert("tarih", model->getData("releaseDate").toDateTime().toString("yyyy-MM-dd hh:mm:ss"));
            obj.insert("isPdfDownloaded", model->getData("isPdfDownloaded").toBool());
            obj.insert("pdfPath", model->getData("pdfPath").toString());
            obj.insert("isNew", model->getData("isNew").toBool());

            response.insert(i, obj);
        }

        doc.setArray(response);

        // qDebug() << QString("Data to Save into %1").arg(this->_saveFilePath);
        // qDebug() << doc.toJson();
        out << doc.toJson();
        file.close();
    }
}

void MagazineListModel::downloadImage(QString imageUrl)
{
    QString fileName = imageUrl.right(imageUrl.length() - imageUrl.lastIndexOf("/") - 1);
    QString filePath = this->getImageFilePath(fileName);

    qDebug() << "Requesting File: " << fileName;

    QFile file(filePath);
    if (!file.exists())
    {
        qDebug() << "Downloading Image: " << filePath;
        this->_networkAccessManager->get(QNetworkRequest(QUrl(imageUrl)));
    }
}

QString MagazineListModel::getImageFilePath(QString fileName)
{
    return QString("%1%2").arg(ApplicationInfo::getDownloadPath()).arg(fileName);
}

QUrl MagazineListModel::getCachedImageUrl(QString imageUrl)
{
    QString fileName = imageUrl.right(imageUrl.length() - imageUrl.lastIndexOf("/") - 1);
    QString filePath = this->getImageFilePath(fileName);

    QFile file(filePath);
    if (file.exists(filePath))
    {
        return QUrl(QString("image://philip/%1").arg(filePath));
    }

    return QUrl(imageUrl);
}

void MagazineListModel::downloadById(int id)
{
    MagazineModel *model = this->getMagazineModelById(id);
    if (model)
    {
        qWarning() << "Downloading";
        QNetworkReply *reply = this->_pdfNetworkAccess->get(QNetworkRequest(QUrl(model->getData("pdfUrl").toString())));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), this, SLOT(handlePdfDownloadProgress(qint64, qint64)));

        this->_currentDownloadNetworkReply = reply;
    }
}

MagazineModel *MagazineListModel::getMagazineModelById(int id)
{
    int len = this->_data.count();
    for (int i = 0; i < len; i++)
    {
        if (this->_data.at(i)->getId() == id)
        {
            return this->_data.at(i);
        }
    }

    return 0;
}

int MagazineListModel::getIndexById(int id)
{
    int len = this->_data.count();
    for (int i = 0; i < len; i++)
    {
        if (this->_data.at(i)->getId() == id)
        {
            return i;
        }
    }

    return -1;
}

void MagazineListModel::cancelDownload()
{
    if (this->_currentDownloadNetworkReply)
    {
        this->_currentDownloadNetworkReply->abort();
        this->_currentDownloadNetworkReply = 0;
    }
}

MagazineListModel::~MagazineListModel()
{
    this->saveToDb();
    for (int i = 0; i < this->_data.length(); i++)
    {
        this->_data.at(i)->deleteLater();
    }
}
