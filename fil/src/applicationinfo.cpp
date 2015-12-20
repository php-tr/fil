#include "applicationinfo.h"

#define Q_D_PTR(CLASS) CLASS *d = static_cast<CLASS *>(this);

ApplicationInfo *ApplicationInfo::m_instance = 0;

ApplicationInfo::ApplicationInfo(QObject *parent)
    : QObject(parent)
{
}

ApplicationInfo *ApplicationInfo::instance()
{
    if (!m_instance)
        m_instance = new ApplicationInfo();

    return m_instance;
}

QString ApplicationInfo::version() const
{
    Q_D_PTR(const ApplicationInfo);
    return d->m_version;
}

void ApplicationInfo::setVersion(const QString &version)
{
    Q_D_PTR(ApplicationInfo);
    d->m_version = version;
}

QString ApplicationInfo::platform() const
{
    Q_D_PTR(const ApplicationInfo);
    return d->m_platform;
}

void ApplicationInfo::setPlatform(const QString &value)
{
    Q_D_PTR(ApplicationInfo);
    d->m_platform = value;
}

#undef Q_D_PTR
