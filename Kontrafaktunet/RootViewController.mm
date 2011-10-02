#import <ZXingWidgetController.h>
#import <QRCodeReader.h>

#import "RootViewController.h"
#import "KontrafactCheckingController.h"

@implementation RootViewController

#pragma mark private

-(IBAction)onInfo{
    InfoController *ctrl = [[[InfoController alloc] initWithNibName:@"InfoController" bundle:nil] autorelease];
    ctrl.delegate = self;
    ctrl.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:ctrl animated:YES];
}

#pragma mark UIView

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
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
    [zctrl release];
    zctrl = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    zctrl.readers = [NSSet setWithObject:[[QRCodeReader new] autorelease]];
    zctrl.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:zctrl animated:YES];
}

#pragma mark ZXingDelegate

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result{
    [self dismissModalViewControllerAnimated:YES];
    [kontrafactController checkCode:result];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller{
    [self dismissModalViewControllerAnimated:YES];
}


@end
