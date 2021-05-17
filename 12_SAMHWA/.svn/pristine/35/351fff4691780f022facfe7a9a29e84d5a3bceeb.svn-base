//
//  PWChangeViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "PWChangeViewController.h"
#import "FBEncryptorAES.h"
#import "UIDevice+IdentifierAddition.h"
#import "MFinityAppDelegate.h"
#import "LoginViewController.h"

#import <dlfcn.h>
#import <mach/port.h>
#import <mach/kern_return.h>
@interface PWChangeViewController ()

@end

@implementation PWChangeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
	UIImage *bgImage = [UIImage imageWithData:decryptData];
	imageView.image = bgImage;
	label1.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
	label2.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
	label3.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    button.backgroundColor =[appDelegate myRGBfromHex:[prefs objectForKey:@"LOGINONCOLOR"]];
    
    int fontSize = 17;
    switch ([prefs integerForKey:@"FONT_SIZE"]) {
        case 1:
            fontSize = fontSize+5;
            break;
        case 2:
            fontSize = fontSize+8;
            break;
        default:
            break;
    }
    
    label1.text = NSLocalizedString(@"message45", @"");
    label2.text = NSLocalizedString(@"message46", @"");
    label3.text = NSLocalizedString(@"message47", @"");
    
    label1.font = [UIFont systemFontOfSize:fontSize];
    label2.font = [UIFont systemFontOfSize:fontSize];
    label3.font = [UIFont systemFontOfSize:fontSize];
    
    [button setTitle:NSLocalizedString(@"message51", @"") forState:UIControlStateNormal];
	//UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	//[backButton setImage:buttonImageBack forState:UIControlStateNormal];
	//backButton.frame = CGRectMake(0, 0, buttonImageBack.size.width, buttonImageBack.size.height);
	
	//[backButton addTarget:self action:@selector(navigationGoBack) forControlEvents:UIControlEventTouchUpInside];
	
	//UIBarButtonItem *customBarItemBack = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	//self.navigationItem.leftBarButtonItem = customBarItemBack;
	currentPW.clearButtonMode = UITextFieldViewModeWhileEditing;
    _newPWD.clearButtonMode = UITextFieldViewModeWhileEditing;
    checkPW.clearButtonMode = UITextFieldViewModeWhileEditing;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = appDelegate.menu_title;
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    }self.navigationItem.titleView = label;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (toInterfaceOrientation==UIDeviceOrientationLandscapeLeft||toInterfaceOrientation==UIDeviceOrientationLandscapeRight) {
        NSData *lDecryptData = [[NSData dataWithContentsOfFile:appDelegate.lSubBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
        UIImage *lBgImage = [UIImage imageWithData:lDecryptData];
        
        if (lBgImage==nil) {
            lBgImage = [UIImage imageNamed:@"w_default2.png"];
        }
        imageView.image = lBgImage;
    }else{
        NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
        UIImage *bgImage = [UIImage imageWithData:decryptData];
        
        if (bgImage==nil) {
            bgImage = [UIImage imageNamed:@"default2.png"];
        }
        imageView.image = bgImage;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark Action Event Handler
- (IBAction)PassWordChange{
	MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *dvcid = [MFinityAppDelegate getUUID];
    
    NSString *encrytcurrentPW = [FBEncryptorAES encryptBase64String:currentPW.text
                                                          keyString:appDelegate.AES256Key
                                                      separateLines:NO];
    encrytcurrentPW = [encrytcurrentPW urlEncodeUsingEncoding:NSUTF8StringEncoding];
    encrytNewPW = [FBEncryptorAES encryptBase64String:_newPWD.text
                                            keyString:appDelegate.AES256Key
                                        separateLines:NO];
    NSString *encrytnewPW = [encrytNewPW urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString;
    NSString *param;
    if (_isOffLine) {
        urlString = [[NSString alloc] initWithFormat:@"%@/ezChangePass",appDelegate.main_url];
	    param = [[NSString alloc]initWithFormat:@"usrNo=%@&dvcid=%@&oldPass=%@&newPass=%@&mode=off_passwd&returnType=JSON&encType=AES256",appDelegate.user_no,dvcid,encrytcurrentPW,encrytnewPW];
    }else{
        urlString = [[NSString alloc] initWithFormat:@"%@/ezChangePass",appDelegate.main_url];
        param = [[NSString alloc]initWithFormat:@"usrNo=%@&dvcid=%@&oldPass=%@&newPass=%@&returnType=JSON&encType=AES256",appDelegate.user_no,dvcid,encrytcurrentPW,encrytnewPW];
    }
    NSLog(@"ezChangePass : %@",urlString);
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:10.0];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
	if(urlConnection){
		receiveData = [[NSMutableData alloc] init];
	}else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
}
#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:currentPW]) {
        [_newPWD becomeFirstResponder];
    }else if([textField isEqual:_newPWD]){
        [checkPW becomeFirstResponder];
    }else if([textField isEqual:checkPW]){
        [checkPW resignFirstResponder];
    }
    return YES;
}

#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"error : %@",error);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPresponse statusCode];
    NSLog(@"statusCode : %ld",(long)statusCode);
	if(statusCode == 404 || statusCode == 500){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[connection cancel];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
		
	}else{
		[receiveData setLength:0];
	}
	
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[receiveData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	[self parserJsonData:receiveData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}

#pragma mark
#pragma mark JSON Data Parsing
- (void)parserJsonData:(NSData *)data{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *encString =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *decString ;
    if (appDelegate.isAES256) {
        decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
    }
    else{
        decString = encString;
    }
    
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSDictionary *dic2 = [MFinityAppDelegate getAllValueUrlDecoding:dic];
    NSLog(@"dic : %@",dic);
    if ([[dic2 objectForKey:@"V0"] isEqualToString:@"True"]) {
        [self userCheck:[dic2 objectForKey:@"V1"]];
    }else if([[dic2 objectForKey:@"V0"] isEqualToString:@"False"]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            
            //로그인화면으로 이동
            LoginViewController *lc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            lc.modalPresentationStyle = UIModalPresentationFullScreen;
            lc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [appDelegate.window setRootViewController:lc];
        }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self userCheck:[dic2 objectForKey:@"V1"]];
    }
    
}
#pragma mark
#pragma mark Password Change Utils
-(void) userCheck:(NSString *)result {

	if ([_newPWD.text isEqualToString:checkPW.text]) {
		if ([result isEqualToString:@"SUCCEED"]) {
            NSUserDefaults *userInfo= [NSUserDefaults standardUserDefaults];
            [userInfo setObject:encrytNewPW forKey:@"OFFLINE_PASSWD"];
            [userInfo synchronize];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"message69", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
            appDelegate.passWord = _newPWD.text;
			[currentPW resignFirstResponder];
			currentPW.text = @"";
			[_newPWD resignFirstResponder];
			_newPWD.text = @"";
			[checkPW resignFirstResponder];
			checkPW.text = @"";
		} else if([result isEqualToString:@"FAILED"]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"message62", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
			[currentPW resignFirstResponder];
			currentPW.text = @"";
			[_newPWD resignFirstResponder];
			_newPWD.text = @"";
			[checkPW resignFirstResponder];
			checkPW.text = @"";
		}
	}else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"message70", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
		//[self.navigationController popViewControllerAnimated:YES];
		[currentPW resignFirstResponder];
		currentPW.text = @"";
		[_newPWD resignFirstResponder];
		_newPWD.text = @"";
		[checkPW resignFirstResponder];
		checkPW.text = @"";
	}
    
	
}
#pragma mark



@end
