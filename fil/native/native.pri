
android {
    # Android native project
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += $$PWD/android/AndroidManifest.xml

    QT += androidextras core-private

    equals(ANDROID_TARGET_ARCH, armeabi-v7a) {
        ANDROID_EXTRA_LIBS += $$PWD/../3rdparty/mupdf-android/armeabi-v7a/libmupdf.so
    }
    equals(ANDROID_TARGET_ARCH, armeabi) {
        ANDROID_EXTRA_LIBS += $$PWD/../3rdparty/mupdf-android/armeabi/libmupdf.so
    }
    equals(ANDROID_TARGET_ARCH, x86)  {
        ANDROID_EXTRA_LIBS += $$PWD/../3rdparty/mupdf-android/x86/libmupdf.so
    }
}

ios {
    QMAKE_INFO_PLIST = $$PWD/ios/Info.plist
    LIBS += \
        -framework CoreData \
        -L$$PWD/ios/3rdparty/google-analytics-ios -lGoogleAnalyticsServices \
        -framework ImageIO \
        -framework MessageUI \
        -framework CoreData \
        -framework SystemConfiguration \
        -lz

    QMAKE_CFLAGS += -fobjc-arc

    LAUNCH_SCREEN.files = \
        $$PWD/ios/Images.xcassets \
        $$PWD/ios/Launch.xib \
        $$PWD/ios/launch-splash.png \
        $$PWD/ios/splash/LaunchImage-568h@2x.png \
        $$PWD/ios/splash/LaunchImage.png \
        $$PWD/ios/splash/LaunchImage@2x.png
    LAUNCH_SCREEN.path =
    QMAKE_BUNDLE_DATA += LAUNCH_SCREEN

    OBJECTIVE_HEADERS += \
        $$PWD/ios/3rdparty/PdfReader/Sources/CGPDFDocument.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderConstants.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderContentPage.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderContentTile.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderContentView.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderDocument.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderDocumentOutline.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderMainPagebar.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderMainToolbar.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbCache.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbFetch.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbQueue.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbRender.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbRequest.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbsView.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbView.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderViewController.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ThumbsMainToolbar.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/ThumbsViewController.h \
        $$PWD/ios/3rdparty/PdfReader/Sources/UIXToolbarView.h

    OBJECTIVE_SOURCES += \
        $$PWD/ios/3rdparty/PdfReader/Sources/CGPDFDocument.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderConstants.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderContentPage.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderContentTile.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderContentView.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderDocument.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderDocumentOutline.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderMainPagebar.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderMainToolbar.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbCache.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbFetch.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbQueue.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbRender.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbRequest.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbsView.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderThumbView.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ReaderViewController.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ThumbsMainToolbar.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/ThumbsViewController.m \
        $$PWD/ios/3rdparty/PdfReader/Sources/UIXToolbarView.m

    LIB_IMAGES.path =
    LIB_IMAGES.files = \
        $$PWD/ios/3rdparty/PdfReader/Graphics/AppIcon-057.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/AppIcon-072.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/AppIcon-114.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/AppIcon-144.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Button-H.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Button-H@2x.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Button-N.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Button-N@2x.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Email.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Email@2x.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Mark-N.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Mark-N@2x.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Mark-Y.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Mark-Y@2x.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Print.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Print@2x.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Thumbs.png \
        $$PWD/ios/3rdparty/PdfReader/Graphics/Reader-Thumbs@2x.png

    QMAKE_BUNDLE_DATA += LIB_IMAGES
}
