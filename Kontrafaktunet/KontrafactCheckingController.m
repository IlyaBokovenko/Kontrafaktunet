#import "KontrafactCheckingController.h"
#import "RESTService.h"
#import "WebParams.h"
#import "Async.h"
#import "UIBlocker.h"
#import "NSError+Utils.h"
#import "CJSONDeserializer.h"
#import "UIAlertView+Utils.h"
#import "Reachability+Utils.h"
#import "UIAlertView+Utils.h"
#import "KontrafaktunetAppDelegate.h"
#import "Settings.h"

typedef enum{
    csInitial,
    csChecking,
    csOK,
    csFake
}eCheckState;

@interface NSMutableString(Utils)
-(NSString*)biteFourCharacters;
@end

@implementation NSMutableString(Utils)
-(NSString*)biteFourCharacters{
    NSRange range = NSMakeRange(0, MIN(4, self.length));
    if(range.length == 0) return @"";
    NSString *bited = [self substringWithRange:range];
    [self deleteCharactersInRange:range];
    return bited;
}
@end

@interface NSString(Utils)
-(NSString*)withoutDeadspace;
-(NSString*)withDeadspace;
-(NSString*)withoutLast;
@end

@implementation NSString(Utils)
-(NSString*)withoutDeadspace{
    return [self stringByReplacingOccurrencesOfString:@"\u200B" withString:@""];
}
-(NSString*)withDeadspace{
    return [NSString stringWithFormat:@"\u200B%@", self];
}
-(NSString*)withoutLast{
    return [self stringByReplacingCharactersInRange:(NSMakeRange(self.length-1, 1)) withString:@""];
}
@end



@implementation KontrafactCheckingController

-(NSString*)code{
    NSString* result = [NSString stringWithFormat:@"%@%@%@%@", 
            [f1.text withoutDeadspace], 
            [f2.text withoutDeadspace], 
            [f3.text withoutDeadspace], 
            [f4.text withoutDeadspace]];
    
    return result;
}

