//
//  LoginViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "LoginViewController.h"
#import "MFinityAppDelegate.h"
#import "CertificateViewController.h"

#import "ZipArchive.h"
#import "UIDevice-Hardware.h"
#import "SecurityManager.h"
#import "UIDevice+IdentifierAddition.h"
#import "FBEncryptorAES.h"
#import "ZipArchive.h"
#import "SVProgressHUD.h"

#import <sys/utsname.h>
#include <sys/param.h>
#include <sys/mount.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <dlfcn.h>
#import <mach/port.h>
#import <mach/kern_return.h>


#define SIZEGAP 60

#define X_OFFSET 130
#define Y_OFFSET 50

@interface LoginViewController (){
    NSString *pwdString;
}

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)SQLiteTest{
    //mFinity.sqlite
    NSError *error;
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"mFinity.sqlite"];
    NSString *libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"Application Support"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"mfrontiers"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"sqlite_db"];
    NSString *dbFilePath = [libraryPath stringByAppendingPathComponent:databasePathFromApp];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager isReadableFileAtPath:dbFilePath]){
        [manager createDirectoryAtPath:libraryPath withIntermediateDirectories:YES attributes:nil error:&error];
        [manager copyItemAtPath:databasePathFromApp toPath:dbFilePath error:nil];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%s",__FUNCTION__);
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    isHideKeyboard = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    _logoView.image = [UIImage imageNamed:@"logo.png"];
    imageView.backgroundColor = [UIColor whiteColor];
    
    txtID.delegate = self;
    txtPWD.delegate = self;
    
    [txtID setAutocorrectionType:UITextAutocorrectionTypeNo];
    [txtPWD setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    txtID.backgroundColor = [appDelegate myRGBfromHex:appDelegate.cBgColor];
    txtPWD.backgroundColor = [appDelegate myRGBfromHex:appDelegate.cBgColor];
    
    //textField 안에 아이콘 삽입
    UIImageView *userImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 35, 35)];
    [userImg setImage:[UIImage imageNamed:@"icon(3-1).png"]];
    [userImg setContentMode:UIViewContentModeCenter];
    UIView *paddingView1 =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 35)];
    [paddingView1 addSubview:userImg];
    [txtID.leftView setFrame:userImg.frame];
    txtID.leftView = paddingView1;
    txtID.leftViewMode = UITextFieldViewModeAlways;

    UIImageView *pwdImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 35, 35)];
    [pwdImg setImage:[UIImage imageNamed:@"login(2).png"]];
    [pwdImg setContentMode:UIViewContentModeCenter];
    UIView *paddingView2 =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 35)];
    [paddingView2 addSubview:pwdImg];
    [txtPWD.leftView setFrame:pwdImg.frame];
    txtPWD.leftView = paddingView2;
    txtPWD.leftViewMode = UITextFieldViewModeAlways;
    
    txtID.text = [prefs stringForKey:@"UserInfo_ID"];
    txtID.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPWD.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPWD.returnKeyType = UIReturnKeyJoin;
    
    label3.text = NSLocalizedString(@"message87", @"");
    label3.textColor = [UIColor blackColor];
    
    if ([prefs objectForKey:@"NAVIFONTCOLOR"]!=nil||[prefs objectForKey:@"NAVIBARCOLOR"]!=nil) {
        NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
        if ([[ver objectAtIndex:0] intValue] >= 7) {
            self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.cNaviFontColor]; //[appDelegate myRGBfromHex:appDelegate.naviFontColor];
            self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.cNaviColor]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor];
            self.navigationController.navigationBar.translucent = NO;
        }else {
            [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.cNaviColor]]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
        }
    }
    
    btnLogin.backgroundColor = [appDelegate myRGBfromHex:@"0B57A0"];
    
    versionLabel.text = [NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    UIBarButtonItem *left;
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"", @"") style:UIBarButtonItemStylePlain target:self action:@selector(backEvent:)];
    }else{
        left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(backEvent:)];
    }
    
    self.navigationItem.backBarButtonItem = left;
    
    if ( [[prefs stringForKey:@"isSave"] isEqualToString:@"1"] ) {
        isSaveId = YES;
        [saveID setBackgroundImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    } else {
        isSaveId = NO;
        [saveID setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
//    if ([[prefs stringForKey:@"isAutoLogin"] isEqualToString:@"1"] ) {
//        isAutoLogin = YES;
//        [saveID setBackgroundImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
//
//    } else {
//        isAutoLogin = NO;
//        [saveID setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
//    }
    
    [label3 setFrame:CGRectMake(label3.frame.origin.x, label3.frame.origin.y, label3.frame.size.width, label3.frame.size.height)];
    [txtID setFrame:CGRectMake(txtID.frame.origin.x, txtID.frame.origin.y, txtID.frame.size.width, 50)];
    [txtPWD setFrame:CGRectMake(txtPWD.frame.origin.x, txtPWD.frame.origin.y, txtPWD.frame.size.width, 50)];
    [saveID setFrame:CGRectMake(saveID.frame.origin.x, saveID.frame.origin.y, saveID.frame.size.width, saveID.frame.size.height)];
    [btnLogin setFrame:CGRectMake(btnLogin.frame.origin.x, btnLogin.frame.origin.y, btnLogin.frame.size.width, 50)];
    
    //cornerRadius사용 시 textField 테두리 선이 끊겨서 흰색으로 선을 덮음
    txtID.layer.cornerRadius = txtID.frame.size.width/15;
    txtID.layer.borderWidth = 0.5;
    txtID.layer.borderColor = [UIColor whiteColor].CGColor;
    txtID.clipsToBounds = YES;
    
    txtPWD.layer.cornerRadius = txtPWD.frame.size.width/15;
    txtPWD.layer.borderWidth = 0.5;
    txtPWD.layer.borderColor = [UIColor whiteColor].CGColor;
    txtPWD.clipsToBounds = YES;
    
    btnLogin.layer.cornerRadius = btnLogin.frame.size.width/15;
       
//    if(appDelegate.useAutoLogin&&[[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]){
//        if([prefs objectForKey:@"AutoLogin_ID"]!=nil&&![[prefs objectForKey:@"AutoLogin_ID"] isEqualToString:@""]){
//            txtID.text = [prefs objectForKey:@"AutoLogin_ID"];
//            NSLog(@"AutoLogin_ID : %@", [prefs objectForKey:@"AutoLogin_ID"]);
//        }
//        if([prefs objectForKey:@"AutoLogin_PWD"]!=nil&&![[prefs objectForKey:@"AutoLogin_PWD"] isEqualToString:@""]){
//            txtPWD.text = [prefs objectForKey:@"AutoLogin_PWD"];
//            NSLog(@"AutoLogin_PWD : %@", [prefs objectForKey:@"AutoLogin_PWD"]);
//        }
//        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(Login) userInfo:nil repeats:NO];
//    }
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft)||(toInterfaceOrientation == UIDeviceOrientationLandscapeRight)) {
        
    }else{
        
    }
}

