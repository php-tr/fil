#ifndef APPLICATION_PLUGIN_H
#define APPLICATION_PLUGIN_H

#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(FilPlugin)

class ApplicationPlugin
{
public:
    static void registerTypes();
    static void loadFonts(const QString &fontPath);
};

#endif // APPLICATION_PLUGIN_H

