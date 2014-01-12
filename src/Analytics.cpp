#include "Analytics.h"
#include "ApplicationInfo.h"
#include <QtAndroidExtras/QtAndroidExtras>

Analytics *Analytics::_instance = 0;

Analytics::Analytics(QObject *parent) :
    QObject(parent), _isInited(false)
{
    _instance = this;
}

void Analytics::sendViewEvent(QString screenName)
{
    this->checkInit();
    QAndroidJniObject::callStaticMethod<void>(
        "org/phptr/philip/Analytics",
        "sendViewEvent",
        "(Ljava/lang/String;)V",
        QAndroidJniObject::fromString(screenName).object<jstring>()
    );
}

void Analytics::sendEvent(QString eventName, QString action, QString label, int value)
{
    this->checkInit();
    QAndroidJniObject::callStaticMethod<void>(
        "org/phptr/philip/Analytics",
        "sendEvent",
        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V",
        QAndroidJniObject::fromString(eventName).object<jstring>(),
        QAndroidJniObject::fromString(action).object<jstring>(),
        QAndroidJniObject::fromString(label).object<jstring>(),
        (jint) value
    );
}

void Analytics::checkInit()
{
    if (!this->_isInited)
    {
        QAndroidJniObject::callStaticMethod<void>(
            "org/phptr/philip/Analytics",
            "initAnalytics",
            "(Ljava/lang/String;)V",
            QAndroidJniObject::fromString(((ApplicationInfo *) this->parent())->config()->trackerId).object<jstring>()
        );
        this->_isInited = true;
    }
}
