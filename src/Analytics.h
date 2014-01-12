#ifndef ANALYTICS_H
#define ANALYTICS_H

#include <QtCore/QObject>
#include <QDebug>

class Analytics : public QObject
{
    Q_OBJECT
public:
    explicit Analytics(QObject *parent = 0);

    static Analytics *getInstance()
    {
        return _instance;
    }

    Q_INVOKABLE void sendViewEvent(QString screenName);
    Q_INVOKABLE void sendEvent(QString eventName, QString action, QString label, int value = 0);

Q_SIGNALS:

public Q_SLOTS:


private:
    static Analytics *_instance;
    bool _isInited;
    void checkInit();
};

#endif // ANALYTICS_H
