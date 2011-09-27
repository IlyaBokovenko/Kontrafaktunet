#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController<UITextFieldDelegate> {
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

@end
