#ifndef PDFREADER_P_H
#define PDFREADER_P_H

#include <QObject>
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(PDF_READER_PRIVATE_TAG)

class PdfReader;

class PdfReaderPrivate : public QObject
{
    Q_OBJECT
public:
    PdfReaderPrivate(PdfReader *q)
        : QObject(0)
        , q_ptr(q)
    {}

    virtual void openPdf(const QString &pdfPath) = 0;
    static PdfReaderPrivate *create(PdfReader *q);

protected:
    Q_DECLARE_PUBLIC(PdfReader)
    PdfReader *q_ptr;
};

#endif // PDFREADER_P_H
