TEMPLATE = app
TARGET = fil

QT += qml qml-private quick quick-private core-private gui-private multimedia sql widgets printsupport frame

# Release Version
VERSION = 2.0.0

# Pre Configure
PROJECT_HOME = $$clean_path($${PWD})
PROJECT_FOLDER = $$basename(PROJECT_HOME)

ANDROID_HOME = $$(ANDROID_HOME)
QT_PATH = $$[QT_INSTALL_PREFIX]

# needs to be filled by own configuration
QML_PATH =
FONT_PATH =
IMAGE_PATH =

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Project Structure
include(src/src.pri)
include(res/res.pri)
include(native/native.pri)

# Default rules for deployment.
include(deployment.pri)

# Main App
include(app/app.pri)


# Compiler Flags
DEFINES += \
    FRAME_QML_PATH="\\\"$$QML_PATH\\\"" \
    FRAME_FONT_PATH="\\\"$$FONT_PATH\\\"" \
    FRAME_IMAGE_PATH="\\\"$$IMAGE_PATH\\\"" \
    IS_MOBILE=$$IS_MOBILE \
    APP_VERSION="\\\"$$VERSION\\\""
