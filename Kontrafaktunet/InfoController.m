#import "InfoController.h"

@implementation InfoController
@synthesize delegate;

#pragma mark private

#pragma mark lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc
{
    [super dealloc];
}


#pragma mark UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark actions

-(IBAction)onBack{
    [delegate infoControllerDidFinish:self];
}

@end