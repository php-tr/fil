#ifndef APPLICATIONINFO_H
#define APPLICATIONINFO_H

#include <QtQuick>
#include <QtQml>
#include <QtCore/QString>
#include <QtCore/QObject>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkRequest>
#include <QNetworkAccessManager>
#include <QtCore/QUrl>
#include <QtCore/QUrlQuery>
#include <QtCore/QFile>
#include <QtCore/QDir>
#include <QtCore/QStandardPaths>
#include <QtCore/QStringList>
#include "MagazineListModel.h"
#include "PdfReader.h"

class ImageProvider;

class ApplicationInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int applicationWidth READ applicationWidth WRITE setApplicationWidth NOTIFY applicationWidthChanged)
    Q_PROPERTY(int applicationDefaultHeight READ applicationDefaultHeight NOTIFY applicationDefaultHeightChanged)
    Q_PROPERTY(qreal ratio READ ratio NOTIFY ratioChanged)
    Q_PROPERTY(qreal hMargin READ hMargin NOTIFY hMarginChanged)
    Q_PROPERTY(QObject *theme READ themeInfo CONSTANT)
    Q_PROPERTY(QObject *magazineListModel READ magazineListModel CONSTANT)
    Q_PROPERTY(QObject *pdfReader READ pdfReader CONSTANT)

private:
    int _applicationWidth;
    int _applicationDefaultHeight;
    qreal _ratio;
    qreal _hMargin;
    QQmlPropertyMap *_themeInfo;
    MagazineListModel *_magazineListModel;
    ImageProvider *_imageProvider;
    PdfReader *_pdfReader;
    QQmlEngine *_qmlEngine;

    inline static QString getPath(QStandardPaths::StandardLocation location)
    {
        QString path = QStandardPaths::standardLocations(location).value(0);
        QDir dir(path);
        if (!dir.exists())
        {
            dir.mkpath(path);
        }

        if (!path.isEmpty() && !path.endsWith("/"))
        {
            path += "/";
        }

        return path;
    }

public:
    ApplicationInfo(ImageProvider *provider, QQmlEngine *qmlEngine);
    ~ApplicationInfo();

    int applicationWidth() const;
    void setApplicationWidth(int newWidth);

    int applicationDefaultHeight() const;

    qreal ratio() const;
    qreal hMargin() const;

    QQmlPropertyMap *themeInfo() const;
    MagazineListModel *magazineListModel() const;
    PdfReader *pdfReader() const;

    Q_INVOKABLE QString getAsset(const QString assetName) const;

    inline static QString getDownloadPath()
    {
        return getPath(QStandardPaths::CacheLocation);
    }

    inline static QString getSettingPath()
    {
        return getPath(QStandardPaths::DataLocation);
    }

private slots:

signals:
    void applicationWidthChanged();
    void ratioChanged();
    void hMarginChanged();
    void applicationDefaultHeightChanged();
};

#endif // APPLICATIONINFO_H
