#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QLoggingCategory>
#include <QQmlContext>
#include <QTranslator>
#include "../src/applicationplugin.h"
#include "../src/applicationinfo.h"

Q_LOGGING_CATEGORY(FRAME_TAG, "org.phptr.fil.main")

static inline QString getPlatform()
{
#if defined(Q_OS_ANDROID)
    return QLatin1String("Android");
#elif defined(Q_OS_IOS)
    return QLatin1String("iOS");
#elif defined(Q_OS_OSX)
    return QLatin1String("OSX");
#else
    return QLatin1String();
#endif
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationVersion(QLatin1String(APP_VERSION));

    // set language
    QTranslator translator;
    translator.load(QLatin1String(":/res/localization/lang_tr.qm"));
    app.installTranslator(&translator);

    ApplicationPlugin::registerTypes();
    ApplicationPlugin::loadFonts(QString(":%1").arg(QLatin1String(FRAME_FONT_PATH)));

    ApplicationInfo *applicationInfo = ApplicationInfo::instance();

    applicationInfo->setPlatform(getPlatform());
    applicationInfo->setVersion(app.applicationVersion());

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:" FRAME_QML_PATH "/main.qml")));

    qCDebug(FRAME_TAG) << engine.offlineStoragePath();

    return app.exec();
}