#pragma mark
#pragma mark Action Event Handler

- (void)keyboardWillAnimate:(NSNotification *)notification{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    if ([notification name]==UIKeyboardWillShowNotification) {
        if(isHideKeyboard){
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 50, self.view.frame.size.width, self.view.frame.size.height)];
            isHideKeyboard = NO;
        }
    }else if([notification name]==UIKeyboardWillHideNotification){
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50,self.view.frame.size.width, self.view.frame.size.height)];
        isHideKeyboard = YES;
    }
    [UIView commitAnimations];
}
- (void)_removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(IBAction) textFieldDoneEditing:(id)sender{
    [sender resignFirstResponder];
}

-(IBAction) backgroundTouch:(id)sender{
    [txtID resignFirstResponder];
    [txtPWD resignFirstResponder];
}

-(IBAction)saveIdButton:(id)sender{
    if (isSaveId) {
        isSaveId = NO;
        [saveID setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    } else {
        isSaveId = YES;
        [saveID setBackgroundImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
    }
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    if (isAutoLogin) {
//        isAutoLogin = NO;
//        [saveID setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
//        [prefs setObject:@"0" forKey:@"isAutoLogin"];
//
//    } else {
//        isAutoLogin = YES;
//        [saveID setBackgroundImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateNormal];
//        [prefs setObject:@"1" forKey:@"isAutoLogin"];
//    }
//    [prefs synchronize];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:txtID]) {
        //[txtPWD becomeFirstResponder];
    }else {
        [txtPWD resignFirstResponder];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Login) userInfo:nil repeats:NO];
        
    }
    return YES;
}

