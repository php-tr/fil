#ifndef MAGAZINELISTMODEL_H
#define MAGAZINELISTMODEL_H

#include <QAbstractListModel>
#include <QtCore/QFile>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QtCore/QJsonArray>
#include <QtCore/QJsonObject>
#include <QtCore/QJsonParseError>
#include <QtCore/QJsonDocument>
#include <QtCore/QDateTime>
#include <QDebug>
#include <QtQml/qqml.h>
#include "MagazineModel.h"


class MagazineListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum
    {
        MagazineDisplayRole = Qt::UserRole + 1,
        ImageDisplayRole = Qt::UserRole + 2,
        IsPdfDownloadedDisplayRole = Qt::UserRole + 3,
        IdDisplayRole = Qt::UserRole + 4,
        PdfPathDisplayRole = Qt::UserRole + 5
    };

    explicit MagazineListModel(QObject *parent = 0);
    ~MagazineListModel();

    Q_INVOKABLE void retrieveDataFromApi();
    Q_INVOKABLE QUrl getCachedImageUrl(QString imageUrl);
    Q_INVOKABLE void downloadById(int id);
    Q_INVOKABLE void open(int id);
    Q_INVOKABLE void cancelDownload();

    void setError(QString errorString);
    Q_INVOKABLE MagazineModel *getMagazineModelById(int id);
    int getIndexById(int id);
    Q_INVOKABLE void saveToDb();

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole);

Q_SIGNALS:
    void ready();
    void error(QString errorString);
    void downloadProgress(qint64 readed, qint64 total);
    void downloadCompleted(int id);
    void downloadError();
    void shouldCheckUpdate();
    void refreshError(QString errorString);
    void refreshed();

public Q_SLOTS:
    void handleNetworkReply(QNetworkReply *reply);
    void handlePdfDownload(QNetworkReply *reply);
    void handlePdfDownloadProgress(qint64, qint64);

private:
    QList<MagazineModel *> _data;
    QNetworkAccessManager *_networkAccessManager;
    QNetworkAccessManager *_pdfNetworkAccess;
    MagazineModel *_currentDownloadableMagazineModel;
    QNetworkReply *_currentDownloadNetworkReply;
    QString _refreshUrl;

    QString _saveFilePath;

    void loadData(QJsonArray data, bool checkUpdatedOnces = false);
    void addMagazineModel(MagazineModel *magazineModel);
    bool hasMagazineModel(MagazineModel *magazineModel);

    void loadFromDb();

    void downloadImage(QString imageUrl);
    QString getImageFilePath(QString fileName);
};

QML_DECLARE_TYPE(MagazineListModel)
#endif // MAGAZINELISTMODEL_H
