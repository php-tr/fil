#include "pdfreader_default_p.h"

Q_LOGGING_CATEGORY(PDF_READER_PRIVATE_TAG, "org.phptr.fil.pdfreader.default")

PdfReaderPrivate *PdfReaderPrivate::create(PdfReader *q)
{
    return new PdfReaderDefaultPrivate(q);
}

PdfReaderDefaultPrivate::PdfReaderDefaultPrivate(PdfReader *q)
    : PdfReaderPrivate(q)
{
}

void PdfReaderDefaultPrivate::openPdf(const QString &pdfPath)
{
    Q_UNUSED(pdfPath);
    qCWarning(PDF_READER_PRIVATE_TAG) << Q_FUNC_INFO << "Unsupported action for this platform.";
}
