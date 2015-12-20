#include "pdfreader.h"
#include "pdfreader_p.h"

Q_LOGGING_CATEGORY(PDF_READER_TAG, "org.phptr.fil.pdfreader")

PdfReader::PdfReader(QObject *parent)
    : QObject(parent)
    , d_ptr(PdfReaderPrivate::create(this))
{
}

void PdfReader::openPdf(const QString &filePath)
{
    qCDebug(PDF_READER_TAG) << "Opening pdf:" << filePath;

    Q_D(PdfReader);
    d->openPdf(filePath);
}
