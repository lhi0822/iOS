//
//  CertificateViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 19..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "CertificateViewController.h"
#import "UIDevice-Hardware.h"
#import "UIDevice-Capabilities.h"
#import <sys/utsname.h>
#include <sys/param.h>
#include <sys/mount.h>
#import <mach/mach.h>

#import <mach/mach_host.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreMotion/CoreMotion.h>

#import <dlfcn.h>
#import <mach/port.h>
#import <mach/kern_return.h>

#import "UIDevice+IdentifierAddition.h"
#import "FBEncryptorAES.h"
#import "MFinityAppDelegate.h"
#import "SVProgressHUD.h"

@interface CertificateViewController (){
    BOOL isTextEnable;

}

@end

@implementation CertificateViewController

- (int) countCores
{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info( mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount ) ;
    
    return hostInfo.max_cpus ;
}

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewCertKey:) name:@"noti_NewCertKey" object:nil];
    isTextEnable = NO;
    
    _logoView.image = [UIImage imageNamed:@"logo.png"];
    imageView.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"LOGINONCOLOR"]==nil) {
        btnCert.backgroundColor = [UIColor blackColor];
    }else{
        btnCert.backgroundColor = [MFinityAppDelegate myRGBfromHex:[prefs objectForKey:@"LOGINONCOLOR"]];
    }
    if ([prefs objectForKey:@"MAINFONTCOLOR"]==nil) {
        label3.textColor = [UIColor whiteColor];
    }else{
        label3.textColor = [MFinityAppDelegate myRGBfromHex:[prefs objectForKey:@"MAINFONTCOLOR"]];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"message59", @"") style:UIBarButtonItemStylePlain target:self action:@selector(closeEvent)];
    self.navigationItem.title = NSLocalizedString(@"message60", @"");
    label1.text = NSLocalizedString(@"message14", @"");
    label2.text = NSLocalizedString(@"message15", @"");
    label3.text = NSLocalizedString(@"message16", @"");
    
    [btnCert setTitle:@"인증요청" forState:UIControlStateNormal];
    
    compNoField.clearButtonMode = UITextFieldViewModeWhileEditing;
    certField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    compNoField.delegate = self;
    certField.delegate = self;
    
    UIView *paddingView1 =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 35)];
    compNoField.leftView = paddingView1;
    compNoField.leftViewMode = UITextFieldViewModeAlways;

    UIView *paddingView2 =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 35)];
    certField.leftView = paddingView2;
    certField.leftViewMode = UITextFieldViewModeAlways;
    
    compNoField.backgroundColor = [appDelegate myRGBfromHex:appDelegate.cBgColor];
    certField.backgroundColor = [appDelegate myRGBfromHex:appDelegate.cBgColor];
    
    btnCert.backgroundColor = [appDelegate myRGBfromHex:@"0B57A0"];
    
    [compNoField setFrame:CGRectMake(compNoField.frame.origin.x, compNoField.frame.origin.y, compNoField.frame.size.width, 50)];
    [certField setFrame:CGRectMake(certField.frame.origin.x, certField.frame.origin.y, certField.frame.size.width, 50)];
    [btnCert setFrame:CGRectMake(btnCert.frame.origin.x, btnCert.frame.origin.y, btnCert.frame.size.width, 50)];
    
    //cornerRadius사용 시 textField 테두리 선이 끊겨서 흰색으로 선을 덮음
    compNoField.layer.cornerRadius = compNoField.frame.size.width/15;
    compNoField.layer.borderWidth = 0.5;
    compNoField.layer.borderColor = [UIColor whiteColor].CGColor;
    compNoField.clipsToBounds = YES;
    
    certField.layer.cornerRadius = certField.frame.size.width/15;
    certField.layer.borderWidth = 0.5;
    certField.layer.borderColor = [UIColor whiteColor].CGColor;
    certField.clipsToBounds = YES;
    
    btnCert.layer.cornerRadius = btnCert.frame.size.width/15;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark Action Event Handler
