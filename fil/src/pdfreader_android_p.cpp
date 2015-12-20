#include "pdfreader_android_p.h"

Q_LOGGING_CATEGORY(PDF_READER_PRIVATE_TAG, "org.phptr.fil.pdfreader.android")

PdfReaderPrivate *PdfReaderPrivate::create(PdfReader *q)
{
    return new PdfReaderAndroidPrivate(q);
}

PdfReaderAndroidPrivate::PdfReaderAndroidPrivate(PdfReader *q)
    : PdfReaderPrivate(q)
    , m_inited(false)
{
}

void PdfReaderAndroidPrivate::openPdf(const QString &pdfPath)
{
    if (!init())
        return;

    m_pdfReaderController.callMethod<void>("openPdf", "(Ljava/lang/String;)V",
                                           QJNIObjectPrivate::fromString(pdfPath).object());
}

bool PdfReaderAndroidPrivate::init()
{
    if (!m_inited) {
        m_pdfReaderController = QJNIObjectPrivate("org/phptr/fil/PdfReaderController",
                                                  "(Landroid/app/Activity;)V",
                                                  QtAndroid::androidActivity().object());
        if (!m_pdfReaderController.isValid()) {
            qCCritical(PDF_READER_PRIVATE_TAG) << "org.phptr.fil.PdfReaderController class not found.";
            return false;
        }

        m_inited = true;
    }

    return m_inited;
}
