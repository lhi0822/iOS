//
//  AppDelegate.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "MFinityAppDelegate.h"

#import "MainViewController.h"
#import "NoticeViewController.h"
#import "MFTableViewController.h"
#import "SettingViewController.h"
#import "EmptyViewController.h"
#import "WebViewController.h"
#import "SecurityManager.h"
#import "SVProgressHUD.h"
#import "KeychainItemWrapper.h"
#import "NotiPushViewController.h"
#import "UIDevice-Hardware.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>


@implementation MFinityAppDelegate {
    NSMutableArray *tabLineArr;
}
@synthesize main_url = _main_url;
@synthesize appDeviceToken = _appDeviceToken;
@synthesize AES256Key = _AES256Key;
@synthesize AES256Key2 = _AES256Key2;
@synthesize menu_title = _menu_title;
@synthesize target_url = _target_url;
@synthesize noticeTabBarNumber = _noticeTabBarNumber;


#pragma mark
#pragma mark Firebase Delegate
-(void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken{
   self.fcmToken = fcmToken;
   
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FCMToken" object:nil userInfo:dataDict];

    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
      if (error != nil) {
        NSLog(@"Error fetching remote instance ID: %@", error);
      } else {
        NSLog(@"Remote instance ID token: %@", result.token);
        NSString* message = [NSString stringWithFormat:@"Remote InstanceID token: %@", result.token];
        //self.instanceIDTokenMessage.text = message;
      }
    }];
}

#pragma mark
#pragma mark Application Delegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   [FIRApp configure];
   [FIRMessaging messaging].delegate = self;
   
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.window setBackgroundColor:[UIColor whiteColor]];

    if (launchOptions != nil)
    {
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            //{"menuNo":"444","aps":{"badge":1,"alert":"E Push Test"},"type":"E","notice":"2"}
            NSLog(@"dictionary : %@",dictionary);
            NSString *type = [dictionary objectForKey:@"type"];
            if ([type isEqualToString:@"E"]) {
                _receivePush = YES;
                _receiveMenuNo = [dictionary objectForKey:@"menuNo"];
                NSLog(@"receiveMenuNo : %@",_receiveMenuNo);
            }
        }
    }
    
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                dispatch_async(dispatch_get_main_queue(), ^{
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                });
                 
             }
             else
             {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
             }
         }];
    }else{
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
       
    }
   
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    introViewController = [[IntroViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:introViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //Initialize
    _isAES256 = YES;
    _demo = @"NOT DEMO";
   
    _AES256Key = @"E3Z2S1M5A9R8T1F3E2E4L31504081532";
    _AES256Key2 = @"E3Z2S1M5A9R8T1F3";
   
    _moreCount = @"30";
    _paramString = @"";
   
   self.isMDM = NO;
   self.isExcuteMDM = NO; //NO
    
    _isInitPwd = NO;
    _isSettingPwd = NO;
   
   _useAutoLogin = YES; //자동로그인
   
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   if(_useAutoLogin){
      if([prefs objectForKey:@"AUTO_LOGIN_DATE"]!=nil){
         _setFirstLogin = NO;
      } else {
         _setFirstLogin = YES;
      }
   }
   
   NSLog(@"### 앱 실행 시 UUID : %@", [prefs objectForKey:@"UUID"]);
   if([prefs objectForKey:@"UUID"]==nil){
      self.device_id = [MFinityAppDelegate getUUID];
      [prefs setObject:self.device_id forKey:@"UUID"];
      [prefs synchronize];
   }
   
   [self loginHistoryToLogFile:[NSString stringWithFormat:@"%s //앱 실행",__func__] result:nil];
   
    //Initialize end
    MainViewController *viewController1 = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    NotiPushViewController *viewController2 = [[NotiPushViewController alloc] initWithNibName:@"NotiPushViewController" bundle:nil];
    MFTableViewController *viewController3 = [[MFTableViewController alloc] initWithNibName:@"MymenuViewController" bundle:nil];
    SettingViewController *viewController4 = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    EmptyViewController *viewController5 = [[EmptyViewController alloc] initWithNibName:@"EmptyViewController" bundle:nil];

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.delegate = self;
    self.uiTabBar = [[UITabBar alloc]init];
    self.uiTabBar.delegate = self;

    self.tabBarController.viewControllers = @[viewController1, viewController2, viewController3, viewController4, viewController5];
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *osVersion = myDevice.systemVersion;
    if ([osVersion intValue]>=7) {
        [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }

    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    NSLog(@"completionHandler : %@",completionHandler);
    completionHandler(UIBackgroundFetchResultNewData);
}

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
//   NSLog(@"%s",__FUNCTION__);
//   return YES;
//}

- (BOOL)application:application handleOpenURL:(NSURL *)url{
    //외부 앱에서 URL call 했을때 호출되는 델리게이트 메소드
    //이부분에 인자값으로 넘어오는 url을 파싱해서 사용하면
    //파라미터처럼 사용할 수 있음
    NSLog(@"%s", __func__);
    return YES;
}
+ (void)exitWorkApp{
    NSString * stringURLScheme = nil;
    BOOL isBe;
    NSArray * URLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (URLTypes && [URLTypes count]) {
        NSDictionary * dict = [URLTypes objectAtIndex:0];
        NSArray * CFBundleURLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
        if (CFBundleURLSchemes && [CFBundleURLSchemes count]) {
            stringURLScheme = [CFBundleURLSchemes objectAtIndex:0];
        }
    }
    
    NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=exitWorkApp"];
    
    [urlString appendFormat:@"&caller=%@", stringURLScheme];
    NSLog(@"urlString : %@",urlString);
    isBe = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"application::openURL::sourceApplication=%@",sourceApplication);
    NSLog(@"url=%@",url);
   
    // Start Line
    // MDM Agent로부터 동작여부 상태 도착.
   
   BOOL isValue;
    if (@available(iOS 13.0, *)) {
       if([url query]) isValue = YES;
       else isValue = NO;
        
    } else {
        if([sourceApplication isEqualToString:@"com.extrus.mdmclient"] && [url query]) isValue = YES;
        else isValue = NO;
    }
   
   if(isValue){
      NSArray * param = [[url query] componentsSeparatedByString:@"&"];
      NSMutableArray *params = [NSMutableArray arrayWithArray:param];
      NSLog(@"param : %@",param);
      [params removeObject:@""];
      param = params;
      NSMutableString * resultMDMAgent = [NSMutableString string];
      
      if ([param count]==1) {
          NSLog(@"_mdmCallAPI : %@",_mdmCallAPI);
          NSLog(@"param : %@",param);

          NSString * value = [[[param objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
          NSLog(@"value : %@",value);
          if ([_mdmCallAPI isEqualToString:@"exitWorkApp"]) {
             
              if (![value isEqualToString:@"1"]) {
                  [resultMDMAgent appendString:@"MDM 업무앱 종료정책이 적용 되지 않았습니다.\n"];
                 
              } else{
                  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Logout) userInfo:nil repeats:NO];
              }
          } else{
              if (![value isEqualToString:@"1"]) {
                  [resultMDMAgent appendString:@"MDM 업무앱 실행정책이 적용 되지 않았습니다.\n"];

              }else{
                  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                  [prefs setObject:[prefs objectForKey:@"preLock"] forKey:@"Lock"];
                  [prefs synchronize];
                  [_window setRootViewController:_tabBarController];
              }
          }
          
      }else{
          for (NSString * str in param) {
//              NSLog(@"str : %@",str);
              if ([[str componentsSeparatedByString:@"="] count] == 2) {
                  NSString * key = [[str componentsSeparatedByString:@"="] objectAtIndex:0];
                  NSString * value = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
//                  NSLog(@"key : %@",key);
                  if ([[key lowercaseString] isEqualToString:@"mdmactive"]) {
                      BOOL isMDMActive = [value boolValue];
                      if (!isMDMActive) {
                          [resultMDMAgent appendString:@"MDM이 설치되지 않았습니다.\n"];
                      }
                     
                  } else if ([[key lowercaseString] isEqualToString:@"isrooted"]) {
                      BOOL isMDMActive = [value boolValue];
                      if (isMDMActive) {
                          [resultMDMAgent appendString:@"탈옥된 디바이스 입니다.\n"];
                      }
                      
                  } else if ([[key lowercaseString] isEqualToString:@"islastversion"]) {
                      
                      
                  } else if ([[key lowercaseString] isEqualToString:@"isvendorpushenabled"]) {
                      BOOL isMDMActive = [value boolValue];
                      if (!isMDMActive) {
                          [resultMDMAgent appendString:@"푸쉬 알림이 활성화 되지 않았습니다.\n"];
                      }
                      
                  } else if ([[key lowercaseString] isEqualToString:@"operationstatus"]) {
                      // 운영상태
                      if ([value isEqualToString:@"0"]) {
                          //unregistered
                          [resultMDMAgent appendString:@"운영이 등록되지 않았습니다.\n"];
                      } else if([value isEqualToString:@"1"]){
                          //disabled
                          [resultMDMAgent appendString:@"운영이 활성화 되지 않았습니다.\n"];
                      }
                      
                  } else if ([[key lowercaseString] isEqualToString:@"status"]) {
                      // MDM 상태
                      if ([value isEqualToString:@"0"]) {
                          //unregistered
                          [resultMDMAgent appendString:@"MDM이 등록되지 않았습니다.\n"];
                      } else if([value isEqualToString:@"1"]){
                          //disabled
                          [resultMDMAgent appendString:@"MDM이 활성화 되지 않았습니다.\n"];
                      }
                      
                  } else if ([[key lowercaseString] isEqualToString:@"result"]) {
                      if (![value isEqualToString:@"1"]) {
                          [resultMDMAgent appendString:@"MDM 업무앱 실행정책이 적용 되지 않았습니다.\n"];
                         
                      }
//                      else {
//                         [[NSNotificationCenter defaultCenter] postNotificationName:@"MDMIntroNotification" object:nil];
//                      }
                  } else if([[key lowercaseString] isEqualToString:@"authtoken"]){
                      NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                      [prefs setObject:value forKey:@"MDM_AUTH_TOKEN"];
                      [prefs synchronize];
                  }
              }
          }
          [[NSNotificationCenter defaultCenter] postNotificationName:@"MDMIntroNotification" object:nil];
      }
      NSLog(@"resultMDMAgent : %@",resultMDMAgent);
      if (![resultMDMAgent isEqualToString:@""]) {
          UIAlertView * alert = [[UIAlertView alloc]
                                 initWithTitle: @"ExafeMDM 상태 정보"
                                 message: resultMDMAgent
                                 delegate:nil
                                 cancelButtonTitle:@"확인"
                                 otherButtonTitles:nil, nil];
          alert.delegate = self;
          [alert show];
      }
   } else {
      exit(0);
   }
    

    return YES;
}

-(void)Logout{
    exit(0);
}
//push : APNS 에 장치 등록 오류시 자동실행
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"deviceToken error : %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   NSLog(@"%s",__func__);
   [self loginHistoryToLogFile:[NSString stringWithFormat:@"%s //백그라운드 전환",__func__] result:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   [self loginHistoryToLogFile:[NSString stringWithFormat:@"%s //포그라운드 전환",__func__] result:nil];
   
   if(self.isMDM){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *authToken = [prefs objectForKey:@"MDM_AUTH_TOKEN"];
        NSString *urlString = [NSString stringWithFormat:@"https://mdm.hhi.co.kr/mdm_admin_server/mdmApi/enterWorkApp?authToken=%@&osType=IOS", authToken];
        NSLog(@"[%s] url : %@", __func__, urlString);
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString] options:NSDataReadingUncached error:&error];
        NSString *returnStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"returnSTR : %@", returnStr);

//        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[returnStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
//        if(![dataDic objectForKey:@"result"]){
//            NSLog(@"MDM 업무앱 실행정책이 적용되지 않았습니다.");
//        } else {
//            NSLog(@"MDM 업무앱 실행정책이 적용되었습니다.");
//        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   
   [self loginHistoryToLogFile:[NSString stringWithFormat:@"%s //앱 종료",__func__] result:nil];
   
   if(self.isMDM){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *authToken = [prefs objectForKey:@"MDM_AUTH_TOKEN"];
        NSString *urlString = [NSString stringWithFormat:@"https://mdm.hhi.co.kr/mdm_admin_server/mdmApi/exitWorkApp?authToken=%@&osType=IOS", authToken];
        NSLog(@"[%s] url : %@", __func__, urlString);
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString] options:NSDataReadingUncached error:&error];
        NSString *returnStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[returnStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if([dataDic objectForKey:@"result"]){
            NSLog(@"MDM 업무앱 종료정책이 적용되었습니다.");
        } else {
            NSLog(@"MDM 업무앱 종료정책이 적용되지 않았습니다.");
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MDM 업무앱 종료정책이 적용되지 않았습니다.", @"MDM 업무앱 종료정책이 적용되지 않았습니다.") message:nil preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//                                                              [alert dismissViewControllerAnimated:YES completion:nil];
//                                                              exit(0);
//                                                          }];
//            [alert addAction:okButton];
//            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    }
   
}

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
 {
 }
 */

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
 {
 }
 */
#pragma mark
#pragma mark

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    tabBar.selectedImageTintColor = [self myRGBfromHex:_tabFontColor];
}
- (void) chageTabBarColor:(BOOL)isSub{
    if (isSub) {
        
        //[self.tabBarController.tabBarItem setTitleTextAttributes:@{UITextAttributeTextColor:[self myRGBfromHex:_subFontColor]} forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[self myRGBfromHex:_tabFontColor]} forState:UIControlStateSelected];
        
        [self.tabBarController.tabBar setSelectedImageTintColor:[self myRGBfromHex:_tabFontColor]];
    }else{
        [self.tabBarController.tabBarItem setTitleTextAttributes:@{UITextAttributeTextColor:[self myRGBfromHex:_tabFontColor]} forState:UIControlStateSelected];
        [self.tabBarController.tabBar setSelectedImageTintColor:[self myRGBfromHex:_tabFontColor]];
    }
    
}