-(IBAction) textFieldDoneEditing:(id)sender{
    NSLog(@"%s",__func__);
//	[sender resignFirstResponder];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(!isTextEnable){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"인증요청 버튼을 눌러주세요. 자동으로 인증을 진행합니다.", @"인증요청 버튼을 눌러주세요. 자동으로 인증을 진행합니다.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
        
    } else {
        return YES;
    }
}

-(IBAction) certificator{
    if(isTextEnable) [self callUserCert];
    else [self callPushCert];
}
- (void) closeEvent
{
    SSLVPNConnect *vpn = [[SSLVPNConnect alloc] init];
    [vpn stopTunnel];
	exit(0);
}

-(void)callUserCert{
    int core = [self countCores];
    NSLog(@"core : %d",core);
    
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *osName = @"iOS";
    NSString *osVersion = myDevice.systemVersion;
    
    // 통신사
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    // Get carrier name
    NSString *carrierName = [carrier carrierName];
    
    //모델 명
    //NSString *modelName = [[UIDevice currentDevice] modelName];
    //가져올수 있는 목록
    //NSArray *deviceArray = [[UIDevice currentDevice]capabilityArray];
    //cpuType
    NSString *cpuType = @"-";

    //제조사
    NSString *production = @"Apple";
    
    //해상도
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    if ([self retinaDisplayCapable]) {
        screenHeight = screenHeight*2;
        screenWidth = screenWidth*2;
    }
    NSString *width = [NSString stringWithFormat:@"%f",screenWidth];
    width = [width stringByDeletingPathExtension];
    NSString *height = [NSString stringWithFormat:@"%f",screenHeight];
    height = [height stringByDeletingPathExtension];
    NSString *resolution = [width stringByAppendingString:@"*"];
    resolution = [resolution stringByAppendingString:height];
    
    //LTE
    NSString *isLTE = @"-";
    if([[MFinityAppDelegate deviceNetworkingType] isEqualToString:@"LTE"]) isLTE = @"Y";
    
    //가속도 센서
    NSString *isAccelerometer = @"";
    if ([self accelerometerAvailable]) {
        isAccelerometer = @"Y";
    }else{
        isAccelerometer = @"N";
    }
    
    //g센서
    NSString *isGyroscope = @"";
    if ([self gyroscopeAvailable]) {
        isGyroscope = @"Y";
    }else{
        isGyroscope = @"N";
    }
    //주변광센서
    NSString *isLightSensor = @"N";
    
    //자기장센서
    
    NSString *isMagnetometer = @"";
    if ([self compassAvailable]) {
        isMagnetometer = @"Y";
    }else{
        isMagnetometer = @"N";
    }
    //방향센서
    NSString *isDirection = @"N";
    if ([self accelerometerAvailable]) {
        isDirection = @"Y";
    }else{
        isDirection = @"N";
    }
    //압력센서
    NSString *isPress = @"N";
    
    //근접센서
    //NSString *isProximity = [self isValue:@"proximity-sensor"];
    NSString *isProximity = @"";
    UIDevice *device = [UIDevice currentDevice];
    if(device.proximityMonitoringEnabled){
        isProximity = @"Y";
    }else{
        isProximity = @"N";
    }
    //온도센서
    NSString *isTemperature = @"N";
    
    //gps
    //NSString *isGPS = [self isValue:@"gps"];
    NSString *isGPS = @"";
    if ([self gpsAvailable]) {
        isGPS = @"Y";
    }else{
        isGPS = @"N";
    }
    //camera
    //NSString *isCamera = [self isValue:@"still-camera"];
    NSString *isCamera = @"";
    if ([self linearCameraAvailable]) {
        isCamera = @"Y";
    }else{
        isCamera = @"N";
    }
    //front_camera
    //NSString *isFrontCamera = [self isValue:@"front-facing-camera"];
    NSString *isFrontCamera = @"";
    if ([self frontCameraAvailable]) {
        isFrontCamera = @"Y";
    }else{
        isFrontCamera = @"N";
    }
    //인터넷전화
    //NSString *isVoip = [self isValue:@"voip"];
    NSString *isVoip = @"Y";
    
    //전화기 여부
    //NSString *isTelephony = [self isValue:@"telephony"];
    NSString *isTelephony = @"";
    if ([self canMakePhoneCalls]) {
        isTelephony = @"Y";
    }else{
        isTelephony = @"N";
    }
    //총 용량
    float totalSpace = 0.0f;
    NSString *totalVolume;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes floatValue];
        totalVolume = [NSString stringWithFormat:@"%0.0f",totalSpace];
    }
    
    NSString *capacity = [NSString stringWithFormat:@"%f",totalSpace];
    capacity = [capacity stringByDeletingPathExtension];
    
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
    float availableDisk;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    statfs([[path lastObject] cString], &tStats);
    availableDisk = (float)(tStats.f_bavail * tStats.f_bsize);
    NSString *usable_volume = [NSString stringWithFormat:@"%0.0f",availableDisk];

    userid = appDelegate.user_id;
    pwd = appDelegate.passWord;
    
    NSString *encodingID = [FBEncryptorAES encryptBase64String:appDelegate.user_id
                                                     keyString:appDelegate.AES256Key
                                                 separateLines:NO];
    
    NSString *encodingPWD = [FBEncryptorAES encryptBase64String:appDelegate.passWord
                                                      keyString:appDelegate.AES256Key
                                                  separateLines:NO];
    encodingID = [encodingID urlEncodeUsingEncoding:NSUTF8StringEncoding];
    encodingPWD = [encodingPWD urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    NSString *dvcMdlCd = [[UIDevice currentDevice] modelIdentifier];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/ezUserCert3",appDelegate.main_url];
//    NSString *param = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&compNo=%@&certCode=%@&dvcId=%@&dvcgubn=%@&dvcMdl=%@&dvcOS=%@&dvcOSVer=%@&tel_corp=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&cpu_type=%@&prod_corp=%@&resolution=%@&lte=%@&accelerometer=%@&gyroscope=%@&light=%@&magnet=%@&direction=%@&press=%@&proximity=%@&temperature=%@&gps=%@&still_cam=%@&front_cam=%@&voip=%@&telephony=%@&total_volume=%@&dvcMdlCd=%@&returnType=JSON",encodingID, encodingPWD,
//             compNoField.text,certField.text, [prefs objectForKey:@"UUID"],appDelegate.dvcGubn,
//             [[UIDevice currentDevice] modelName], osName, osVersion,carrierName,extra_ram,extra_total_volume,
//             extra_usable_volume, usable_volume, appDelegate.appDeviceToken,isRooting,cpuType,production, resolution,
//             isLTE, isAccelerometer, isGyroscope, isLightSensor, isMagnetometer, isDirection, isPress, isProximity,
//             isTemperature, isGPS, isCamera, isFrontCamera, isVoip, isTelephony, totalVolume, dvcMdlCd];
    NSString *param = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&compNo=%@&certCode=%@&dvcId=%@&dvcgubn=%@&dvcMdl=%@&dvcOS=%@&dvcOSVer=%@&tel_corp=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&cpu_type=%@&prod_corp=%@&resolution=%@&lte=%@&accelerometer=%@&gyroscope=%@&light=%@&magnet=%@&direction=%@&press=%@&proximity=%@&temperature=%@&gps=%@&still_cam=%@&front_cam=%@&voip=%@&telephony=%@&total_volume=%@&dvcMdlCd=%@&returnType=JSON",encodingID, encodingPWD,
             compNoField.text,certField.text, [prefs objectForKey:@"UUID"],appDelegate.dvcGubn,
             [[UIDevice currentDevice] modelName], osName, osVersion,carrierName,extra_ram,extra_total_volume,
             extra_usable_volume, usable_volume, appDelegate.fcmToken,isRooting,cpuType,production, resolution,
             isLTE, isAccelerometer, isGyroscope, isLightSensor, isMagnetometer, isDirection, isPress, isProximity,
             isTemperature, isGPS, isCamera, isFrontCamera, isVoip, isTelephony, totalVolume, dvcMdlCd];
    if (appDelegate.isAES256) {
        param = [param stringByAppendingString:@"&encType=AES256"];
        
    }
    
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableString *str = [NSMutableString stringWithString:urlString];
    NSRange range = [str rangeOfString:@" "];
    while (range.location != NSNotFound) {
        [str replaceCharactersInRange:range withString:@"%20"];
        range = [str rangeOfString:@" "];
    }
    urlString = str;
    NSLog(@"cert url : %@",urlString);
    if ([certField.text isEqualToString:@""]||[compNoField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message57", @"") message:NSLocalizedString(@"message61", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
    }else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: postData];
        [request setTimeoutInterval:30.0];
        NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if(urlCon){
            [SVProgressHUD show];
            receiveData = [[NSMutableData alloc]init];
        }else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        }
    }
}

