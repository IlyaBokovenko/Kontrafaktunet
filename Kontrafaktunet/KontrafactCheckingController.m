#import "KontrafactCheckingController.h"
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


@implementation KontrafactCheckingController

-(NSString*)code{
    return [NSString stringWithFormat:@"%@%@%@%@", f1.text, f2.text, f3.text, f4.text];
}

-(void)setCode:(NSString*)code{
    NSMutableString* trimmed = [[[code stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -"]] 
                                 mutableCopy] autorelease];
    f1.text = [trimmed biteFourCharacters];
    f2.text = [trimmed biteFourCharacters];
    f3.text = [trimmed biteFourCharacters];
    f4.text = [trimmed biteFourCharacters];
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


-(void)showTextFields:(BOOL)show{
    f1.hidden = !show;
    f2.hidden = !show;
    f3.hidden = !show;
    f4.hidden = !show;
}

-(void)clearFields{
    f1.text = @"";
    f2.text = @"";
    f3.text = @"";
    f4.text = @"";
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
            bgImage.image = [UIImage imageNamed:@"check-bg.png"];
            [indicator stopAnimating];
            break;
        case csChecking:
            [check setImage:[UIImage imageNamed:@"checking-button.png"] forState:UIControlStateNormal];
            check.enabled = NO;
            check.hidden = NO;
            checkOther.hidden = YES;
            bgImage.image = [UIImage imageNamed:@"check-bg.png"];            
            [indicator startAnimating];
            break;
        case csOK:
            [self showTextFields:NO];
            check.enabled = YES;
            check.hidden = YES;
            checkOther.hidden = NO;
            bgImage.image = [UIImage imageNamed:@"checked-bg.png"];
            [indicator stopAnimating];            
            break;
        case csFake:
            [self showTextFields:NO];
            check.enabled = YES;
            check.hidden = YES;
            checkOther.hidden = NO;
            bgImage.image = [UIImage imageNamed:@"fake-bg.png"];
            [indicator stopAnimating];            
            break;            
        default:
            break;
    }
}


-(id)privateCheckCode:(NSString*)code{
    RESTService *service = [[[RESTService alloc] initWithBaseUrl:@"http://code.slognosti.ru/api.ashx"] autorelease];
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
        [self focus:f3];
    }else if(f == f3){
        [self focus:f2];
    }else if(f == f2){
        [self focus:f1];
    }
}

-(void)asyncCheckCode:(NSString*)code{
    [self updateUI:csChecking];    
    [self hideKeyboard];
    
    UIBlocker *blocker =[UIBlocker blockerForView:self.view];
    blocker.indicator = indicator;
    
    BlockingAsyncCallback *cb = [BlockingAsyncCallback callbackWithDelegate:self 
                                                                  onSuccess:@selector(onChecked:) 
                                                                    onError:@selector(onCheckError:) 
                                                                    blocker:blocker];
    [[[AsyncObject asyncObjectForTarget:self] proxyWithCallback:cb] privateCheckCode:code];
}

#pragma mark lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI:csInitial];
}


- (void)dealloc
{
    [f1 release];
    [f2 release];
    [f3 release];
    [f4 release];
    
    [check release];
    
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
    [self asyncCheckCode:code];
}

#pragma mark events

-(IBAction)onCheck{
    if(self.code.length==0) return;
    [self asyncCheckCode:self.code];
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
    if(textField.text.length > 0 && result.length == 0){
        [self switchToPrevField:textField];
    }else if(result.length >= 4){
        [self switchToNextField:textField];
    }
    return YES;
}

@end