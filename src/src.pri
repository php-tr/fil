SOURCES += \
    $$PWD/main.cpp \ 
    $$PWD/ApplicationInfo.cpp \
    $$PWD/MagazineModel.cpp \
    $$PWD/MagazineListModel.cpp \
    $$PWD/ImageProvider.cpp

HEADERS += \
    $$PWD/ApplicationInfo.h \
    $$PWD/MagazineModel.h \
    $$PWD/MagazineListModel.h \
    $$PWD/ImageProvider.h \
    $$PWD/NativeDialog.h \
    $$PWD/PdfReader.h

ios {
    OBJECTIVE_SOURCES += \
        $$PWD/NativeDialog.mm \
        $$PWD/PdfReader.mm
} else: android {
    SOURCES += \
        $$PWD/PdfReader.cpp \
        $$PWD/NativeDialog.cpp
}