-(void)callPushCert{
    userid = appDelegate.user_id;
    pwd = appDelegate.passWord;
    NSString *encodingID = [FBEncryptorAES encryptBase64String:appDelegate.user_id
                                                     keyString:appDelegate.AES256Key
                                                 separateLines:NO];
    encodingID = [encodingID urlEncodeUsingEncoding:NSUTF8StringEncoding];
    
    NSString *dvcid = [MFinityAppDelegate getUUID];
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/getNewCertKey",appDelegate.main_url];
//    NSString *param = [[NSString alloc]initWithFormat:@"id=%@&compNo=10&push_1=%@&push_2=-&dvcOS=iOS&dvcid=%@&dvcgubn=%@&returnType=JSON",encodingID, appDelegate.appDeviceToken, dvcid,appDelegate.dvcGubn];
    NSString *param = [[NSString alloc]initWithFormat:@"id=%@&compNo=10&push_1=%@&push_2=-&dvcOS=iOS&dvcid=%@&dvcgubn=%@&returnType=JSON",encodingID, appDelegate.fcmToken, dvcid,appDelegate.dvcGubn];
    if (appDelegate.isAES256) {
        param = [param stringByAppendingString:@"&encType=AES256"];
    }
    
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableString *str = [NSMutableString stringWithString:urlString];
    NSRange range = [str rangeOfString:@" "];
    while (range.location != NSNotFound) {
        [str replaceCharactersInRange:range withString:@"%20"];
        range = [str rangeOfString:@" "];
    }
    urlString = str;
    NSLog(@"getNewCertKey url : %@",urlString);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:30.0];
    NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(urlCon){
        [SVProgressHUD show];
        receiveData = [[NSMutableData alloc]init];
    }else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}

