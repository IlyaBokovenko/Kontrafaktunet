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
    [super dealloc];
}

#pragma mark InfoControllerDelegate

-(void)infoControllerDidFinish:(InfoController*)ctrl{
    [self dismissModalViewControllerAnimated:YES];
}

@end