- (NSDictionary *)contracts{
    NSDictionary *returnDic;
    ABAddressBookRef ref;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)  {
        CFErrorRef error = nil;
        ref = ABAddressBookCreateWithOptions(NULL,&error);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(ref, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self RefContacts:ref];
                        CFRelease(ref);
                    } else  {
                        //NSLog(@"비활성, 오류 마음에 드시는 메시지를 써넣으세요");
                    }
                });
            });
        } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            returnDic = [self RefContacts:ref];
            CFRelease(ref);
        } else {
            //NSLog(@"장치의 설정 - 개인정보 보호 - 연락처 정보를 활성화 해주세요");
        }
    } else {
        ref = ABAddressBookCreate();
        returnDic = [self RefContacts:ref];
        CFRelease(ref);
    }
    return returnDic;
}

- (NSDictionary *) RefContacts:(ABAddressBookRef) addressBook {
    //===================================================//
    // 주소록의 모든 정보를 구조체에 저장을 합니다.
    //===================================================//
    //  ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    //===================================================//
    // 저장된 구조체에서 해당 자료를 추출해 옵니다.
    //===================================================//
    NSMutableDictionary *addressDic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < nPeople ; i++) {
        NSMutableDictionary *personDic = [[NSMutableDictionary alloc]init];
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSNumber *recordId = [NSNumber numberWithInteger: ABRecordGetRecordID(ref)];
        ////NSLog(@"Name : %@ - %@ %@", recordId, (lastName != nil) ? (__bridge NSString *)lastName : @"",(firstName != nil) ? (__bridge NSString *)firstName : @"" );
        NSString *name = [NSString stringWithFormat:@"%@%@",lastName,firstName];
        [personDic setObject:name forKey:@"NAME"];
        if (firstName != nil)
            CFRelease(firstName);
        if (lastName != nil)
            CFRelease(lastName);
        
        // 사진이미지는 여기에 넘어옵니다.
        if (ABPersonHasImageData(ref)) {
            NSData *contactImageData = (__bridge NSData*)ABPersonCopyImageDataWithFormat(ref,kABPersonImageFormatThumbnail);
            UIImage *image = [[UIImage alloc] initWithData:contactImageData];
            // image를 저장하는 펑션은 여기에 작성하시면 됩니다.
            
        }
    
        //========================================================//
        // 전화번호 구조체 및 카테고리 저장/추출
        // 전화번호 구조체에는 전화번호와 집전화, 핸드폰 이런 카테고리 구분이 있으며
        // 이것은 Label로 구별합니다.
        // Label : kABHomeLabel, kABPersonPhoneIPhoneLabel 등등...
        //==================================
        NSMutableArray *phoneNumbers = [[NSMutableArray alloc]init];
        ABMultiValueRef phoneNums = (ABMultiValueRef)ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for (CFIndex j = 0; j < ABMultiValueGetCount(phoneNums); j++) {
            CFStringRef label = ABMultiValueCopyLabelAtIndex(phoneNums, j);
            CFStringRef tempRef = (CFStringRef)ABMultiValueCopyValueAtIndex(phoneNums, j);
            NSString *phoneString = [NSString stringWithFormat:@"%@",tempRef];
            phoneString = [phoneString stringByReplacingOccurrencesOfString:@"-" withString:@""];
            // 전화번호의 형태라벨별로 추출. 다른 형식도 이렇게 추출이 됩니다.
            if (CFStringCompare(label, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                if (tempRef != nil){
                    [phoneNumbers addObject:(__bridge NSString *)tempRef];
                    [personDic setObject:phoneString forKey:@"PHONE_NO"];
                    
                }else{
                    [personDic setObject:@"" forKey:@"PHONE_NO"];
                }
            } else if (CFStringCompare(label, kABPersonPhoneIPhoneLabel, 0) == kCFCompareEqualTo) {
                if (tempRef != nil){
                    [phoneNumbers addObject:(__bridge NSString *)tempRef];
                    [personDic setObject:phoneString forKey:@"IPHONE_NO"];
                    
                }else{
                    [personDic setObject:@"" forKey:@"IPHONE_NO"];
                }
            } else if (CFStringCompare(label, kABHomeLabel, 0) == kCFCompareEqualTo) {
                if (tempRef != nil){
                    [personDic setObject:phoneString forKey:@"HOME_NO"];
                    [phoneNumbers addObject:(__bridge NSString *)tempRef];
                    
                }else{
                    [personDic setObject:@"" forKey:@"HOME_NO"];
                }
            }
            
            CFRelease(label);
            CFRelease(tempRef);
        }
        [addressDic setObject:personDic forKey:[NSString stringWithFormat:@"%d",i]];
    }
    
    CFRelease(allPeople);
    return addressDic;
}
- (void) setTabBar:(NSDictionary *)dic {
    if (_naviFontColor == nil) {
        _naviFontColor = _mainFontColor;
    }
    NSLog(@"tab dic : %@", dic);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *osVersion = myDevice.systemVersion;
    CGRect frame = CGRectMake(0, 0, 480, 49);
    if (7>[osVersion intValue]>4) {
        [[self.tabBarController tabBar] setTintColor:[self myRGBfromHex:[prefs stringForKey:@"TabBarColor"]]];
        //[self.tabBarController tabBar].barTintColor = [self myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
        ////NSLog(@"appearance : %@",[UITabBarItem appearance]);
        if (_tabFontColor == nil) {
            NSLog(@"_tabFontColor == nil");
            [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[self myRGBfromHex:_mainFontColor]} forState:UIControlStateSelected];
            [self.tabBarController.tabBar setSelectedImageTintColor:[self myRGBfromHex:_mainFontColor]];
        }else{
            NSLog(@"_tabFontColor != nil");
            [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[self myRGBfromHex:_tabFontColor]} forState:UIControlStateSelected];
            [self.tabBarController.tabBar setSelectedImageTintColor:[self myRGBfromHex:_tabFontColor]];
        }

        //[self.tabBarController.tabBarItem setTitleTextAttributes:@{UITextAttributeTextColor:[self myRGBfromHex:_mainFontColor]} forState:UIControlStateNormal];

        //[[UITabBarItem appearance] setSelectedImageTintColor:[UIColor greenColor]];
        //[[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor]} forState:UIControlStateNormal];
        
    }else if([osVersion intValue]>6){
        [self.tabBarController tabBar].barTintColor = [self myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],NSForegroundColorAttributeName : [self myRGBfromHex:_tabFontColor]} forState:UIControlStateSelected];
        [[UITabBar appearance] setTintColor:[self myRGBfromHex:_tabFontColor]];
    }
    else{
        UIView *v = [[UIView alloc] initWithFrame:frame];
        [v setBackgroundColor:[self myRGBfromHex:[prefs stringForKey:@"TabBarColor"]]];
        [v setAlpha:0.5];
        [[self.tabBarController tabBar] addSubview:v];

    }
    
    MFTableViewController *tb = [[MFTableViewController alloc]init];
    tb.urlString = @"MY_MENU_CALL";
    UINavigationController *mainView = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc]init]];
    //2018.06 UI개선
    //UINavigationController *noticeView = [[UINavigationController alloc] initWithRootViewController:[[Notice_PushViewController alloc]init]];
    UINavigationController *noticeView = [[UINavigationController alloc] initWithRootViewController:[[NotiPushViewController alloc]init]];
    UINavigationController *myMenuView = [[UINavigationController alloc] initWithRootViewController:tb];
    UINavigationController *settingView = [[UINavigationController alloc] initWithRootViewController:[[SettingViewController alloc]init]];
    UINavigationController *exit = [[UINavigationController alloc] initWithRootViewController:[[EmptyViewController alloc]init]];
    UINavigationController *webView1 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    UINavigationController *webView2 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    UINavigationController *webView3 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    UINavigationController *webView4 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    UINavigationController *webView5 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    UINavigationController *webView6 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];

    controllers = [NSDictionary dictionaryWithObjectsAndKeys:mainView,@"1",noticeView,@"2",myMenuView,@"3",settingView,@"4",exit,@"5",webView1,@"6",webView2,@"7",webView3,@"8",webView4,@"9",webView5,@"10",webView6,@"11", nil];

   NSArray *icons = [[NSArray alloc]initWithObjects:
                     [UIImage imageNamed:@"bottom_icon01.png"],
                     [UIImage imageNamed:@"bottom_icon02.png"],
                     [UIImage imageNamed:@"bottom_icon03.png"],
                     [UIImage imageNamed:@"bottom_icon04.png"],
                     [UIImage imageNamed:@"bottom_icon05.png"],
                     [UIImage imageNamed:@"bottom_icon06.png"],
                     [UIImage imageNamed:@"bottom_icon07.png"],
                     [UIImage imageNamed:@"bottom_icon08.png"],
                     [UIImage imageNamed:@"bottom_icon09.png"],
                     [UIImage imageNamed:@"bottom_icon10.png"],
                     [UIImage imageNamed:@"bottom_icon11.png"],nil];
   
   NSArray *selectedIcons = [[NSArray alloc]initWithObjects:
                             [UIImage imageNamed:@"bottom_over_icon01.png"],
                             [UIImage imageNamed:@"bottom_over_icon02.png"],
                             [UIImage imageNamed:@"bottom_over_icon03.png"],
                             [UIImage imageNamed:@"bottom_over_icon04.png"],
                             [UIImage imageNamed:@"bottom_over_icon05.png"],
                             [UIImage imageNamed:@"bottom_over_icon06.png"],
                             [UIImage imageNamed:@"bottom_over_icon07.png"],
                             [UIImage imageNamed:@"bottom_over_icon08.png"],
                             [UIImage imageNamed:@"bottom_over_icon09.png"],
                             [UIImage imageNamed:@"bottom_over_icon10.png"],
                             [UIImage imageNamed:@"bottom_over_icon11.png"],nil];
   
    NSMutableArray *setTabs = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray *tabNumbers = [[NSMutableArray alloc]initWithObjects: nil];
    NSMutableArray *titles = [[NSMutableArray alloc]initWithObjects: nil];
    NSMutableArray *urls = [[NSMutableArray alloc]initWithObjects: nil];
    NSMutableArray *tabs = [[NSMutableArray alloc]initWithObjects: nil];
    //NSMutableArray *targetUrls = [[NSMutableArray alloc]initWithObjects: nil];

    for (int i=0; i<[dic count]; i++) {
        NSDictionary *subDic = [dic objectForKey:[NSString stringWithFormat:@"%d",i+1]];
       
        NSString *tabVar = [subDic objectForKey:@"TAB"];

        if ([tabVar intValue]==2) {
            _noticeTitle = [subDic objectForKey:@"TITLE"];
            _noticeTabBarNumber = [NSString stringWithFormat:@"%d",i];
        }
        [tabNumbers addObject:tabVar];
        if ([tabVar intValue]>5) {
            _menu_title = [subDic objectForKey:@"TITLE"];
            _target_url = [subDic objectForKey:@"URL"];
        }

        [urls addObject:[subDic objectForKey:@"URL"]];
        [titles addObject:[subDic objectForKey:@"TITLE"]];
        [setTabs addObject:[controllers objectForKey:tabVar]];
        [tabs addObject:tabVar];

        UINavigationController *tempController = [setTabs objectAtIndex:i];
        NSString *iconVar = [subDic objectForKey:@"ICON"];

        tempController.tabBarItem.image = [icons objectAtIndex:[iconVar intValue]-1];
        tempController.tabBarItem.selectedImage = [selectedIcons objectAtIndex:[iconVar intValue]-1];
        tempController.tabBarItem.title = [subDic objectForKey:@"ICONTITLE"];
        tempController.navigationItem.title = [subDic objectForKey:@"TITLE"];
    }
    _tabNumberArray = [[NSArray alloc]initWithArray:tabs];
    _titleArray = [[NSArray alloc]initWithArray:titles];
    urlArray = [[NSArray alloc]initWithArray:urls];
    tabArray = [[NSArray alloc]initWithArray:setTabs];
    self.tabBarController.viewControllers = setTabs;
    switch ([prefs integerForKey:@"startTabNumber"]) {
        case 0:
            _menu_title = [_titleArray objectAtIndex:0];
            _target_url = [urlArray objectAtIndex:0];
            break;
        case 1:
            _menu_title = [_titleArray objectAtIndex:1];
            _target_url = [urlArray objectAtIndex:1];
            break;
        case 2:
            _menu_title = [_titleArray objectAtIndex:2];
            _target_url = [urlArray objectAtIndex:2];
            break;
        case 3:
            _menu_title = [_titleArray objectAtIndex:3];
            _target_url = [urlArray objectAtIndex:3];
            break;
        case 4:
            _menu_title = [_titleArray objectAtIndex:4];
            _target_url = [urlArray objectAtIndex:4];
            break;
        default:
            break;
    }
    _pre_tabID = [prefs integerForKey:@"startTabNumber"];
    self.tabBarController.selectedIndex = [prefs integerForKey:@"startTabNumber"];

}