- (void)noti_NewCertKey:(NSNotification *)notification{
    @try{
        NSDictionary *userInfo = notification.userInfo;
        NSLog(@"userInfo : %@", userInfo);
        
        NSString *compNo = [userInfo objectForKey:@"COMP_NO"];
        NSString *authCode = [userInfo objectForKey:@"AUTH_CODE"];
        
        compNoField.text = compNo;
        certField.text = authCode;
        
        [self callUserCert];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark
#pragma mark Device information Utils

- (BOOL) canMakePhoneCalls
{
	return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
}

- (BOOL) gpsAvailable{
    return [CLLocationManager locationServicesEnabled];
}

- (BOOL) accelerometerAvailable{
    CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    BOOL accelerometer = motionManager.accelerometerAvailable;
    return accelerometer;
}

- (BOOL) gyroscopeAvailable
{
#ifdef __IPHONE_4_0
	CMMotionManager *motionManager = [[CMMotionManager alloc] init];
	BOOL gyroAvailable = motionManager.gyroAvailable;
	return gyroAvailable;
#else
	return NO;
#endif
	
}

- (BOOL) compassAvailable
{
	BOOL compassAvailable = NO;
	
#ifdef __IPHONE_3_0
	compassAvailable = [CLLocationManager headingAvailable];
#else
	CLLocationManager *cl = [[CLLocationManager alloc] init];
	compassAvailable = cl.headingAvailable;
	[cl release];
#endif
	
	return compassAvailable;
    
}

- (BOOL) retinaDisplayCapable
{
	int scale = 1.0;
	UIScreen *screen = [UIScreen mainScreen];
	if([screen respondsToSelector:@selector(scale)])
		scale = screen.scale;
	
	if(scale == 2.0f) return YES;
	else return NO;
}
- (BOOL) frontCameraAvailable
{
#ifdef __IPHONE_4_0
	return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
#else
	return NO;
#endif
    
	
}
- (BOOL) linearCameraAvailable
{
#ifdef __IPHONE_4_0
	return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
#else
	return NO;
#endif
    
	
}

- (BOOL) cameraFlashAvailable
{
#ifdef __IPHONE_4_0
	return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
#else
	return NO;
#endif
}
#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
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
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
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
    NSDictionary *dic;
    NSError *error;
    if([methodName isEqualToString:@"getNewCertKey"]){
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        
        NSError *error;
        
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        } else{
            decString = encString;
        }
        
        @try{
            if(decString!=nil&&![decString isEqualToString:@""]){
                NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                NSLog(@"getNewCertKey dataDic : %@", dataDic);
                
                NSString *v1 = [dataDic objectForKey:@"V1"];
                if(![[v1 lowercaseString] isEqualToString:@"true"]){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"인증 실패", @"인증 실패") message:NSLocalizedString(@"입력하여 시도해주세요.", @"입력하여 시도해주세요.") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                        isTextEnable = YES;
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                
                } else {
                    NSLog(@"getNewCertKey V1 is TRUE");
                    isTextEnable = YES;
                }
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"인증 실패", @"인증 실패") message:NSLocalizedString(@"인증값을 받아오는데 실패하였습니다. 입력하여 시도해주세요.", @"인증값을 받아오는데 실패하였습니다. 입력하여 시도해주세요.") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    isTextEnable = YES;
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } @catch(NSException *e){
            NSLog(@"getNewCertKey Exception : %@", e);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"인증 실패", @"인증 실패") message:NSLocalizedString(@"인증값을 받아오는데 실패하였습니다. 입력하여 시도해주세요.", @"인증값을 받아오는데 실패하였습니다. 입력하여 시도해주세요.") preferredStyle:UIAlertControllerStyleAlert];
           UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인") style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
               isTextEnable = YES;
                                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                            }];
           [alert addAction:okButton];
           [self presentViewController:alert animated:YES completion:nil];
        }
        
    }else if([methodName isEqualToString:@"ezUserCert3"]){
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        NSError *error;
        
        // if AES256
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        NSLog(@"dataDic : %@", dataDic);
        
        NSString *result = [super resultUserCheck:[MFinityAppDelegate getAllValueUrlDecoding:dataDic]];
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
            
            if(appDelegate.useAutoLogin){
                [prefs setObject:appDelegate.user_id forKey:@"AutoLogin_ID"];
                [prefs setObject:appDelegate.passWord forKey:@"AutoLogin_PWD"];
                [prefs synchronize];
            }
            
            BOOL isSave = [super saveFile];
            if (isSave) {
                [self updateApplication];
            }
        }else if([result isEqualToString:@"FAILED"]){
            
            if([failedMessage isEqualToString:@"CODE_ERROR"]){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message18", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                
            }else if ([failedMessage isEqualToString:@"COMP_NO_ERROR"]) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message19", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                
            }else {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message20", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
            }
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
        if ([[resultString uppercaseString] isEqualToString:@"SUCCEED"]) {
            [self syncAgent];
        }else{
            [self updateApplication];
        }
        
    }else if([methodName isEqualToString:@"PUSHID_UPDATE"]||[methodName isEqualToString:@"pushNotiUpdate"]){
        
    }else {
        NSLog(@"index : %d",index);
        NSLog(@"[readArray count] : %lu",(unsigned long)[readArray count]);
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}
#pragma mark
#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:NSLocalizedString(@"message54", @"알림")]) {
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
    }
}
#pragma mark
#pragma mark Certificate Utils

-(NSString *)isValue:(NSString *)name{
    NSArray *deviceArray = [[UIDevice currentDevice]capabilityArray];
	int indexValue = [deviceArray indexOfObject:name];
	if (indexValue < [deviceArray count]) {
		return @"Y";
	}else {
		return @"N";
	}
}



@end
