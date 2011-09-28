#import "RootViewController.h"
#import "RESTService.h"
#import "WebParams.h"
#import "Async.h"
#import "UIBlocker.h"
#import "NSError+Utils.h"
#import "CJSONDeserializer.h"
#import "UIAlertView+Utils.h"

typedef enum{
    csInitial,
    csChecking,
    csOK,
    csFake
}eCheckState;

@implementation RootViewController

#pragma mark private

-(NSString*)code{
    return [NSString stringWithFormat:@"%@%@%@%@", f1.text, f2.text, f3.text, f4.text];
}

-(void)updateStateImage:(eCheckState)checkState{
    NSString *name = [[NSArray arrayWithObjects:@"question.png", @"question.png", @"checkmark.png", @"fake.png", nil] objectAtIndex:checkState];
    statusImage.image = [UIImage imageNamed:name];
}

-(void)updateCheckButton:(eCheckState)checkState{
    NSString *name = [[NSArray arrayWithObjects:@"check-button.png", @"checking-button.png", @"checked-button.png", @"fake-button.png", nil] objectAtIndex:checkState];
    if(checkState == csChecking){
        check.enabled = NO;
    }else{
        check.enabled = YES;
        [check setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    }
}

-(void)updateUI:(eCheckState)checkState{
    [self updateStateImage:checkState];
    [self updateCheckButton:checkState];
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

-(void)onChecked:(id)data{
    NSError *error = nil;
    id deserialized = [[CJSONDeserializer deserializer] deserialize:data error:&error];
    if(error){
        [error display];
        [self updateUI:csInitial];
    }else{
        if(![deserialized respondsToSelector:@selector(intValue)]){
            [UIAlertView showAlertViewErrorMessage:@"Wrong server response!"];
            [self updateUI:csInitial];
            return;
        }
        BOOL ok = [deserialized intValue];
        [self updateUI: ok ? csOK : csFake];
    }
    check.enabled = YES;
}

-(void)onCheckError:(NSError*)error{
    check.enabled = YES;
    [error display];
}

-(void)hideKeyboard{
    [f1 resignFirstResponder];
    [f2 resignFirstResponder];
    [f3 resignFirstResponder];
    [f4 resignFirstResponder];
}

-(void)focus:(UITextField*)f{
    [f performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
}

-(void)switchToNextField:(UITextField*)f{
    if(f == f1){
        [self focus:f2];
    }else if(f == f2){
        [self focus:f3];
    }else if(f == f3){
        [self focus:f4];
    }else if(f == f4){
        [f4 performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.1];
    }
}

-(void)clearFields{
    f1.text = @"";
    f2.text = @"";
    f3.text = @"";
    f4.text = @"";
    [f1 becomeFirstResponder];
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
    
    [indicator release];
    
    [super dealloc];
}

#pragma mark UIView

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark events

-(IBAction)onCheck{
    [self updateUI:csChecking];    
    [self hideKeyboard];
    
    UIBlocker *blocker =[UIBlocker blockerForView:self.view];
    blocker.indicator = indicator;
    
    BlockingAsyncCallback *cb = [BlockingAsyncCallback callbackWithDelegate:self 
                                                                  onSuccess:@selector(onChecked:) 
                                                                    onError:@selector(onCheckError:) 
                                                                    blocker:blocker];
    [[[AsyncObject asyncObjectForTarget:self] proxyWithCallback:cb] checkCode];
}

-(IBAction)onInfo{
    InfoController *ctrl = [[[InfoController alloc] initWithNibName:@"InfoController" bundle:nil] autorelease];
    ctrl.delegate = self;
    ctrl.modalTransitionStyle =  UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:ctrl animated:YES];
}

#pragma mark UITextFieldDelegate

-(IBAction)beginEditing{
    [self clearFields];
    [self updateUI:csInitial];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(result.length >= 4){
        [self switchToNextField:textField];
    }
    return YES;
}

#pragma mark InfoControllerDelegate

-(void)infoControllerDidFinish:(InfoController*)ctrl{
    [self dismissModalViewControllerAnimated:YES];
}

@end
