//
//  AppDelegate.m
//  Anymate
//
//  Created by Kyeong In Park on 12. 12. 14..
//  Copyright (c) 2012년 Kyeong In Park. All rights reserved.
//

#import "AppDelegate.h"

#import "WebViewController.h"
#import "LoginViewController.h"
#import "WebViewController.h"


@implementation AppDelegate
@synthesize viewController2;
@synthesize appDeviceToken;
@synthesize urlString;
@synthesize model_nm;
@synthesize isPush;
@synthesize isSetting;
@synthesize isSet;
@synthesize appVersion;
@synthesize isSetPush;
@synthesize gwID,gwPW;
@synthesize compNm;
@synthesize pushURL;
@synthesize isLogin, isLogout;
- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

#pragma mark - Firebase
-(void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken{
    self.fcmToken = fcmToken;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.fcmToken forKey:@"DEVICE_TOKEN"];
    [prefs synchronize];
    
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

#pragma mark - App Delegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%s",__FUNCTION__);
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;

    if (@available(iOS 10.0, *)) {
        if ([UNUserNotificationCenter class] != nil) {
          // iOS 10 or later
          // For iOS 10 display notification (sent via APNS)
          [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert|UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
          [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
              NSLog(@"[pushlog] NOT RUNNING : %@", [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]);
              if(launchOptions!=nil) [self receiveNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
          }];
        }
    }
    else {
      // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
      UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
      UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
      [application registerUserNotificationSettings:settings];
    }
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [application registerForRemoteNotifications];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"SOUND_NUMBER"]==nil) {
        [prefs setInteger:0 forKey:@"SOUND_NUMBER"];
        [prefs synchronize];
    }
   
    self.isSet = @"NO";
    self.isLogout = NO;
    self.appDeviceToken = @"";
    self.isLoad = NO;

    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&error];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    //쿠키허용
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

