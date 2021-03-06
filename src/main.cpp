#include <QGuiApplication>
#include <QtQuick>
#include <QtQml>
#ifdef Q_OS_ANDROID
#include <QtAndroidExtras/QtAndroidExtras>
#endif
#include "ApplicationInfo.h"
#include "ImageProvider.h"
#include "NativeDialog.h"
#include "PdfReader.h"
#include "Analytics.h"

static const struct {
    const char *type;
    int major;
    int minor;
} pages[] = {
    { "MagazineList", 1, 0 },
    { "Refresh", 1, 0 }
};

static const struct {
    const char *type;
    int major;
    int minor;
} elements[] = {
    { "ModalDialog", 1, 0 },
    { "DownloadProgress", 1, 0 },
    { "ModalMessage", 1, 0 }
};

static QObject *applicationProvider(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(jsEngine);

    ImageProvider *provider = new ImageProvider();
    qmlEngine->addImageProvider(QLatin1String("philip"), provider);

    return new ApplicationInfo(provider, qmlEngine);
}

#ifdef Q_OS_ANDROID

static void downloadConfirmed(JNIEnv *, jclass, jint magazineId)
{
    emit NativeDialog::getInstance()->downloadConfirmed((int) magazineId);
}

static JNINativeMethod methods[] =
{
    {"downloadConfirmed", "(I)V", (void *) downloadConfirmed}
};

int JNICALL JNI_OnLoad(JavaVM *vm, void *)
{
    JNIEnv *env;
    if (vm->GetEnv(reinterpret_cast<void **>(&env), JNI_VERSION_1_4) != JNI_OK)
    {
        return JNI_FALSE;
    }

    jclass mainActivity = env->FindClass("org/phptr/philip/MainActivity");
    if (env->RegisterNatives(mainActivity, methods, sizeof(methods) / sizeof(methods[0])))
    {
        return JNI_FALSE;
    }

    return JNI_VERSION_1_4;
}
#endif

int main(int argc, char *argv[])
{
    // initialize Qt app
    QGuiApplication app(argc, argv);

    // set basic info into app
    app.setOrganizationName("PHP TR");
    app.setApplicationName("PHiLiP");

    // set orientation
    app.primaryScreen()->setOrientationUpdateMask(Qt::LandscapeOrientation | Qt::PortraitOrientation);

    QString translationPath = QString("phrase-tr");

#ifndef Q_OS_IOS
    QFontDatabase::addApplicationFont(":/philip/fonts/OpenSans-Bold.ttf");
    QFontDatabase::addApplicationFont(":/philip/fonts/OpenSans-Semibold.ttf");
    int openSansId = QFontDatabase::addApplicationFont(":/philip/fonts/OpenSans-Regular.ttf");
    QStringList loadedFontFamilies = QFontDatabase::applicationFontFamilies(openSansId);
    if (!loadedFontFamilies.empty())
    {
        QString fontName = loadedFontFamilies.at(0);
        QGuiApplication::setFont(QFont(fontName));
    }
    else
    {
        qWarning("Error: fail to load Open Sans font");
    }
    int trBlueHeighwayId = QFontDatabase::addApplicationFont(":/philip/fonts/TR-Blue-Highway.ttf");
    QStringList highwayFamily = QFontDatabase::applicationFontFamilies(trBlueHeighwayId);
    if (!highwayFamily.empty())
    {
        QGuiApplication::setFont(QFont(highwayFamily.at(0)));
    }
    else
    {
        qWarning("Error: fail to load TR Blue Highway font");
    }

    translationPath = ":/philip/phrase-tr";
#endif

    // set translator
    QTranslator translator;
    translator.load(translationPath);
    qWarning() << "Translator Status: " << app.installTranslator(&translator);

    QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf8"));

    // register custom qml classes and instances
    const char *qmlPackage = "org.phptr.philip";
    qmlRegisterSingletonType<ApplicationInfo>(qmlPackage, 1, 0, "ApplicationInfo", applicationProvider);
    qmlRegisterType<MagazineListModel>(qmlPackage, 1, 0, "MagazineListModel");
    qmlRegisterType<NativeDialog>(qmlPackage, 1, 0, "NativeDialog");
    qmlRegisterType<MagazineModel>(qmlPackage, 1, 0, "MagazineModel");
    qmlRegisterType<Analytics>(qmlPackage, 1, 0, "Analytics");
    // qmlRegisterType<Dialog>(qmlPackage, 1, 0, "PdfReader");

    for (int i = 0; i < int(sizeof(pages) / sizeof(pages[0])); i++)
    {
        qmlRegisterType(QString("qrc:/philip/qml/page/%1.qml").arg(pages[i].type), qmlPackage, pages[i].major, pages[i].minor, pages[i].type);
    }

    for (int i = 0; i < int(sizeof(elements) / sizeof(elements[0])); i++)
    {
        qmlRegisterType(QString("qrc:/philip/qml/element/%1.qml").arg(elements[i].type), qmlPackage, elements[i].major, elements[i].minor, elements[i].type);
    }

    // init qml app engine
    QQmlApplicationEngine engine(QUrl("qrc:/philip/qml/main.qml"));

    // check if top layer of main is not QQuickWindow
    QObject *top = engine.rootObjects().at(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(top);
    if (!window)
    {
        qWarning("Error: The top object is not a window.");
        return EXIT_FAILURE;
    }

    // show window
    window->show();

    // main loop of app
    return app.exec();
}
