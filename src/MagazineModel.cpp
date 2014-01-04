#include "MagazineModel.h"
#include <QtCore/QDebug>

MagazineModel::MagazineModel(QObject *parent) :
    QObject(parent)
{
}

void MagazineModel::setData(int id, QString name, QString imageUrl, QString pdfUrl, qulonglong fileSize, QDateTime releaseDate, bool isNew, QString pdfPath)
{
    this->_data.id = id;
    this->_data.name = name;
    this->_data.imageUrl = imageUrl;
    this->_data.pdfUrl = pdfUrl;
    this->_data.fileSize = fileSize;
    this->_data.releaseDate = releaseDate;
    this->_data.pdfPath = pdfPath;
    this->_data.isPdfDownloaded = pdfPath.isEmpty() ? false : true;
    this->_data.pdfPath = pdfPath;
    this->_data.isNew = isNew;

   //  qDebug() << QString("Id: %1, Name: %2, ImageUrl: %3, PdfUrl: %4, FileSize: %5, ReleaseDate: %6, isPdfDownloaded: %7, isNew: %8").arg(id).arg(name).arg(imageUrl).arg(pdfUrl).arg(fileSize).arg(releaseDate.toUTC().toString()).arg(isPdfDownloaded).arg(isNew);
   // qDebug() << releaseDate;
}

void MagazineModel::setPdfPath(QString pdfPath)
{
    this->_data.pdfPath = pdfPath;
    this->_data.isPdfDownloaded = true;

    emit this->isPdfDownloadedChanged();
}

QVariant MagazineModel::getData(QString prop)
{
    if (prop == "id")
    {
        return this->_data.id;
    }
    else if (prop == "name")
    {
        return this->_data.name;
    }
    else if (prop == "imageUrl")
    {
        return this->_data.imageUrl;
    }
    else if (prop == "pdfUrl")
    {
        return this->_data.pdfUrl;
    }
    else if (prop == "fileSize")
    {
        return this->_data.fileSize;
    }
    else if (prop == "isNew")
    {
        return this->_data.isNew;
    }
    else if (prop == "releaseDate")
    {
        return this->_data.releaseDate;
    }
    else if (prop == "isPdfDownloaded")
    {
        return this->_data.isPdfDownloaded;
    }
    else if (prop == "pdfPath")
    {
        return this->_data.pdfPath;
    }

    return QVariant();
}

int MagazineModel::getId()
{
    return this->_data.id;
}

bool MagazineModel::getIsPdfDownloaded()
{
    return this->_data.isPdfDownloaded;
}
