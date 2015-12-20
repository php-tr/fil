#include "applicationplugin.h"
#include "applicationinfo.h"
#include "pdfreader.h"
#include <QDir>
#include <QFontDatabase>

Q_LOGGING_CATEGORY(FilPlugin, "org.phptr.fil.plugin")

static inline QObject *createApplicationInfo(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)

    return ApplicationInfo::instance();
}

void ApplicationPlugin::registerTypes()
{
    const char *uri = "org.phptr.fil";
    qmlRegisterSingletonType<ApplicationInfo>(uri, 2, 0, "ApplicationInfo", createApplicationInfo);
    qmlRegisterType<PdfReader>(uri, 2, 0, "PdfReader");
}

void ApplicationPlugin::loadFonts(const QString &fontPath)
{
    const QStringList fontList = QDir(fontPath).entryList();
    qDebug() << "FONT LIST:" << fontPath << fontList;
    foreach (const QString &fontName, fontList) {
        if (QFontDatabase::addApplicationFont(QString("%1/%2").arg(fontPath).arg(fontName)) == -1)
            qCritical(FilPlugin) << "The font " << QString("'%2/%1'").arg(fontPath).arg(fontName) << "cannot be loaded.";
    }
}
