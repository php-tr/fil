#include "pdfreader_ios_p.h"
#include "pdfreader.h"
#include <QtGui>
#include <qpa/qplatformnativeinterface.h>
#include <QtQuick>
#import "ReaderDocument.h"
#import "ReaderViewController.h"
#import <UIKit/UIKit.h>

Q_LOGGING_CATEGORY(PDF_READER_PRIVATE_TAG, "org.phptr.fil.pdfreader.ios")

@interface ReaderViewDelegate : NSObject <ReaderViewControllerDelegate>
{
    PdfReaderIOSPrivate *m_pdfReader;
}
@end

@implementation ReaderViewDelegate

- (id) initWithPdfReader:(PdfReaderIOSPrivate *)pdfReader
{
    self = [super init];
    if (self) {
        m_pdfReader = pdfReader;
    }

    return self;
}

- (void) dismissReaderViewController:(ReaderViewController *)viewController
{
    Q_UNUSED(viewController)

    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController dismissViewControllerAnimated:YES completion:nil];

    m_pdfReader->handleClose();
}

@end

PdfReaderPrivate *PdfReaderPrivate::create(PdfReader *q)
{
    return new PdfReaderIOSPrivate(q);
}

PdfReaderIOSPrivate::PdfReaderIOSPrivate(PdfReader *q)
    : PdfReaderPrivate(q)
    , m_reader([[ReaderViewDelegate alloc] initWithPdfReader:this])
{
}

void PdfReaderIOSPrivate::openPdf(const QString &pdfPath)
{
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:pdfPath.toNSString() password:nil];
    ReaderViewController *viewController = [[ReaderViewController alloc] initWithReaderDocument:document];
    viewController.delegate = m_reader;

    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentViewController:viewController animated:YES completion:nil];
}

void PdfReaderIOSPrivate::handleClose()
{
    Q_Q(PdfReader);
    emit q->closed();
}
