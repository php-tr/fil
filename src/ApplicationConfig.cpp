#include "ApplicationConfig.h"
#include <QtCore/QFile>
#include <QtCore/QJsonArray>
#include <QtCore/QJsonObject>
#include <QtCore/QJsonParseError>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonValue>
#include <QDebug>

ApplicationConfig::ApplicationConfig(QObject *parent) :
    QObject(parent)
{
    bool gotConfig = false;

    this->serviceUrl = "http://fil.php-tr.com/mobile.php?type=pdf_list&token=iyeO0/tpdSKkpelwO1l1Jd01t2Qvr4nMek3TC43xEYw=";

    QFile file(":/philip/config.json");
    if (file.exists() && file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QJsonParseError error;
        QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &error);
        file.close();

        if (doc.isObject() && !doc.isEmpty())
        {
            if (error.error != QJsonParseError::NoError)
            {
                qWarning() << "JSON Parse Error: " << error.errorString();
            }
            else
            {
                gotConfig = true;

                QJsonObject obj = doc.object();
#if defined(Q_OS_IOS)
                this->trackerId = obj["iOSTrackerId"].toString();
#elif defined(Q_OS_ANDROID)
                this->trackerId = obj["androidTrackerId"].toString();
#else
#error "Please define analytics code for this platform."
#endif
                this->serviceUrl = obj["serviceUrl"].toString();

                qWarning() << "Config Loaded";
            }
        }
    }

    if (!gotConfig)
    {
        this->trackerId = "";
    }
}
