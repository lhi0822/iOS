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

-(void)viewWillAppear:(BOOL)animated{
    //2018.06 UI개선
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = [appDelegate myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
    
    if([appDelegate.mainType isEqualToString:@"1"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            appDelegate.scrollView.hidden = YES;
            self.tabBarController.tabBar.hidden = NO;
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            appDelegate.scrollView.hidden = NO;
            self.tabBarController.tabBar.hidden = YES;
            
            [label1 setFrame:CGRectMake(label1.frame.origin.x, appDelegate.scrollView.frame.size.height+20, label1.frame.size.width, label1.frame.size.height)];
            [label2 setFrame:CGRectMake(label2.frame.origin.x, label1.frame.origin.y+label1.frame.size.height+8, label2.frame.size.width, label2.frame.size.height)];
            [label3 setFrame:CGRectMake(label3.frame.origin.x, label2.frame.origin.y+label2.frame.size.height+8, label3.frame.size.width, label3.frame.size.height)];
            
            [currentPW setFrame:CGRectMake(currentPW.frame.origin.x, appDelegate.scrollView.frame.size.height+25, currentPW.frame.size.width, currentPW.frame.size.height)];
            [_newPWD setFrame:CGRectMake(_newPWD.frame.origin.x, currentPW.frame.origin.y+currentPW.frame.size.height+24, _newPWD.frame.size.width, _newPWD.frame.size.height)];
            [checkPW setFrame:CGRectMake(checkPW.frame.origin.x, _newPWD.frame.origin.y+_newPWD.frame.size.height+24, checkPW.frame.size.width, checkPW.frame.size.height)];
            
            [button setFrame:CGRectMake(button.frame.origin.x, checkPW.frame.origin.y+checkPW.frame.size.height+24, button.frame.size.width, button.frame.size.height)];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"2"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            appDelegate.scrollView.hidden = YES;
            self.tabBarController.tabBar.hidden = NO;
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            appDelegate.scrollView.hidden = NO;
            self.tabBarController.tabBar.hidden = YES;
            
            [label1 setFrame:CGRectMake(label1.frame.origin.x, appDelegate.scrollView.frame.size.height+20, label1.frame.size.width, label1.frame.size.height)];
            [label2 setFrame:CGRectMake(label2.frame.origin.x, label1.frame.origin.y+label1.frame.size.height+8, label2.frame.size.width, label2.frame.size.height)];
            [label3 setFrame:CGRectMake(label3.frame.origin.x, label2.frame.origin.y+label2.frame.size.height+8, label3.frame.size.width, label3.frame.size.height)];
            
            [currentPW setFrame:CGRectMake(currentPW.frame.origin.x, appDelegate.scrollView.frame.size.height+25, currentPW.frame.size.width, currentPW.frame.size.height)];
            [_newPWD setFrame:CGRectMake(_newPWD.frame.origin.x, currentPW.frame.origin.y+currentPW.frame.size.height+24, _newPWD.frame.size.width, _newPWD.frame.size.height)];
            [checkPW setFrame:CGRectMake(checkPW.frame.origin.x, _newPWD.frame.origin.y+_newPWD.frame.size.height+24, checkPW.frame.size.width, checkPW.frame.size.height)];
            
            [button setFrame:CGRectMake(button.frame.origin.x, checkPW.frame.origin.y+checkPW.frame.size.height+24, button.frame.size.width, button.frame.size.height)];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"3"]){
        appDelegate.scrollView.hidden = NO;
        self.tabBarController.tabBar.hidden = YES;
        
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            [imageView setFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, appDelegate.scrollView.frame.origin.y-self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            [label1 setFrame:CGRectMake(label1.frame.origin.x, appDelegate.scrollView.frame.size.height+20, label1.frame.size.width, label1.frame.size.height)];
            [label2 setFrame:CGRectMake(label2.frame.origin.x, label1.frame.origin.y+label1.frame.size.height+8, label2.frame.size.width, label2.frame.size.height)];
            [label3 setFrame:CGRectMake(label3.frame.origin.x, label2.frame.origin.y+label2.frame.size.height+8, label3.frame.size.width, label3.frame.size.height)];
            
            [currentPW setFrame:CGRectMake(currentPW.frame.origin.x, appDelegate.scrollView.frame.size.height+25, currentPW.frame.size.width, currentPW.frame.size.height)];
            [_newPWD setFrame:CGRectMake(_newPWD.frame.origin.x, currentPW.frame.origin.y+currentPW.frame.size.height+24, _newPWD.frame.size.width, _newPWD.frame.size.height)];
            [checkPW setFrame:CGRectMake(checkPW.frame.origin.x, _newPWD.frame.origin.y+_newPWD.frame.size.height+24, checkPW.frame.size.width, checkPW.frame.size.height)];
            
            [button setFrame:CGRectMake(button.frame.origin.x, checkPW.frame.origin.y+checkPW.frame.size.height+24, button.frame.size.width, button.frame.size.height)];
        }
    }
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark Action Event Handler
-(IBAction) PassWordChange{
	MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
//	NSString *dvcid = [MFinityAppDelegate getUUID];
    
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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (_isOffLine) {
        urlString = [[NSString alloc] initWithFormat:@"%@/ezChangePass",appDelegate.main_url];
        param = [[NSString alloc]initWithFormat:@"usrNo=%@&dvcid=%@&oldPass=%@&newPass=%@&mode=off_passwd&returnType=JSON&encType=AES256",appDelegate.user_no,[prefs objectForKey:@"UUID"],encrytcurrentPW,encrytnewPW];
    }else{
        urlString = [[NSString alloc] initWithFormat:@"%@/ezChangePass",appDelegate.main_url];
        param = [[NSString alloc]initWithFormat:@"usrNo=%@&dvcid=%@&oldPass=%@&newPass=%@&returnType=JSON&encType=AES256",appDelegate.user_no,[prefs objectForKey:@"UUID"],encrytcurrentPW,encrytnewPW];
    }
    NSLog(@"ezChangePass : %@",urlString);
    
    [appDelegate loginHistoryToLogFile:[NSString stringWithFormat:@"%s",__func__] result:nil];

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
    }
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
        //[self userCheck:[dic2 objectForKey:@"V1"]];
        [self userCheck:dic2];
    }else if([[dic2 objectForKey:@"V0"] isEqualToString:@"False"]){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }else{
        //[self userCheck:[dic2 objectForKey:@"V1"]];
        [self userCheck:dic2];
    }
    
}

-(void) userCheck:(NSDictionary *)dict{
    NSString *v1 = [dict objectForKey:@"V1"];
    NSString *v2 = [dict objectForKey:@"V2"];
    
    if ([_newPWD.text isEqualToString:checkPW.text]) {
        if ([v1 isEqualToString:@"SUCCEED"]) {
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
            
        } else if([v1 isEqualToString:@"FAILED"]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:v2 delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
            
            [currentPW resignFirstResponder];
            currentPW.text = @"";
            [_newPWD resignFirstResponder];
            _newPWD.text = @"";
            [checkPW resignFirstResponder];
            checkPW.text = @"";
        }
    } else {
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
/*
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
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"message70", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
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
*/


@end
