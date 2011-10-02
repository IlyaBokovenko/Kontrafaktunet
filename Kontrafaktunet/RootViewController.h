#import <UIKit/UIKit.h>
#import "InfoController.h"


@protocol ZXingDelegate;
@class ZXingWidgetController;

@class KontrafactCheckingController;

@interface RootViewController : UIViewController<UITextFieldDelegate, InfoControllerDelegate, ZXingDelegate> {
    IBOutlet KontrafactCheckingController* kontrafactController;
    
    ZXingWidgetController *zctrl;
}

-(IBAction)onInfo;
-(IBAction)onScan;


@end