- (void)applicationWillTerminate:(UIApplication *)application{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void) receiveNotification:(NSDictionary *)userInfo{
    NSLog(@"[pushlog] : %s", __func__);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    @try{
        if (self.isLogin) {
            NSDictionary *aps = [userInfo valueForKey:@"aps"];
            
            if([userInfo valueForKey:@"url"]!=nil && ![[userInfo valueForKey:@"url"] isEqual:@""] && ![[userInfo valueForKey:@"url"] isEqual:@"(null)"]){
                self.pushURL = [userInfo valueForKey:@"url"];
        
                [prefs setObject:userInfo forKey:@"PUSH_DICT"];
                [prefs synchronize];
            }
            NSLog(@"[pushlog] receiveNotification pushURL : %@", self.pushURL);

            if([aps valueForKey:@"alert"]!=nil){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"알림" message:[aps valueForKey:@"alert"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                    [prefs removeObjectForKey:@"PUSH_DICT"];
                    [prefs synchronize];
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    if(self.pushURL!=nil && ![self.pushURL isEqualToString:@""]){
                        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
                        NSArray *arr = [navigationController viewControllers];
                        WebViewController *webView = [[navigationController viewControllers]objectAtIndex:[arr count]-1];
                        if (webView != nil) {
                            if ([UIApplication sharedApplication].applicationIconBadgeNumber !=0) {
                                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                            }
                            
                            [webView dismissViewControllerAnimated:YES completion:nil];
                            webView.urlString = self.pushURL;
                            [webView moveToPage];
                        }
                    }
                }];
                
                [alert addAction:cancelButton];
                [alert addAction:okButton];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
        
    } @catch(NSException *e){
        
    }
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [FIRMessaging messaging].APNSToken = deviceToken;
    
    if (@available(iOS 13.0, *)) {
        self.appDeviceToken = [self stringFromDeviceToken:deviceToken];
        
    } else {
        self.appDeviceToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        self.appDeviceToken = [self.appDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    NSLog(@"self.appDeviceToken : %@",self.appDeviceToken);
    
//    FCM 토큰 사용으로 주석처리
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    [prefs setObject:self.appDeviceToken forKey:@"DEVICE_TOKEN"];
//    [prefs synchronize];
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

/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"[pushlog] 노티클릭 : %@", userInfo);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([userInfo valueForKey:@"url"]!=nil && ![[userInfo valueForKey:@"url"] isEqual:@""] && ![[userInfo valueForKey:@"url"] isEqual:@"(null)"]){
        self.pushURL = [userInfo valueForKey:@"url"];
        
        [prefs setObject:self.pushURL forKey:@"PUSH_URL"];
        [prefs synchronize];
    }
    NSLog(@"[pushlog] 노티클릭 push prefs : %@", [prefs objectForKey:@"PUSH_URL"]);
    
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    NSString *domain = [prefs objectForKey:@"URL"];
//    self.pushURL = [domain stringByAppendingFormat:@"%@", [userInfo valueForKey:@"url"]];
    
    if([userInfo valueForKey:@"url"]!=nil && ![[userInfo valueForKey:@"url"] isEqual:@""] && ![[userInfo valueForKey:@"url"] isEqual:@"(null)"]){
        self.pushURL = [userInfo valueForKey:@"url"];   
    }
    NSLog(@"[pushlog] self.pushURL : %@",self.pushURL);
    
    NSString *badge = [aps valueForKey:@"badge"];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:[badge intValue]];

    NSString *alert = [[aps valueForKey:@"alert"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"alert : %@", alert);
    
    UIApplicationState state = [application applicationState];
    
    if (state==UIApplicationStateActive) {
        if (self.isLogin) {
            if(![alert isEqualToString:@""] && alert!=nil){
                //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                
                NSLog(@"soundNumber : %@", [prefs objectForKey:@"SOUND_NUMBER"]);
                NSString *soundPath=nil;
                SystemSoundID SoundID;
                if([[prefs objectForKey:@"SOUND_NUMBER"] intValue]==0){
                    soundPath = [[NSBundle mainBundle] pathForResource:@"anymate" ofType:@"caf"];
                    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &SoundID);
                    AudioServicesPlayAlertSound(SoundID);
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    
                } else if([[prefs objectForKey:@"SOUND_NUMBER"] intValue]==1){
                    AudioServicesPlayAlertSound(1007);
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"알림" message:[aps valueForKey:@"alert"] delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
                [alertView show];
                [alertView release];
            }
        }
        
    }else if(state == UIApplicationStateInactive && self.isLogin){
        self.isPush = YES;
    }
     
}
*/

//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
//    NSLog(@"[pushlog] FORE/BACK GROUND userInfo : %@", userInfo);
////    [self receiveNotification:userInfo];
////    completionHandler(UIBackgroundFetchResultNewData);
//}

#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog( @"[pushlog] Handle push from foreground %@", notification.request.content.userInfo );
    if (self.isLogin) {
        [self receiveNotification:notification.request.content.userInfo];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"[pushlog] 노티클릭 : %@", response.notification.request.content.userInfo);
    NSDictionary *pushDict = response.notification.request.content.userInfo;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([pushDict valueForKey:@"url"]!=nil && ![[pushDict valueForKey:@"url"] isEqual:@""] && ![[pushDict valueForKey:@"url"] isEqual:@"(null)"]){
        self.pushURL = [pushDict valueForKey:@"url"];
        
        //[prefs setObject:self.pushURL forKey:@"PUSH_URL"];
        [prefs setObject:pushDict forKey:@"PUSH_DICT"];
        [prefs synchronize];
    }
    NSLog(@"[pushlog] 노티클릭 push prefs : %@", [prefs objectForKey:@"PUSH_DICT"]);
    
    if (self.isLogin) {
        [self receiveNotification:pushDict];
    }
    
//    if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
////        if(self.isLogin){
////            self.isPush = YES;
////        }
//
//    } else if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
//
//    } else if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
//
//    }
 
    completionHandler();
}
 

- (BOOL)deviceIsSilenced {
    CFStringRef state;
    UInt32 propertySize = sizeof(CFStringRef);
    OSStatus audioStatus = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
    if (audioStatus == kAudioSessionNoError) {
        
        // "Speaker" regardless of silent switch setting, but "Headphone" when my headphones are plugged in
        return (CFStringGetLength(state) <= 0);
    }
    return NO;
}
- (UIColor *) myRGBfromHex: (NSString *) code {
    
    NSString *str = [[code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([str length] < 6)
        return [UIColor blackColor];
    if ([str hasPrefix:@"0X"])
        str = [str substringFromIndex:2];
    if ([str hasPrefix:@"#"])
        str = [str substringFromIndex:1];
    if ([str length] != 6)
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
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"notification Error" message:[NSString stringWithFormat:@"%@",error]  delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alertView show];
    NSLog(@"deviceToken error : %@", error);
}
- (BOOL)application:application handleOpenURL:(NSURL *)url{
    @try {
        NSString *strURL = [url absoluteString];
        NSLog(@"strURL = %@",strURL);
        
        NSArray *arr = [strURL componentsSeparatedByString:@"id="];
        NSString *temp = [arr objectAtIndex:1];
        NSString *idString = [[temp componentsSeparatedByString:@"&"] objectAtIndex:0];
        NSArray *arr2 = [[[temp componentsSeparatedByString:@"&"] objectAtIndex:1] componentsSeparatedByString:@"pw="];
        NSString *pwString = [arr2 objectAtIndex:1];
        NSLog(@"id : %@, pw : %@",idString, pwString);
        self.gwID = idString;
        self.gwPW = pwString;
    }
    @catch (NSException *exception) {
        NSLog(@"exception : %@",exception);
    }
    
    return YES;
}
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

