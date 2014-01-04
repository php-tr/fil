#ifndef PDFREADER_H
#define PDFREADER_H

#include <QtCore/QObject>
#include <QtQml>

class PdfReader : public QObject
{
    Q_OBJECT
public:
    explicit PdfReader(QObject *parent = 0, QQmlEngine *qmlEngine = 0);

Q_SIGNALS:

public Q_SLOTS:
    void openPdf(QString filePath);

private:
    void *_pdfReaderDelegate;
    QQmlEngine *_qmlEngine;
};

#endif // PDFREADER_H