//2018.06 UI개선
- (void)setScrollTabBar:(NSDictionary *)dic{
    self.tabBarController.tabBar.hidden = YES;
    
    if (_naviFontColor == nil) {
        _naviFontColor = _mainFontColor;
    }
    
    NSMutableDictionary *scrollTabDic = [NSMutableDictionary dictionary];
    int tabCnt=0;
    for (int i=0; i<[dic count]; i++) {
        NSDictionary *subDic = [dic objectForKey:[NSString stringWithFormat:@"%d",i+1]];
        if(![subDic isEqual:@"*"]){
            tabCnt++;
            [scrollTabDic setObject:subDic forKey:[NSString stringWithFormat:@"%d",tabCnt]];
        }
    }

    MFTableViewController *tb = [[MFTableViewController alloc]init];
    tb.urlString = @"MY_MENU_CALL";
    UINavigationController *mainView = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc]init]];
    //2018.06 UI개선
    //UINavigationController *noticeView = [[UINavigationController alloc] initWithRootViewController:[[Notice_PushViewController alloc]init]];
    UINavigationController *noticeView = [[UINavigationController alloc] initWithRootViewController:[[NotiPushViewController alloc]init]];
    UINavigationController *myMenuView = [[UINavigationController alloc] initWithRootViewController:tb];
    UINavigationController *settingView = [[UINavigationController alloc] initWithRootViewController:[[SettingViewController alloc]init]];
    UINavigationController *exit = [[UINavigationController alloc] initWithRootViewController:[[EmptyViewController alloc]init]];
    UINavigationController *webView1 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    UINavigationController *webView2 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    UINavigationController *webView3 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    UINavigationController *webView4 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    UINavigationController *webView5 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    UINavigationController *webView6 = [[UINavigationController alloc] initWithRootViewController:[[WebViewController alloc]init]];
    
    controllers = [NSDictionary dictionaryWithObjectsAndKeys:mainView,@"1",noticeView,@"2",myMenuView,@"3",settingView,@"4",exit,@"5",webView1,@"6",webView2,@"7",webView3,@"8",webView4,@"9",webView5,@"10",webView6,@"11", nil];
   
   NSArray *icons = [[NSArray alloc]initWithObjects:
                     [UIImage imageNamed:@"bottom_icon01.png"],
                     [UIImage imageNamed:@"bottom_icon02.png"],
                     [UIImage imageNamed:@"bottom_icon03.png"],
                     [UIImage imageNamed:@"bottom_icon04.png"],
                     [UIImage imageNamed:@"bottom_icon05.png"],
                     [UIImage imageNamed:@"bottom_icon06.png"],
                     [UIImage imageNamed:@"bottom_icon07.png"],
                     [UIImage imageNamed:@"bottom_icon08.png"],
                     [UIImage imageNamed:@"bottom_icon09.png"],
                     [UIImage imageNamed:@"bottom_icon10.png"],
                     [UIImage imageNamed:@"bottom_icon11.png"],nil];
   
   NSArray *selectedIcons = [[NSArray alloc]initWithObjects:
                     [UIImage imageNamed:@"bottom_over_icon01.png"],
                     [UIImage imageNamed:@"bottom_over_icon02.png"],
                     [UIImage imageNamed:@"bottom_over_icon03.png"],
                     [UIImage imageNamed:@"bottom_over_icon04.png"],
                     [UIImage imageNamed:@"bottom_over_icon05.png"],
                     [UIImage imageNamed:@"bottom_over_icon06.png"],
                     [UIImage imageNamed:@"bottom_over_icon07.png"],
                     [UIImage imageNamed:@"bottom_over_icon08.png"],
                     [UIImage imageNamed:@"bottom_over_icon09.png"],
                     [UIImage imageNamed:@"bottom_over_icon10.png"],
                     [UIImage imageNamed:@"bottom_over_icon11.png"],nil];
   
    NSMutableArray *setTabs = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray *tabNumbers = [[NSMutableArray alloc]initWithObjects: nil];
    NSMutableArray *titles = [[NSMutableArray alloc]initWithObjects: nil];
    NSMutableArray *urls = [[NSMutableArray alloc]initWithObjects: nil];
    NSMutableArray *tabs = [[NSMutableArray alloc]initWithObjects: nil];
   
    for (int i=0; i<[scrollTabDic count]; i++) {
        NSDictionary *subDic = [scrollTabDic objectForKey:[NSString stringWithFormat:@"%d",i+1]];
        
        if(![subDic isEqual:@"*"]){
            NSString *tabVar = [subDic objectForKey:@"TAB"];
            
            if ([tabVar intValue]==2) {
                _noticeTitle = [subDic objectForKey:@"TITLE"];
                _noticeTabBarNumber = [NSString stringWithFormat:@"%d",i];
            }
            [tabNumbers addObject:tabVar];
            if ([tabVar intValue]>5) {
                _menu_title = [subDic objectForKey:@"TITLE"];
                _target_url = [subDic objectForKey:@"URL"];
            }
            
            [urls addObject:[subDic objectForKey:@"URL"]];
            [titles addObject:[subDic objectForKey:@"TITLE"]];
            [setTabs addObject:[controllers objectForKey:tabVar]];
            [tabs addObject:tabVar];
           
           if([controllers objectForKey:tabVar] == myMenuView){
              self.isMyMenu = YES;
           }
            
            UINavigationController *tempController = [setTabs objectAtIndex:i];
            NSString *iconVar = [subDic objectForKey:@"ICON"];
            
            tempController.tabBarItem.image = [icons objectAtIndex:[iconVar intValue]-1];
            tempController.tabBarItem.selectedImage = [selectedIcons objectAtIndex:[iconVar intValue]-1];
            tempController.tabBarItem.title = [subDic objectForKey:@"ICONTITLE"];
            tempController.navigationItem.title = [subDic objectForKey:@"TITLE"];
        }
        
    }
    _tabNumberArray = [[NSArray alloc]initWithArray:tabs];
    _titleArray = [[NSArray alloc]initWithArray:titles];
    urlArray = [[NSArray alloc]initWithArray:urls];
    tabArray = [[NSArray alloc]initWithArray:setTabs];
    self.tabBarController.viewControllers = setTabs;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *osVersion = myDevice.systemVersion;
    
    self.tabBarController.view.backgroundColor = [self myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
    
    CGRect frame = CGRectMake(0, 0, 480, 49);
    if (7>[osVersion intValue]>4) {
        [[self.tabBarController tabBar] setTintColor:[self myRGBfromHex:[prefs stringForKey:@"TabBarColor"]]];
        if (_tabFontColor == nil) {
            NSLog(@"_tabFontColor == nil");
            [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[self myRGBfromHex:_mainFontColor]} forState:UIControlStateSelected];
            [self.tabBarController.tabBar setSelectedImageTintColor:[self myRGBfromHex:_mainFontColor]];
        }else{
            NSLog(@"_tabFontColor != nil");
            [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[self myRGBfromHex:_tabFontColor]} forState:UIControlStateSelected];
            [self.tabBarController.tabBar setSelectedImageTintColor:[self myRGBfromHex:_tabFontColor]];
        }
        
    } else if([osVersion intValue]>6){
        [self.tabBarController tabBar].barTintColor = [self myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
        
        
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:introViewController];
       
        float btnWidth = 0;
        if(scrollTabDic.count>5) btnWidth = [[UIScreen mainScreen] bounds].size.width/5.5;
        else if(scrollTabDic.count<=5) btnWidth = [[UIScreen mainScreen] bounds].size.width/scrollTabDic.count;
        float btnHeight = 60;
        
       if([self.tabBarType isEqualToString:@"T"]){
          self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.tabBarController.tabBar.frame.origin.x, nvc.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, self.tabBarController.tabBar.frame.size.width, btnHeight)]; //상단
       } else if([self.tabBarType isEqualToString:@"B"]){
          self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.tabBarController.tabBar.frame.origin.x, self.window.frame.size.height - nvc.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height, self.tabBarController.tabBar.frame.size.width, btnHeight)]; //하단
       }
        
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        
        tabLineArr = [NSMutableArray array];
        
        for(int i=0; i<scrollTabDic.count; i++){
           NSDictionary *subDic = [scrollTabDic objectForKey:[NSString stringWithFormat:@"%d",i+1]];
           NSString *iconVar = nil;
           
           if(![subDic isEqual:@"*"]){
              iconVar = [subDic objectForKey:@"ICON"];
           }
           
            UIButton *tabButton = [[UIButton alloc] initWithFrame:CGRectMake(i*btnWidth, 0, btnWidth, btnHeight)];
            tabButton.backgroundColor = [self myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
            [tabButton setTintColor:[self myRGBfromHex:_tabFontColor]];
        
            UIButton *tabLineBtn;
            if([self.tabBarType isEqualToString:@"T"]){
                tabLineBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*btnWidth, btnHeight-5, btnWidth, 5)];
                
            } else if([self.tabBarType isEqualToString:@"B"]){
                tabLineBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*btnWidth, 0, btnWidth, 5)];
            }
            
            tabLineBtn.backgroundColor = [UIColor clearColor];
            [tabLineBtn setTag:i+1];
            
           if(tabLineBtn.tag==1) tabLineBtn.backgroundColor = /*[self myRGBfromHex:@"0093d5"];*/ [self myRGBfromHex:_tabFontColor];
            
            [tabLineArr addObject:tabLineBtn];
            
            if([self.tabTitleType isEqualToString:@"T"]){
                NSDictionary *attrDict = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],NSForegroundColorAttributeName : [self myRGBfromHex:_tabFontColor]};
                NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
                [attString appendAttributedString:[[NSAttributedString alloc] initWithString:[_titleArray objectAtIndex:i] attributes:attrDict]];
    
                [tabButton setAttributedTitle:attString forState:UIControlStateNormal];
            }

           
            [tabButton setImage:[icons objectAtIndex:[iconVar integerValue]-1] forState:UIControlStateNormal];
            
            CGFloat spacing = 0.0;
            
            CGSize imageSize = tabButton.imageView.image.size;
            tabButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing)-2, 0.5);

            CGSize titleSize = [tabButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: tabButton.titleLabel.font}];
            tabButton.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
            
            [tabButton setTag:i+1];
            [tabButton addTarget:self action:@selector(didTapClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.scrollView addSubview:tabButton];
            [self.scrollView addSubview:tabLineBtn];
        }
        
        if(scrollTabDic.count>5) self.scrollView.contentSize = CGSizeMake(btnWidth*scrollTabDic.count, btnHeight);
        else if(scrollTabDic.count<=5) self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, btnHeight);
        [self.tabBarController.view addSubview:self.scrollView];
    }
    else{
        UIView *v = [[UIView alloc] initWithFrame:frame];
        [v setBackgroundColor:[self myRGBfromHex:[prefs stringForKey:@"TabBarColor"]]];
        [v setAlpha:0.5];
        [[self.tabBarController tabBar] addSubview:v];
    }
}

