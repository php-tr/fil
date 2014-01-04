#include "ApplicationInfo.h"

#include <QtGui/QGuiApplication>
#include <QtGui/QScreen>
#include <QDebug>
#include <QtCore/QJsonDocument>

ApplicationInfo::ApplicationInfo(ImageProvider *provider, QQmlEngine *qmlEngine)
    : _imageProvider(provider), _qmlEngine(qmlEngine)
{
    QRect rect = qApp->primaryScreen()->geometry();

    this->_ratio = qMin(qMax(rect.width(), rect.height()) / 1136., qMin(rect.width(), rect.height()) / 640.);
    this->_hMargin = 20 * this->_ratio;
    this->_applicationWidth = rect.width();
    this->_applicationDefaultHeight = rect.height();

    this->_themeInfo = new QQmlPropertyMap(this);
    this->_themeInfo->insert(QLatin1String("headerBackgroundColor"), QVariant("#5498D0"));
    this->_themeInfo->insert(QLatin1String("headerTextColor"), QVariant("#FFFFFF"));
    this->_themeInfo->insert(QLatin1String("headerBottomLine1Color"), QVariant("#36BCE1"));
    this->_themeInfo->insert(QLatin1String("headerBottomLine2Color"), QVariant("#17E3F2"));
    this->_themeInfo->insert(QLatin1String("magazineListBackgroundColor"), QVariant("#5498D0"));
    this->_themeInfo->insert(QLatin1String("magazineListBackgroundColorActive"), QVariant("#17E3F2"));
    this->_themeInfo->insert(QLatin1String("bodyBackgroundColor"), QVariant("#FFFFFF"));
    this->_themeInfo->insert(QLatin1String("colorAlt2"), QVariant("#4781b1"));
    this->_themeInfo->insert(QLatin1String("textColor"), QVariant("#FFFFFF"));
    this->_themeInfo->insert(QLatin1String("primaryFont"), QVariant("TR Blue Highway"));
    this->_themeInfo->insert(QLatin1String("secondaryFont"), QVariant("Open Sans"));
    this->_themeInfo->insert(QLatin1String("modalBackgroundColor"), QVariant("#000000"));

    this->_magazineListModel = new MagazineListModel(this);
    this->_pdfReader = new PdfReader(this, this->_qmlEngine);
}

int ApplicationInfo::applicationWidth() const
{
    return this->_applicationWidth;
}

int ApplicationInfo::applicationDefaultHeight() const
{
    return this->_applicationDefaultHeight;
}

void ApplicationInfo::setApplicationWidth(int newWidth)
{
    if (this->_applicationWidth != newWidth)
    {
        this->_applicationWidth = newWidth;
        emit this->applicationWidthChanged();
    }
}

qreal ApplicationInfo::ratio() const
{
    return this->_ratio;
}

qreal ApplicationInfo::hMargin() const
{
    return this->_hMargin;
}

QQmlPropertyMap *ApplicationInfo::themeInfo() const
{
    return this->_themeInfo;
}

MagazineListModel *ApplicationInfo::magazineListModel() const
{
    return this->_magazineListModel;
}

QString ApplicationInfo::getAsset(const QString assetName) const
{
    return QString("qrc:/philip/asset/%1").arg(assetName);
}

PdfReader *ApplicationInfo::pdfReader() const
{
    return this->_pdfReader;
}
