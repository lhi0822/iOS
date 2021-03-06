//
//  LoginViewController.m
//  Anymate
//
//  Created by Kyeong In Park on 12. 12. 24..
//  Copyright (c) 2012년 Kyeong In Park. All rights reserved.
//

#import "LoginViewController.h"
#import "UrlSettingViewController.h"
#import "AppDelegate.h"
#import "CustomAlertView.h"
#import "WebViewController.h"
#import "UIDevice-Hardware.h"
#import "UIDevice+IdentifierAddition.h"
#import "CompanySelectViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "KeychainItemWrapper.h"
#import "RecoDefaults.h"
#import "BeaconManager_Reco.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface LoginViewController (){
    BeaconManager_Reco *bm;
//    BeaconManager_Minew *bm;
    BOOL isFirst;
}

@end

@implementation LoginViewController
@synthesize compDic;
@synthesize compCode;
@synthesize compName;
@synthesize progressView;
@synthesize indicatorView;
BOOL isLogin;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.model_nm = [[UIDevice currentDevice] modelName];
    
    UISegmentedControl *button = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"URL설정",nil]]autorelease];
    button.momentary = YES;
    [button addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventValueChanged];
    
    UISegmentedControl *button2 = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"회사설정",nil]]autorelease];
    button2.momentary = YES;
    [button2 addTarget:self action:@selector(right2BtnClick) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=right;
    self.navigationItem.leftBarButtonItem = right2;
    
    appDelegate.isLogout = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];
    self.compCode = @"";
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if (IS_OS_8_OR_LATER) {
        SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
            [locationManager respondsToSelector:requestSelector]) {
            [locationManager performSelector:requestSelector withObject:NULL];
        } else {
            [locationManager startUpdatingLocation];
        }
    }else{
        [locationManager startUpdatingLocation];
    }
        
