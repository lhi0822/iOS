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
    
    
    if(_isNavi){
        self.navigationController.navigationBar.topItem.title = @"비밀번호 변경";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStylePlain target:self action:@selector(closeModal:)];
        float navbar = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        
        [label1 setFrame:CGRectMake(label1.frame.origin.x, label1.frame.origin.y+navbar, label1.frame.size.width, label1.frame.size.height)];
        [label2 setFrame:CGRectMake(label2.frame.origin.x, label2.frame.origin.y+navbar, label2.frame.size.width, label2.frame.size.height)];
        [label3 setFrame:CGRectMake(label3.frame.origin.x, label3.frame.origin.y+navbar, label3.frame.size.width, label3.frame.size.height)];
        [currentPW setFrame:CGRectMake(currentPW.frame.origin.x, currentPW.frame.origin.y+navbar, currentPW.frame.size.width, currentPW.frame.size.height)];
        [_newPWD setFrame:CGRectMake(_newPWD.frame.origin.x, _newPWD.frame.origin.y+navbar, _newPWD.frame.size.width, _newPWD.frame.size.height)];
        [checkPW setFrame:CGRectMake(checkPW.frame.origin.x, checkPW.frame.origin.y+navbar, checkPW.frame.size.width, checkPW.frame.size.height)];
        [button setFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y+navbar, button.frame.size.width, button.frame.size.height)];
        
    } else {
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
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark Action Event Handler
-(IBAction) PassWordChange{
    if([self passwordCheck]){
        MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
        
//        NSString *encrytcurrentPW = [FBEncryptorAES encryptBase64String:currentPW.text
//                                                              keyString:appDelegate.AES256Key
//                                                          separateLines:NO];
//        encrytcurrentPW = [encrytcurrentPW urlEncodeUsingEncoding:NSUTF8StringEncoding];
//
//        encrytNewPW = [FBEncryptorAES encryptBase64String:_newPWD.text
//                                                keyString:appDelegate.AES256Key
//                                            separateLines:NO];
//        NSString *encrytnewPW = [encrytNewPW urlEncodeUsingEncoding:NSUTF8StringEncoding];
//
//        NSString *encrytcheckPW = [FBEncryptorAES encryptBase64String:checkPW.text
//                                                              keyString:appDelegate.AES256Key
//                                                          separateLines:NO];
//        encrytcheckPW = [encrytcheckPW urlEncodeUsingEncoding:NSUTF8StringEncoding];
        
        NSString *urlString;
        NSString *param;

        if (_isOffLine) {
            urlString = [[NSString alloc] initWithFormat:@"%@/setPwdUpdate",appDelegate.main_url];
            //param = [[NSString alloc]initWithFormat:@"user_id=%@&old_pass=%@&new_pass=%@&new_pass2=%@&encType=AES256",appDelegate.user_id,encrytcurrentPW,encrytnewPW,encrytcheckPW];
            param = [[NSString alloc]initWithFormat:@"user_id=%@&old_pass=%@&new_pass=%@&new_pass2=%@&encType=AES256",appDelegate.user_id,currentPW.text,_newPWD.text,checkPW.text];
        }else{
            urlString = [[NSString alloc] initWithFormat:@"%@/setPwdUpdate",appDelegate.main_url];
            //param = [[NSString alloc]initWithFormat:@"user_id=%@&old_pass=%@&new_pass=%@&new_pass2=%@&encType=AES256",appDelegate.user_id,encrytcurrentPW,encrytnewPW,encrytcheckPW];
            param = [[NSString alloc]initWithFormat:@"user_id=%@&old_pass=%@&new_pass=%@&new_pass2=%@&encType=AES256",appDelegate.user_id,currentPW.text,_newPWD.text,checkPW.text];
        }
        NSLog(@"ezChangePass : %@",urlString);
        NSLog(@"ezChangeParam : %@",param);
        
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
    
}

-(BOOL)passwordCheck{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"MY PWD : %@", appDelegate.passWord);
    NSLog(@"CURR PWD : %@", currentPW.text);
    NSLog(@"NEW PWD : %@", _newPWD.text);
    NSLog(@"CHECK PWD : %@", checkPW.text);
    
    if([currentPW.text isEqualToString:@""]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message44", @"") message:NSLocalizedString(@"비밀번호를 입력하세요.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        //NSLog(@"비밀번호를 입력하세요.");
        return NO;
    }
    
    if([_newPWD.text isEqualToString:@""]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message44", @"") message:NSLocalizedString(@"새 비밀번호를 입력하세요.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        //NSLog(@"새 비밀번호를 입력하세요.");
        return NO;
    }
    
    if([checkPW.text isEqualToString:@""]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message44", @"") message:NSLocalizedString(@"비밀번호 확인을 입력하세요.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        //NSLog(@"비밀번호 확인을 입력하세요.");
        return NO;
    }
    
    
//    if(![currentPW.text isEqualToString:appDelegate.passWord]){
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message44", @"") message:NSLocalizedString(@"기존 패스워드가 틀렸습니다.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
//        [alertView show];
//        //NSLog(@"비밀번호가 틀렸습니다.");
//        return NO;
//    }
    
    if([currentPW.text isEqualToString:_newPWD.text]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message44", @"") message:NSLocalizedString(@"기존과 동일한 비밀번호는 사용하실 수 없습니다.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        //NSLog(@"기존과 동일한 비밀번호는 사용하실 수 없습니다.");
        return NO;
    }
    
    if(![_newPWD.text isEqualToString:checkPW.text]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message44", @"") message:NSLocalizedString(@"비밀번호 확인이 일치하지 않습니다.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        //NSLog(@"비밀번호 확인이 일치하지 않습니다.");
        return NO;
    }
    
    return YES;
}

#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPresponse statusCode];
	
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
#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:NSLocalizedString(@"message121", @"")]) {
        exit(0);
        
    } else if ([alertView.title isEqualToString:@"SUCCESS"]) {
        if(_isNavi) [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark
#pragma mark JSON Data Parsing
- (void)parserJsonData:(NSData *)data{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *encString =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"encString : %@", encString);
    
    /*
    NSString *decString;
    if (appDelegate.isAES256) {
        decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
    }
    else{
        decString = encString;
    }
    //NSLog(@"encString : %@", encString);
    
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSDictionary *dic2 = [MFinityAppDelegate getAllValueUrlDecoding:dic];
    NSLog(@"dic : %@",dic);
    
    if ([[dic2 objectForKey:@"V0"] isEqualToString:@"True"]) {
        [self userCheck:[dic2 objectForKey:@"V1"]];
        
    }else if([[dic2 objectForKey:@"V0"] isEqualToString:@"False"]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
    }else{
        [self userCheck:[dic2 objectForKey:@"V1"]];
    }
     */
    
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[encString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSDictionary *dic2 = [MFinityAppDelegate getAllValueUrlDecoding:dic];
    NSLog(@"dic2 : %@", dic2);
    
    NSString *result = [dic2 objectForKey:@"V1"];
    NSString *msg = [dic2 objectForKey:@"V2"];
    if([result isEqualToString:@"SUCCESS"]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(result, @"") message:NSLocalizedString(msg, @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
        NSUserDefaults *userInfo= [NSUserDefaults standardUserDefaults];
        [userInfo setObject:encrytNewPW forKey:@"OFFLINE_PASSWD"];
        [userInfo synchronize];
        
        MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
        appDelegate.passWord = _newPWD.text;
        [currentPW resignFirstResponder];
        currentPW.text = @"";
        [_newPWD resignFirstResponder];
        _newPWD.text = @"";
        [checkPW resignFirstResponder];
        checkPW.text = @"";
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(result, @"") message:NSLocalizedString(msg, @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }
    
}
#pragma mark
#pragma mark Password Change Utils
- (NSString *) serialNumber
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs objectForKey:@"UUID"] == nil) {
        [prefs setObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"UUID"];
        [prefs synchronize];
    }
    
    return [prefs objectForKey:@"UUID"];
    /*
	NSString *serialNumber = nil;
	
	void *IOKit = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW);
	if (IOKit)
	{
		mach_port_t *kIOMasterPortDefault = dlsym(IOKit, "kIOMasterPortDefault");
		CFMutableDictionaryRef (*IOServiceMatching)(const char *name) = dlsym(IOKit, "IOServiceMatching");
		mach_port_t (*IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching) = dlsym(IOKit, "IOServiceGetMatchingService");
		CFTypeRef (*IORegistryEntryCreateCFProperty)(mach_port_t entry, CFStringRef key, CFAllocatorRef allocator, uint32_t options) = dlsym(IOKit, "IORegistryEntryCreateCFProperty");
		kern_return_t (*IOObjectRelease)(mach_port_t object) = dlsym(IOKit, "IOObjectRelease");
		
		if (kIOMasterPortDefault && IOServiceGetMatchingService && IORegistryEntryCreateCFProperty && IOObjectRelease)
		{
			mach_port_t platformExpertDevice = IOServiceGetMatchingService(*kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
			if (platformExpertDevice)
			{
				CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(platformExpertDevice, CFSTR("IOPlatformSerialNumber"), kCFAllocatorDefault, 0);
				if (CFGetTypeID(platformSerialNumber) == CFStringGetTypeID())
				{
					serialNumber = [NSString stringWithString:(__bridge NSString*)platformSerialNumber];
					CFRelease(platformSerialNumber);
				}
				IOObjectRelease(platformExpertDevice);
			}
		}
		dlclose(IOKit);
	}
	
	return serialNumber;
     */
    
}
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
