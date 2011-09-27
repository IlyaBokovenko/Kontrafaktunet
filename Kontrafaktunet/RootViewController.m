#import "RootViewController.h"

@implementation RootViewController

#pragma mark lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)dealloc
{
    [f1 release];
    [f2 release];
    [f3 release];
    [f4 release];
    
    [check release];
    
    [statusImage release];
    
    [super dealloc];
}

#pragma mark UIView

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark events

-(IBAction)onCheck{
    
}


@end
