#include "NativeDialog.h"
#include <UIKit/UIKit.h>

@interface AlertViewDelegate : NSObject <UIAlertViewDelegate>
{
    NativeDialog *_dialog;
}
@end

@implementation AlertViewDelegate

- (id) initWithDialog:(NativeDialog *)dialog
{
    self = [super init];
    if (self)
    {
        _dialog = dialog;
    }

    return self;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        emit _dialog->downloadConfirmed(_dialog->getId());
    }
}

@end

NativeDialog::NativeDialog(QQuickItem *parent) :
    QQuickItem(parent), _alertViewDelegate([[AlertViewDelegate alloc] initWithDialog:this])
{

}

void NativeDialog::confirmDownload(int magazineId)
{
    this->_id = magazineId;
    UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"Download Confirmation", nil)
                              message: NSLocalizedString(@"Are you sure to download magazine?", nil)
                              delegate:id(this->_alertViewDelegate)
                              cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                              otherButtonTitles: NSLocalizedString(@"Download", nil), nil];
    [alert show];
}

int NativeDialog::getId()
{
    return this->_id;
}