//    locationManager.delegate = self;
//    locationManager.allowsBackgroundLocationUpdates = YES;
//    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [locationManager requestAlwaysAuthorization];
//    }
//    [locationManager startUpdatingLocation];
    
    idTextField.returnKeyType = UIReturnKeyNext;
    pwTextField.returnKeyType = UIReturnKeyDone;
    idTextFieldRect = idTextField.frame;
    pwTextFieldRect = pwTextField.frame;
    idLabelRect = idLabel.frame;
    pwLabelRect = pwLabel.frame;
    idSaveButtonRect = idSaveButton.frame;
    pwSaveButtonRect = pwSaveButton.frame;
    loginButtonRect = loginButton.frame;
    imageView.image = [UIImage imageNamed:@"bg_login.png"];
    loginButton.backgroundColor = [appDelegate myRGBfromHex:@"2D4260"];
    verLabel.text = [NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    NSLog(@"DEVICE_ID : %@",[prefs objectForKey:@"DEVICE_ID"]);
//    NSLog(@"DEVICE_TOKEN : %@",[prefs objectForKey:@"DEVICE_TOKEN"]);
    
    //테스트위해 초기화
//    [prefs setObject:nil forKey:@"LOGIN_DATE"];
//    [prefs synchronize];
    
    /*
//    wifi정보가져오기
    NSArray *interFaceNames = ( id)CNCopySupportedInterfaces();
    for (NSString *name in interFaceNames) {
        NSDictionary *info = ( id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)name);
//        NSLog(@"infoo : %@", info);
//        NSLog(@"wifi info: bssid: %@, ssid:%@, ssidData: %@", info[@"BSSID"], info[@"SSID"], info[@"SSIDDATA"]);
     }
    
//    NSLog(@"get ip : %@", [self getIPAddress]);
    
    NSString *publicIP = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://icanhazip.com/"] encoding:NSUTF8StringEncoding error:nil];
    publicIP = [publicIP stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]; // IP comes with a newline for some reason
//    NSLog(@"publicIP : %@", publicIP);
    
//    wifi연결
//    if (@available (iOS 11.0, *)) {
//        NEHotspotConfiguration * configuration = [[NEHotspotConfiguration alloc] initWithSSID:@"FeelData" passphrase:@"1234567890123" isWEP:NO];
//        configuration.joinOnce = YES;
//        [[NEHotspotConfigurationManager sharedManager] applyConfiguration: configuration completionHandler: ^ (NSError * _Nullable error) {
//            if (error == nil) {
//                NSLog (@ "Is Connected!!");
//            } else {
//                NSLog (@ "Error is: %@", error);
//            }
//        }];
//    } else {
//        NSLog (@ "This Device Not iOS 11 +");
//    }
     */
}
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    if (appDelegate.isLogout) {
        appDelegate.pushURL = @"";
    }
    
    int offset;
    NSString *imageName;
    
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    if ([appDelegate.model_nm isEqualToString:@"iPhone 5"]) {
        offset = 260;
        imageName = @"bg_login.png";
    }else{
        offset = 200;
        imageName = @"bg_login.png";
    }
    
    self.indicatorView.center = self.view.center;
    
    appDelegate.isLogin = NO;
    
    if (!appDelegate.isPush) {
        appDelegate.pushURL = @"";
    }
    
    self.indicatorView.center = self.view.center;
    self.navigationController.navigationBarHidden = NO;
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingString:@"/compInfo.plist"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.compDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    pwTextField.text = @"";
    
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:@"#19385b"]];
    if ([appDelegate.isSet isEqualToString:@"NO"]) {
        if (![fileManager isReadableFileAtPath:filePath]) {
            [self performSegueWithIdentifier:@"MODAL_URL_SETTING" sender:nil];
            
        }else{
            if ([prefs boolForKey:@"ID_SAVE"]) {
                NSArray *allKeys = [self.compDic allKeys];
                for (int i=0; i<[allKeys count]; i++) {
                    if ([[prefs objectForKey:@"COMP_NAME"]isEqualToString:[self.compDic objectForKey:[allKeys objectAtIndex:i]]]) {
                        self.compCode = [allKeys objectAtIndex:i];
                    }
                }
                
                [idSaveButton setBackgroundImage:[UIImage imageNamed:@"checkbox_over.png"] forState:UIControlStateNormal];
                isIdSave = YES;
                idTextField.text = [prefs objectForKey:@"ID"];
                self.compName = [prefs objectForKey:@"COMP_NAME"];
                self.navigationController.navigationBar.topItem.title = [prefs objectForKey:@"COMP_NAME"];
            }else{
                [idSaveButton setBackgroundImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
            }
            if ([prefs boolForKey:@"PW_SAVE"]) {
                [pwSaveButton setBackgroundImage:[UIImage imageNamed:@"checkbox_over.png"] forState:UIControlStateNormal];
                isPwSave = YES;
                pwTextField.text = [prefs objectForKey:@"PW"];
            }else{
                [pwSaveButton setBackgroundImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
            }
            
            isFirst = YES;
            if(!appDelegate.isLogout){
                NSString *_urlString = [NSString stringWithFormat:@"%@/m/main/?event=getBeacon&cpn_code=%@",[prefs objectForKey:@"URL"], self.compCode];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_urlString]];
                NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
                [urlConnection start];
            }
        }
        
    }else{
        if (self.compDic.count == 1) {
            self.compName = [self.compDic.allValues objectAtIndex:0];
            self.compCode = [self.compDic.allKeys objectAtIndex:0];
            self.navigationController.navigationBar.topItem.title = [self.compDic.allValues objectAtIndex:0];
        }else{
            self.compName = @"";
            self.navigationController.navigationBar.topItem.title = @"";
        }
        isPwSave = NO;
        isIdSave = NO;
        idTextField.text = @"";
        
        isFirst = YES;
        if(!appDelegate.isLogout){
            NSString *_urlString = [NSString stringWithFormat:@"%@/m/main/?event=getBeacon&cpn_code=%@",[prefs objectForKey:@"URL"], self.compCode];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_urlString]];
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            [urlConnection start];
        }
    }

}

