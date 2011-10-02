#import <ZXingWidgetController.h>
#import <QRCodeReader.h>
#import <MultiFormatOneDReader.h>

#import "RootViewController.h"
#import "KontrafactCheckingController.h"
#import "UIBlocker.h"

@implementation RootViewController

#pragma mark private

-(IBAction)onInfo{
    InfoController *ctrl = [[[InfoController alloc] initWithNibName:@"InfoController" bundle:nil] autorelease];
    ctrl.delegate = self;
    ctrl.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:ctrl animated:YES];
}

#pragma mark UIView

-(void)viewDidLoad{
    [super viewDidLoad];
    blocker = [[UIBlocker blockerForView:self.view] retain];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [blocker release];
    [kontrafactController release];
    [zctrl release];
    [super dealloc];
}

#pragma mark InfoControllerDelegate

-(void)infoControllerDidFinish:(InfoController*)ctrl{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark events

-(void)onScan{
    [blocker blockUI];
    [blocker showIndicator];
    
    [zctrl release];
    zctrl = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    zctrl.readers = [NSSet setWithObjects:[[QRCodeReader new] autorelease], [[MultiFormatOneDReader new] autorelease], nil];
    zctrl.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:zctrl animated:YES];
}

#pragma mark ZXingDelegate

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result{
    [blocker unblockUI];
    [self dismissModalViewControllerAnimated:YES];
    [kontrafactController checkCode:result];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller{
    [blocker unblockUI];
    [self dismissModalViewControllerAnimated:YES];
}


@end
