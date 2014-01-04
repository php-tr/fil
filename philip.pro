
TEMPLATE = app
QT += qml quick gui network

TARGET = philip

TRANSLATIONS += phrase-tr.ts

include (src/src.pri)

APP_FILES = \
    $$PWD/qml/main.qml \
    $$PWD/qml/page/BasicPage.qml \
    $$PWD/qml/page/MagazineList.qml \
    $$PWD/qml/page/Separator.qml \
    $$PWD/qml/page/Refresh.qml \
    $$PWD/qml/element/ModalDialog.qml \
    $$PWD/qml/element/DownloadProgress.qml \
    $$PWD/qml/element/ModalMessage.qml

APP_FILES += \
    $$PWD/asset/fil-bg-tiled.png \
    $$PWD/asset/fil-header-logo.png \
    $$PWD/asset/refresh.png \
    $$PWD/asset/view.png \
    $$PWD/asset/download.png \
    $$PWD/asset/close.png \
    $$PWD/asset/spinner.png

OTHER_FILES += $$APP_FILES


QRE_FILE = $$OUT_PWD/philip.qrc
QRE_CONTEXT = \
    "<RCC>" \
    "<qresource>"
for (resourceFile, APP_FILES) {
    absolutePath = $$absolute_path($$resourceFile)
    resourceInPath = $$relative_path($$absolutePath, $$_PRO_FILE_PWD_)
    resourceOutPath = $$relative_path($$absolutePath, $$OUT_PWD)

    QRE_CONTEXT += "<file alias=\"philip/$$resourceInPath\">$$resourceOutPath</file>"
}
QRE_CONTEXT += \
    "</qresource>" \
    "</RCC>"

write_file($$QRE_FILE, QRE_CONTEXT)|error("Aborting. Could not save generated resource file.")

RESOURCES += $$QRE_FILE

ios {
    TRANS.files = $$PWD/phrase-tr.qm
    TRANS.path =

    FONTS.files = $$PWD/fonts/OpenSans-Bold.ttf $$PWD/fonts/OpenSans-Semibold.ttf $$PWD/fonts/OpenSans-Regular.ttf $$PWD/fonts/TR-Blue-Highway.ttf
    FONTS.path = fonts

    LOCALIZED.files = $$PWD/ios/tr.lproj/Localizable.strings
    LOCALIZED.path = tr.lproj

    SPLASH.files = $$PWD/ios/Splash/Default@2x.png $$PWD/ios/Splash/Default.png
    SPLASH.path =

    ICON.files = $$PWD/ios/Icon/Icon.png $$PWD/ios/Icon/Icon@2x.png $$PWD/ios/Icon/Icon-120.png \
                 $$PWD/ios/Icon/Icon-72.png $$PWD/ios/Icon/Icon-72@2x.png $$PWD/ios/Icon/iTunesArtwork.png $$PWD/ios/Icon/iTunesArtwork@2x.png
    ICON.path

    QMAKE_BUNDLE_DATA += \
        FONTS \
        LOCALIZED \
        TRANS \
        SPLASH \
        ICON

    QMAKE_INFO_PLIST = ios/iosInfo.plist
    QMAKE_LFLAGS += -framework ImageIO -framework MessageUI
    QMAKE_CFLAGS += -fobjc-arc

    OBJECTIVE_HEADERS += \
        $$PWD/ios/Library/PdfReader/Sources/CGPDFDocument.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderConstants.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderContentPage.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderContentTile.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderContentView.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderDocument.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderDocumentOutline.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderMainPagebar.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderMainToolbar.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbCache.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbFetch.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbQueue.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbRender.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbRequest.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbsView.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbView.h \
        $$PWD/ios/Library/PdfReader/Sources/ReaderViewController.h \
        $$PWD/ios/Library/PdfReader/Sources/ThumbsMainToolbar.h \
        $$PWD/ios/Library/PdfReader/Sources/ThumbsViewController.h \
        $$PWD/ios/Library/PdfReader/Sources/UIXToolbarView.h

    OBJECTIVE_SOURCES += \
        $$PWD/ios/Library/PdfReader/Sources/CGPDFDocument.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderConstants.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderContentPage.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderContentTile.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderContentView.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderDocument.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderDocumentOutline.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderMainPagebar.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderMainToolbar.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbCache.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbFetch.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbQueue.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbRender.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbRequest.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbsView.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderThumbView.m \
        $$PWD/ios/Library/PdfReader/Sources/ReaderViewController.m \
        $$PWD/ios/Library/PdfReader/Sources/ThumbsMainToolbar.m \
        $$PWD/ios/Library/PdfReader/Sources/ThumbsViewController.m \
        $$PWD/ios/Library/PdfReader/Sources/UIXToolbarView.m

    LIB_IMAGES.path =
    LIB_IMAGES.files = \
        $$PWD/ios/Library/PdfReader/Graphics/AppIcon-057.png \
        $$PWD/ios/Library/PdfReader/Graphics/AppIcon-072.png \
        $$PWD/ios/Library/PdfReader/Graphics/AppIcon-114.png \
        $$PWD/ios/Library/PdfReader/Graphics/AppIcon-144.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Button-H.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Button-H@2x.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Button-N.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Button-N@2x.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Email.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Email@2x.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Mark-N.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Mark-N@2x.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Mark-Y.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Mark-Y@2x.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Print.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Print@2x.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Thumbs.png \
        $$PWD/ios/Library/PdfReader/Graphics/Reader-Thumbs@2x.png

    QMAKE_BUNDLE_DATA += LIB_IMAGES
}

