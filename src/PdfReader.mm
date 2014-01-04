#include "PdfReader.h"
#include <UIKit/UIKit.h>
#include <QtGui>
#include <QtGui/5.2.0/QtGui/qpa/qplatformnativeinterface.h>
#include <QtQuick>
#include "ReaderDocument.h"
#include "ReaderViewController.h"

@interface ReaderViewDelegate : NSObject <ReaderViewControllerDelegate>
{
    PdfReader *_pdfReader;
}
@end

@implementation ReaderViewDelegate

- (id) initWithPdfReader:(PdfReader *)pdfReader
{
    self = [super init];
    if (self)
    {
        _pdfReader = pdfReader;
    }

    return self;
}

- (void) dismissReaderViewController:(ReaderViewController *)viewController
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

PdfReader::PdfReader(QObject *parent, QQmlEngine *qmlEngine) :
    QObject(parent),
    _pdfReaderDelegate([[ReaderViewDelegate alloc] initWithPdfReader:this]),
    _qmlEngine(qmlEngine)
{

}

void PdfReader::openPdf(QString filePath)
{
    const char *charPdfPath = filePath.toLocal8Bit().data();
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:[NSString stringWithUTF8String:charPdfPath] password:nil];
    ReaderViewController *viewController = [[ReaderViewController alloc] initWithReaderDocument:document];
    viewController.delegate = id(this->_pdfReaderDelegate);

    QObject *top = qobject_cast<QQmlApplicationEngine *>(this->_qmlEngine)->rootObjects().at(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(top);

    UIView *view = static_cast<UIView *>(
        QGuiApplication::platformNativeInterface()->nativeResourceForWindow("uiview", window)
    );
    UIViewController *qtController = [[view window] rootViewController];
    [qtController presentViewController:viewController animated:YES completion:nil];
}