-(void)setCode:(NSString*)code{
    NSMutableString* trimmed = [[[code stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -"]] 
                                 mutableCopy] autorelease];
    f1.text = [[trimmed biteFourCharacters] withDeadspace];
    f2.text = [[trimmed biteFourCharacters] withDeadspace];
    f3.text = [[trimmed biteFourCharacters] withDeadspace];
    f4.text = [[trimmed biteFourCharacters] withDeadspace];
}

-(void)showTextFields:(BOOL)show{
    f1.hidden = !show;
    f2.hidden = !show;
    f3.hidden = !show;
    f4.hidden = !show;
}

-(void)clearFields{
    f1.text = [@"" withDeadspace];
    f2.text = [@"" withDeadspace];
    f3.text = [@"" withDeadspace];
    f4.text = [@"" withDeadspace];
}

-(void)updateUI:(eCheckState)checkState{
    switch (checkState) {
        case csInitial:
            [self clearFields];
            [self showTextFields:YES];
            [check setImage:[UIImage imageNamed:@"check-button.png"] forState:UIControlStateNormal];
            check.enabled = YES;
            check.hidden = NO;
            checkOther.hidden = YES;
            scanButton.hidden = NO;
            thinLine.hidden = NO;
            bgImage.image = [UIImage imageNamed:@"check-bg.png"];
            [indicator stopAnimating];
            break;
        case csChecking:
            [check setImage:[UIImage imageNamed:@"checking-button.png"] forState:UIControlStateNormal];
            check.enabled = NO;
            check.hidden = NO;
            checkOther.hidden = YES;
            scanButton.hidden = NO;
            thinLine.hidden = NO;
            bgImage.image = [UIImage imageNamed:@"check-bg.png"];            
            [indicator startAnimating];
            break;
        case csOK:
            [self showTextFields:NO];
            check.enabled = YES;
            check.hidden = YES;
            checkOther.hidden = NO;
            scanButton.hidden = YES;
            thinLine.hidden = YES;
            bgImage.image = [UIImage imageNamed:@"checked-bg.png"];
            [indicator stopAnimating];            
            break;
        case csFake:
            [self showTextFields:NO];
            check.enabled = YES;
            check.hidden = YES;
            checkOther.hidden = NO;
            scanButton.hidden = YES;
            thinLine.hidden = YES;
            bgImage.image = [UIImage imageNamed:@"fake-bg.png"];
            [indicator stopAnimating];            
            break;            
        default:
            break;
    }
}


-(id)checkCodeViaServer:(NSString*)code{
    RESTService *service = [[[RESTService alloc] initWithBaseUrl:[NSString stringWithFormat:@"http://%@/api.ashx", [Settings host]]] autorelease];
    WebParams *params = [WebParams params];
    [params addParam:@"check" forKey:@"command"];
    [params addParam:code forKey:@"code"];
    
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
}

-(void)onCheckError:(NSError*)error{
    [error display];
    [self updateUI:csInitial];    
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

-(void)switchToPrevField:(UITextField*)f{
    if(f == f4){
        f3.text = [f3.text withoutLast];
        [self focus:f3];
    }else if(f == f3){
        f2.text = [f2.text withoutLast];
        [self focus:f2];
    }else if(f == f2){
        f1.text = [f1.text withoutLast];
        [self focus:f1];
    }
}

-(void)asyncCheckCodeViaServer:(NSString*)code{
    [self updateUI:csChecking];    
    [self hideKeyboard];
    
    UIBlocker *blocker =[UIBlocker blockerForView:self.view];
    blocker.indicator = indicator;
    
    BlockingAsyncCallback *cb = [BlockingAsyncCallback callbackWithDelegate:self 
                                                                  onSuccess:@selector(onChecked:) 
                                                                    onError:@selector(onCheckError:) 
                                                                    blocker:blocker];
    [[[AsyncObject asyncObjectForTarget:self] proxyWithCallback:cb] checkCodeViaServer:code];
}


-(UIViewController*)rootController{
        return ((KontrafaktunetAppDelegate*)([UIApplication sharedApplication].delegate)).rootController;
}

-(void)checkCodeViaSms:(NSString*)code{
    MFMessageComposeViewController *msgController = [[MFMessageComposeViewController new] autorelease];
    msgController.messageComposeDelegate = self;
    msgController.body = code;
    msgController.recipients = [NSArray arrayWithObject:[Settings phone]];
    msgController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [rootBlocker blockUI];
    [rootBlocker showIndicator];
    [self.rootController presentModalViewController:msgController animated:YES];
}

#pragma mark lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    rootBlocker = [[UIBlocker blockerForView:self.rootController.view] retain];
    [self updateUI:csInitial];
}


- (void)dealloc
{
    [rootBlocker release];
    [f1 release];
    [f2 release];
    [f3 release];
    [f4 release];
    
    [check release];
    [scanButton release];
    
    [thinLine release];
    
    [indicator release];
    
    [super dealloc];
}

#pragma mark UIView

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark accessing

-(void)checkCode:(NSString*)code{
    self.code = code;
    [Reachability setHostName:[Settings host]];
    
    [rootBlocker blockUI];
    [rootBlocker showIndicator];
    BOOL isReachable = [Reachability isNetworkReachable];
    [rootBlocker unblockUI];
    
    if(isReachable){
        [self asyncCheckCodeViaServer:code];  
    }else{
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Сервер не доступен"
                                                         message:@"Проверить код с помощью бесплатного смс?"
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"Да", @"Нет", nil] autorelease];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark events

-(IBAction)onCheck{
    if(self.code.length==0) return;
    [self checkCode:self.code];
}


-(IBAction)onCheckOther{
    [self updateUI:csInitial];
}

#pragma mark UITextFieldDelegate

-(IBAction)beginEditing{
    [self clearFields];
    [f1 becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(result.length == 0){
        [self switchToPrevField:textField];
        return NO;
    }else if([result withoutDeadspace].length >= 4){
        [self switchToNextField:textField];
        return YES;
    }

    return YES;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [self checkCodeViaSms:self.code];  
    }
}

#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller 
                 didFinishWithResult:(MessageComposeResult)result{
    [rootBlocker unblockUI];
    [self.rootController dismissModalViewControllerAnimated:YES];
    if(result == MessageComposeResultSent){
        [UIAlertView showAlertViewWithTitle:@"Успешно" message:@"Через некоторое время сервер вышлет Вам результаты проверки"];
    }else if(result == MessageComposeResultFailed){
        [UIAlertView showAlertViewWithTitle:@"" message:@"Не удалось отправить смс!"];
    }
}

@end