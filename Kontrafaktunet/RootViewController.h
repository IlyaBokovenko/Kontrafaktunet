#import <UIKit/UIKit.h>
#import "InfoController.h"

@interface RootViewController : UIViewController<UITextFieldDelegate, InfoControllerDelegate> {
    IBOutlet UITextField *f1;
    IBOutlet UITextField *f2;
    IBOutlet UITextField *f3;
    IBOutlet UITextField *f4;
    
    IBOutlet UIButton *check;
    
    IBOutlet UIImageView *statusImage;
    
    IBOutlet UIActivityIndicatorView *indicator;
}

-(IBAction)onCheck;
-(IBAction)beginEditing;
-(IBAction)onInfo;


@end
