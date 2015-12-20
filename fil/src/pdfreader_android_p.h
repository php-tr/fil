#ifndef PDFREADER_ANDROID_P_H
#define PDFREADER_ANDROID_P_H

#include "pdfreader_p.h"
#include <QtAndroidExtras>
#include <private/qjni_p.h>

class PdfReaderAndroidPrivate : public PdfReaderPrivate
{
    Q_OBJECT
public:
    PdfReaderAndroidPrivate(PdfReader *q);
    void openPdf(const QString &pdfPath);
    bool init();

private:
    bool m_inited;
    QJNIObjectPrivate m_pdfReaderController;
};

#endif // PDFREADER_ANDROID_P_H
