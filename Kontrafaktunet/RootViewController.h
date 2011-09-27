#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController {
    IBOutlet UITextField *f1;
    IBOutlet UITextField *f2;
    IBOutlet UITextField *f3;
    IBOutlet UITextField *f4;
    
    IBOutlet UIButton *check;
    
    IBOutlet UIImageView *statusImage;
}

-(IBAction)onCheck;


@end