//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    if ([textField isEqual:txtPWD]) {
//        [txtPWD resignFirstResponder];
//        NSLog(@"패스워드 클릭!");
//        [self showCharKeyForViewMode];
//
//        return NO;
//    }
//    return YES;
//}

-(void)removeData{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"URL_INFO"];
    [prefs removeObjectForKey:@"UserInfo_ID"];
    [prefs removeObjectForKey:@"isSave"];
    [prefs removeObjectForKey:@"Update"];
    [prefs removeObjectForKey:@"startTabNumber"];
    [prefs removeObjectForKey:@"AutoLogin_ID"];
    [prefs removeObjectForKey:@"AutoLogin_PWD"];
    [prefs removeObjectForKey:@"isAutoLogin"];
    [prefs synchronize];
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [arrayPaths objectAtIndex:0];
    NSFileManager *manager =[NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
    NSLog(@"fileList : %@",fileList);
    for (int i=0; i<[fileList count]; i++) {
        NSString *str = [fileList objectAtIndex:i];
        NSString *fileName = [docDir stringByAppendingPathComponent:str];
        NSLog(@"fileName : %@",fileName);
        if (![[fileName lastPathComponent] isEqualToString:@"URLConnectionInfo.plist"]) {
            [manager removeItemAtPath:fileName error:NULL];
        }
    }
    NSLog(@"[manager contentsOfDirectoryAtPath:docDir error:NO]; : %@",[manager contentsOfDirectoryAtPath:docDir error:NO]);
    NSString *LibraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    LibraryPath = [LibraryPath stringByAppendingPathComponent:@"Application Support"];
    LibraryPath = [LibraryPath stringByAppendingPathComponent:@"oracle"];
    NSString *filePath = LibraryPath;
    if ([manager isReadableFileAtPath:filePath]) {
        [manager removeItemAtPath:filePath error:nil];
    }
}

-(IBAction) LoginButton{
    [txtID resignFirstResponder];
    [txtPWD resignFirstResponder];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Login) userInfo:nil repeats:NO];
}

