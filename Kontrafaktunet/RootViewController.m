#import "RootViewController.h"
#import "RESTService.h"
#import "WebParams.h"
#import "Async.h"

@implementation RootViewController

#pragma mark private

-(NSString*)code{
    return [NSString stringWithFormat:@"%@%@%@%@", f1.text, f2.text, f3.text, f4.text];
}

-(id)checkCode{
    RESTService *service = [[[RESTService alloc] initWithBaseUrl:@"http://code.slognosti.ru/api.ashx"] autorelease];
    WebParams *params = [WebParams params];
    [params addParam:@"check" forKey:@"command"];
    [params addParam:self.code forKey:@"code"];
    
    NSError *error = nil;
    id result = [service get:@"" withParams:params error:&error]; 
    if(error) return  error;
    return  result;
}

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
