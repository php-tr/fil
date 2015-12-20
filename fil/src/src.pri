
HEADERS += \
    $$PWD/applicationplugin.h \
    $$PWD/applicationinfo.h \
    $$PWD/pdfreader.h \
    $$PWD/pdfreader_p.h

ios {
    HEADERS += $$PWD/pdfreader_ios_p.h
    OBJECTIVE_SOURCES += $$PWD/pdfreader_ios_p.mm
} else:android {
    HEADERS += $$PWD/pdfreader_android_p.h
    SOURCES += $$PWD/pdfreader_android_p.cpp
} else {
    HEADERS += $$PWD/pdfreader_default_p.h
    SOURCES += $$PWD/pdfreader_default_p.cpp
}

SOURCES += \
    $$PWD/applicationplugin.cpp \
    $$PWD/applicationinfo.cpp \
    $$PWD/pdfreader.cpp