-(void) Login{
    NSLog(@"%s",__FUNCTION__);
    if (!isButtonClick) {
        isButtonClick = YES;
    
        [txtID resignFirstResponder];
        [txtPWD resignFirstResponder];
         
        myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        myIndicator.center = CGPointMake(160, 240);
        
        userid = txtID.text;
        pwd = txtPWD.text;
        
        if (appDelegate.changeURL) {
            NSLog(@"** changeURL **");
            [self removeData];
        }
        [SVProgressHUD show];
        
        //아이디 저장
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if (isSaveId) {
            [prefs setObject:userid forKey:@"UserInfo_ID"];
            [prefs setObject:@"1" forKey:@"isSave"];
        } else {
            [prefs setObject:@"" forKey:@"UserInfo_ID"];
            [prefs setObject:@"0" forKey:@"isSave"];
        }
        [prefs synchronize];
        
        NSString *usable_volume = [self print_free_memory];
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [networkInfo subscriberCellularProvider];
        NSString *carrierName = [carrier carrierName];
        UIDevice *myDevice = [UIDevice currentDevice];
        
        NSString *osName = @"iOS";
        NSString *osVersion = myDevice.systemVersion;
        NSString *extra_ram = @"N";
        NSString *extra_total_volume = @"0";
        NSString *extra_usable_volume = @"0";
        NSString *isRooting = [MFinityAppDelegate isRooted]?@"YES":@"NO";
       
        NSString *encodingID = [FBEncryptorAES encryptBase64String:userid keyString:appDelegate.AES256Key separateLines:NO];
        NSString *encodingPWD = [FBEncryptorAES encryptBase64String:pwd keyString:appDelegate.AES256Key separateLines:NO];
        NSLog(@"encodingPWD : %@", encodingPWD);

        encodingID = [encodingID urlEncodeUsingEncoding:NSUTF8StringEncoding];
        encodingPWD = [encodingPWD urlEncodeUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"encodingPWD2 : %@", encodingPWD);
        
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        filePath = [filePath stringByAppendingFormat:@"/10/webAppVersion.plist"];
        NSPropertyListFormat format;
        NSDictionary *webappDic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
        NSLog(@"webappDic : %@", webappDic);
        NSString *MF_VER = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        NSString *urlString = [[NSString alloc] initWithFormat:@"%@/ezLogin3",appDelegate.main_url];
        NSString *paramString = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&dvcid=%@&dvcgubn=%@&tel_corp=%@&os_ver=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&dvcOS=%@&RES_VER=%@&MF_VER=%@&dvcMdl=%@&prod_corp=Apple&returnType=JSON",encodingID, encodingPWD, [prefs objectForKey:@"UUID"],appDelegate.dvcGubn,carrierName,osVersion,extra_ram,extra_total_volume,extra_usable_volume,usable_volume,appDelegate.fcmToken,isRooting,osName,[webappDic objectForKey:@"RES_VER"],MF_VER, [[UIDevice currentDevice] modelName]];
        
        if (appDelegate.isAES256) {
            paramString = [paramString stringByAppendingString:@"&encType=AES256"];
        }
        NSLog(@"paramString : %@", paramString);
         
        NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSMutableString *str = [NSMutableString stringWithString:urlString];
        
        NSRange range = [str rangeOfString:@" "];
        while (range.location !=NSNotFound) {
            [str replaceCharactersInRange:range withString:@"%20"];
            range = [str rangeOfString:@" "];
        }
        urlString = str;
        
        if ([userid isEqualToString:@""]||[pwd isEqualToString:@""]) {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message2", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
            [alertView show];
        }else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody: paramData];
            [request setTimeoutInterval:30.0];
            NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (urlCon) {
                receiveData = [[NSMutableData alloc]init];
            }else{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
            }
        }
    }
}

#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [SVProgressHUD dismiss];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    NSLog(@"error : %@",error);
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    
    if ([methodName isEqualToString:@"MLogout"]) {
        SSLVPNConnect *vpn = [[SSLVPNConnect alloc] init];
        [vpn stopTunnel];
        exit(0);
    }else{
        if(statusCode == 404 || statusCode == 500){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
            [SVProgressHUD dismiss];
            [connection cancel];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receiveData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    NSError *error;
    
    if([methodName isEqualToString:@"ezLogin3"]){
        [SVProgressHUD dismiss];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        NSError *error;
        
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
//        NSLog(@"encString : %@", encString);
        
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        NSLog(@"decString : %@", decString);
        
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        NSString *result = [super resultUserCheck:[MFinityAppDelegate getAllValueUrlDecoding:dataDic]];
        NSLog(@"result:  %@", result);
        
        if ([result isEqualToString:@"SUCCEED"]) {
            
            //푸시모듈연결
//            [[PushManager defaultManager] registerService:self completionHandler:^(BOOL success) {
//                NSString *message = ( ! success ) ? @"Registering Service And User is FAIL !!" : @"Registering Service And User is SUCCESS !!";
//                if ( NSClassFromString(@"UIAlertController") ) {
//                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"알림" message:message preferredStyle:UIAlertControllerStyleAlert];
//
//                    [alert addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//                    }]];
//                    [self presentViewController:alert animated:YES completion:nil];
//                }
//                else {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
//                    [alert show];
//                }
//            }];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            if([prefs objectForKey:@"FCM_TOKEN"]==nil || ![appDelegate.fcmToken isEqualToString:[prefs objectForKey:@"FCM_TOKEN"]]){
                NSLog(@"FCM 키가 없거나 다름 ! \nappDelegate.fcmToken : %@ \nFCM_TOKEN : %@", appDelegate.fcmToken, [prefs objectForKey:@"FCM_TOKEN"]);
                [prefs setObject:appDelegate.fcmToken forKey:@"FCM_TOKEN"];
                [prefs synchronize];

                NSString *urlString = [[NSString alloc] initWithFormat:@"%@/PUSHID_UPDATE",appDelegate.main_url];
                NSString *paramString = [[NSString alloc]initWithFormat:@"cuserno=%@&dvcid=%@&pushid1=%@&pushid2=-",appDelegate.user_no, [MFinityAppDelegate getUUID], appDelegate.fcmToken];
                NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

                NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody: paramData];
                [request setTimeoutInterval:10.0];
                NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                if (urlCon) {
                    receiveData = [[NSMutableData alloc]init];
                }else{
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
                }
            }
            
            if(appDelegate.useAutoLogin){
                [prefs setObject:txtID.text forKey:@"AutoLogin_ID"];
                [prefs setObject:txtPWD.text forKey:@"AutoLogin_PWD"];
                [prefs synchronize];
            }
            
            BOOL isSave = [super saveFile];
            if (isSave) {
                [self temp];
                [self updateApplication];
            }
            
        }else if([result isEqualToString:@"FAILED"]){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message5", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }
        
    }else if([methodName isEqualToString:@"deleteSubscription"]){
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        NSString *resultString = [dataDic objectForKey:@"V1"];
        if ([[resultString uppercaseString] isEqualToString:@"FAILED"]) {
            isSubscriptionSucceed = YES;
        }else{
            isSubscriptionSucceed = NO;
        }
        [self updateApplication];
        
    }else if([methodName isEqualToString:@"PUSHID_UPDATE"]||[methodName isEqualToString:@"pushNotiUpdate"]){
        
    }else {
        if (index<=[readArray count]-1) {
            [self fileUpload:[readArray objectAtIndex:index++]];
            
        } else{
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
            NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtPath:txtPath error:nil];
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Succeed"];
            [self deleteSubscription];
        }
    }
}

