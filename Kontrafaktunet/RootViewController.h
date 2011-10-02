#import <UIKit/UIKit.h>
#import "InfoController.h"


@protocol ZXingDelegate;
@class ZXingWidgetController;
@class UIBlocker;

@class KontrafactCheckingController;

@interface RootViewController : UIViewController<UITextFieldDelegate, InfoControllerDelegate, ZXingDelegate> {
    IBOutlet KontrafactCheckingController* kontrafactController;
    
    ZXingWidgetController *zctrl;
    UIBlocker *blocker;
}

-(IBAction)onInfo;
-(IBAction)onScan;


@end
