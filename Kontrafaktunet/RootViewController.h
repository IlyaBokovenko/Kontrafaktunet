#import <UIKit/UIKit.h>
#import "InfoController.h"

@class KontrafactCheckingController;

@interface RootViewController : UIViewController<UITextFieldDelegate, InfoControllerDelegate> {
    IBOutlet KontrafactCheckingController* kontrafactController;
}

-(IBAction)onInfo;


@end