-(void)selectTabLine:(NSInteger)selectedTab{
    //NSLog(@"tabLineArr : %@", tabLineArr);
    
    for(int i=0; i<tabLineArr.count; i++){
        UIButton *lineBtn = [tabLineArr objectAtIndex:i];
        
        if(lineBtn.tag == selectedTab){
            lineBtn.backgroundColor = /*[self myRGBfromHex:@"0093d5"];*/ [self myRGBfromHex:_tabFontColor];
            
        } else {
            lineBtn.backgroundColor = [UIColor clearColor];
        }
    }
}


- (void)didTapClick:(UIButton *)sender{
    self.selectTabNo = sender.tag;
 
    [self selectTabLine:sender.tag];
    
    switch (sender.tag) {
        case 1:
        {
            _menu_title = [_titleArray objectAtIndex:0];
            _target_url = [urlArray objectAtIndex:0];
            self.tabBarController.selectedIndex = 0;
            break;
        }
        case 2:
        {
            _menu_title = [_titleArray objectAtIndex:1];
            _target_url = [urlArray objectAtIndex:1];
            self.tabBarController.selectedIndex = 1;
            break;
        }
        case 3:
        {
            _menu_title = [_titleArray objectAtIndex:2];
            _target_url = [urlArray objectAtIndex:2];
            self.tabBarController.selectedIndex = 2;
            break;
        }
        case 4:
        {
            _menu_title = [_titleArray objectAtIndex:3];
            _target_url = [urlArray objectAtIndex:3];
            self.tabBarController.selectedIndex = 3;
            break;
        }
        case 5:
        {
            _menu_title = [_titleArray objectAtIndex:4];
            _target_url = [urlArray objectAtIndex:4];
            self.tabBarController.selectedIndex = 4;
            break;
        }
        case 6:
        {
            _menu_title = [_titleArray objectAtIndex:5];
            _target_url = [urlArray objectAtIndex:5];
            self.tabBarController.selectedIndex = 5;
            break;
        }
        default:
            break;
    }
    
    
    //선택된 탭바 인덱스
    NSInteger tabIndex = self.tabBarController.selectedIndex;
    UINavigationController *temp = [tabArray objectAtIndex:tabIndex];
    
    UINavigationController *exit = [controllers objectForKey:@"5"];
    UINavigationController *web1 = [controllers objectForKey:@"6"];
    UINavigationController *web2 = [controllers objectForKey:@"7"];
    UINavigationController *web3 = [controllers objectForKey:@"8"];
    UINavigationController *web4 = [controllers objectForKey:@"9"];
    UINavigationController *web5 = [controllers objectForKey:@"10"];
    UINavigationController *web6 = [controllers objectForKey:@"11"];
    UINavigationController *main = [controllers objectForKey:@"1"];
    UINavigationController *mymenu = [controllers objectForKey:@"3"];
    UINavigationController *notice = [controllers objectForKey:@"2"];
    UINavigationController *setting = [controllers objectForKey:@"4"];
   
   _isWebviewTab = NO;
    
    if (![temp isEqual:exit]) {
        _pre_tabID = tabIndex;
    }
    if ([temp isEqual:exit]) {
        NSLog(@"_pre_tabID : %ld",(long)_pre_tabID);
        self.tabBarController.selectedIndex = _pre_tabID;
        
        //self._menu_title = self.preTitleName;
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message49", @"") message:nil delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""), nil];
        [alert show];
        
    } else if([temp isEqual:web1]||[temp isEqual:web2]||[temp isEqual:web3]||[temp isEqual:web4]||[temp isEqual:web5]||[temp isEqual:web6]){
        _isMainWebView = YES;
        if (_isOffLine) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message112", @"")];
        }
        _pre_tabID = tabIndex;
        _menu_title = [_titleArray objectAtIndex:tabIndex];
        if ([[[urlArray objectAtIndex:tabIndex] substringToIndex:4] isEqualToString:@"http"]||[[[urlArray objectAtIndex:tabIndex] substringToIndex:5] isEqualToString:@"https"]) {
            _target_url = [urlArray objectAtIndex:tabIndex];
            NSLog(@"_target_url : %@",_target_url);
           
           if([[_target_url lastPathComponent] isEqualToString:@"surveyList"]) _isWebviewTab = YES;
           else _isWebviewTab = NO;
           
        }else {
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            documentFolder = [documentFolder stringByAppendingString:@"/WebApp"];
            NSString *htmlFilePath = [documentFolder stringByAppendingFormat:@"/html/%@",[urlArray objectAtIndex:tabIndex]];
            
            _target_url = htmlFilePath;
        }
        
    } else if([temp isEqual:main]){
        _pre_tabID = tabIndex;
        _menu_title = _preMainTitle;
        _target_url = [urlArray objectAtIndex:tabIndex];
    } else if([temp isEqual:mymenu]){
        _pre_tabID = tabIndex;
        _menu_title = [_titleArray objectAtIndex:tabIndex];
        _target_url = [urlArray objectAtIndex:tabIndex];
    } else if([temp isEqual:notice]){
        _noticeTitle = [_titleArray objectAtIndex:tabIndex];
        _target_url = _preURL;
    } else if([temp isEqual:setting]){
        _menu_title = [_titleArray objectAtIndex:tabIndex];
        _target_url = _preURL;
    }
    
    
    
}


