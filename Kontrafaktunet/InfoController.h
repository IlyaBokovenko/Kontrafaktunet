#import <UIKit/UIKit.h>

@class InfoController;

@protocol InfoControllerDelegate
-(void)infoControllerDidFinish:(InfoController*)ctrl;
@end


@interface InfoController : UIViewController {
    id<InfoControllerDelegate> delegate;
}
@property(nonatomic, assign) id<InfoControllerDelegate> delegate;

-(IBAction)onBack;

@end