- (void)keyboardWillAnimate:(NSNotification *)notification{
    if (isRotate) {
        CGRect keyboardBounds;
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
        NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        
        keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        if ([notification name]==UIKeyboardWillShowNotification) {
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 80, self.view.frame.size.width, self.view.frame.size.height)];
        }else if([notification name]==UIKeyboardWillHideNotification){
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 80,self.view.frame.size.width, self.view.frame.size.height)];
        }
        [UIView commitAnimations];
    }
    
}
- (void)applicationDidBecomeActive:(NSNotification *)notification{
    if([UIApplication sharedApplication].networkActivityIndicatorVisible){

    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}
- (void)applicationWillEnterForeground:(NSNotification *)notification{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
}
- (void)applicationDidEnterBackground:(NSNotification *)notification{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
}

-(void)rightBtnClick{
    [self performSegueWithIdentifier:@"MODAL_URL_SETTING" sender:nil];
}

-(void)right2BtnClick{
    CompanySelectViewController *vc = [[CompanySelectViewController alloc]init];
    vc.compDic = self.compDic;
    
    [self presentSemiViewController:vc withOptions:@{
                                                     KNSemiModalOptionKeys.pushParentBack : @(NO),
                                                     KNSemiModalOptionKeys.parentAlpha : @(0.5)
                                                     }];
}
- (void)usingData:(NSString *)compNm{
    
    self.navigationController.navigationBar.topItem.title = compNm;
    NSArray *allValues = [self.compDic allValues];
    NSArray *allKeys = [self.compDic allKeys];
    for (int i=0; i<[allValues count]; i++) {
        if ([compNm isEqualToString:[allValues objectAtIndex:i]]) {
            self.compCode = [allKeys objectAtIndex:i];
//            NSLog(@"self.compCode : %@", self.compCode);
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==111) {
        if (buttonIndex == 0) {
            self.navigationController.navigationBar.topItem.title = self.compName;
            NSArray *allValues = [self.compDic allValues];
            NSArray *allKeys = [self.compDic allKeys];
            for (int i=0; i<[allValues count]; i++) {
                if ([self.compName isEqualToString:[allValues objectAtIndex:i]]) {
                    self.compCode = [allKeys objectAtIndex:i];
                }
            }
        }
    }else if(alertView.tag==112){
        isLogin = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [indicatorView stopAnimating];
    }else if(alertView.tag==1001){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if(buttonIndex == 0){
            //설정안함
            [prefs setBool:YES forKey:@"IS_BEACON_SET"];
        }else{
            //확인
            [prefs setBool:NO forKey:@"IS_BEACON_SET"];
        }
        [prefs synchronize];
    }
}

- (IBAction)Login:(id)sender{
    appDelegate.isLogout = NO;
    isFirst = NO;
    if (!isLogin) {
        if ([idTextField.text isEqualToString:@""]){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"로그인 실패" message:@"ID를 입력해주세요." delegate:self cancelButtonTitle:@"확인" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
            
        }else if([pwTextField.text isEqualToString:@""]){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"로그인 실패" message:@"Password를 입력해주세요." delegate:self cancelButtonTitle:@"확인" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
        
        }else if([self.compCode isEqualToString:@""]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"로그인 실패" message:@"회사설정에서 회사를 선택해주세요." delegate:self cancelButtonTitle:@"확인" otherButtonTitles: nil];
            [alertView show];
            [alertView release];
        
        }else{
            isLogin = YES;
            self.indicatorView.center = loginButton.center;
            [self.indicatorView startAnimating];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
            [idTextField resignFirstResponder];
            [pwTextField resignFirstResponder];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setBool:isIdSave forKey:@"ID_SAVE"];
            [prefs setBool:isPwSave forKey:@"PW_SAVE"];
            if (isIdSave) {
                [prefs setObject:idTextField.text forKey:@"ID"];
                [prefs setObject:self.navigationItem.title forKey:@"COMP_NAME"];
            }
            if (isPwSave) {
                [prefs setObject:pwTextField.text forKey:@"PW"];
            }
            [prefs synchronize];
            
            NSString *_urlString = [NSString stringWithFormat:@"%@/m/main/",[prefs objectForKey:@"URL"]];
            
            NSString *model_nm = [[[UIDevice currentDevice] modelName] urlEncodeUsingEncoding:NSUTF8StringEncoding];
//            if (appDelegate.appDeviceToken == nil) {
//                appDelegate.appDeviceToken = @"";
//            }
            if (appDelegate.fcmToken == nil) {
                appDelegate.fcmToken = @"";
            }
            NSString *uuid = [self getUUID];

            NSString *encodeId = [idTextField.text urlEncodeUsingEncoding:NSUTF8StringEncoding];
            NSString *encodePwd = [pwTextField.text urlEncodeUsingEncoding:NSUTF8StringEncoding];
            //NSLog(@"encodeId : %@, encodePwd : %@", encodeId, encodePwd);
            
            
            //ph 폰번호
            NSString *param = [NSString stringWithFormat:@"id=%@&pass=%@&sel_cpn_code=%@&mode=login&token=%@&os_type=I&device_id=%@&model_nm=%@&ver=beacon",encodeId,encodePwd,self.compCode,appDelegate.fcmToken,uuid,model_nm];
            
            NSLog(@"##urlString : %@", _urlString);
            NSLog(@"##param : %@", param);
            
            getBadge = NO;
            
            NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_urlString]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody: postData];
            [request setTimeoutInterval:10.0];
            
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            [urlConnection start];
        }
    }
}