-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
	//선택된 탭바 인덱스
	NSInteger tabIndex = tabBarController.selectedIndex;
    UINavigationController *temp = [tabArray objectAtIndex:tabIndex];
    
    UINavigationController *exit = [controllers objectForKey:@"5"];
    UINavigationController *web1 = [controllers objectForKey:@"6"];
    UINavigationController *web2 = [controllers objectForKey:@"7"];
    UINavigationController *web3 = [controllers objectForKey:@"8"];
    UINavigationController *web4 = [controllers objectForKey:@"9"];
    UINavigationController *web5 = [controllers objectForKey:@"10"];
    UINavigationController *web6 = [controllers objectForKey:@"11"];
    UINavigationController *main = [controllers objectForKey:@"1"];
    UINavigationController *mymenu = [controllers objectForKey:@"3"];
    UINavigationController *notice = [controllers objectForKey:@"2"];
    UINavigationController *setting = [controllers objectForKey:@"4"];
   
    _isWebviewTab = NO;
   
    if (![temp isEqual:exit]) {
        _pre_tabID = tabIndex;
    }
    if ([temp isEqual:exit]) {
       NSLog(@"_pre_tabID : %ld",(long)_pre_tabID);
        self.tabBarController.selectedIndex = _pre_tabID;
        
        //self._menu_title = self.preTitleName;
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message49", @"") message:nil delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""), nil];
        [alert show];
        
    } else if([temp isEqual:web1]||[temp isEqual:web2]||[temp isEqual:web3]||[temp isEqual:web4]||[temp isEqual:web5]||[temp isEqual:web6]){
        _isMainWebView = YES;
        if (_isOffLine) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message112", @"")];
        }
        _pre_tabID = tabIndex;
        _menu_title = [_titleArray objectAtIndex:tabIndex];
        if ([[[urlArray objectAtIndex:tabIndex] substringToIndex:4] isEqualToString:@"http"]||[[[urlArray objectAtIndex:tabIndex] substringToIndex:5] isEqualToString:@"https"]) {
            _target_url = [urlArray objectAtIndex:tabIndex];
            NSLog(@"_target_url : %@",_target_url);
           
           if([[_target_url lastPathComponent] isEqualToString:@"surveyList"]) _isWebviewTab = YES;
           else _isWebviewTab = NO;
           
        }else {
            
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            documentFolder = [documentFolder stringByAppendingString:@"/WebApp"];
            NSString *htmlFilePath = [documentFolder stringByAppendingFormat:@"/html/%@",[urlArray objectAtIndex:tabIndex]];
            
            _target_url = htmlFilePath;
        }
        
    } else if([temp isEqual:main]){
        _pre_tabID = tabIndex;
        _menu_title = _preMainTitle;
        _target_url = [urlArray objectAtIndex:tabIndex];
    } else if([temp isEqual:mymenu]){
        _pre_tabID = tabIndex;
        _menu_title = [_titleArray objectAtIndex:tabIndex];
        _target_url = [urlArray objectAtIndex:tabIndex];
    } else if([temp isEqual:notice]){
        _noticeTitle = [_titleArray objectAtIndex:tabIndex];
        _target_url = _preURL;
    } else if([temp isEqual:setting]){
        _menu_title = [_titleArray objectAtIndex:tabIndex];
        _target_url = _preURL;
    }
}
#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [SVProgressHUD dismiss];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
   NSLog(@"statusCode : %ld",(long)statusCode);
    
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    
    if([methodName isEqualToString:@"GetExecuteMenuInfo"]){
        if(statusCode == 404 || statusCode == 500){
            [SVProgressHUD dismiss];
        }
    }else if([methodName isEqualToString:@"MLogout"]){
       if(self.isMDM){
//          if([self.mdmFlag isEqualToString:@"T"]){
//             NSString * stringURLScheme = nil;
//             BOOL isBe;
//             NSArray * URLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
//             if (URLTypes && [URLTypes count]) {
//                NSDictionary * dict = [URLTypes objectAtIndex:0];
//                NSArray * CFBundleURLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
//                if (CFBundleURLSchemes && [CFBundleURLSchemes count]) {
//                   stringURLScheme = [CFBundleURLSchemes objectAtIndex:0];
//                }
//             }
//             _mdmCallAPI = @"exitWorkApp";
//             NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=exitWorkApp"];
//
//             [urlString appendFormat:@"&caller=%@", stringURLScheme];
//             NSLog(@"urlString : %@",urlString);
//             isBe = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
          
             _mdmCallAPI = @"exitWorkApp";
             
             NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
             NSString *authToken = [prefs objectForKey:@"MDM_AUTH_TOKEN"];
             NSString *urlString = [NSString stringWithFormat:@"https://mdm.hhi.co.kr/mdm_admin_server/mdmApi/exitWorkApp?authToken=%@&osType=IOS", authToken];
             NSError *error;
              
             NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString] options:NSDataReadingUncached error:&error];
             NSString *returnStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[returnStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
             if([dataDic objectForKey:@"result"]){
                 [SVProgressHUD dismiss];
                 NSLog(@"MDM 업무앱 종료정책이 적용되었습니다.");
                 exit(0);
             } else {
                 [SVProgressHUD dismiss];
                 NSLog(@"MDM 업무앱 종료정책이 적용되지 않았습니다.");
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MDM 업무앱 종료정책이 적용되지 않았습니다.", @"MDM 업무앱 종료정책이 적용되지 않았습니다.") message:nil preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                                                   exit(0);
                                                               }];
                 [alert addAction:okButton];
                 [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
             }
             
