#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class UIBlocker;

@interface KontrafactCheckingController : UIViewController<UIAlertViewDelegate, MFMessageComposeViewControllerDelegate> {
    IBOutlet UITextField *f1;
    IBOutlet UITextField *f2;
    IBOutlet UITextField *f3;
    IBOutlet UITextField *f4;
    
    IBOutlet UIButton *check;
    IBOutlet UIButton *checkOther;
    
    IBOutlet UIActivityIndicatorView *indicator;    
    IBOutlet UIImageView *bgImage;
    
    UIBlocker *rootBlocker;
}

-(IBAction)onCheck;
-(IBAction)onCheckOther;
-(IBAction)beginEditing;

-(void)checkCode:(NSString*)code;

@end
