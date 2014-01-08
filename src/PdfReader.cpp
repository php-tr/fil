#include "PdfReader.h"
#include <QtGui>
#include <QtGui/5.2.0/QtGui/qpa/qplatformnativeinterface.h>
#include <QtQuick>
#include <QtAndroidExtras/QtAndroidExtras>

PdfReader::PdfReader(QObject *parent, QQmlEngine *qmlEngine) :
    QObject(parent),
    _pdfReaderDelegate(0),
    _qmlEngine(qmlEngine)
{

}

void PdfReader::openPdf(QString filePath)
{
    qWarning() << "Static method calling.";
    QAndroidJniObject::callStaticMethod<void>(
        "org/phptr/philip/PdfReaderActivity",
        "openPdf",
        "(Ljava/lang/String;)V",
        QAndroidJniObject::fromString(filePath).object<jstring>()
    );
}
