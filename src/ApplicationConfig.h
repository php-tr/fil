#ifndef APPLICATIONCONFIG_H
#define APPLICATIONCONFIG_H

#include <QtCore/QObject>
#include <QtCore/QString>

class ApplicationConfig : public QObject
{
    Q_OBJECT
public:
    explicit ApplicationConfig(QObject *parent = 0);
    QString serviceUrl;
    QString trackerId;

Q_SIGNALS:

public Q_SLOTS:

private:
};

#endif // APPLICATIONCONFIG_H
