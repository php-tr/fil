#ifndef PDFREADER_IOS_P_H
#define PDFREADER_IOS_P_H

#include "pdfreader_p.h"

Q_FORWARD_DECLARE_OBJC_CLASS(ReaderViewDelegate);

class PdfReaderIOSPrivate : public PdfReaderPrivate
{
    Q_OBJECT
public:
    PdfReaderIOSPrivate(PdfReader *q);
    void openPdf(const QString &pdfPath);
    void handleClose();

private:
    ReaderViewDelegate *m_reader;
};

#endif // PDFREADER_IOS_P_H
