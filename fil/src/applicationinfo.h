#ifndef APPLICATION_INFO_H
#define APPLICATION_INFO_H

#include <QObject>
#include <qqml.h>

class ApplicationInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString platform READ platform CONSTANT)

public:
    explicit ApplicationInfo(QObject *parent = 0);

    static ApplicationInfo *instance();

    QString version() const;
    void setVersion(const QString &version);

    QString platform() const;
    void setPlatform(const QString &value);

private:
    static ApplicationInfo *m_instance;

    QString m_version;
    QString m_platform;
};

QML_DECLARE_TYPE(ApplicationInfo)

#endif // APPLICATION_INFO_H
