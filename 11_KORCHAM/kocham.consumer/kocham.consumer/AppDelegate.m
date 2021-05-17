//
//  AppDelegate.m
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 1..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "AppDelegate.h"
#import "MFUtil.h"
#import "iX.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface AppDelegate ()

@end

@implementation AppDelegate


#pragma mark - Firebase Delegate
-(void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken{
    self.fcmToken = fcmToken;
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FCMToken" object:nil userInfo:dataDict];

    [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result, NSError * _Nullable error) {
      if (error != nil) {
        NSLog(@"Error fetching remote instance ID: %@", error);
      } else {
        NSLog(@"Remote instance ID token: %@", result.token);
        NSString* message =
          [NSString stringWithFormat:@"Remote InstanceID token: %@", result.token];
        //self.instanceIDTokenMessage.text = message;
      }
    }];
}

#pragma mark - App Delegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    
//    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) ) {
//        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//
//        if (launchOptions != nil) {
//            NSLog(@"launchOptions : %@",launchOptions);
//            NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//            NSLog(@"dictionary : %@",dictionary);
//        }
//
//    } else {
//        NSLog(@"10.0");
//        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        center.delegate = self;
//        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
//             if( !error ) {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
//                     NSLog( @"Push registration success." );
//                 });
//             } else {
//                 NSLog( @"Push registration FAILED" );
//                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
//                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
//             }
//         }];
//    }
    
    if (@available(iOS 10.0, *)) {
        if ([UNUserNotificationCenter class] != nil) {
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
    
    self.appDeviceToken = @"";
    [self registerCustomUserAgent];
    
    return YES;
}

-(void)registerCustomUserAgent{
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
//    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
//
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    NSString *customUserAgent = [NSString stringWithFormat:@"korchampass %@", version];
//
//    NSDictionary *dict = @{@"UserAgent" : [NSString stringWithFormat:@"%@ %@", userAgent, customUserAgent]};
//    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
//    NSLog(@"[registerCustomUserAgent] : %@", userAgent);
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *customUserAgent = [NSString stringWithFormat:@"korchampass %@", version];

        if([result rangeOfString:@"korchampass"].location==NSNotFound){
            NSDictionary *dict = @{@"UserAgent" : [NSString stringWithFormat:@"%@ %@", result, customUserAgent]};
            //webView.customUserAgent = [dict objectForKey:@"UserAgent"];
            
            [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
        }
        NSLog(@"customUserAgent : %@", webView.customUserAgent);
    }];
}



- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

-(void)ixShieldDebugCheck{
    #pragma mark 2. 안티 디버깅
    int ret = ix_runAntiDebugger();
    //0 : 탐지 안됨 (iX_FALSE)
    //1 : 탐지 됨 (iX_TRUE)
    if (ret != 1) {
        if(ret == 0) {
            NSLog(@"[ixShield(AV)] Not Used Debugger!");
        }
        else {
            NSLog(@"[ixShield(AV)] %@", [NSString stringWithFormat:@"error code : %d", ret]);
        }
    }
    else {
        NSLog(@"[ixShield(AV)] Detected Debugger!");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"%s",__FUNCTION__);
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"%s",__FUNCTION__);
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /*
    UIApplicationShortcutItem * item1 = [[UIApplicationShortcutItem alloc]initWithType: @"test1"
                                                                            localizedTitle: @"김민구"
                                                                         localizedSubtitle: nil
                                                                                      icon: [UIApplicationShortcutIcon iconWithType: UIApplicationShortcutIconTypeHome]
                                                                                  userInfo: nil];
    UIApplicationShortcutItem * item2 = [[UIApplicationShortcutItem alloc]initWithType: @"test2"
                                                                            localizedTitle: @"이혜경"
                                                                         localizedSubtitle: nil
                                                                                      icon: [UIApplicationShortcutIcon iconWithType: UIApplicationShortcutIconTypeLove]
                                                                                  userInfo: nil];
    
    [UIApplication sharedApplication].shortcutItems = @[item1,item2];
    */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"%s",__FUNCTION__);
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%s",__FUNCTION__);
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self ixShieldDebugCheck];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"%s", __func__);
    
    //ixShield의 메모리를 정리
    ix_dealloc();
}
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"urlQuery : %@",[url query]);
    NSLog(@"url : %@",url);
    NSDictionary *paramDic = [MFUtil getParametersByString:[url query]];
    NSLog(@"paramDic : %@",paramDic);
    if (paramDic != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenUrlNotification" object:nil userInfo:paramDic];
    }
    
    return YES;
}
- (BOOL)application:application handleOpenURL:(NSURL *)url{
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"urlQuery : %@",[url query]);
    NSLog(@"url : %@",url);
    NSDictionary *paramDic = [MFUtil getParametersByString:[url query]];
    NSLog(@"paramDic : %@",paramDic);
    
    return YES;
}
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


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"deviceToken error : %@", error);
    self.appDeviceToken = @"-";
}
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
//    }];
//}
//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
//    NSLog(@"completionHandler : %@",completionHandler);
//    completionHandler(UIBackgroundFetchResultNewData);
//}
//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
//    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
//    {
//        NSLog( @"iOS version >= 10. Let NotificationCenter handle this one." );
//        // set a member variable to tell the new delegate that this is background
//        return;
//    }
//    NSLog( @"HANDLE PUSH, didReceiveRemoteNotification: %@", userInfo );
//
//    // custom code to handle notification content
//
//    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
//    {
//        NSLog( @"INACTIVE" );
//        self.inactivePushInfo = userInfo;
//        completionHandler( UIBackgroundFetchResultNewData );
//    }
//    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
//    {
//        NSLog( @"BACKGROUND" );
//        self.inactivePushInfo = userInfo;
//        completionHandler( UIBackgroundFetchResultNewData );
//    }
//    else
//    {
//        NSLog( @"FOREGROUND" );
//        completionHandler( UIBackgroundFetchResultNewData );
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:userInfo];
//    }
//}

- (void) receiveNotification:(NSDictionary *)userInfo{
    NSLog(@"[pushlog] : %s", __func__);
}

#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog( @"Handle push from foreground" );
    NSLog(@"willPresentNotification %@", notification.request.content.userInfo);
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:notification.request.content.userInfo];
    [self receiveNotification:notification.request.content.userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"[pushlog] 노티클릭 : %@", response.notification.request.content.userInfo);
    
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive ){
        NSLog( @"INACTIVE" );
        self.inactivePushInfo = response.notification.request.content.userInfo;
        //completionHandler( UNNotificationPresentationOptionAlert );
    }
    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground ){
        NSLog( @"BACKGROUND" );
        self.inactivePushInfo = response.notification.request.content.userInfo;
        //completionHandler( UNNotificationPresent );
    }
    self.inactivePushInfo = response.notification.request.content.userInfo;

    //[[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:response.notification.request.content.userInfo];
//    completionHandler();

}
@end
