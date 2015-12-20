#ifndef PDFREADER_H
#define PDFREADER_H

#include <QObject>
#include <qqml.h>
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(PDF_READER_TAG)

class PdfReaderPrivate;

class PdfReader : public QObject
{
    Q_OBJECT
public:
    explicit PdfReader(QObject *parent = 0);

signals:
    void closed();

public slots:
    void openPdf(const QString &filePath);

private:
    Q_DECLARE_PRIVATE(PdfReader)
    PdfReaderPrivate *d_ptr;
};

QML_DECLARE_TYPE(PdfReader)

#endif // PDFREADER_H
