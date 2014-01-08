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

static void downloadConfirmed(JNIEnv *, jclass, jint magazineId)
{
    emit NativeDialog::getInstance()->downloadConfirmed((int) magazineId);
}

static JNINativeMethod methods[] =
{
    {"downloadConfirmed", "(I)V", (void *) downloadConfirmed}
};

int JNICALL JNI_OnLoad(JavaVM *vm, void *)
{
    JNIEnv *env;
    if (vm->GetEnv(reinterpret_cast<void **>(&env), JNI_VERSION_1_4) != JNI_OK)
    {
        return JNI_FALSE;
    }

    jclass clazz = env->FindClass("org/phptr/philip/MainActivity");
    if (env->RegisterNatives(clazz, methods, sizeof(methods) / sizeof(methods[0])))
    {
        return JNI_FALSE;
    }

    return JNI_VERSION_1_4;
}
