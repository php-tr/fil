#include <QGuiApplication>
#include <QtQuick>
#include <QtQml>

#include "ApplicationInfo.h"
#include "ImageProvider.h"
#include "NativeDialog.h"
#include "PdfReader.h"

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

int main(int argc, char *argv[])
{
    // initialize Qt app
    QGuiApplication app(argc, argv);

    // set basic info into app
    app.setOrganizationName("PHP TR");
    app.setApplicationName("PHiLiP");

    // set orientation
    app.primaryScreen()->setOrientationUpdateMask(Qt::LandscapeOrientation | Qt::PortraitOrientation);

    // set translator
    QTranslator translator;
    translator.load("phrase-tr");
    qWarning() << "Translator Status: " << app.installTranslator(&translator);

    QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf8"));

    // register custom qml classes and instances
    const char *qmlPackage = "org.phptr.philip";
    qmlRegisterSingletonType<ApplicationInfo>(qmlPackage, 1, 0, "ApplicationInfo", applicationProvider);
    qmlRegisterType<MagazineListModel>(qmlPackage, 1, 0, "MagazineListModel");
    qmlRegisterType<NativeDialog>(qmlPackage, 1, 0, "NativeDialog");
    qmlRegisterType<MagazineModel>(qmlPackage, 1, 0, "MagazineModel");
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