#pragma mark
#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.message isEqualToString:NSLocalizedString(@"message6", @"")]) {
        CertificateViewController *certView = [[CertificateViewController alloc] init];
        [self.navigationController pushViewController:certView animated:YES];
    }
    
    if ([alertView.title isEqualToString:NSLocalizedString(@"message54", @"")]) {
        if (buttonIndex==0) {
            NSURL *browser = [NSURL URLWithString:deployURL];
            [[UIApplication sharedApplication] openURL:browser];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",appDelegate.main_url]]];
            [request setHTTPMethod:@"POST"];
            NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            [conn start];
            //exit(0);
        }else{
            [appDelegate.window setRootViewController:appDelegate.tabBarController];
            //[self dismissViewControllerAnimated:NO completion:nil];
        }
    }else if([alertView.title isEqualToString:NSLocalizedString(@"message56", @"")]){
        isButtonClick = NO;
    }else if([alertView.title isEqualToString:NSLocalizedString(@"message55", @"")]){
        isButtonClick = NO;
    }else if ([alertView.title isEqualToString:NSLocalizedString(@"message121", @"")]) {
        //exit(0);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",appDelegate.main_url]]];
        [request setHTTPMethod:@"POST"];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        [conn start];
    }
}

#pragma mark
#pragma mark Login Util
-(void)temp{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager isReadableFileAtPath:filePath]) {
        NSError *error;
        NSString *tempFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        tempFilePath = [tempFilePath stringByAppendingFormat:@"/webapp/webAppVersion.plist"];
        [manager copyItemAtPath:tempFilePath toPath:filePath error:&error];
    }
}

-(BOOL) isCellNetwork{
    struct sockaddr_in zeroAddr;
    bzero(&zeroAddr, sizeof(zeroAddr));
    zeroAddr.sin_len = sizeof(zeroAddr);
    zeroAddr.sin_family = AF_INET;
    
    SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddr);
    SCNetworkReachabilityFlags flag;
    SCNetworkReachabilityGetFlags(target, &flag);
    
    if (flag & kSCNetworkReachabilityFlagsIsWWAN) {
        return YES;
    }else {
        return	NO;
    }
}

- (NSString *)print_free_memory{
    float availableDisk;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    statfs([[paths lastObject] cString], &tStats);
    availableDisk = (float)(tStats.f_bavail * tStats.f_bsize);
    return [NSString stringWithFormat:@"%0.0f",availableDisk];
}

