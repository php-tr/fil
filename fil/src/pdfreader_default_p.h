#ifndef PDFREADER_DEFAULT_P_H
#define PDFREADER_DEFAULT_P_H

#include "pdfreader_p.h"

class PdfReaderDefaultPrivate : public PdfReaderPrivate
{
    Q_OBJECT
public:
    PdfReaderDefaultPrivate(PdfReader *q);
    void openPdf(const QString &pdfPath);
};

#endif // PDFREADER_DEFAULT_P_H