//          } else {
//             exit(0);
//          }
          
       } else {
          exit(0);
       }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"didReceiveData");
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    NSLog(@"%s methodName : %@",__FUNCTION__,methodName);
    if([methodName isEqualToString:@"GetExecuteMenuInfo"]){
        [self.receiveData appendData:data];
    }else{
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"str : %@",[str AES256DecryptWithKeyString:_AES256Key]);
    }
    
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"connectionDidFinishLoading");
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    
    if([methodName isEqualToString:@"GetExecuteMenuInfo"]){
        NSString *encString =[[NSString alloc]initWithData:self.receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (self.isAES256) {
            decString = [encString AES256DecryptWithKeyString:self.AES256Key];
        }
        else{
            decString = encString;
        }
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        NSLog(@"dic : %@",dic);
        [SVProgressHUD dismiss];
        
    }else{
        
    }
}
#pragma mark
#pragma mark UIAlertView Delegate
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    //AlterView 버튼이 클릭되었을때 실행
    if (alert.tag == 101) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",_main_url]]];
        [request setHTTPMethod:@"POST"];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        [conn start];
        //exit(0);
    } else if(alert.tag == 104){
       if (buttonIndex == 1) {
          NSArray *nvcChild = [_tabBarController selectedViewController].childViewControllers;
          [[NSNotificationCenter defaultCenter] postNotificationName:@"ExecutePush" object:[nvcChild objectAtIndex:nvcChild.count-1] userInfo:_userInfo];
       }
    
    }else{
        if ([alert.title isEqualToString:NSLocalizedString(@"message152", @"")]) {
            exit(0);
        }else{
            if (buttonIndex == 0) {
                if ([alert.title isEqualToString:NSLocalizedString(@"message49", @"프로그램을 종료하시겠습니까?")]) {
                    if (_isOffLine) {
                        exit(0);
                    }else{
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",_main_url]]];
                        [request setHTTPMethod:@"POST"];
                        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
                        [conn start];
                    }
                    
                }else if([alert.title isEqualToString:@"Lost Device"]){
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",_main_url]]];
                    [request setHTTPMethod:@"POST"];
                    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
                    [conn start];
                }
            } else if(buttonIndex == 1) {
                [alert dismissWithClickedButtonIndex:buttonIndex animated:YES];
            }
        }
        
    }
    
    
}
#pragma mark - UNUserNotificationCenterDelegate
- (void) receiveNotification:(NSDictionary *)userInfo{
    UIApplication *application = [UIApplication sharedApplication];
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSDictionary *alert = [aps valueForKey:@"alert"];
    
    NSString *type = [userInfo valueForKey:@"type"];
    NSString *type2 = [userInfo valueForKey:@"type2"];
    
    NSString *badge = [aps valueForKey:@"badge"];
    NSString *contentsMessage = @"";
    if (![_demo isEqualToString:@"DEMO"]) {
        [[UIApplication sharedApplication]setApplicationIconBadgeNumber:[badge intValue]];
        if (application.applicationIconBadgeNumber!=0) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[_noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%ld",(long)application.applicationIconBadgeNumber]];
        }else{
            [[[[[self tabBarController] tabBar] items]objectAtIndex:[_noticeTabBarNumber intValue]]setBadgeValue:nil];
        }
        if ([type isEqualToString:@"notice"]) {
            self.tabBarController.selectedIndex = [_noticeTabBarNumber intValue];
            if ([badge intValue]>0) {
                [[[[[self tabBarController] tabBar] items] objectAtIndex:[_noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",[badge intValue]]];
            }
        } else {
            [[[[[self tabBarController] tabBar] items]objectAtIndex:[_noticeTabBarNumber intValue]]setBadgeValue:nil];
        }
    }
    
    UIApplicationState state = [application applicationState];
    NSLog(@"receiveNotification userInfo : %@",userInfo);
    
    if (state==UIApplicationStateActive) {
        NSLog(@"stateActive");
        if (_isLogin) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            UIAlertView *alertView;
            
            if ([type isEqualToString:@"M1"]) {
                if ([type2 isEqualToString:@"DEL_MENU"]) {
                    contentsMessage = NSLocalizedString(@"message122", @"");
                }else if ([type2 isEqualToString:@"DEL_DEVICE"]) {
                    contentsMessage = NSLocalizedString(@"message123", @"");
                }else if ([type2 isEqualToString:@"SUS_DEVICE"]) {
                    contentsMessage = NSLocalizedString(@"message124", @"");
                }else if ([type2 isEqualToString:@"DEL_USER"]) {
                    contentsMessage = NSLocalizedString(@"message125", @"");
                }else if ([type2 isEqualToString:@"SUS_USER"]) {
                    contentsMessage = NSLocalizedString(@"message126", @"");
                }
               
               NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
               [prefs removeObjectForKey:@"UserInfo_ID"];
               [prefs removeObjectForKey:@"isSave"];
               [prefs removeObjectForKey:@"AutoLogin_ID"];
               [prefs removeObjectForKey:@"AutoLogin_PWD"];
               [prefs removeObjectForKey:@"isAutoLogin"];
               [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
               [prefs synchronize];
               
                alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 101;
               
            }else if ([type isEqualToString:@"M2"]) {
                [self removeData];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message152", @"") message:NSLocalizedString(@"message153", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
               
            }else if ([type isEqualToString:@"M3"]) {
               NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
               [prefs removeObjectForKey:@"UserInfo_ID"];
               [prefs removeObjectForKey:@"isSave"];
               [prefs removeObjectForKey:@"AutoLogin_ID"];
               [prefs removeObjectForKey:@"AutoLogin_PWD"];
               [prefs removeObjectForKey:@"isAutoLogin"];
               [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
               [prefs synchronize];
               
               [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:userInfo];
               alertView = [[UIAlertView alloc]initWithTitle:@"Message" message:[alert valueForKey:@"body"] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
               alertView.tag = 103;
               
            }else if([type isEqualToString:@"E"]){
                _userInfo = userInfo;
                if (_isLogin) {
                    alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:[alert valueForKey:@"body"] delegate:self cancelButtonTitle:NSLocalizedString(@"message52", @"") otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                    alertView.tag = 104;
                }else{
                    _receivePush = YES;
                    _receiveMenuNo = [userInfo objectForKey:@"menuNo"];
                }
            }
            else if([type isEqualToString:@"notice"]||[type isEqualToString:@"P1"]){
                alertView = [[UIAlertView alloc]initWithTitle:@"Notice" message:[alert valueForKey:@"body"] delegate:self cancelButtonTitle:NSLocalizedString(@"message52", @"") otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 102;
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:userInfo];
                alertView = [[UIAlertView alloc]initWithTitle:@"Message" message:[alert valueForKey:@"body"] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 103;
            }
            [alertView show];
        }
        
        
    }else if(state == UIApplicationStateBackground){
       NSLog(@"stateBackground");
        if ([type isEqualToString:@"M2"]) {
            [self removeData];
           
        }else if ([type isEqualToString:@"M1"]) {
            UIAlertView *alertView;
            if ([type2 isEqualToString:@"DEL_MENU"]) {
                contentsMessage = NSLocalizedString(@"message122", @"");
            }else if ([type2 isEqualToString:@"DEL_DEVICE"]) {
                contentsMessage = NSLocalizedString(@"message123", @"");
            }else if ([type2 isEqualToString:@"SUS_DEVICE"]) {
                contentsMessage = NSLocalizedString(@"message124", @"");
            }else if ([type2 isEqualToString:@"DEL_USER"]) {
                contentsMessage = NSLocalizedString(@"message125", @"");
            }else if ([type2 isEqualToString:@"SUS_USER"]) {
                contentsMessage = NSLocalizedString(@"message126", @"");
            }
           
           NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
           [prefs removeObjectForKey:@"UserInfo_ID"];
           [prefs removeObjectForKey:@"isSave"];
           [prefs removeObjectForKey:@"AutoLogin_ID"];
           [prefs removeObjectForKey:@"AutoLogin_PWD"];
           [prefs removeObjectForKey:@"isAutoLogin"];
           [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
           [prefs synchronize];
           
            alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
            alertView.tag = 101;
            [alertView show];
           
        }else if([type isEqualToString:@"M3"]){
           NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
           [prefs removeObjectForKey:@"UserInfo_ID"];
           [prefs removeObjectForKey:@"isSave"];
           [prefs removeObjectForKey:@"AutoLogin_ID"];
           [prefs removeObjectForKey:@"AutoLogin_PWD"];
           [prefs removeObjectForKey:@"isAutoLogin"];
           [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
           [prefs synchronize];
           
        }else if([type isEqualToString:@"E"]){
            _userInfo = userInfo;
            if (_isLogin) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:[alert valueForKey:@"body"] delegate:self cancelButtonTitle:NSLocalizedString(@"message52", @"") otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 104;
                [alertView show];
            }else{
                _receivePush = YES;
                _receiveMenuNo = [userInfo objectForKey:@"menuNo"];
            }
            
        }
      
    }else if(state == UIApplicationStateInactive){
       NSLog(@"stateInactive");
        if([type isEqualToString:@"M1"]){
            if(_isLogin){
                if ([type2 isEqualToString:@"DEL_MENU"]) {
                    contentsMessage = NSLocalizedString(@"message122", @"");
                }else if ([type2 isEqualToString:@"DEL_DEVICE"]) {
                    contentsMessage = NSLocalizedString(@"message123", @"");
                }else if ([type2 isEqualToString:@"SUS_DEVICE"]) {
                    contentsMessage = NSLocalizedString(@"message124", @"");
                }else if ([type2 isEqualToString:@"DEL_USER"]) {
                    contentsMessage = NSLocalizedString(@"message125", @"");
                }else if ([type2 isEqualToString:@"SUS_USER"]) {
                    contentsMessage = NSLocalizedString(@"message126", @"");
                }
               
               NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
               [prefs removeObjectForKey:@"UserInfo_ID"];
               [prefs removeObjectForKey:@"isSave"];
               [prefs removeObjectForKey:@"AutoLogin_ID"];
               [prefs removeObjectForKey:@"AutoLogin_PWD"];
               [prefs removeObjectForKey:@"isAutoLogin"];
               [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
               [prefs synchronize];
               
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 101;
                [alertView show];
            }
            
        }else if ([type isEqualToString:@"M2"]) {
            [self removeData];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message152", @"") message:NSLocalizedString(@"message153", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
           
        }else if ([type isEqualToString:@"M3"]) {
           NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
           [prefs removeObjectForKey:@"UserInfo_ID"];
           [prefs removeObjectForKey:@"isSave"];
           [prefs removeObjectForKey:@"AutoLogin_ID"];
           [prefs removeObjectForKey:@"AutoLogin_PWD"];
           [prefs removeObjectForKey:@"isAutoLogin"];
           [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
           [prefs synchronize];
           
        }else if([type isEqualToString:@"E"]){
            _userInfo = userInfo;
            if (_isLogin) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:[alert valueForKey:@"body"] delegate:self cancelButtonTitle:NSLocalizedString(@"message52", @"") otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 104;
                [alertView show];
            }else{
                _receivePush = YES;
                _receiveMenuNo = [userInfo objectForKey:@"menuNo"];
            }
            
        }
    }
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"%s notification : %@",__FUNCTION__,notification.request.content.userInfo);
    NSDictionary *userInfo = notification.request.content.userInfo;
    [self receiveNotification:userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"response.notification.request.content.userInfo : %@",response.notification.request.content.userInfo);
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
    {
        NSLog( @"INACTIVE" );
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        [self receiveNotification:userInfo];
       
    } else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground ) {
        NSLog( @"BACKGROUND" );
    }
   
   completionHandler();
}

#pragma mark
#pragma mark Push Delegate Method
//push : APNS 에 장치 등록 성공시 자동실행
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
   [FIRMessaging messaging].APNSToken = deviceToken;
   
	if (@available(iOS 13.0, *)) {
        self.appDeviceToken = [self stringFromDeviceToken:deviceToken];
        
    } else {
        self.appDeviceToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        self.appDeviceToken = [self.appDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
   
   NSLog(@"deviceToken : %@", self.appDeviceToken);
	
}

- (NSString *)stringFromDeviceToken:(NSData *)deviceToken {
    NSUInteger length = deviceToken.length;
    if (length == 0) {
        return nil;
    }
    const unsigned char *buffer = deviceToken.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(length * 2)];
    for (int i = 0; i < length; ++i) {
        [hexString appendFormat:@"%02x", buffer[i]];
    }
    return [hexString copy];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetch:(void (^)(UIBackgroundFetchResult result))handler{
    NSLog(@"didReceiveRemoteNotification");
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    
    NSString *type = [userInfo valueForKey:@"type"];
    //NSString *type2 = [userInfo valueForKey:@"type2"];
    
    NSString *badge = [aps valueForKey:@"badge"];
    if (![_demo isEqualToString:@"DEMO"]) {
        [[UIApplication sharedApplication]setApplicationIconBadgeNumber:[badge intValue]];
        if (application.applicationIconBadgeNumber!=0) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[_noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%ld",(long)application.applicationIconBadgeNumber]];
        }else{
            [[[[[self tabBarController] tabBar] items]objectAtIndex:[_noticeTabBarNumber intValue]]setBadgeValue:nil];
        }
        if ([type isEqualToString:@"notice"]) {
            self.tabBarController.selectedIndex = [_noticeTabBarNumber intValue];
            if ([badge intValue]>0) {
                [[[[[self tabBarController] tabBar] items] objectAtIndex:[_noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",[badge intValue]]];
            }
        }
        else {
            [[[[[self tabBarController] tabBar] items]objectAtIndex:[_noticeTabBarNumber intValue]]setBadgeValue:nil];
        }
    }
//    [self receiveNotification:userInfo];
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    [self receiveNotification:userInfo];
}
#pragma mark
#pragma mark Util Method

- (BOOL)isIphoneX {
   if (CGRectEqualToRect([UIScreen mainScreen].bounds,CGRectMake(0, 0, 375, 812))) {
      return YES;
   } else {
      return NO;
   }
}

+ (void) checkWebappDirectory:(NSString *)menuNo{
    NSLog(@"%s",__FUNCTION__);
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *tmpFolder = [documentFolder stringByAppendingPathComponent:@"10"];
    tmpFolder = [tmpFolder stringByAppendingPathComponent:@"webapp"];
    if (menuNo!=nil) {
        tmpFolder = [tmpFolder stringByAppendingPathComponent:menuNo];
    }
    NSArray *list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmpFolder error:nil];
    NSLog(@"tmpFolder : %@",tmpFolder);
    NSLog(@"File List : %@", list);
}
+ (NSString *) getUUID
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
    
    return uuid;
}
- (UIColor *) myRGBfromHex: (NSString *) code {
    
    NSString *str = [[code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([str length] < 6)  // 일단 6자 이하면 말이 안되니까 검은색을 리턴해주자.
        return [UIColor blackColor];
    
    // 0x로 시작하면 0x를 지워준다.
    if ([str hasPrefix:@"0X"])
        str = [str substringFromIndex:2];
    
    // #으로 시작해도 #을 지워준다.
    
    if ([str hasPrefix:@"#"])
        str = [str substringFromIndex:1];
    if ([str length] != 6) //그랫는데도 6자 이하면 이것도 이상하니 그냥 검은색을 리턴해주자.
        return [UIColor blackColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rcolorString = [str substringWithRange:range];
    range.location = 2;
    NSString *gcolorString = [str substringWithRange:range];
    range.location = 4;
    NSString *bcolorString = [str substringWithRange:range];
    unsigned int red, green, blue;
    [[NSScanner scannerWithString: rcolorString] scanHexInt:&red];
    [[NSScanner scannerWithString: gcolorString] scanHexInt:&green];
    [[NSScanner scannerWithString: bcolorString] scanHexInt:&blue];
    
    
    return [UIColor colorWithRed:((float) red / 255.0f)
                           green:((float) green / 255.0f)
                            blue:((float) blue / 255.0f)
                           alpha:1.0f];
}

- (UIColor *) myRGBfromHex: (NSString *) code :(float)alpha{
   
   NSString *str = [[code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
   if ([str length] < 6)  // 일단 6자 이하면 말이 안되니까 검은색을 리턴해주자.
      return [UIColor blackColor];
   
   // 0x로 시작하면 0x를 지워준다.
   if ([str hasPrefix:@"0X"])
      str = [str substringFromIndex:2];
   
   // #으로 시작해도 #을 지워준다.
   
   if ([str hasPrefix:@"#"])
      str = [str substringFromIndex:1];
   if ([str length] != 6) //그랫는데도 6자 이하면 이것도 이상하니 그냥 검은색을 리턴해주자.
      return [UIColor blackColor];
   NSRange range;
   range.location = 0;
   range.length = 2;
   NSString *rcolorString = [str substringWithRange:range];
   range.location = 2;
   NSString *gcolorString = [str substringWithRange:range];
   range.location = 4;
   NSString *bcolorString = [str substringWithRange:range];
   unsigned int red, green, blue;
   [[NSScanner scannerWithString: rcolorString] scanHexInt:&red];
   [[NSScanner scannerWithString: gcolorString] scanHexInt:&green];
   [[NSScanner scannerWithString: bcolorString] scanHexInt:&blue];
   
   
   return [UIColor colorWithRed:((float) red / 255.0f)
                          green:((float) green / 255.0f)
                           blue:((float) blue / 255.0f)
                          alpha:alpha];
}
+ (UIColor *) myRGBfromHex: (NSString *) code {
    
    NSString *str = [[code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([str length] < 6)  // 일단 6자 이하면 말이 안되니까 검은색을 리턴해주자.
        return [UIColor blackColor];
    
    // 0x로 시작하면 0x를 지워준다.
    if ([str hasPrefix:@"0X"])
        str = [str substringFromIndex:2];
    
    // #으로 시작해도 #을 지워준다.
    
    if ([str hasPrefix:@"#"])
        str = [str substringFromIndex:1];
    if ([str length] != 6) //그랫는데도 6자 이하면 이것도 이상하니 그냥 검은색을 리턴해주자.
        return [UIColor blackColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rcolorString = [str substringWithRange:range];
    range.location = 2;
    NSString *gcolorString = [str substringWithRange:range];
    range.location = 4;
    NSString *bcolorString = [str substringWithRange:range];
    unsigned int red, green, blue;
    [[NSScanner scannerWithString: rcolorString] scanHexInt:&red];
    [[NSScanner scannerWithString: gcolorString] scanHexInt:&green];
    [[NSScanner scannerWithString: bcolorString] scanHexInt:&blue];
    
    
    return [UIColor colorWithRed:((float) red / 255.0f)
                           green:((float) green / 255.0f)
                            blue:((float) blue / 255.0f)
                           alpha:1.0f];
}
+ (NSString *)getAES256Key{
    return @"E3Z2S1M5A9R8T1F3E2E4L31504081532";
}
-(void)removeData{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs removeObjectForKey:@"URL_INFO"];
    [prefs removeObjectForKey:@"UserInfo_ID"];
    [prefs removeObjectForKey:@"isSave"];
    [prefs removeObjectForKey:@"Update"];
    [prefs removeObjectForKey:@"COMMON_DOWNLOAD"];
    [prefs removeObjectForKey:@"IntroCount"];
    [prefs removeObjectForKey:@"IntroImagePath"];
    [prefs removeObjectForKey:@"LOGINOFFCOLOR"];
    [prefs removeObjectForKey:@"LOGINONCOLOR"];
    [prefs removeObjectForKey:@"LoginImagePath"];
    [prefs removeObjectForKey:@"MAINFONTCOLOR"];
    [prefs removeObjectForKey:@"MainBgFilePath"];
    [prefs removeObjectForKey:@"NAVIBARCOLOR"];
    [prefs removeObjectForKey:@"NAVIFONTCOLOR"];
    [prefs removeObjectForKey:@"NAVIISSHADOW"];
    [prefs removeObjectForKey:@"NAVISHADOWCOLOR"];
    [prefs removeObjectForKey:@"NAVISHAODWOFFSET"];
    [prefs removeObjectForKey:@"OFFLINE_FLAG"];
    [prefs removeObjectForKey:@"OFFLINE_ID"];
    [prefs removeObjectForKey:@"RES_VER"];
    [prefs removeObjectForKey:@"SubOffButtonFilePath"];
    [prefs removeObjectForKey:@"SubBgFilePath"];
    [prefs removeObjectForKey:@"SubOnButtonFilePath"];
    [prefs removeObjectForKey:@"TabBarColor"];
   [prefs removeObjectForKey:@"AutoLogin_ID"];
   [prefs removeObjectForKey:@"AutoLogin_PWD"];
   [prefs removeObjectForKey:@"isAutoLogin"];
   [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
    [prefs synchronize];
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [arrayPaths objectAtIndex:0];
    NSFileManager *manager =[NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];

    for (int i=0; i<[fileList count]; i++) {
        NSString *str = [fileList objectAtIndex:i];
        NSString *fileName = [docDir stringByAppendingPathComponent:str];
        
        //if (![[fileName lastPathComponent] isEqualToString:@"URLConnectionInfo.plist"]) {
            [manager removeItemAtPath:fileName error:NULL];
        //}
    }
    NSString *LibraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    LibraryPath = [LibraryPath stringByAppendingPathComponent:@"Application Support"];
    LibraryPath = [LibraryPath stringByAppendingPathComponent:@"oracle"];
    NSString *filePath = LibraryPath;
    if ([manager isReadableFileAtPath:filePath]) {
        [manager removeItemAtPath:filePath error:nil];
    }
    
}
+ (NSData *) getDecodeData:(NSData *)data{
    NSString *seedString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    seedString = [NSString decodeString:seedString];
    
    return [seedString dataUsingEncoding:NSUTF8StringEncoding];
}
+ (NSDictionary *)getAllValueUrlDecoding:(NSDictionary *)dic{
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc]init];
    for (NSString *key in [dic allKeys]) {
        NSString *oValue = [dic objectForKey:key];
        oValue =[oValue stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
        [resultDic setObject:[oValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:key];
    }
    return resultDic;
}

+ (NSString *)deviceNetworkingType
{
   NSString *strNetworkInfo = @"No wifi or cellular";
   struct sockaddr_storage zeroAddress;
   bzero(&zeroAddress,sizeof(zeroAddress)); zeroAddress.ss_len = sizeof(zeroAddress);
   zeroAddress.ss_family = AF_INET;
   // Recover reachability flags
   SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL,(struct sockaddr *)&zeroAddress);
   SCNetworkReachabilityFlags flags;
   BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability,&flags);
   CFRelease(defaultRouteReachability);
   if(!didRetrieveFlags){ return strNetworkInfo;}
   BOOL isReachable = ((flags & kSCNetworkFlagsReachable)!=0);
   BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired)!=0);
   if(!isReachable || needsConnection) {return strNetworkInfo;}
   if((flags & kSCNetworkReachabilityFlagsConnectionRequired)== 0){
      strNetworkInfo = @"WIFI";
   }
   if(((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0) {
      if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0){
         strNetworkInfo = @"WIFI";
      }
   }
   if ((flags & kSCNetworkReachabilityFlagsIsWWAN) ==kSCNetworkReachabilityFlagsIsWWAN) {
      if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
         CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
         NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
         if (currentRadioAccessTechnology) {
            if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
               //strNetworkInfo =@"4G";
               strNetworkInfo = @"LTE";
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
               strNetworkInfo =@"2G";
            } else {
               strNetworkInfo =@"3G";
            }
         }
      } else {
         if((flags & kSCNetworkReachabilityFlagsReachable) == kSCNetworkReachabilityFlagsReachable) {
            if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection) {
               if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {
                  strNetworkInfo =@"2G";
               } else {
                  strNetworkInfo =@"3G";
               }
            }
         }
      }
   }
   return strNetworkInfo;
}


-(void)loginHistoryToLogFile:(NSString *)loc result:(NSString *)result{
   //로그인이력 저장
   NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
   formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
   NSString *today = [formatter stringFromDate:[NSDate date]];
   NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
   NSString *compFolder = [documentFolder stringByAppendingFormat:@"/hshi.mobile.ios.mfinity/10"];
//   NSLog(@"compFolder : %@", compFolder);
   
   NSFileManager *fileManager = [NSFileManager defaultManager];
   BOOL issue = [fileManager isReadableFileAtPath:compFolder];
   if (issue) { }
   else {
      [fileManager createDirectoryAtPath:compFolder withIntermediateDirectories:YES attributes:nil error:nil];
   }
   NSString *fileName = [NSString stringWithFormat:@"%@/SmartOne_Login.log", compFolder];
   NSString *dvcTy = @"";
   if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
      dvcTy = @"iPad";
   } else if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
      dvcTy = @"iPhone";
   } else if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomTV){
      dvcTy = @"Apple TV";
   } else if (@available(iOS 14.0, *)) {
      if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomMac){
         dvcTy = @"iMac";
      }
   }  else if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomCarPlay){
      dvcTy = @"CarPlay";
   }  else if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomUnspecified){
      dvcTy = @"Unspecified";
   }else {
      dvcTy = @"none";
   }
   NSString *modelName = [[UIDevice currentDevice] modelName];
   if(result==nil) result = @"-";
   
   NSString *content = [NSString stringWithFormat:@"[ %@ ] %@ \nUSER_ID : %@ (%@) \nDVC_ID : %@ \nDVC_TY : %@ (%@) \nDVC_OS : %@ \nAPP_VER : %@ \nRESULT : %@ \n\n\n", today, loc, self.user_id, self.user_no, [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"], dvcTy, modelName, [[UIDevice currentDevice] systemVersion], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], result];
//   NSLog(@"content : %@", content);
   
   NSError* error = nil;
   if(![fileManager fileExistsAtPath:fileName]) {
      [content writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
      
   } else {
      NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
      
      NSDictionary *attr = [fileManager attributesOfItemAtPath:fileName error:NULL];
//      NSLog(@"생성날짜 : %@ / 수정날짜 : %@", [attr objectForKey:NSFileCreationDate], [attr objectForKey:NSFileModificationDate]);
      
      //오늘날짜
      NSDate *todayDate = [NSDate date];
      NSDate *modDate = [attr objectForKey:NSFileModificationDate];
      NSCalendar *sysCalendar = [NSCalendar currentCalendar];
      unsigned int unitFlags = NSCalendarUnitDay;
      
      NSDateComponents *clearDayComponent = [[NSDateComponents alloc] init];
      clearDayComponent.day = 30;
      NSCalendar *theCalendar = [NSCalendar currentCalendar];
      NSDate *clearDate = [theCalendar dateByAddingComponents:clearDayComponent toDate:modDate options:0];
      
      NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
      dayComponent.day = 1;
      
      //최근 수정날짜와 오늘 날짜 비교
      NSDate *endDate = [theCalendar dateByAddingComponents:dayComponent toDate:modDate options:0];
      NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:todayDate toDate:endDate options:0];//날짜 비교해서 차이값 추출
      NSInteger date = dateComp.day;
//      NSLog(@"DATE : %lu", date);
      if(date<0){
         [fileHandle seekToEndOfFile];
         [fileHandle writeData:[@"=================================================================================== \n\n\n" dataUsingEncoding:NSUTF8StringEncoding]];
      }
      
      NSDateComponents *clearDateComp = [sysCalendar components:unitFlags fromDate:todayDate toDate:clearDate options:0];//날짜 비교해서 차이값 추출
      NSInteger resultDate = clearDateComp.day;
//      NSLog(@"resultDate : %lu", resultDate);
      if(resultDate<0){
         //로그파일 초기화
         [fileHandle truncateFileAtOffset:0];
         [fileHandle seekToEndOfFile];
         [fileHandle writeData:[[NSString stringWithFormat:@"지난 데이터 삭제 %@ ========================================== \n\n\n", today] dataUsingEncoding:NSUTF8StringEncoding]];
      }
      
      [fileHandle seekToEndOfFile];
      [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
      [fileHandle closeFile];
   }
}


#pragma mark
#pragma mark


@end
@implementation NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding)));
}
+ (NSString *)urlDecodeString:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                             (CFStringRef)temp,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8));
    return result;
}
- (NSString *)AES256EncryptWithKeyString:(NSString *)key
{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData AES256EncryptWithKey:key];
    
    NSString *encryptedString = [encryptedData base64Encoding];
    
    return encryptedString;
}

- (NSString *)AES256DecryptWithKeyString:(NSString *)key
{
    NSData *encryptedData = [NSData dataWithBase64EncodedString:self];
    NSData *plainData = [encryptedData AES256DecryptWithKey:key];
    
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return plainString;
}

@end
@implementation NSData (NSData_AES256)
- (NSData *)AES256EncryptWithKey:(NSString *)key
{
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
    
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key
{
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}
@end
