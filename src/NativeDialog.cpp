#include "NativeDialog.h"
#include <QtAndroidExtras/QtAndroidExtras>

NativeDialog *NativeDialog::_instance = 0;

NativeDialog::NativeDialog(QQuickItem *parent) :
    QQuickItem(parent), _alertViewDelegate(0)
{
    _instance = this;
}

void NativeDialog::confirmDownload(int magazineId)
{
    QAndroidJniObject::callStaticMethod<void>("org/phptr/philip/MainActivity", "confirmDownload", "(I)V", (jint) magazineId);
}

int NativeDialog::getId()
{
    return this->_id;
}
