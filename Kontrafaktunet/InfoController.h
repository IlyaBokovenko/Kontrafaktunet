#import <UIKit/UIKit.h>
#import "PagerController.h"
#import "WebViewController.h"

@class InfoController;

@protocol InfoControllerDelegate
-(void)infoControllerDidFinish:(InfoController*)ctrl;
@end


@interface InfoController : UIViewController<PagerControllerDelegate, PagerControllerDataSource, WebViewControllerDelegate> {
    id<InfoControllerDelegate> delegate;
    
    IBOutlet PagerController *pageController;
    IBOutlet UIPageControl *pageControl;
}
@property(nonatomic, assign) id<InfoControllerDelegate> delegate;

-(IBAction)onBack;
-(IBAction)onGotoSite;
-(IBAction)onPageChanged;

@end
