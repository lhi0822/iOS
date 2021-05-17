//
//  LoginViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "LoginViewController.h"
#import "MFinityAppDelegate.h"
#import "ZipArchive.h"
#import "UIDevice-Hardware.h"
#import "CertificateViewController.h"
#import "SecurityManager.h"
#import "URLInsertViewController.h"
#import "UIDevice+IdentifierAddition.h"
#import "FBEncryptorAES.h"
#import "ZipArchive.h"
#import "SVProgressHUD.h"
#import "URLSettingViewController.h"
#import "WebViewController.h"
//#import "WKWebViewController.h"

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


#define SIZEGAP 70
@interface LoginViewController (){
    NSString *autoLoginStatus; //valid:유효/expire:만료/none:자동로그인X
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
    // Do any additional setup after loading the view from its nib.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    isHideKeyboard = YES;
    
    autoLoginStatus = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AgreementNotification:) name:@"AgreementNotification" object:nil];
    
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    
    [txtID setAutocorrectionType:UITextAutocorrectionTypeNo];
    [txtPWD setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    if (screenHeight/screenWidth>1.5) {
        [btnLogin setFrame:CGRectMake(btnLogin.frame.origin.x
                                      , btnLogin.frame.origin.y+SIZEGAP+10,
                                      btnLogin.frame.size.width,
                                      btnLogin.frame.size.height+5)];
        [label3 setFrame:CGRectMake(label3.frame.origin.x,
                                    label3.frame.origin.y+SIZEGAP+10,
                                    label3.frame.size.width,
                                    label3.frame.size.height)];
        [label5 setFrame:CGRectMake(label5.frame.origin.x,
                                    label5.frame.origin.y+SIZEGAP,
                                    label5.frame.size.width,
                                    label5.frame.size.height)];
        [txtID setFrame:CGRectMake(txtID.frame.origin.x,
                                   txtID.frame.origin.y+SIZEGAP,
                                   txtID.frame.size.width,
                                   txtID.frame.size.height+5)];
        [txtPWD setFrame:CGRectMake(txtPWD.frame.origin.x,
                                    txtPWD.frame.origin.y+SIZEGAP+5,
                                    txtPWD.frame.size.width,
                                    txtPWD.frame.size.height+5)];
        [saveID setFrame:CGRectMake(saveID.frame.origin.x,
                                    saveID.frame.origin.y+SIZEGAP+10,
                                    saveID.frame.size.width,
                                    saveID.frame.size.height)];
        [offLine setFrame:CGRectMake(offLine.frame.origin.x,
                                     offLine.frame.origin.y+SIZEGAP,
                                     offLine.frame.size.width,
                                     offLine.frame.size.height)];
        [infoImageView setFrame:CGRectMake(infoImageView.frame.origin.x,
                                           infoImageView.frame.origin.y+SIZEGAP,
                                           infoImageView.frame.size.width,
                                           infoImageView.frame.size.height)];
        [label4 setFrame:CGRectMake(label4.frame.origin.x,
                                    label4.frame.origin.y+SIZEGAP,
                                    label4.frame.size.width,
                                    label4.frame.size.height)];
        [initPwd setFrame:CGRectMake(initPwd.frame.origin.x,
                                     initPwd.frame.origin.y+SIZEGAP+10,
                                     initPwd.frame.size.width,
                                     initPwd.frame.size.height)];
        [autoLogin setFrame:CGRectMake(autoLogin.frame.origin.x,
                                       autoLogin.frame.origin.y+SIZEGAP+10,
                                       autoLogin.frame.size.width,
                                       autoLogin.frame.size.height)];
        [autoLoginLbl setFrame:CGRectMake(autoLoginLbl.frame.origin.x,
                                          autoLoginLbl.frame.origin.y+SIZEGAP+10,
                                          autoLoginLbl.frame.size.width,
                                          autoLoginLbl.frame.size.height)];
    }

    if ([prefs objectForKey:@"MAINFONTCOLOR"]==nil) {
        label3.textColor = [UIColor whiteColor];
        label4.textColor = [UIColor whiteColor];
        label5.textColor = [UIColor whiteColor];
        autoLoginLbl.textColor = [UIColor whiteColor];
    }else{
        label3.textColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"MAINFONTCOLOR"]];
        label4.textColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"MAINFONTCOLOR"]];
        label5.textColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"MAINFONTCOLOR"]];
        autoLoginLbl.textColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"MAINFONTCOLOR"]];
    }
    
    if ([prefs objectForKey:@"LOGINONCOLOR"]==nil) {
        btnLogin.backgroundColor = [UIColor blackColor];
    }else{
        btnLogin.backgroundColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"LOGINONCOLOR"]];
    }
    [btnLogin setTitle:NSLocalizedString(@"LOGIN", @"login") forState:UIControlStateNormal];

    
    
    if ([prefs objectForKey:@"NAVIFONTCOLOR"]!=nil||[prefs objectForKey:@"NAVIBARCOLOR"]!=nil) {
        NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
        if ([[ver objectAtIndex:0] intValue] >= 7) {
            self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"NAVIFONTCOLOR"]];
            self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"NAVIBARCOLOR"]];
            self.navigationController.navigationBar.translucent = NO;
        }else {
            [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:[prefs objectForKey:@"NAVIBARCOLOR"]]];
        }
    }
    
    UIImageView *userImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 30, 30)];
    [userImg setImage:[UIImage imageNamed:@"id_img.png"]];
    [userImg setContentMode:UIViewContentModeCenter];
    UIView *paddingView1 =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 30)];
    [paddingView1 addSubview:userImg];
    [txtID.leftView setFrame:userImg.frame];
    txtID.leftView = paddingView1;
    txtID.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *pwdImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 30, 30)];
    [pwdImg setImage:[UIImage imageNamed:@"pwd_img.png"]];
    [pwdImg setContentMode:UIViewContentModeCenter];
    UIView *paddingView2 =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 30)];
    [paddingView2 addSubview:pwdImg];
    [txtPWD.leftView setFrame:pwdImg.frame];
    txtPWD.leftView = paddingView2;
    txtPWD.leftViewMode = UITextFieldViewModeAlways;
    
    btnLogin.backgroundColor = [appDelegate myRGBfromHex:@"0093d5"];
    btnLogin.layer.cornerRadius = btnLogin.frame.size.width/30;
    btnLogin.clipsToBounds = YES;
    
    versionLabel.text = [NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    //mainType = [[NSString alloc]initWithFormat:@""];
    txtID.delegate = self;
    txtPWD.delegate = self;

    //self.navigationItem.title = [prefs objectForKey:@"URL_NAME"];
    /*
    if ([prefs objectForKey:@"URL_INFO"]==nil || [[prefs objectForKey:@"URL_INFO"] isEqualToString:@""]) {
        
    }else{
        appDelegate.main_url = [prefs objectForKey:@"URL_INFO"];
    }*/
    NSString *path = [prefs stringForKey:@"LoginImagePath"];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSLog(@"path : %@",path);
    NSError *error;
    NSLog(@"Login documentPath : %@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]);
    NSArray * directoryContents2 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Containers/Data/Application/A7EAD8CB-D63F-4B5A-81F4-0ECF435D0EFC/Documents/10/icon" error:&error];
    for(NSString *tmp in directoryContents2){
        NSLog(@"icon Path : %@",tmp);
    }
    
    NSLog(@"isFile : %@",[manager isReadableFileAtPath:path]?@"YES":@"NO");
    NSData *decryptData = [[NSData dataWithContentsOfFile:path] AES256DecryptWithKey:appDelegate.AES256Key];
    NSLog(@"decryptData : %@",decryptData);
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    label1.text = NSLocalizedString(@"message85", @"");
    label2.text = NSLocalizedString(@"message86", @"");
    label3.text = NSLocalizedString(@"message87", @"");
    
    NSLog(@"bgImage : %@",bgImage);
    if (bgImage==nil) {
        imageView.image = [UIImage imageNamed:@"login.png"];
    }else{
        imageView.image = bgImage;
    }
    
    label4.text = NSLocalizedString(@"message109", @"");
    if (label4.text.length > 80) {
        label4.font = [UIFont boldSystemFontOfSize:12];
    }else{
        label4.font = [UIFont boldSystemFontOfSize:13];
    }
    
    [label4 setHidden:YES];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    UIBarButtonItem *left;
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"", @"") style:UIBarButtonItemStylePlain target:self action:nil];
        
    }else{
        
        //left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(backEvent:)];
        
    }
    
    [initPwd setImage:[[UIImage imageNamed:@"btn_setting_blue.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [initPwd setTitle:@"비밀번호 초기화" forState:UIControlStateNormal];
    initPwd.tintColor = [appDelegate myRGBfromHex:@"0093d5"];
    [initPwd setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 5.0)];
    
    self.navigationItem.backBarButtonItem = left;
    
    //txtID.text = [prefs stringForKey:@"UserInfo_ID"];
    txtID.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPWD.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtID.placeholder = NSLocalizedString(@"ID", @"id");
    txtPWD.placeholder = NSLocalizedString(@"PASSWORD", @"password");
    
    if ( [[prefs stringForKey:@"isSave"] isEqualToString:@"1"] ) {
        isSaveId = YES;
        [saveID setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        //[switchIdSave setOn:YES];
    } else {
        isSaveId = NO;
        [saveID setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
        //[switchIdSave setOn:NO];
    }
    if ([[prefs stringForKey:@"isAutoLogin"] isEqualToString:@"1"] ) {
        isAutoLogin = YES;
        [autoLogin setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        
    } else {
        isAutoLogin = NO;
        [autoLogin setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    
    txtPWD.returnKeyType = UIReturnKeyJoin;
    
    if(screenWidth<330){
        label3.font = [UIFont systemFontOfSize:11];
        autoLoginLbl.font = [UIFont systemFontOfSize:11];
        
        [label3 setFrame:CGRectMake(label3.frame.origin.x-5,
                                    label3.frame.origin.y,
                                    label3.frame.size.width,
                                    label3.frame.size.height)];
        [autoLogin setFrame:CGRectMake(autoLogin.frame.origin.x-15,
                                       autoLogin.frame.origin.y,
                                       autoLogin.frame.size.width,
                                       autoLogin.frame.size.height)];
        [autoLoginLbl setFrame:CGRectMake(autoLoginLbl.frame.origin.x-20,
                                          autoLoginLbl.frame.origin.y,
                                          autoLoginLbl.frame.size.width,
                                          autoLoginLbl.frame.size.height)];
        [initPwd setFrame:CGRectMake(initPwd.frame.origin.x+5,
                                     initPwd.frame.origin.y,
                                     initPwd.frame.size.width,
                                     initPwd.frame.size.height)];
    }
    
    txtID.text = [prefs stringForKey:@"UserInfo_ID"];
    
    if(appDelegate.useAutoLogin){
        [autoLogin setHidden:NO];
        [autoLoginLbl setHidden:NO];
        
//        [prefs setObject:@"2019-04-28" forKey:@"AUTO_LOGIN_DATE"];
//        [prefs synchronize];
        
//        NSLog(@"AUTO_LOGIN_DATE : %@", [prefs objectForKey:@"AUTO_LOGIN_DATE"]);
//        NSLog(@"[prefs objectForKey: isAutoLogin] : %@", [prefs objectForKey:@"isAutoLogin"]);
        if ([[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]&&[prefs objectForKey:@"AUTO_LOGIN_DATE"]!=nil) {
            //if 만료날짜 지났는지 안지났는지 체크해야됨
            
            //1.자동로그인 시작 날짜
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd";
            NSDate *startDate = [formatter dateFromString:[prefs objectForKey:@"AUTO_LOGIN_DATE"]];
            NSLog(@"startDate: %@", startDate);
            
            
            //2.자동로그인 시작날짜로부터 30일
            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
            dayComponent.day = 30;
            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            NSDate *endDate = [theCalendar dateByAddingComponents:dayComponent toDate:startDate options:0];
            NSLog(@"endDate: %@", endDate);
            
            //3. 오늘 날짜
            NSDate *today = [NSDate date];
            
            //4.자동로그인30일과 오늘 날짜 비교
            NSCalendar *sysCalendar = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSCalendarUnitDay;
            NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:today toDate:endDate options:0];//날짜 비교해서 차이값 추출
            NSInteger date = dateComp.day;
            
            if(date>=0){
                autoLoginStatus = @"valid";
                //유효
                if([[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]&&[prefs objectForKey:@"AutoLogin_ID"]!=nil&&![[prefs objectForKey:@"AutoLogin_ID"] isEqualToString:@""]){
                    txtID.text = [prefs objectForKey:@"AutoLogin_ID"];
                    NSLog(@"AutoLogin_ID : %@", [prefs objectForKey:@"AutoLogin_ID"]);
                }
                if([[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]&&[prefs objectForKey:@"AutoLogin_PWD"]!=nil&&![[prefs objectForKey:@"AutoLogin_PWD"] isEqualToString:@""]){
                    txtPWD.text = [prefs objectForKey:@"AutoLogin_PWD"];
                    NSLog(@"AutoLogin_PWD : %@", [prefs objectForKey:@"AutoLogin_PWD"]);
                }
                
                //[self Login];
                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(Login) userInfo:nil repeats:NO];
                
            } else {
                autoLoginStatus = @"expire";
                //만료
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message54", @"") message:NSLocalizedString(@"message171", @"") preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alert animated:YES completion:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
                
                [prefs setObject:@"0" forKey:@"isAutoLogin"];
                [prefs synchronize];
            }
        } else {
            autoLoginStatus = @"none";
        }
        
    } else {
        [autoLogin setHidden:YES];
        [autoLoginLbl setHidden:YES];
    }
     
     
    /*
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:@"app_oracle.sync"];
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    BOOL issue = [fileManager isReadableFileAtPath:documentFolder];
    if (!issue) {
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"app_oracle.sync.zip"];
        NSString *documentDirPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *documentDBPath = [documentDirPath stringByAppendingPathComponent:@"app_oracle.sync.zip"];
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager copyItemAtPath:databasePathFromApp toPath:documentDBPath error:nil];
        
        ZipArchive *zip = [[ZipArchive alloc]init];
        if ([zip UnzipOpenFile:documentDBPath]) {
            [zip UnzipFileTo:documentDirPath overWrite:YES];
        }
        [zip UnzipCloseFile];
        
    }
    */

}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, 0,self.view.frame.size.width, self.view.frame.size.height)];
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
        [saveID setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
	}
}
-(IBAction)offLineButton:(id)sender{
    
    if (isOffline) {
        isOffline = NO;
        [offLine setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
        [infoImageView setHidden:YES];
        [label4 setHidden:YES];
	} else {
        isOffline = YES;
        [offLine setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        [label4 setHidden:NO];
        [infoImageView setHidden:NO];
	}
}

- (IBAction)initPwdButton:(id)sender {
    NSLog(@"비밀번호 초기화");
    appDelegate.isInitPwd = YES;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    appDelegate.naviBarColor = @"#535768";
    appDelegate.naviFontColor = @"#ffffff";
    [prefs setObject:appDelegate.naviBarColor forKey:@"NAVIBARCOLOR"];
    [prefs setObject:appDelegate.naviFontColor forKey:@"NAVIFONTCOLOR"];
    
    appDelegate.menu_title = [[NSString alloc] initWithFormat:@"비밀번호 초기화"];
    appDelegate.target_url = [[NSString alloc] initWithFormat:@"https://touch1.hhi.co.kr/dataservice41/PwdUpdate.jsp"];
    WebViewController *vc = [[WebViewController alloc] init];
//    WKWebViewController *vc = [[WKWebViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
-(IBAction)connInfoSetting:(id)sender{
    
    URLSettingViewController *vc = [[URLSettingViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    settingButton.alpha = 0.3;
}
-(IBAction)connInfoSetting2:(id)sender{
    settingButton.alpha = 0.8;
}
-(IBAction)connInfoSetting3:(id)sender{
    settingButton.alpha = 0.3;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"[textFieldShouldReturn]");
    if ([textField isEqual:txtID]) {
        [txtPWD becomeFirstResponder];
    }else {
        [txtPWD resignFirstResponder];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Login) userInfo:nil repeats:NO];
        
    }
    return YES;
}
-(void)rightBtnClick{
    
    URLSettingViewController *vc = [[URLSettingViewController alloc]initWithNibName:@"URLSettingViewController.xib" bundle:Nil];
    [self.navigationController pushViewController:vc animated:YES];
}
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
    [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
    [prefs synchronize];
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [arrayPaths objectAtIndex:0];
    NSFileManager *manager =[NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:nil];
    NSLog(@"fileList : %@",fileList);
    for (int i=0; i<[fileList count]; i++) {
        NSString *str = [fileList objectAtIndex:i];
        NSString *fileName = [docDir stringByAppendingPathComponent:str];
        NSLog(@"fileName : %@",fileName);
        if (![[fileName lastPathComponent] isEqualToString:@"URLConnectionInfo.plist"]) {
            [manager removeItemAtPath:fileName error:NULL];
        }
    }
    NSLog(@"[manager contentsOfDirectoryAtPath:docDir error:NO]; : %@",[manager contentsOfDirectoryAtPath:docDir error:nil]);
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

- (IBAction)autoLoginButton:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (isAutoLogin) {
        isAutoLogin = NO;
        [autoLogin setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
        [prefs setObject:@"0" forKey:@"isAutoLogin"];
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"auto_login_notice_title", @"auto_login_notice_title") message:NSLocalizedString(@"auto_login_notice", @"auto_login_notice") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message173", @"message173") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             isAutoLogin = NO;
                                                             [autoLogin setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
                                                             [prefs setObject:@"0" forKey:@"isAutoLogin"];
                                                             
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message172", @"message172") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             isAutoLogin = YES;
                                                             [autoLogin setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
                                                             [prefs setObject:@"1" forKey:@"isAutoLogin"];
                                                             
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:cancelButton];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    [prefs synchronize];
}

-(void)Login{
   appDelegate.isInitPwd = NO;
    if (!isButtonClick) {
        isButtonClick = YES;

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if([autoLoginStatus isEqualToString:@"expire"]&&[[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]){
            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *todayStr = [dateFormatter stringFromDate:today];
            [prefs setObject:todayStr forKey:@"AUTO_LOGIN_DATE"];
            [prefs synchronize];

            autoLoginStatus = @"valid";

        } else if ([autoLoginStatus isEqualToString:@"none"]&&[[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]) {
            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *todayStr = [dateFormatter stringFromDate:today];
            [prefs setObject:todayStr forKey:@"AUTO_LOGIN_DATE"];
            [prefs synchronize];

            autoLoginStatus = @"valid";
        }

        NSUserDefaults *userInfo= [NSUserDefaults standardUserDefaults];
        [txtID resignFirstResponder];
        [txtPWD resignFirstResponder];
        myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        myIndicator.center = CGPointMake(160, 240);

        userid = txtID.text;
        pwd = txtPWD.text;

        if (isOffline) {
            appDelegate.isOffLine = YES;
            if ([userInfo objectForKey:@"OFFLINE_PASSWD"]==nil) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"message101", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                
            }else if([[userInfo objectForKey:@"OFFLINE_FLAG"] isEqualToString:@"N"]){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"message102", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                
            }else{
                NSString* offLinePWD = [FBEncryptorAES decryptBase64String:[userInfo objectForKey:@"OFFLINE_PASSWD"]keyString: [MFinityAppDelegate getAES256Key]];

                if(![[userInfo objectForKey:@"OFFLINE_ID"] isEqualToString:txtID.text] || ![offLinePWD isEqualToString:txtPWD.text]){
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message5", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                    
                }else {
                    [SVProgressHUD show];
                    //myIndicator.hidesWhenStopped = NO;
                    //[self.view addSubview:myIndicator];
                    //[myIndicator startAnimating];
                    pwd = txtPWD.text;
                    NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    //save = [save stringByAppendingFormat:@"/HHILogin"];
                    save = [save stringByAppendingFormat:@"/ezLogin3"];

                    NSError *error;
                    NSData *data = [NSData dataWithContentsOfFile:save];

                    NSDictionary *dataDic =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    NSString *result = [super resultUserCheck:[MFinityAppDelegate getAllValueUrlDecoding:dataDic]];
                    
                    if ([result isEqualToString:@"SUCCEED"]) {
                        NSString *mainBgFilename = [appDelegate.bgImagePath lastPathComponent];
                        NSString *subBgFilename = [appDelegate.subBgImagePath lastPathComponent];
                        NSString *loginImageFilename = [appDelegate.loginImagePath lastPathComponent];

                        NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                        documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
                        documentFolder = [documentFolder stringByAppendingPathComponent:@"icon"];

                        appDelegate.bgImagePath = [documentFolder stringByAppendingPathComponent:mainBgFilename];
                        appDelegate.subBgImagePath = [documentFolder stringByAppendingPathComponent:subBgFilename];
                        appDelegate.loginImagePath = [documentFolder stringByAppendingPathComponent:loginImageFilename];

                        NSLog(@"%s",__FUNCTION__);
                        [MFinityAppDelegate checkWebappDirectory:nil];
                        [MFinityAppDelegate checkWebappDirectory:@"585"];

                        [self updateApplication];
                        
                    } else if([result isEqualToString:@"FAILED"]){
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message5", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                        [alertView show];
                    }
                }
            }

        }else{
            if (appDelegate.changeURL) {
                NSLog(@"** changeURL **");
                [self removeData];
            }
            appDelegate.isOffLine = NO;
            [SVProgressHUD show];
            
            //아이디 저장
            if (isSaveId) {
                [userInfo setObject:userid forKey:@"UserInfo_ID"];
                [userInfo setObject:@"1" forKey:@"isSave"];
            } else {
                [userInfo setObject:@"" forKey:@"UserInfo_ID"];
                [userInfo setObject:@"0" forKey:@"isSave"];
            }
            
            [userInfo synchronize];

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
            NSString *isRooting = @"-";
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath: @"/Applications/Cydia.app"]||
                [fileManager fileExistsAtPath: @"/Applications/RockApp.app"]||
                [fileManager fileExistsAtPath: @"/Applications/Icy.app"]||
                [fileManager fileExistsAtPath: @"/Applications/FakeCrrier.app"]||
                [fileManager fileExistsAtPath: @"/Applications/WinterBoard.app"]||
                [fileManager fileExistsAtPath: @"/Applications/SBSettings.app"]||
                [fileManager fileExistsAtPath: @"/Applications/MxTube.app"]||
                [fileManager fileExistsAtPath: @"/Applications/InteliScreen.app"]||
                [fileManager fileExistsAtPath: @"/Applications/blackra1n.app"]||
                [fileManager fileExistsAtPath: @"/Applications/.app"]||
                [fileManager fileExistsAtPath: @"/usr/sbin/sshd"]||
                [fileManager fileExistsAtPath: @"/usr/bin/sshd"]||
                [fileManager fileExistsAtPath: @"/usr/libexec/sftp-server"]||
                [fileManager fileExistsAtPath: @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist"]||
                [fileManager fileExistsAtPath: @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist"]||
                [fileManager fileExistsAtPath: @"/private/var/lib/apt"]||
                [fileManager fileExistsAtPath: @"/private/var/stash"]||
                [fileManager fileExistsAtPath: @"/private/var/mobile/Library/SBSettings/Themes"]||
                [fileManager fileExistsAtPath: @"/System/Library/LaunchDaemons/com.ikey.bbot.plist"]||
                [fileManager fileExistsAtPath: @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist"]||
                [fileManager fileExistsAtPath: @"/private/var/tmp/cydia.log"]||
                [fileManager fileExistsAtPath: @"/private/var/lib/cydia"]) {
                isRooting = @"Y";
            }else{
                isRooting = @"N";
            }
            
            NSString *encodingID = [FBEncryptorAES encryptBase64String:userid
                                                             keyString:appDelegate.AES256Key
                                                         separateLines:NO];

            NSString *encodingPWD = [FBEncryptorAES encryptBase64String:pwd
                                                              keyString:appDelegate.AES256Key
                                                          separateLines:NO];

            encodingID = [encodingID urlEncodeUsingEncoding:NSUTF8StringEncoding];
            encodingPWD = [encodingPWD urlEncodeUsingEncoding:NSUTF8StringEncoding];

            NSString *dvcid = [MFinityAppDelegate getUUID];
            NSString *compNo = [userInfo objectForKey:@"COMP_NO"];

            NSString *RES_VER;
            if (compNo == nil) {
                RES_VER = @"#";
            }else{
                NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",[[NSString stringWithFormat:@"%@",compNo] AES256DecryptWithKeyString:appDelegate.AES256Key]];

                if([NSData dataWithContentsOfFile:filePath]!=nil){
                    NSError *error;
                    NSPropertyListFormat format;
                    NSDictionary *webappDic = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:filePath]  options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];

                    RES_VER = [webappDic objectForKey:@"RES_VER"];
                }
            }

            NSString *MF_VER = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            NSString *urlString;
            NSData *paramData;
            NSString *paramString;

            if (appDelegate.isAES256) {
                urlString = [[NSString alloc] initWithFormat:@"%@/ezLogin3",appDelegate.main_url];
//                paramString = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&dvcid=%@&dvcgubn=P&tel_corp=%@&os_ver=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&dvcOS=%@&RES_VER=%@&MF_VER=%@&returnType=JSON&encType=AES256",encodingID, encodingPWD, [prefs objectForKey:@"UUID"],carrierName,osVersion,extra_ram,extra_total_volume,extra_usable_volume,usable_volume,appDelegate.appDeviceToken,isRooting,osName,RES_VER,MF_VER];
                paramString = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&dvcid=%@&dvcgubn=P&tel_corp=%@&os_ver=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&dvcOS=%@&RES_VER=%@&MF_VER=%@&returnType=JSON&encType=AES256",encodingID, encodingPWD, [prefs objectForKey:@"UUID"],carrierName,osVersion,extra_ram,extra_total_volume,extra_usable_volume,usable_volume,appDelegate.fcmToken,isRooting,osName,RES_VER,MF_VER];

            }else{
                urlString = [[NSString alloc] initWithFormat:@"%@/HHILogin",appDelegate.main_url];
//                paramString = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&dvcid=%@&dvcgubn=P&tel_corp=%@&os_ver=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&dvcOS=%@&RES_VER=%@&MF_VER=%@&returnType=JSON",encodingID, encodingPWD, [prefs objectForKey:@"UUID"],carrierName,osVersion,extra_ram,extra_total_volume,extra_usable_volume,usable_volume,appDelegate.appDeviceToken,isRooting,osName,RES_VER,MF_VER];
                paramString = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&dvcid=%@&dvcgubn=P&tel_corp=%@&os_ver=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&dvcOS=%@&RES_VER=%@&MF_VER=%@&returnType=JSON",encodingID, encodingPWD, [prefs objectForKey:@"UUID"],carrierName,osVersion,extra_ram,extra_total_volume,extra_usable_volume,usable_volume,appDelegate.fcmToken,isRooting,osName,RES_VER,MF_VER];
            }

            paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSMutableString *str = [NSMutableString stringWithString:urlString];

            NSRange range = [str rangeOfString:@" "];
            while (range.location !=NSNotFound) {
                [str replaceCharactersInRange:range withString:@"%20"];
                range = [str rangeOfString:@" "];
            }
            urlString = str;
            NSLog(@"urlString : %@",urlString);
            NSLog(@"paramString : %@",paramString);

            if ([userid isEqualToString:@""]||[pwd isEqualToString:@""]) {
                [SVProgressHUD dismiss];
                //[myIndicator stopAnimating];
                //myIndicator.hidesWhenStopped =YES;
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message2", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
                [alertView show];
            } else {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];

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
        }
    }
}
- (void)AgreementNotification:(NSNotification *)notification{
    NSString *loginResult = [notification.object objectForKey:@"LOGIN_RESULT"];
    NSString *agreeValue = [notification.object objectForKey:@"AGREE_VALUE"];
    
    if([agreeValue isEqualToString:@"0"]){
        //미동의
        isButtonClick = NO;
        isAutoLogin = NO;
        txtID.text = nil;
        txtPWD.text = nil;
        [saveID setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
        [autoLogin setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs removeObjectForKey:@"UserInfo_ID"];
        [prefs removeObjectForKey:@"isSave"];
        [prefs removeObjectForKey:@"AutoLogin_ID"];
        [prefs removeObjectForKey:@"AutoLogin_PWD"];
        [prefs removeObjectForKey:@"isAutoLogin"];
        [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
        [prefs synchronize];
        
    } else {
        if([loginResult isEqualToString:@"NOTCERT"]){
            CertificateViewController *certView = [[CertificateViewController alloc] init];
            [self.navigationController pushViewController:certView animated:YES];
        }
    }
}

#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [SVProgressHUD dismiss];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	//[myIndicator stopAnimating];
    
    NSLog(@"error : %@",error);
	//myIndicator.hidesWhenStopped =YES;
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
        if(appDelegate.isMDM){
            appDelegate.mdmCallAPI = @"exitWorkApp";
            [MFinityAppDelegate exitWorkApp];
        } else {
            exit(0);
        }
        
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
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    if([methodName isEqualToString:@"getOfflineMenuList"]){
        [offLineData appendData:data];
    } else {
        receiveData = [[NSMutableData alloc]init];
        [receiveData appendData:data];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    NSDictionary *dic;
    NSError *error;
    if ([methodName isEqualToString:@"getOfflineMenuList"]) {
        @try {
            // if AES256
            NSString *encString =[[NSString alloc]initWithData:offLineData encoding:NSUTF8StringEncoding];
            NSString *decString ;
            if (appDelegate.isAES256) {
                decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
            }
            else{
                decString = encString;
            }
            
            dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            // if nomal
            //dic = [NSJSONSerialization JSONObjectWithData:offLineData options:kNilOptions error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }

        if ([[[dic objectForKey:[NSString stringWithFormat:@"%d",0]]objectForKey:@"V0"]isEqualToString:@"True"]) {
            NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            save = [save stringByAppendingFormat:@"/getOffLineMenuList"];
            [offLineData writeToFile:save atomically:YES];
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }
    //}else if([methodName isEqualToString:@"HHILogin"]){
    }else if([methodName isEqualToString:@"ezLogin3"]){
        [SVProgressHUD dismiss];

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        NSError *error;

        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];

        NSString *result = [super resultUserCheck:[MFinityAppDelegate getAllValueUrlDecoding:dataDic]];
        
        //그룹사수정
        [self callGetGroupImage];
        NSLog(@"LOGIN RESULT : %@", result);
        
        if ([result isEqualToString:@"SUCCEED"]) {
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
            
            if([prefs objectForKey:@"DEVICE_ID"]==nil||[[prefs objectForKey:@"DEVICE_ID"]isEqual:@""]||[[prefs objectForKey:@"DEVICE_ID"]isEqual:@"null"]||[[prefs objectForKey:@"DEVICE_ID"]isEqual:@"(null)"]){
//                NSString *dvcid = [MFinityAppDelegate getUUID];
                [prefs setObject:[prefs objectForKey:@"UUID"] forKey:@"DEVICE_ID"];
                [prefs synchronize];
            }
            NSLog(@"DEVICE_ID : %@", [prefs objectForKey:@"DEVICE_ID"]);
            
            if(appDelegate.useAutoLogin){
                if(appDelegate.setFirstLogin&&[[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]){
                    NSLog(@"자동 로그인 실행");
                    NSDate *today = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSString *todayStr = [dateFormatter stringFromDate:today];
                    [prefs setObject:todayStr forKey:@"AUTO_LOGIN_DATE"];
                }
                
//                NSLog(@"로그인성공 userid : %@, pwd : %@", txtID.text, txtPWD.text);
                [prefs setObject:txtID.text forKey:@"AutoLogin_ID"];
                [prefs setObject:txtPWD.text forKey:@"AutoLogin_PWD"];
                
                [prefs synchronize];
            }
            
            BOOL isSave = [super saveFile];
            if (isSave) {
                [self temp];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                if([[prefs objectForKey:@"OFFLINE_FLAG"] isEqualToString:@"Y"]){
                    NSString *offLineMenuURL;
                    
                    NSString *paramString;
                    offLineMenuURL = [NSString stringWithFormat:@"%@/getOfflineMenuList",appDelegate.main_url];
                    if (appDelegate.isAES256) {
                        paramString = [[NSString alloc]initWithFormat:@"usrNo=%@&appNo=%@&devOs=I&devTy=P&returnType=JSON&encType=AES256",appDelegate.user_no,appDelegate.app_no];
                    }else{
                        paramString = [[NSString alloc]initWithFormat:@"usrNo=%@&appNo=%@&devOs=I&devTy=P&returnType=JSON",appDelegate.user_no,appDelegate.app_no];
                        
                    }
                    //NSLog(@"offLineMenuURL : %@",offLineMenuURL);
                    NSData *postData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:offLineMenuURL]];
                    [urlRequest setHTTPMethod:@"POST"];
                    [urlRequest setHTTPBody: postData];
                    [urlRequest setTimeoutInterval:10.0];
                    NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                    if(urlCon){
                        offLineData = [[NSMutableData alloc] init];
                    }else {
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
                    }
                }
                
                [self updateApplication];
            }
            
        } else if([result isEqualToString:@"NOTCERT"]){
            if([personalAgree isEqualToString:@"F"]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message6", @"") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"") style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    AgreementViewController *vc = [[AgreementViewController alloc] initWithNibName:@"AgreementViewController" bundle:nil];
                                                                    vc.loginResult = result;
                                                                    vc.modalPresentationStyle = UIModalPresentationFullScreen;
                                                                    [self presentViewController:vc animated:YES completion:nil];
                                                              }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message6", @"") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"") style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    CertificateViewController *certView = [[CertificateViewController alloc] init];
                                                                    [self.navigationController pushViewController:certView animated:YES];
                                                              }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else if([result isEqualToString:@"FAILED"]){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message55", @"") message:NSLocalizedString(@"message5", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }
    
    } else if([methodName isEqualToString:@"getGroupImage"]){
        [SVProgressHUD dismiss];

        NSError *error;
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        
        NSData *jsonData = [encString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        //NSLog(@"jsondic : %@", jsonDic);
        
        NSString *introBgPath = [NSString urlDecodeString:[jsonDic objectForKey:@"INTRO_IMG_SRC"]];
        NSString *loginBgPath = [NSString urlDecodeString:[jsonDic objectForKey:@"LOGIN_IMG_SRC"]];
        //NSString *introBgPath = @"https://dev.hhi.co.kr:44175/mfinity/upload/theme/bg.png";
        //NSString *loginBgPath = @"https://dev.hhi.co.kr:44175/mfinity/upload/theme/bg.png";
        
        appDelegate.introImagePath = introBgPath;
        appDelegate.loginImagePath = loginBgPath;
        
        NSLog(@"## saveFile documentPath : %@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *compDocFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
        if (![fileManager isReadableFileAtPath:compDocFolder]) {
            [fileManager createDirectoryAtPath:compDocFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *photoFolder = @"icon";
        NSString *iconSaveFolder = [compDocFolder stringByAppendingFormat:@"/%@",photoFolder];
        
        BOOL issue = [fileManager isReadableFileAtPath:iconSaveFolder];
        if (!issue) {
            [fileManager createDirectoryAtPath:iconSaveFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }

        NSString *introBgFilename = [appDelegate.introImagePath lastPathComponent];
        NSString *loginImageFilename = [appDelegate.loginImagePath lastPathComponent];
        
        NSString *loginBgfilePath = [iconSaveFolder stringByAppendingPathComponent:loginImageFilename];
        NSString *introfilePath = [iconSaveFolder stringByAppendingPathComponent:introBgFilename];
        
        UIImage *introImage = [UIImage imageWithContentsOfFile:introfilePath];
        UIImage *loginBgImage = [UIImage imageWithContentsOfFile:loginBgfilePath];
        
        NSData *data=nil;
        NSData *encryptData = nil;
        if (![fileManager isReadableFileAtPath:introfilePath]||![fileManager isReadableFileAtPath:loginBgfilePath]) {
            NSLog(@"## downloading");
            
            introImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.introImagePath]]];
            data = [NSData dataWithData:UIImagePNGRepresentation(introImage)];
            encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
            [encryptData writeToFile:introfilePath atomically:YES];
            
            loginBgImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:appDelegate.loginImagePath]]];
            data = [NSData dataWithData:UIImagePNGRepresentation(loginBgImage)];
            encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
            [encryptData writeToFile:loginBgfilePath atomically:YES];
        }

        appDelegate.loginImagePath = loginBgfilePath;
        appDelegate.introImagePath = introfilePath;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:introfilePath forKey:@"IntroImagePath"];
        [prefs setObject:loginBgfilePath forKey:@"LoginImagePath"];
        NSLog(@"## loginBgfilePath : %@",loginBgfilePath);
    
    } else if([methodName isEqualToString:@"userAuthLock"]){
//        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
//        NSLog(@"[userAuthLock] encString : %@",encString);
//
//        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
////        NSLog(@"[userAuthLock] dataDic : %@",[MFinityAppDelegate getAllValueUrlDecoding:dataDic]);
//
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[dataDic objectForKey:@"msg"] message:nil preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction * action) {
//                                                             [alert dismissViewControllerAnimated:YES completion:nil];
//                                                         }];
//        [alert addAction:okButton];
//        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)callGetGroupImage{
    NSString *urlString;
    NSData *paramData;
    NSString *paramString;
    
    urlString = [[NSString alloc] initWithFormat:@"%@/getGroupImage",appDelegate.main_url];
    paramString = [[NSString alloc]initWithFormat:@"cuser_no=%@&comp_no=%@&app_no=%@&dvcgubn=P",appDelegate.user_no,appDelegate.comp_no,appDelegate.app_no];
    
    paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableString *str = [NSMutableString stringWithString:urlString];
    
    NSRange range = [str rangeOfString:@" "];
    while (range.location !=NSNotFound) {
        [str replaceCharactersInRange:range withString:@"%20"];
        range = [str rangeOfString:@" "];
    }
    urlString = str;
    NSLog(@"getGroupImage urlString : %@",urlString);
    NSLog(@"getGroupImage paramString : %@",paramString);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    
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

#pragma mark
#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if ([alertView.message isEqualToString:NSLocalizedString(@"message6", @"")]) {
//		CertificateViewController *certView = [[CertificateViewController alloc] init];
//		[self.navigationController pushViewController:certView animated:YES];
//    }
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
//#ifdef DEBUG
//            [appDelegate.window setRootViewController:appDelegate.tabBarController];
//#else
//            [self enterWorkApp];
//#endif
            if(appDelegate.isMDM) [self enterWorkApp];
            else [appDelegate.window setRootViewController:appDelegate.tabBarController];
            
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


@end
