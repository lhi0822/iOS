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

//2018.06 UI개선
#define SIZEGAP 50

@interface CertificateViewController (){


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
    
    //2018.06 UI개선
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    
    if (screenHeight/screenWidth>1.5) {
        [compNoField setFrame:CGRectMake(compNoField.frame.origin.x
                                      , compNoField.frame.origin.y+SIZEGAP,
                                      compNoField.frame.size.width,
                                      compNoField.frame.size.height)];
        [certField setFrame:CGRectMake(certField.frame.origin.x
                                         , certField.frame.origin.y+SIZEGAP,
                                         certField.frame.size.width,
                                         certField.frame.size.height)];
        [btnCert setFrame:CGRectMake(btnCert.frame.origin.x
                                         , btnCert.frame.origin.y+SIZEGAP,
                                         btnCert.frame.size.width,
                                         btnCert.frame.size.height)];
        [label3 setFrame:CGRectMake(label3.frame.origin.x,
                                    label3.frame.origin.y+SIZEGAP,
                                    label3.frame.size.width,
                                    label3.frame.size.height)];
        [infoIcon setFrame:CGRectMake(infoIcon.frame.origin.x,
                                    infoIcon.frame.origin.y+SIZEGAP,
                                    infoIcon.frame.size.width,
                                    infoIcon.frame.size.height)];
    }
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *path = [prefs stringForKey:@"LoginImagePath"];
    NSData *decryptData = [[NSData dataWithContentsOfFile:path] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    if (bgImage==nil) {
        //2018.06 UI개선
        imageView.image = [UIImage imageNamed:@"login.png"];
    }else{
        imageView.image = bgImage;
    }
    
    if ([prefs objectForKey:@"LOGINONCOLOR"]==nil) {
        btnCert.backgroundColor = [UIColor blackColor];
    }else{
        btnCert.backgroundColor = [MFinityAppDelegate myRGBfromHex:[prefs objectForKey:@"LOGINONCOLOR"]];
    }
    //2018.06 UI개선
    btnCert.backgroundColor = [appDelegate myRGBfromHex:@"0093d5"];
    btnCert.layer.cornerRadius = btnCert.frame.size.width/30;
    btnCert.clipsToBounds = YES;
    
    if ([prefs objectForKey:@"MAINFONTCOLOR"]==nil) {
        label3.textColor = [UIColor whiteColor];
    }else{
        label3.textColor = [MFinityAppDelegate myRGBfromHex:[prefs objectForKey:@"MAINFONTCOLOR"]];
    }
    
    //imageView.image = [UIImage imageNamed:@"bg.png"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"message59", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(closeEvent)];
    self.navigationItem.title = NSLocalizedString(@"message60", @"");
    label1.text = NSLocalizedString(@"message14", @"");
    label2.text = NSLocalizedString(@"message15", @"");
    label3.text = NSLocalizedString(@"message16", @"");
    [btnCert setTitle:NSLocalizedString(@"Authentication", @"Authentication") forState:UIControlStateNormal];
    certField.clearButtonMode = UITextFieldViewModeWhileEditing;
    compNoField.clearButtonMode = UITextFieldViewModeWhileEditing;
    certField.placeholder = NSLocalizedString(@"Authentication Code", @"");
    compNoField.placeholder = NSLocalizedString(@"Company No.", @"");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark Action Event Handler
-(IBAction) textFieldDoneEditing:(id)sender{
	[sender resignFirstResponder];
}
-(IBAction) certificator{
    
    //myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//myIndicator.center = CGPointMake(160, 240);
    int core = [self countCores];
    NSLog(@"core : %d",core);
    [certField resignFirstResponder];
	[compNoField resignFirstResponder];
	
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
    /*
     NSString *cpuType = [self isValue:@"armv7"];
     if ([cpuType isEqualToString:@"Y"]) {
     cpuType = @"armv7";
     }else {
     NSString *tempType = [self isValue:@"armv6"];
     if ([tempType isEqualToString:@"Y"]) {
     cpuType = @"armv6";
     }else{
     cpuType = @"null";
     }
     }
     */
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
    
    //ios13 업데이트에서 StatusBar Crash로 네트워크 체크로직 교체(190918)
    /*
    //NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    NSArray *subviews = nil;
    id statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    if ([statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        subviews = [[[statusBar valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    } else {
        subviews = [[statusBar valueForKey:@"foregroundView"] subviews];
    }
    
    NSNumber *dataNetworkItemView = nil;
    
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
		//totalSpace = ((totalSpace/1024)/1024)/1024;
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
	//NSString *dvcid = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString *dvcid = [MFinityAppDelegate getUUID];
    /*
     NSString *encodingID = [NSString encodeString:appDelegate._user_id];
     NSString *encodingPWD = [NSString encodeString:appDelegate._user_pw];
     encodingID = [encodingID urlEncodeUsingEncoding:NSUTF8StringEncoding];
     encodingPWD = [encodingPWD urlEncodeUsingEncoding:NSUTF8StringEncoding];
     */
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
    NSString *urlString;
    
    NSString *dvcMdlCd = [[UIDevice currentDevice] modelIdentifier];
    NSString *param;
    urlString = [[NSString alloc] initWithFormat:@"%@/ezUserCert3",appDelegate.main_url];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (appDelegate.isAES256) {
//        param = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&compNo=%@&certCode=%@&dvcId=%@&dvcgubn=P&dvcMdl=%@&dvcOS=%@&dvcOSVer=%@&tel_corp=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&cpu_type=%@&prod_corp=%@&resolution=%@&lte=%@&accelerometer=%@&gyroscope=%@&light=%@&magnet=%@&direction=%@&press=%@&proximity=%@&temperature=%@&gps=%@&still_cam=%@&front_cam=%@&voip=%@&telephony=%@&total_volume=%@&dvcMdlCd=%@&returnType=JSON&encType=AES256",encodingID, encodingPWD,
//                 compNoField.text,certField.text, [prefs objectForKey:@"UUID"],
//                 [[UIDevice currentDevice] modelName], osName, osVersion,carrierName,extra_ram,extra_total_volume,
//                 extra_usable_volume, usable_volume, appDelegate.appDeviceToken,isRooting,cpuType,production, resolution,
//                 isLTE, isAccelerometer, isGyroscope, isLightSensor, isMagnetometer, isDirection, isPress, isProximity,
//                 isTemperature, isGPS, isCamera, isFrontCamera, isVoip, isTelephony, totalVolume, dvcMdlCd];
        param = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&compNo=%@&certCode=%@&dvcId=%@&dvcgubn=P&dvcMdl=%@&dvcOS=%@&dvcOSVer=%@&tel_corp=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&cpu_type=%@&prod_corp=%@&resolution=%@&lte=%@&accelerometer=%@&gyroscope=%@&light=%@&magnet=%@&direction=%@&press=%@&proximity=%@&temperature=%@&gps=%@&still_cam=%@&front_cam=%@&voip=%@&telephony=%@&total_volume=%@&dvcMdlCd=%@&returnType=JSON&encType=AES256",encodingID, encodingPWD,
                 compNoField.text,certField.text, [prefs objectForKey:@"UUID"],
                 [[UIDevice currentDevice] modelName], osName, osVersion,carrierName,extra_ram,extra_total_volume,
                 extra_usable_volume, usable_volume, appDelegate.fcmToken,isRooting,cpuType,production, resolution,
                 isLTE, isAccelerometer, isGyroscope, isLightSensor, isMagnetometer, isDirection, isPress, isProximity,
                 isTemperature, isGPS, isCamera, isFrontCamera, isVoip, isTelephony, totalVolume, dvcMdlCd];
    }else{
//        param = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&compNo=%@&certCode=%@&dvcId=%@&dvcgubn=P&dvcMdl=%@&dvcOS=%@&dvcOSVer=%@&tel_corp=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&cpu_type=%@&prod_corp=%@&resolution=%@&lte=%@&accelerometer=%@&gyroscope=%@&light=%@&magnet=%@&direction=%@&press=%@&proximity=%@&temperature=%@&gps=%@&still_cam=%@&front_cam=%@&voip=%@&telephony=%@&total_volume=%@&dvcMdlCd=%@&returnType=JSON",encodingID, encodingPWD,
//                 compNoField.text,certField.text, [prefs objectForKey:@"UUID"],
//                 [[UIDevice currentDevice] modelName], osName, osVersion,carrierName,extra_ram,extra_total_volume,
//                 extra_usable_volume, usable_volume, appDelegate.appDeviceToken,isRooting,cpuType,production, resolution,
//                 isLTE, isAccelerometer, isGyroscope, isLightSensor, isMagnetometer, isDirection, isPress, isProximity,
//                 isTemperature, isGPS, isCamera, isFrontCamera, isVoip, isTelephony, totalVolume, dvcMdlCd];
        param = [[NSString alloc]initWithFormat:@"id=%@&pwd=%@&compNo=%@&certCode=%@&dvcId=%@&dvcgubn=P&dvcMdl=%@&dvcOS=%@&dvcOSVer=%@&tel_corp=%@&extra_ram=%@&extra_total_volume=%@&extra_usable_volume=%@&usable_volume=%@&push_1=%@&push_2=-&rooting=%@&cpu_type=%@&prod_corp=%@&resolution=%@&lte=%@&accelerometer=%@&gyroscope=%@&light=%@&magnet=%@&direction=%@&press=%@&proximity=%@&temperature=%@&gps=%@&still_cam=%@&front_cam=%@&voip=%@&telephony=%@&total_volume=%@&dvcMdlCd=%@&returnType=JSON",encodingID, encodingPWD,
                 compNoField.text,certField.text, [prefs objectForKey:@"UUID"],
                 [[UIDevice currentDevice] modelName], osName, osVersion,carrierName,extra_ram,extra_total_volume,
                 extra_usable_volume, usable_volume, appDelegate.fcmToken,isRooting,cpuType,production, resolution,
                 isLTE, isAccelerometer, isGyroscope, isLightSensor, isMagnetometer, isDirection, isPress, isProximity,
                 isTemperature, isGPS, isCamera, isFrontCamera, isVoip, isTelephony, totalVolume, dvcMdlCd];
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
        [request setTimeoutInterval:10.0];
        NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if(urlCon){
            [SVProgressHUD show];
            receiveData = [[NSMutableData alloc]init];
        }else {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        }
	}
}
- (void) closeEvent
{
	exit(0);
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
    //[myIndicator stopAnimating];
    [SVProgressHUD dismiss];
    //myIndicator.hidesWhenStopped =YES;
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
        if(appDelegate.isMDM){
            appDelegate.mdmCallAPI = @"exitWorkApp";
            [MFinityAppDelegate exitWorkApp];
        } else {
            exit(0);
        }
        
    }else{
        if(statusCode == 404 || statusCode == 500){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
            //[myIndicator stopAnimating];
            //myIndicator.hidesWhenStopped =YES;
            [SVProgressHUD dismiss];
            [connection cancel];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
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
    } else{
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
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }
        
        if ([[[dic objectForKey:[NSString stringWithFormat:@"%d",0]]objectForKey:@"V0"]isEqualToString:@"True"]) {
            //NSLog(@"session true");
            NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            save = [save stringByAppendingPathComponent:appDelegate.comp_no];
            save = [save stringByAppendingFormat:@"/getOffLineMenuList"];
            
            [offLineData writeToFile:save atomically:YES];
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }
    }else if([methodName isEqualToString:@"ezUserCert3"]){
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
        //NSLog(@"cert result : %@",result);
        
        //그룹사수정
        [self callGetGroupImage];
        
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
            
            if([prefs objectForKey:@"DEVICE_ID"]==nil||[[prefs objectForKey:@"DEVICE_ID"]isEqual:@""]){
//                NSString *dvcid = [MFinityAppDelegate getUUID];
                [prefs setObject:[prefs objectForKey:@"UUID"] forKey:@"DEVICE_ID"];
                [prefs synchronize];
            }
            
            if(appDelegate.useAutoLogin){
                if(appDelegate.setFirstLogin&&[[prefs objectForKey:@"isAutoLogin"] isEqualToString:@"1"]){
                    NSLog(@"인증) 자동 로그인 실행");
                    NSDate *today = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSString *todayStr = [dateFormatter stringFromDate:today];
                    [prefs setObject:todayStr forKey:@"AUTO_LOGIN_DATE"];
                }
                
//                NSLog(@"인증) 로그인성공 userid : %@, pwd : %@", appDelegate.user_id, appDelegate.passWord);
                [prefs setObject:appDelegate.user_id forKey:@"AutoLogin_ID"];
                [prefs setObject:appDelegate.passWord forKey:@"AutoLogin_PWD"];
                [prefs synchronize];
            }
            
            BOOL isSave = [super saveFile];
            if (isSave) {
                if([[prefs objectForKey:@"OFFLINE_FLAG"] isEqualToString:@"Y"]){
                    NSString *offLineMenuURL = [NSString stringWithFormat:@"%@/getOfflineMenuList",appDelegate.main_url];
                    NSString *param;
                    if (appDelegate.isAES256) {
                        param = [[NSString alloc]initWithFormat:@"usrNo=%@&appNo=%@&devOs=I&devTy=P&returnType=JSON&encType=AES256",appDelegate.user_no,appDelegate.app_no];
                    }else{
                        param = [[NSString alloc]initWithFormat:@"usrNo=%@&appNo=%@&devOs=I&devTy=P&returnType=JSON",appDelegate.user_no,appDelegate.app_no];
                    }
                    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:offLineMenuURL]];
                    [request setHTTPMethod:@"POST"];
                    [request setHTTPBody: postData];
                    [request setTimeoutInterval:10.0];
                    NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    if(urlCon){
                        offLineData = [[NSMutableData alloc] init];
                    }else {
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
                    }
                }
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
    } else if([methodName isEqualToString:@"getGroupImage"]){
        [SVProgressHUD dismiss];
        
        NSError *error;
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        
        NSData *jsonData = [encString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"jsondic : %@", jsonDic);
        
        NSString *introBgPath = [NSString urlDecodeString:[jsonDic objectForKey:@"INTRO_IMG_SRC"]];
        NSString *loginBgPath = [NSString urlDecodeString:[jsonDic objectForKey:@"LOGIN_IMG_SRC"]];
        
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
        
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
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
