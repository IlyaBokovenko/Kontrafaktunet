#import "InfoController.h"

@implementation InfoController
@synthesize delegate;

#pragma mark private

#pragma mark lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    pageController.dataSource = self;
    pageController.delegate = self;
    pageController.view;
    [pageController reloadData];
}

- (void)dealloc
{
    [pageControl release];
    [pageController release];
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

-(IBAction)onGotoSite{
    WebViewController *ctrl = [WebViewController webViewControllerForUrl:@"http://www.google.com"];
    ctrl.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    ctrl.delegate = self;
    [self presentModalViewController:ctrl animated:YES];
}

-(IBAction)onPageChanged{
    [pageController switchPage:pageControl.currentPage animated:YES];
    [pageControl updateCurrentPageDisplay];
}

#pragma mark PagerControllerDelegate, PagerControllerDataSource
- (NSUInteger)numberOfPagesInPager:(PagerController*)pager{
    return 3;
}

- (UIView*)viewForPage:(NSUInteger)pageIndex inPager:(PagerController*)pager{
    NSString *name = [[NSArray arrayWithObjects:@"2.JPG", @"5.JPG", @"8.JPG", nil] objectAtIndex:pageIndex];
    UIImageView* image = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:name]] autorelease];
    image.contentMode = UIViewContentModeScaleAspectFit;
    return image;
}

- (void)pagerController:(PagerController*)pager didSwitchToPage:(NSUInteger)page{
    
}

#pragma mark WebViewControllerDelegate

-(void)webViewControllerDidDismiss:(WebViewController*)ctrl{
    [self dismissModalViewControllerAnimated:YES];
}

@end