#pragma mark -
#pragma mark NFilter
- (void)showCharKeyForViewMode
{
    NSLog(@"%s", __func__);
    
    

    if (self.numPad != nil) {
        [self.numPad.view removeFromSuperview];
        self.numPad = nil;
    }
    
    if (self.charPad != nil) {
        [self.charPad.view removeFromSuperview];
        self.charPad = nil;
    }
    
    self.charPad = [[NFilterChar alloc] initWithNibName:@"NFilterChar" bundle:nil];
    self.charPad.useInitialVector = YES;
    [self.charPad setServerPublickey:@"MDIwGhMABBYCBEsAMWHtqFKFE9xK+8OWdHVjeXSQBBTlmbbw1STxAJoZXHDu2Uyj8drXTg=="];   // 더미용 공개키입니다 자사의 공개키로 바꿔주세요
    [self.charPad setCallbackMethod:self
                    methodOnConfirm:@selector(onConfirmNFilter:encText:dummyText:tagName:)
                       methodOnPrev:@selector(onPrevNFilter:encText:dummyText:tagName:)
                       methodOnNext:@selector(onNextNFilter:encText:dummyText:tagName:)
                      methodOnPress:@selector(onPressNFilter:encText:dummyText:tagName:)
                  methodOnReArrange:@selector(onReArrangeNFilter)
     ];
    [self.charPad setCloseCallbackMethod:self methodOnClose:@selector(onCloseNFilter:encText:dummyText:tagName:)];
    
    [self.charPad setLengthWithTagName:@"encdata2" length:64];
    [self.charPad setFullMode:NO];
    [self.charPad setNoPadding:NO];
    [self.charPad setSupportBackgroundEvent:NO];
    [self.charPad setSupportBackGroundClose:YES];
    [self.charPad setSupportViewRotatation:_isSupportLandscape];
    [self.charPad setMasking:NFilterMaskingDefault];
    [self.charPad setAttachType:NFilterAttachViewController];
    [self.charPad setShowHanguleText:YES];
    [self.charPad setNFilterHeight:250];
    [self.charPad setDeepSecMode:NO];
    [self.charPad setUseVoiceOverViaSpreaker:YES];
    [self.charPad setAllowCloseKeypadConfirmPressed:_isCloseKeypad];
    [self.charPad setBottomMaginForIPhoneX:40];
    [self.charPad setMaginForIPhoneX:40];
    [self.charPad setTransparentBottomForIPhoneX:YES];
    [self.charPad setSupportLinkage:NO];
    
    // 아이패드인 경우
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [self.charPad setShowKeypadBubble:NO];
    }
    
    if (_isCustomKeypad == YES) self.charPad.delegate = self;
    

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self.charPad setVerticalFrame:0];
    } else {
        [self.charPad setVerticalFrame:20];
    }

    self.charPad.toolbar2 = [self createNFilterToolbarForChar];
    self.charPad.toolbar2.delegate = self;
    
    [self.charPad showKeypad:[UIApplication sharedApplication].statusBarOrientation parentViewController:self];
}

#pragma mark -
#pragma mark NFilter toolbar callback 함수

- (void) NFilterToolbarButtonClick:(NFilterButtonType)buttonType withButton :(UIButton *)button
{
    if (self.numPad != nil)
    {
        if (buttonType == NFilterButtonTypeReplace)
            [self.numPad pressKeypadReload];
        else if (buttonType == NFilterButtonTypeOK)
            [self.numPad pressConfirm];
        else if (buttonType == NFilterButtonTypeDelete)
            [self.numPad pressBack];
        else if (buttonType == NFilterButtonTypeNext)
            NSLog(@"이전 작업 처리를 하세요.");
        else if (buttonType == NFilterButtonTypePrev)
            NSLog(@"다음 작업 처리를 하세요.");
    }
    else if (self.charPad != nil)
    {
        if (buttonType == NFilterButtonTypeNext)
            NSLog(@"이전 작업 처리를 하세요.");
        else if (buttonType == NFilterButtonTypeOK)
            [self.charPad pressConfirm];
        else if (buttonType == NFilterButtonTypePrev)
            NSLog(@"다음 작업 처리를 하세요.");
        else if (buttonType == NFilterButtonTypeReplace)
             [self.charPad pressKeypadReload];
        else if (buttonType == NFilterButtonTypeDelete)
            [self.charPad pressBack];
        
    }
}

