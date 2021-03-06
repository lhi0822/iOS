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
@interface LoginViewController (){
    NSString *cpuType;
    NSString *production;
    NSString *resolution;
    NSString *isLTE;
    NSString *isAccelerometer;
    NSString *isGyroscope;
    NSString *isLightSensor;
    NSString *isMagnetometer;
    NSString *isDirection;
    NSString *isPress;
    NSString *isProximity;
    NSString *isTemperature;
    NSString *isGPS;
    NSString *isCamera;
    NSString *isFrontCamera;
    NSString *isVoip;
    NSString *isTelephony;
    NSString *totalVolume;
    
    NSString *autoLoginStatus; //valid:유효/expire:만료/none:자동로그인X
}

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
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


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%s",__FUNCTION__);
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    isHideKeyboard = YES;
    
    autoLoginStatus = @"";
    
    txtID.text = [prefs stringForKey:@"UserInfo_ID"];
    
    //[prefs setObject:@"2019-08-30" forKey:@"AUTO_LOGIN_DATE"];
    //[prefs synchronize];
    
    if(appDelegate.useAutoLogin){
        [autoLogin setHidden:NO];
        [autoLoginLbl setHidden:NO];
        
        NSLog(@"[prefs objectForKey: isAutoLogin] : %@", [prefs objectForKey:@"isAutoLogin"]);
        if ([[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]&&[prefs objectForKey:@"AUTO_LOGIN_DATE"]!=nil) {
            
            //2019-10-10 자동로그인 기한 사용안함
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
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(Login) userInfo:nil repeats:NO];
            
            /*
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
            NSLog(@"date : %ld", (long)date);
            
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
                [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Login) userInfo:nil repeats:NO];
                
            } else {
                autoLoginStatus = @"expire";
                //만료
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message54", @"message54") message:NSLocalizedString(@"message171", @"message171") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:okButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                [prefs setObject:@"0" forKey:@"isAutoLogin"];
                [prefs synchronize];
            }
             */
        } else {
            autoLoginStatus = @"none";
        }
    } else {
        [autoLogin setHidden:YES];
        [autoLoginLbl setHidden:YES];

    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    [txtID setAutocorrectionType:UITextAutocorrectionTypeNo];
    [txtPWD setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    btnLogin.layer.cornerRadius = btnLogin.frame.size.width/15;
    
    if (screenHeight/screenWidth>1.5) {
        [btnLogin setFrame:CGRectMake(btnLogin.frame.origin.x
                                      , btnLogin.frame.origin.y+SIZEGAP,
                                      btnLogin.frame.size.width,
                                      btnLogin.frame.size.height)];
        [label3 setFrame:CGRectMake(label3.frame.origin.x,
                                    label3.frame.origin.y+SIZEGAP,
                                    label3.frame.size.width,
                                    label3.frame.size.height)];
        [label5 setFrame:CGRectMake(label5.frame.origin.x,
                                    label5.frame.origin.y+SIZEGAP,
                                    label5.frame.size.width,
                                    label5.frame.size.height)];
        [txtID setFrame:CGRectMake(txtID.frame.origin.x,
                                   txtID.frame.origin.y+SIZEGAP,
                                   txtID.frame.size.width,
                                   txtID.frame.size.height)];
        [txtPWD setFrame:CGRectMake(txtPWD.frame.origin.x,
                                    txtPWD.frame.origin.y+SIZEGAP,
                                    txtPWD.frame.size.width,
                                    txtPWD.frame.size.height)];
        [saveID setFrame:CGRectMake(saveID.frame.origin.x,
                                    saveID.frame.origin.y+SIZEGAP,
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
        [autoLogin setFrame:CGRectMake(autoLogin.frame.origin.x,
                                    autoLogin.frame.origin.y+SIZEGAP,
                                    autoLogin.frame.size.width,
                                    autoLogin.frame.size.height)];
        [autoLoginLbl setFrame:CGRectMake(autoLoginLbl.frame.origin.x,
                                    autoLoginLbl.frame.origin.y+SIZEGAP,
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
    
    versionLabel.text = [NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    //mainType = [[NSString alloc]initWithFormat:@""];
    txtID.delegate = self;
    txtPWD.delegate = self;
    
    NSString *path = [prefs stringForKey:@"LoginImagePath"];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSData *decryptData = [[NSData dataWithContentsOfFile:path] AES256DecryptWithKey:appDelegate.AES256Key];
    
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    label1.text = NSLocalizedString(@"message85", @"");
    label2.text = NSLocalizedString(@"message86", @"");
    label3.text = NSLocalizedString(@"message87", @"");
    
    
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
        left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"", @"") style:UIBarButtonItemStylePlain target:self action:@selector(backEvent:)];
        
    }else{
        
        left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(backEvent:)];
        
    }
    
    self.navigationItem.backBarButtonItem = left;
    
    txtID.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPWD.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    if ( [[prefs stringForKey:@"isSave"] isEqualToString:@"1"] ) {
        isSaveId = YES;
        [saveID setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    } else {
        isSaveId = NO;
        [saveID setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    }
    
    if ([[prefs stringForKey:@"isAutoLogin"] isEqualToString:@"1"] ) {
           isAutoLogin = YES;
           [autoLogin setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
           
       } else {
           isAutoLogin = NO;
           [autoLogin setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
       }
    
    txtPWD.returnKeyType = UIReturnKeyJoin;
    
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
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

- (IBAction)autoLoginButton:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (isAutoLogin) {
        isAutoLogin = NO;
        [autoLogin setBackgroundImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
        [prefs setObject:@"0" forKey:@"isAutoLogin"];
        
    } else {
        isAutoLogin = YES;
        [autoLogin setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        [prefs setObject:@"1" forKey:@"isAutoLogin"];
        
    }
    [prefs synchronize];
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
        
        NSLog(@"autoLoginStatus : %@", autoLoginStatus);
        NSLog(@"AUTO_LOGIN_DATE : %@", [prefs objectForKey:@"AUTO_LOGIN_DATE"]);
        
        NSUserDefaults *userInfo= [NSUserDefaults standardUserDefaults];
        [txtID resignFirstResponder];
        [txtPWD resignFirstResponder];
        myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        myIndicator.center = CGPointMake(160, 240);
        
        userid = txtID.text;
        pwd = txtPWD.text;
        
        NSLog(@"pwd : %@", pwd);
        
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
                    pwd = txtPWD.text;
                    NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
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
                        
                        [self updateApplication];
                        
                    }else if([result isEqualToString:@"FAILED"]){
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
            
            NSString *GUID = nil;
            //아이디 저장
            if (isSaveId) {
                [userInfo setObject:userid forKey:@"UserInfo_ID"];
                [userInfo setObject:@"1" forKey:@"isSave"];
            } else {
                [userInfo setObject:@"" forKey:@"UserInfo_ID"];
                [userInfo setObject:@"0" forKey:@"isSave"];
            }
            if (![userInfo stringForKey:@"uuid"]) {
                CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
                //GUID = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
                GUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
                [userInfo setObject:GUID forKey:@"uuid"];
            }else {
                GUID = [userInfo stringForKey:@"uuid"];
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
            NSString *isRooting = [MFinityAppDelegate isRooted]?@"YES":@"NO";
            
            [self getDeviceInfo];

            //if aes 256
            NSString *encodingID = [FBEncryptorAES encryptBase64String:userid
                                                             keyString:appDelegate.AES256Key
                                                         separateLines:NO];
            
            NSString *encodingPWD = [FBEncryptorAES encryptBase64String:pwd
                                                              keyString:appDelegate.AES256Key
                                                          separateLines:NO];
            
            encodingID = [encodingID urlEncodeUsingEncoding:NSUTF8StringEncoding];
            encodingPWD = [encodingPWD urlEncodeUsingEncoding:NSUTF8StringEncoding];
            
            //NSString *dvcid = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
            NSString *dvcid = [MFinityAppDelegate getUUID];
            //
            //NSString *dvcid = [OpenUDID value];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",[[prefs objectForKey:@"COMP_NO"] AES256DecryptWithKeyString:appDelegate.AES256Key]];
            
            NSPropertyListFormat format;
            NSDictionary *webappDic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
            NSString *MF_VER = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            NSString *urlString;
            NSData *paramData;
            NSString *paramString;
            
            NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            documents = [documents stringByAppendingPathComponent:@"10"];
            documents = [documents stringByAppendingPathComponent:@"webapp"];
            
            if (appDelegate.isAES256) {
                urlString = [[NSString alloc] initWithFormat:@"%@/ezLogin3",appDelegate.main_url];
                
//                paramString = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&dvcid=%@&dvcgubn=P&os_ver=%@&push_1=%@&dvcMdl=%@&rooting=%@&dvcOS=%@&RES_VER=%@&MF_VER=%@&returnType=JSON&encType=AES256",encodingID, encodingPWD, dvcid,osVersion,appDelegate.appDeviceToken,[[UIDevice currentDevice] modelName],isRooting,osName,[webappDic objectForKey:@"RES_VER"],MF_VER];
                paramString = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&dvcid=%@&dvcgubn=P&os_ver=%@&push_1=%@&dvcMdl=%@&rooting=%@&dvcOS=%@&RES_VER=%@&MF_VER=%@&returnType=JSON&encType=AES256",encodingID, encodingPWD, dvcid,osVersion,appDelegate.fcmToken,[[UIDevice currentDevice] modelName],isRooting,osName,[webappDic objectForKey:@"RES_VER"],MF_VER];
                
                paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"&tel_corp=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&cpu_type=%@&prod_corp=%@&resolution=%@&lte=%@&accelerometer=%@&gyroscope=%@&light=%@&magnet=%@&direction=%@&press=%@&proximity=%@&temperature=%@&gps=%@&still_cam=%@&front_cam=%@&voip=%@&telephony=%@&total_volume=%@",carrierName,extra_ram,extra_total_volume,extra_usable_volume,usable_volume,cpuType,production,resolution,isLTE, isAccelerometer, isGyroscope, isLightSensor, isMagnetometer, isDirection, isPress, isProximity,isTemperature, isGPS, isCamera, isFrontCamera, isVoip, isTelephony, totalVolume]];
                
                
            }else{
                urlString = [[NSString alloc] initWithFormat:@"%@/ezLogin3",appDelegate.main_url];
                
//                paramString = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&dvcid=%@&dvcgubn=P&os_ver=%@&push_1=%@&dvcMdl=%@&rooting=%@&dvcOS=%@&RES_VER=%@&MF_VER=%@&returnType=JSON&encType=AES256",encodingID, encodingPWD, dvcid,osVersion,appDelegate.appDeviceToken,[[UIDevice currentDevice] modelName],isRooting,osName,[webappDic objectForKey:@"RES_VER"],MF_VER];
                paramString = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&dvcid=%@&dvcgubn=P&os_ver=%@&push_1=%@&dvcMdl=%@&rooting=%@&dvcOS=%@&RES_VER=%@&MF_VER=%@&returnType=JSON&encType=AES256",encodingID, encodingPWD, dvcid,osVersion,appDelegate.fcmToken,[[UIDevice currentDevice] modelName],isRooting,osName,[webappDic objectForKey:@"RES_VER"],MF_VER];
                
                paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"&tel_corp=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&cpu_type=%@&prod_corp=%@&resolution=%@&lte=%@&accelerometer=%@&gyroscope=%@&light=%@&magnet=%@&direction=%@&press=%@&proximity=%@&temperature=%@&gps=%@&still_cam=%@&front_cam=%@&voip=%@&telephony=%@&total_volume=%@",carrierName,extra_ram,extra_total_volume,extra_usable_volume,usable_volume,cpuType,production,resolution,isLTE, isAccelerometer, isGyroscope, isLightSensor, isMagnetometer, isDirection, isPress, isProximity,isTemperature, isGPS, isCamera, isFrontCamera, isVoip, isTelephony, totalVolume]];
            }
            
            paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSMutableString *str = [NSMutableString stringWithString:urlString];
            
            NSRange range = [str rangeOfString:@" "];
            while (range.location !=NSNotFound) {
                [str replaceCharactersInRange:range withString:@"%20"];
                range = [str rangeOfString:@" "];
            }
            urlString = str;
            NSLog(@"dvcid : %@",dvcid);
            NSLog(@"urlString : %@",urlString);
            NSLog(@"ezLogin3 paramString : %@",paramString);
            
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
    }else{
        
    }
}

-(void)getDeviceInfo{
    //cpuType
    cpuType = @"-";
    //제조사
    production = @"Apple";
    //해상도
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    if ([appDelegate retinaDisplayCapable]) {
        screenHeight = screenHeight*2;
        screenWidth = screenWidth*2;
    }
    NSString *width = [NSString stringWithFormat:@"%f",screenWidth];
    width = [width stringByDeletingPathExtension];
    NSString *height = [NSString stringWithFormat:@"%f",screenHeight];
    height = [height stringByDeletingPathExtension];
    resolution = [width stringByAppendingString:@"*"];
    resolution = [resolution stringByAppendingString:height];
    
    //LTE
    isLTE = @"-";
    if([[MFinityAppDelegate deviceNetworkingType] isEqualToString:@"LTE"]) isLTE = @"Y";
    
    /*
    //ios13 업데이트에서 StatusBar Crash로 네트워크 체크로직 교체(190918)
    NSNumber *dataNetworkItemView = nil;
    
    NSArray *subviews = nil;
    id statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    NSLog(@"##### statusBar : %@", statusBar);
    NSLog(@"##### statusBar22 : %@", [statusBar class]);
    //##### statusBar : <UIStatusBar_Placeholder: 0x12bc1f860; frame = (0 0; 375 44); autoresize = W+BM; layer = <CALayer: 0x28211c820>>

    if ([statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        subviews = [[[statusBar valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];

    } else if([statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Placeholder")]){
        NSLog(@"여기다!!!");
        NSLog(@"statusBar valueForKey : %@", [statusBar valueForKey:@"statusBarWindow"]);
        //subviews = [[[statusBar valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];

    } else {
        subviews = [[statusBar valueForKey:@"foregroundView"] subviews];
    }
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    switch ([[dataNetworkItemView valueForKey:@"dataNetworkType"]integerValue]) {
        case 0:
            NSLog(@"No wifi or cellular");
            break;
            
        case 1:
            NSLog(@"2G");
            break;
            
        case 2:
            NSLog(@"3G");
            break;
            
        case 3:
            NSLog(@"4G");
            break;
            
        case 4:
            isLTE = @"Y";
            NSLog(@"LTE");
            break;
            
        case 5:
            NSLog(@"Wifi");
            break;
            
        default:
            break;
    }
    */
    
    //가속도 센서
    isAccelerometer = @"";
    if ([appDelegate accelerometerAvailable]) {
        isAccelerometer = @"Y";
    }else{
        isAccelerometer = @"N";
    }
    //g센서
    isGyroscope = @"";
    if ([appDelegate gyroscopeAvailable]) {
        isGyroscope = @"Y";
    }else{
        isGyroscope = @"N";
    }
    //주변광센서
    isLightSensor = @"N";
    
    //자기장센서
    isMagnetometer = @"";
    if ([appDelegate compassAvailable]) {
        isMagnetometer = @"Y";
    }else{
        isMagnetometer = @"N";
    }
    //방향센서
    isDirection = @"N";
    if ([appDelegate accelerometerAvailable]) {
        isDirection = @"Y";
    }else{
        isDirection = @"N";
    }
    //압력센서
    isPress = @"N";
    
    //근접센서
    isProximity = @"";
    UIDevice *device = [UIDevice currentDevice];
    if(device.proximityMonitoringEnabled){
        isProximity = @"Y";
    }else{
        isProximity = @"N";
    }
    //온도센서
    isTemperature = @"N";
    
    //gps
    isGPS = @"";
    if ([appDelegate gpsAvailable]) {
        isGPS = @"Y";
    }else{
        isGPS = @"N";
    }
    //camera
    isCamera = @"";
    if ([appDelegate linearCameraAvailable]) {
        isCamera = @"Y";
    }else{
        isCamera = @"N";
    }
    //front_camera
    isFrontCamera = @"";
    if ([appDelegate frontCameraAvailable]) {
        isFrontCamera = @"Y";
    }else{
        isFrontCamera = @"N";
    }
    //인터넷전화
    isVoip = @"Y";
    
    //전화기 여부
    isTelephony = @"";
    if ([appDelegate canMakePhoneCalls]) {
        isTelephony = @"Y";
    }else{
        isTelephony = @"N";
    }
    //총 용량
    float totalSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        totalVolume = [NSString stringWithFormat:@"%0.0f",totalSpace];
        //totalSpace = ((totalSpace/1024)/1024)/1024;
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
    
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    if([methodName isEqualToString:@"getOfflineMenuList"]){
        [offLineData appendData:data];
    } else {
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
            } else{
                decString = encString;
            }
            dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
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
        
        if ([result isEqualToString:@"SUCCEED"]) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            if([prefs objectForKey:@"FCM_TOKEN"]==nil || ![appDelegate.fcmToken isEqualToString:[prefs objectForKey:@"FCM_TOKEN"]]){
                NSLog(@"FCM 키가 없거나 다름 ! \nappDelegate.fcmToken : %@ \nFCM_TOKEN : %@", appDelegate.fcmToken, [prefs objectForKey:@"FCM_TOKEN"]);
                [prefs setObject:appDelegate.fcmToken forKey:@"FCM_TOKEN"];
                [prefs synchronize];

                NSString *urlString = [[NSString alloc] initWithFormat:@"%@/PUSHID_UPDATE",appDelegate.main_url];
                NSString *paramString = [[NSString alloc]initWithFormat:@"cuserno=%@&dvcos=iOS&dvcid=%@&pushid1=%@&pushid2=-",appDelegate.user_no, [MFinityAppDelegate getUUID], appDelegate.fcmToken];
                NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                
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
            
            if([prefs objectForKey:@"PushNoti"]==nil){
                [prefs setObject:@"YES" forKey:@"PushNoti"];
                [prefs synchronize];
                
                NSString *urlString = [[NSString alloc] initWithFormat:@"%@/pushNotiUpdate",appDelegate.main_url];
                NSString *paramString = [[NSString alloc]initWithFormat:@"cuserno=%@&dvcid=%@&pushflag=Y",appDelegate.user_no, [MFinityAppDelegate getUUID]];
                
                NSLog(@"urlString : %@", urlString);
                NSLog(@"paramString : %@", paramString);
                
                NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

                NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody: paramData];
                [request setTimeoutInterval:30.0];
                NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                if (urlCon) {
                    receiveData = [[NSMutableData alloc]init];
                }
            }
            
            if(appDelegate.useAutoLogin){
                if([[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]){
                    NSLog(@"자동 로그인@@@@@@@@@@@@@@@");
                    NSDate *today = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSString *todayStr = [dateFormatter stringFromDate:today];
                    [prefs setObject:todayStr forKey:@"AUTO_LOGIN_DATE"];
                }
                
                NSLog(@"로그인성공 userid : %@, pwd : %@", txtID.text, txtPWD.text);
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
                    NSLog(@"getOfflineMenuList parameter : %@",paramString);
                    NSData *postData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:offLineMenuURL]];
                    [urlRequest setHTTPMethod:@"POST"];
                    [urlRequest setHTTPBody: postData];
                    [urlRequest setTimeoutInterval:30.0];
                    NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                    if(urlCon){
                        offLineData = [[NSMutableData alloc] init];
                    }else {
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
                    }
                }
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
        } else{
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
        
    } else if([methodName isEqualToString:@"PUSHID_UPDATE"]||[methodName isEqualToString:@"pushNotiUpdate"]){
        
    } else {
        if (index<=[readArray count]-1) {
            [self fileUpload:[readArray objectAtIndex:index++]];
        }else{
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
-(void)loginSuccess{
    
}
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