-(void)callBadgeType {
    getBadge = YES;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *_urlString = [NSString stringWithFormat:@"%@/m/main/?event=getBadgeType",[prefs objectForKey:@"URL"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_urlString]];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [urlConnection start];
}

-(IBAction)idSave:(id)sender{
    if (isIdSave) {
        isIdSave = NO;
        [idSaveButton setBackgroundImage: [UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    }else{
        isIdSave = YES;
        [idSaveButton setBackgroundImage: [UIImage imageNamed:@"checkbox_over.png"] forState:UIControlStateNormal];
    }
}
-(IBAction)pwSave:(id)sender{
    if (isPwSave) {
        isPwSave = NO;
        [pwSaveButton setBackgroundImage: [UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
        
    }else{
        isPwSave = YES;
        [pwSaveButton setBackgroundImage: [UIImage imageNamed:@"checkbox_over.png"] forState:UIControlStateNormal];
        
    }
}

-(IBAction)hidden:(id)sender{
    /*
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userID = [prefs objectForKey:@"ID"];
    NSString *compNm = [prefs objectForKey:@"COMP_NAME"];

     if ([compNm isEqualToString:@"디비밸리(주)"]) {
         if ([userID isEqualToString:@"jhpark"]){
             NSURL *url = [NSURL URLWithString:@"http://gw.dbvalley.com/m/main/?event=set_beacon&device_id=63275E3A-7E48-4E36-9B1B-765DF74D7D0B&token=45bf7dd6a2b8d486392f61449fc6cadbc32c3ff782969f3220ff27d15a96ad41&uuid=44425641-4C4C-4559-414E-594D41544533&major=10051&minor=10001"];
             SessionHTTP *session = [[SessionHTTP alloc] init];
             session.delegate = self;
             [session URL:url parameter:nil];
         }else if([userID isEqualToString:@"mgkim"]){
             NSURL *url = [NSURL URLWithString:@"http://gw.dbvalley.com/m/main/?event=set_beacon&device_id=0A18E915-0B51-499C-B6CD-875064A52470&token=74cf2051bd4d1abed08589117cd30f0575ad189144d0f1d0e4d8f6750b35bdec&uuid=44425641-4C4C-4559-414E-594D41544533&major=10051&minor=10001"];
             SessionHTTP *session = [[SessionHTTP alloc] init];
             session.delegate = self;
             [session URL:url parameter:nil];
         }
         else if([userID isEqualToString:@"hilee"]){
             NSURL *url = [NSURL URLWithString:@"http://gw.dbvalley.com/m/main/?event=set_beacon&device_id=DEDB3282-9E9F-4163-AA41-1E457B41984E&token=43af754e328c888000b57166aee3cbd3a095ea424f86db090016f7f67e51b291&uuid=44425641-4C4C-4559-414E-594D41544533&major=10051&minor=10001"];
             SessionHTTP *session = [[SessionHTTP alloc] init];
             session.delegate = self;
             [session URL:url parameter:nil];
         }
     }
    */
}


#pragma mark - SessionHTTP Delegate
-(void)returnData:(SessionHTTP *)session{
    NSLog(@"dataStr : %@", session.dataStr);
    
    NSError *dicError;
    NSDictionary *dataDiction = [NSJSONSerialization JSONObjectWithData:[session.dataStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
    NSString *resultCode = [NSString stringWithFormat:@"%@",[dataDiction objectForKey:@"code"]];
    
    //로그테스트
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"[LOGIN] returnData" message:resultCode preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok")
//                                                           style:UIAlertActionStyleCancel
//                                                         handler:^(UIAlertAction *action) { }]];
//    [self presentViewController:alert animated:YES completion:nil];

    NSString *resultString = @"";
    if ([resultCode isEqualToString:@"990"]) {
        //resultString = NSLocalizedString(@"login_code_990", @"login_code_990");
    }else if ([resultCode isEqualToString:@"991"]) {
        //resultString = NSLocalizedString(@"login_code_991", @"login_code_991");
    }else if ([resultCode isEqualToString:@"992"]) {
        //resultString = NSLocalizedString(@"login_code_992", @"login_code_992");
    }else if ([resultCode isEqualToString:@"100"]) {
        resultString = NSLocalizedString(@"login_code_100", @"login_code_100");
    }else if ([resultCode isEqualToString:@"200"]) {
        resultString = NSLocalizedString(@"login_code_200", @"login_code_200");
    }else if ([resultCode isEqualToString:@"300"]) {
        //resultString = NSLocalizedString(@"login_code_300", @"login_code_300");
    }else if ([resultCode isEqualToString:@"400"]) {
        //resultString = NSLocalizedString(@"login_code_400", @"login_code_400");
    }else if ([resultCode isEqualToString:@"500"]) {
        //resultString = NSLocalizedString(@"login_code_500", @"login_code_500");
    }else if ([resultCode isEqualToString:@"600"]) {
        //resultString = NSLocalizedString(@"login_code_600", @"login_code_600");
    }else if ([resultCode isEqualToString:@"0"]) {
        resultString = NSLocalizedString(@"login_code_0", @"login_code_0");
    }
}

-(void)returnData:(SessionHTTP *)SessionHTTP withErrorMessage:(NSString *)errorMessage error:(NSError *)error{
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [self.indicatorView stopAnimating];
    isLogin = NO;
    if (error.code == -1003) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *errorMessage = [NSString stringWithFormat:@"정보가 올바르지 않습니다.\n%@\nURL을 확인하세요.",[prefs objectForKey:@"URL"]];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"로그인 오류" message:errorMessage delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"오류" message:@"일시적인 네트워크 오류가 발생했습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
}

#pragma mark - NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [self.indicatorView stopAnimating];
    isLogin = NO;
    if (error.code == -1003) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *errorMessage = [NSString stringWithFormat:@"정보가 올바르지 않습니다.\n%@\nURL을 확인하세요.",[prefs objectForKey:@"URL"]];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"로그인 오류" message:errorMessage delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"오류" message:@"일시적인 네트워크 오류가 발생했습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if (@available(iOS 11.0, *)) {
        //WKWebView에서 사용하기 위한 로그인 세션 쿠키 공유
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mainString = [NSString stringWithFormat:@"%@/m/main/",[prefs objectForKey:@"URL"]];
        if([response.URL.absoluteString isEqualToString:mainString]){
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[httpResponse allHeaderFields] forURL:response.URL];
            for (NSHTTPCookie *cookie in cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            }
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *absoluteString = connection.currentRequest.URL.absoluteString;
    NSLog(@"didReceiveData query : %@",connection.currentRequest.URL.query);
    NSString *query = connection.currentRequest.URL.query;
    
    if ([query rangeOfString:@"&"].location != NSNotFound) {
        query = [[query componentsSeparatedByString:@"&"] objectAtIndex:0];
    }
//    NSLog(@"query2 : %@",query);
    
    NSString *returnString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didReceiveData returnString : %@", returnString);
    
    if (query==nil) {
        returnCode = returnString;
    } else {
        if ([query isEqualToString:@"event=get_version"]) {
//            NSLog(@"getVersion");
            appDelegate.appVersion = returnString;
        } else if([query isEqualToString:@"event=getBadgeType"]){
            isBadge = returnString;
        } else if([query isEqualToString:@"event=getBeacon"]){
//            NSLog(@"getBeacon : %@",returnString);
            isBeacon = returnString;
            
            NSData *jsonData = [returnString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            
            NSString *beaconUseFlag = [dict objectForKey:@"USE_FLAG"];
            NSString *uuidStr = [dict objectForKey:@"UUID"];
            
//            uuidStr = @"43F67CE0-8DC1-11E5-AEFC-000EA5D5C51B";
            
            if([beaconUseFlag isEqualToString:@"Y"]){
                appDelegate.supportedUUIDs = @[[[NSUUID alloc] initWithUUIDString:uuidStr]];
                NSLog(@"supportedUUIDs : %@", appDelegate.supportedUUIDs);
                
                //beacon------------------------------------------------------------
                bm = [[BeaconManager_Reco alloc]init];
//                bm = [[BeaconManager_Minew alloc]init];
                [bm performSelector:@selector(beaconSetting)];
                //beacon------------------------------------------------------------
            }
        }
    }
    
    NSArray *tempArr = [[absoluteString lastPathComponent] componentsSeparatedByString:@"="];
    if ([tempArr count]==1) {
        returnCode = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }else{
        appDelegate.appVersion = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if(!isFirst){
        if(!getBadge){
            [self callBadgeType];
        } else {
            [self resultLogin];
        }
    }
}


- (void)resultLogin{
    NSLog(@"%s code : %@", __func__, returnCode);
    isFirst = NO;
    
    if ([returnCode isEqualToString:@"250"]) {
        if ([UIApplication sharedApplication].applicationIconBadgeNumber !=0) {
            if([isBadge isEqualToString:@"1"]){
                //로그인시 뱃지카운트 초기화
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            } else {
                NSLog(@"LoginViewController isBadge 0");
            }
        }
        
        appDelegate.isSet = @"NO";
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        NSLog(@"appDelegate.appVersion : %@", appDelegate.appVersion);
        if (appDelegate.appVersion == nil || [appDelegate.appVersion isEqualToString:@"0"]) {
            if(!appDelegate.isLogout){
                NSString *_urlString = [NSString stringWithFormat:@"%@/m/main/?event=get_version&os=I",[prefs objectForKey:@"URL"]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_urlString]];
                NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
                [urlConnection start];
            }
            
        }else{
            if (isBeacon!=nil) {
                if ([isBeacon boolValue]) {
                    if (![prefs boolForKey:@"IS_BEACON_SET"]) {
                        locationManager = [[CLLocationManager alloc] init];
                        locationManager.delegate = self;
                        
                        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                            [locationManager requestWhenInUseAuthorization];
                        }
                    }
                }
                appDelegate.isLogin = YES;
               
                isLogin = NO;
                idTextField.text = @"";
                pwTextField.text = @"";
                isBeacon = nil;
                
                [self performSegueWithIdentifier:@"PUSH_WEB_VIEW" sender:nil];
                
            }else{
                if(!appDelegate.isLogout){
                    //ph 폰번호
                    NSString *_urlString = [NSString stringWithFormat:@"%@/m/main/?event=getBeacon&cpn_code=%@",[prefs objectForKey:@"URL"], self.compCode];
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_urlString]];
                    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
                    [urlConnection start];
                }
                
            }
        }
    } /*else if([returnCode isEqualToString:@"444"]){
       //세션중복 로그인 방지
       }else if([returnCode isEqualToString:@"404"]){
       //존재하지 않는 아이디
       }else if([returnCode isEqualToString:@"450"]){
       //비밀번호 불일치
       }else if([returnCode isEqualToString:@"600"]){
       //승인대기자
       }else if([returnCode isEqualToString:@"610"]){
       //사용중지자
       }else if([returnCode isEqualToString:@"620"]){
       //계정상태 일시중지
       }else if([returnCode isEqualToString:@"1000"]){
       //서버 장애/일시오류
       }*/else{
           UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"로그인 실패" message:@"로그인 정보가 일치하지 않습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles: nil];
           [alertView show];
           alertView.tag = 112;
           [alertView release];
       }
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    NSLog(@"row string : %@",[[self.compDic allValues] objectAtIndex:row]);
    label.text = [[self.compDic allValues] objectAtIndex:row];
    self.compName = label.text;
    [label setTextAlignment:NSTextAlignmentCenter];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return self.compDic.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [[self.compDic allValues] objectAtIndex:row];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:idTextField]) {
        [pwTextField becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"PUSH_WEB_VIEW"]){
        WebViewController *webView = segue.destinationViewController;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        webView.compName = self.compName;
        webView.isBadge = isBadge;
        
//        NSLog(@"[pushlog] appDelegate.pushURL : %@",appDelegate.pushURL);
//        if (appDelegate.pushURL == nil || [appDelegate.pushURL isEqualToString:@""]) {
//            webView.urlString = [NSString stringWithFormat:@"%@/m/main/?mode=portal",[prefs objectForKey:@"URL"]];
//
//        }else{
//            webView.urlString = appDelegate.pushURL;
//        }
        
        NSDictionary *pushDict = [prefs objectForKey:@"PUSH_DICT"];
        NSLog(@"[pushlog] login push key : %@", [prefs objectForKey:@"PUSH_DICT"]);
        if (pushDict == nil) {
            webView.urlString = [NSString stringWithFormat:@"%@/m/main/?mode=portal",[prefs objectForKey:@"URL"]];

        }else{
            NSString *pushUrl = [pushDict objectForKey:@"url"];
            
            if (![[pushUrl substringToIndex:7] isEqualToString:@"http://"]&&![[pushUrl substringToIndex:8] isEqualToString:@"https://"]) {
                NSLog(@"url형식이 아니라면22");
                pushUrl = [[prefs objectForKey:@"URL"] stringByAppendingString:pushUrl];
            }
            
            NSLog(@"[pushlog] login pushUrl : %@", pushUrl);
            webView.urlString = pushUrl;
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [self.indicatorView stopAnimating];
    }
     
}

#pragma mark
#pragma mark Login Util method
- (NSString*) getUUID
{
    // initialize keychaing item for saving UUID.
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    
    NSString *uuid = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    
    if( uuid == nil || uuid.length == 0)
    {
        // if there is not UUID in keychain, make UUID and save it.
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        uuid = [NSString stringWithString:(__bridge NSString *) uuidStringRef];
        CFRelease(uuidStringRef);
        
        // save UUID in keychain
        [wrapper setObject:uuid forKey:(__bridge id)(kSecAttrAccount)];
        
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:uuid forKey:@"DEVICE_ID"];
    [prefs synchronize];
    return uuid;
}


#pragma mark
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotate{
    return YES;
}

#pragma mark
#pragma mark Location Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Updateing Failed! : %@",error);
} // 위치 정보 가져오는 것 실패 때


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"locationManager didUpdateLocations ??? : %@",locations);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
// CLLocation *)newLocation 여기에 위도경도가 변수에 들어가 있다.
{
    double latitude;  //더블형
    double longitude;
    
    latitude = newLocation.coordinate.latitude; //위도정보
    longitude = newLocation.coordinate.longitude;//경도 정보
    
    NSString *lbl_laText = [NSString stringWithFormat:@"위도는 : %g",latitude];
    NSString *lbl_loText = [NSString stringWithFormat:@"경도는 : %g",longitude];
    
    NSLog(@"%@",lbl_loText);
    NSLog(@"%@",lbl_laText);
    
}
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error{
    //NSLog(@"didFinishDeferredUpdatesWithError");
}
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    //NSLog(@"didExitRegion");
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    NSLog(@"kCLAuthorizationStatusNotDetermined : %d",kCLAuthorizationStatusNotDetermined);
    NSLog(@"kCLAuthorizationStatusRestricted : %d",kCLAuthorizationStatusRestricted);
    NSLog(@"kCLAuthorizationStatusDenied : %d",kCLAuthorizationStatusDenied);
    NSLog(@"kCLAuthorizationStatusAuthorizedAlways : %d",kCLAuthorizationStatusAuthorizedAlways);
    NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse : %d",kCLAuthorizationStatusAuthorizedWhenInUse);
    NSLog(@"kCLAuthorizationStatusAuthorized : %d",kCLAuthorizationStatusAuthorized);
    
    NSLog(@"status : %d",status);
    
    if (status!=kCLAuthorizationStatusAuthorizedAlways) {
        NSString *message = @"근태관리(출퇴근부) 이용시\n설정 > 개인 정보 보호 > 위치 서비스 > Anymate 에서 위치 접근을 \"항상\" 으로 설정하셔야 합니다.";
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:message message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"다시 보지 않기", @"다시 보지 않기") otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
        alertView.tag = 1001;
        [alertView show];
    }
    