#pragma mark -
#pragma mark NFilter 키패드 callback 함수
/*--------------------------------------------------------------------------------------
 엔필터 '키' 버튼 눌렀을 때 발생하는 콜백함수
 ---------------------------------------------------------------------------------------*/
- (void)onPressNFilter:(NSString *)secureText encText:(NSString *)encText dummyText:(NSString *)dummyText tagName:(NSString *)tagName
{
    NSLog(@"엔필터 키눌림");
    NSLog(@"태그: %@", tagName);
    NSLog(@"암호문 : %@", secureText);
    NSLog(@"더미: %@", dummyText);
    NSLog(@"서버에 보낼 암호문: %@", encText);
    
    txtPWD.text = dummyText;
    pwdString = encText;
    NSLog(@"패스워드1 : %@", pwdString);
}

/*--------------------------------------------------------------------------------------
 엔필터 '확인' 버튼 눌렀을 때 발생하는 콜백함수
 ---------------------------------------------------------------------------------------*/
- (void)onConfirmNFilter:(NSString *)secureText encText:(NSString *)encText dummyText:(NSString *)dummyText tagName:(NSString *)tagName
{
    NSLog(@"%s", __func__);
    NSLog(@"엔필터 닫힘");
    NSLog(@"태그: %@", tagName);
    NSLog(@"암호문 : %@", secureText);
    NSLog(@"더미: %@", dummyText);
    NSLog(@"서버에 보낼 암호문: %@", encText);
    
    NSLog(@"패스워드2 : %@", pwdString);
    
//    NSString *decPwd = [FBEncryptorAES encryptBase64String:pwdString keyString:appDelegate.AES256Key separateLines:NO];
    NSString *decPwd = [FBEncryptorAES decryptBase64String:pwdString keyString:@"MDIwGhMABBYCBEsAMWHtqFKFE9xK+8OWdHVjeXSQBBTlmbbw1STxAJoZXHDu2Uyj8drXTg=="];
    NSLog(@"decPwd0 : %@", decPwd);

    // allowCloseKeypadConfirmPressed 속성이 NO여서 키패드가 안닫힐때 내려가게하고 싶으면 아래와 같이 closeKeypad를 호출하면 키패드가 내려갑니다.
    [self.charPad closeKeypad];
}

/*--------------------------------------------------------------------------------------
 엔필터 'Background Close'동작할때 발생하는 콜백 함수
 ---------------------------------------------------------------------------------------*/
- (void)onCloseNFilter:(NSString *)secureText encText:(NSString *)encText dummyText:(NSString *)dummyText tagName:(NSString *)tagName
{
    NSLog(@"엔필터 닫힘 : onCloseNFilter");
    NSLog(@"태그: %@", tagName);
    NSLog(@"암호문 : %@", secureText);
    NSLog(@"더미: %@", dummyText);
    NSLog(@"서버에 보낼 암호문: %@", encText);
    
    NSLog(@"패스워드3 : %@", pwdString);
}

- (NFilterToolbar2 *)createNFilterToolbarForChar
{
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    NFilterToolbar2 *toolbar = [[NFilterToolbar2 alloc] initWithFrame:CGRectMake(0, 100, screenWidth, 44)];
    toolbar.backgroundColor = UIColorFromRGB(0xebebeb);

    NFilterButton2 *toolbarButton = [[NFilterButton2 alloc] initWithFrame:CGRectMake(0, 0, 80, 42)];
    UIButton *btn = toolbarButton.button;
    // 확인
    [btn setTitle:@"확인" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[SampleUtils imageFromColor:[UIColor orangeColor]] forState:UIControlStateNormal];
    toolbarButton.nFilterbuttonType = NFilterButtonTypeOK;
    toolbarButton.alignWithMargins = YES;
    toolbarButton.margins = NFMarginsMake(4, 4, 4, 4);
    toolbarButton.dock = NFDockTypeRight;
    
    [toolbar addToolbarButton:toolbarButton];
    
    toolbar.align = NFilterToolbarAlignTop;
    return toolbar;
}

@end