//    if (status==kCLAuthorizationStatusAuthorizedAlways || status==kCLAuthorizationStatusAuthorizedWhenInUse) {
//        [manager startUpdatingLocation];
//    }
    
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    /*
     int x_offset = 130;
     int y_offset = 50;
     NSString *imageName = @"bg_login.png";
     
     UIView *view = (UIView *)[self.view viewWithTag:100];
     UIImageView *view1 = (UIImageView *)[self.view viewWithTag:101];
     if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
     isRotate = YES;
     
     view.frame = CGRectMake(0, 44, 568, 256);
     //view1.frame = CGRectMake(0, 44, 568, 256);
     view1.image = [UIImage imageNamed:imageName];
     [logoView setFrame:CGRectMake(logoView.frame.origin.x+x_offset, logoView.frame.origin.y-y_offset, logoView.frame.size.width, logoView.frame.size.height)];
     [idTextField setFrame:CGRectMake(idTextField.frame.origin.x+x_offset, idTextField.frame.origin.y-y_offset, idTextField.frame.size.width, idTextField.frame.size.height)];
     [pwTextField setFrame:CGRectMake(pwTextField.frame.origin.x+x_offset, pwTextField.frame.origin.y-y_offset, pwTextField.frame.size.width, pwTextField.frame.size.height)];
     [idLabel setFrame:CGRectMake(idLabel.frame.origin.x+x_offset, idLabel.frame.origin.y-y_offset, idLabel.frame.size.width, idLabel.frame.size.height)];
     [pwLabel setFrame:CGRectMake(pwLabel.frame.origin.x+x_offset, pwLabel.frame.origin.y-y_offset, pwLabel.frame.size.width, pwLabel.frame.size.height)];
     [idSaveButton setFrame:CGRectMake(idSaveButton.frame.origin.x+x_offset, idSaveButton.frame.origin.y-y_offset, idSaveButton.frame.size.width, idSaveButton.frame.size.height)];
     [pwSaveButton setFrame:CGRectMake(pwSaveButton.frame.origin.x+x_offset, pwSaveButton.frame.origin.y-y_offset, pwSaveButton.frame.size.width, pwSaveButton.frame.size.height)];
     [loginButton setFrame:CGRectMake(loginButton.frame.origin.x+x_offset, loginButton.frame.origin.y-y_offset, loginButton.frame.size.width, loginButton.frame.size.height)];
     
     [verLabel setFrame:CGRectMake(0, 0, verLabel.frame.size.width, verLabel.frame.size.height)];
     }else {
     
     isRotate = NO;
     view1.image = [UIImage imageNamed:imageName];
     [logoView setFrame:CGRectMake(logoView.frame.origin.x-x_offset, logoView.frame.origin.y+y_offset, logoView.frame.size.width, logoView.frame.size.height)];
     [idTextField setFrame:CGRectMake(idTextField.frame.origin.x-x_offset, idTextField.frame.origin.y+y_offset, idTextField.frame.size.width, idTextField.frame.size.height)];
     [pwTextField setFrame:CGRectMake(pwTextField.frame.origin.x-x_offset, pwTextField.frame.origin.y+y_offset, pwTextField.frame.size.width, pwTextField.frame.size.height)];
     [idLabel setFrame:CGRectMake(idLabel.frame.origin.x-x_offset, idLabel.frame.origin.y+y_offset, idLabel.frame.size.width, idLabel.frame.size.height)];
     [pwLabel setFrame:CGRectMake(pwLabel.frame.origin.x-x_offset, pwLabel.frame.origin.y+y_offset, pwLabel.frame.size.width, pwLabel.frame.size.height)];
     [idSaveButton setFrame:CGRectMake(idSaveButton.frame.origin.x-x_offset, idSaveButton.frame.origin.y+y_offset, idSaveButton.frame.size.width, idSaveButton.frame.size.height)];
     [pwSaveButton setFrame:CGRectMake(pwSaveButton.frame.origin.x-x_offset, pwSaveButton.frame.origin.y+y_offset, pwSaveButton.frame.size.width, pwSaveButton.frame.size.height)];
     [loginButton setFrame:CGRectMake(loginButton.frame.origin.x-x_offset, loginButton.frame.origin.y+y_offset, loginButton.frame.size.width, loginButton.frame.size.height)];
     
     [verLabel setFrame:CGRectMake(0, 66, verLabel.frame.size.width, verLabel.frame.size.height)];
     }
     
     self.indicatorView.center = view.center;
     */
}

- (void)dealloc {
    [idTextField release];
    [pwTextField release];
    [imageView release];
    [logoView release];
    [idLabel release];
    [pwLabel release];
    [verLabel release];
    [loginButton release];
    [idSaveButton release];
    [pwSaveButton release];
    [super dealloc];
}
@end


#pragma mark
@implementation NSString (URLEncoding2)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding{
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding));
}
+ (NSString *)urlDecodeString:(NSString *)str
{
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)str,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    return [result autorelease];
}
@end

