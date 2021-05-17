//
//  AppDelegate.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "AppDelegate.h"
#import "HDNotificationView.h"
#import "MFDBHelper.h"
#import "FBEncryptorAES.h"

#import "PostDetailViewController.h"
#import "NewsFeedViewController.h"
#import "TeamListViewController.h"
#import "TeamSelectController.h"
#import "WebKitViewController.h"
#import "NotiChatViewController.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "DetectTouchWindow.h"
#import "SyncChatInfo.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@interface AppDelegate () {
    RMQServerViewController *rmq;
    BOOL isPush;
    
    int tCount;
    int endTCount;
    NSTimer *myTimer;
}
@end


@implementation AppDelegate

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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog();
    
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    
    //터치 감지를 위해
    self.window = [[DetectTouchWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IntroViewController *destination = (IntroViewController *)[storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    [self.window setBackgroundColor:[UIColor clearColor]];
    [self.window setRootViewController:navController];
    [self.window makeKeyAndVisible];
    
    [self setupAPNS:application :launchOptions];
    
    self.appPrefs = [NSUserDefaults standardUserDefaults];
    
    //큐이름에 널이 들어가는 경우가 있어서 널값일 경우 10으로 넣어줌
    NSString *compNo = [self.appPrefs objectForKey:@"COMP_NO"];
    if(compNo!=nil&&![compNo isEqual:@""]){
        
    } else {
        [self.appPrefs setObject:@"10" forKey:@"COMP_NO"];
        [self.appPrefs synchronize];
    }
    
    //처음 설치하면 키값이 없겠지
    if([self.appPrefs objectForKey:@"IS_FIRST_LOGIN"]==nil){
        [self.appPrefs setObject:@"FIRST" forKey:@"IS_FIRST_LOGIN"];
        [self.appPrefs synchronize];
    }
    
    if([self.appPrefs objectForKey:@"IS_TUTORIAL"]==nil){
        [self.appPrefs setObject:@"YES" forKey:@"IS_TUTORIAL"];
        [self.appPrefs synchronize];
    }
  
//    앱 실행시 에러테스트
//    NSMutableDictionary *aa = [[NSMutableDictionary alloc] init];
//    [aa setObject:[self.appPrefs objectForKey:@"ZZZ"] forKey:@"aa"];
//    NSLog(@"aa : %@", aa);
    
//    NSLog(@"처음ㅇㅁㅁㅁㅁㅁ : %@", [self.appPrefs objectForKey:@"INSTALL_DATE"]);
    if([self.appPrefs objectForKey:@"INSTALL_DATE"]==nil){
        //처음 설치시 설치 시간 저장 (20200824131110 / YYYYMMDDHHMMSS)
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        [self.appPrefs setObject:currentTime forKey:@"INSTALL_DATE"];
        NSLog(@"처음설치날짜 : %@", currentTime);
        [self.appPrefs synchronize];
    }
    
    if([self.appPrefs objectForKey:@"BACKGROUND_TIME"]!=nil){
        [self.appPrefs removeObjectForKey:@"BACKGROUND_TIME"];
        [self.appPrefs synchronize];
    }
    
    self.errorExecCnt = 0;
    
    self.isLogin = NO;
    self.mqConnect = NO;
    
    self.appDeviceToken = @"";
    self.ipAddr = @"";
    
    self.isChatViewing = NO;
    self.canFeedRefresh = NO;
    self.teamListRefresh = NO;
   
//    [self.appPrefs setObject:[[MFSingleton sharedInstance] notiExtScheme] forKey:@"NOTIGROUPNAME"];
//    [self.appPrefs synchronize];
    
    self.tabBarController = [MFUtil setDefualtTabBar];
    self.tabBarController.delegate = self;
    self.uiTabBar = [[UITabBar alloc]init];
    self.uiTabBar.delegate = self;
    self.tabItemArr = [self.appPrefs objectForKey:[self setPreferencesKey:@"TABITEM"]];
    if(self.tabItemArr.count<=0){
        NSArray *defaultTabArr;
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
            defaultTabArr = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
        } else {
            defaultTabArr = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", nil];
        }
        
        [self.appPrefs setObject:defaultTabArr forKey:[self setPreferencesKey:@"TABITEM"]];
        [self.appPrefs synchronize];
    }
    
    if([self.appPrefs objectForKey:@"IS_DVC_FIRST"]==nil){
        //제일 처음 IS_DVC_FIRST 값을 true로 둔다. (예를들어, 1.1.5 -> 1.1.6 업데이트 할 경우)
        //값이 true일 경우, DVC_ID 값 삭제
        //getUUID 호출하여 DVC_ID 저장 후 IS_DVC_FIRST 값 false
        [self.appPrefs setBool:true forKey:@"IS_DVC_FIRST"];
        [self.appPrefs synchronize];
        
        if([self.appPrefs objectForKey:@"IS_DVC_FIRST"]){
            [self.appPrefs removeObjectForKey:[self setPreferencesKey:@"DVCID"]];
            [self.appPrefs setBool:false forKey:@"IS_DVC_FIRST"];
            [self.appPrefs synchronize];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_RmqConnect:) name:@"noti_RmqConnect" object:nil];
    
    rmq = [[RMQServerViewController alloc]init];
    
    ChatListViewController *vc = [[ChatListViewController alloc] init];
    
    if([self.appPrefs objectForKey:@"USERID"]!=nil&&![[self.appPrefs objectForKey:@"USERID"] isEqual:@""]&&![[self.appPrefs objectForKey:@"USERID"] isEqual:@"(null)"]){
        //로컬DB 세팅하기 위해
        if([self.appPrefs objectForKey:[self setPreferencesKey:@"SETLOCALDB"]]==nil||[[self.appPrefs objectForKey:[self setPreferencesKey:@"SETLOCALDB"]] isEqual:@""]||[[self.appPrefs objectForKey:[self setPreferencesKey:@"SETLOCALDB"]] isEqual:@"(null)"]){
            [self.appPrefs setObject:@"NOT_SET" forKey:[self setPreferencesKey:@"SETLOCALDB"]];
        }
        
        if([self.appPrefs objectForKey:[self setPreferencesKey:@"DBNAME"]]!=nil&&![self.appPrefs isEqual:@""]&&![self.appPrefs isEqual:@"(null)"]) self.dbHelper = [[MFDBHelper alloc] init:@"1" userId:nil]; //[[MFDBHelper alloc] init];
        
        if([self.appPrefs objectForKey:[self setPreferencesKey:@"IMGQUALITY"]]==nil||[[self.appPrefs objectForKey:[self setPreferencesKey:@"IMGQUALITY"]] isEqual:@""]||[[self.appPrefs objectForKey:[self setPreferencesKey:@"IMGQUALITY"]] isEqual:@"(null)"]){
            [self.appPrefs setObject:@"HIGH" forKey:[self setPreferencesKey:@"IMGQUALITY"]];
        }
        
        [self.appPrefs synchronize];
    }
    
    [self.appPrefs setObject:[[MFSingleton sharedInstance] aes256key] forKey:@"AES256KEY"];
    [self.appPrefs synchronize];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
//    SyncChatInfo *sync = [[SyncChatInfo alloc] init];
//    [sync syncChatRoom];
    
//    백그라운드 테스크등록
//    if (@available(iOS 13.0, *)) {
//        [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:@"hhi.mobile.ios.sns.chatRoomList" usingQueue:nil launchHandler:^(__kindof BGTask * _Nonnull task) {
//            [self handleChatList:task];
//        }];
//    } else {
//        // Fallback on earlier versions
//    }
    
    /*
    if(SYSTEM_VERSION_LESS_THAN( @"10.0" )) {
        //Deprecated 함수지만 조건이 10버전 이하이므로 상관없음
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        if (launchOptions != nil) {
            NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            
        } else{
            NSLog( @"registerForPushWithOptions" );
        }
        
    } else {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error){
             if(!error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                     if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
                         // 1번 상태에서 push 수신
                         NSLog(@"앱 종료때도 푸시를 받을수 있다 : %@", [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]);
                         [self receiveNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
                     }
                 });
             } else {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
             }
         }];
    }
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    */
    
    return YES;
}

//-(void)handleChatList:(BGTask *)task API_AVAILABLE(ios(13.0)){
//    NSLog();
//    [AppDelegate scheduleAppRefresh];
//}
//+(void)scheduleAppRefresh {
//    NSLog();
//    if (@available(iOS 13.0, *)) {
//        BGAppRefreshTaskRequest *request = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:@"hhi.mobile.ios.sns.chatRoomList"];
//        request.earliestBeginDate = [NSDate dateWithTimeIntervalSinceNow:2*60];
//        NSError *error = NULL;
//        BOOL success = [[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:&error];
//        if (!success) {
//            NSLog(@"Failed to submit request: %@",error);
//        } else {
//            NSLog(@"성공???????");
//        }
//
//    } else {
//        // Fallback on earlier versions
//    }
//}

- (void)setupAPNS:(UIApplication *)application :(NSDictionary *)launchOptions{
    NSLog();
    if (@available(iOS 10.0, *)) {
        if ([UNUserNotificationCenter class] != nil) {
          // iOS 10 or later
          // For iOS 10 display notification (sent via APNS)
          [UNUserNotificationCenter currentNotificationCenter].delegate = self;
          UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert|UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
          [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
              NSLog(@"NOT RUNNING : %@", [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]);
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
    
    /*
    Background Fetch는 사용자의 App 사용패턴을 익혀서 Fetch를 합니다. 예를 들어 App이 매일 1시와 5시에 주로 실행된다고 System에서 파악하면 App은 해당 시간에 Background에 있는 App을 깨워서
    AppDelegate에 performFetchWithCompletionHandler를 호출하게 됩니다. setMinimumBackgroundFetchInterval를 이용하여 Background Fetch 간에 최소시간을 설정합니다. 하지만 System 권장설정일 뿐 정확하게 동작하지는 않습니다.
     */
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
//    [application setMinimumBackgroundFetchInterval:300];
    
    [application registerForRemoteNotifications];
}
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    NSLog(@"performFetch completionHandler : %@",completionHandler);
    completionHandler(UIBackgroundFetchResultNewData);
}

- (NSString *)setPreferencesKey:(NSString *)keyName{
    NSString *resultKey = @"";
    NSString *userId = [self.appPrefs objectForKey:@"USERID"];
    resultKey = [NSString stringWithFormat:@"%@_%@",userId,keyName];
    return resultKey;
}

-(void)dataNetworkCheck{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"네트워크 사용 할 수 없음");
            self.networkStatus = @"0";
            [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        } else if (status == AFNetworkReachabilityStatusUnknown){
            NSLog(@"네트워크 상태 알 수 없음");
            self.networkStatus = @"1";
            [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        } else {
            if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                NSLog(@"WIFI");
                self.networkStatus = @"2";
                [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
                
            } else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
                NSLog(@"Cellular 네트워크");
                self.networkStatus = @"3";
                [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
            }
        }
    }];
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog();
    self.isChatViewing = NO;
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.strings = nil;
//    NSLog(@"pastedBoard : %@", pasteboard.strings);
    
    if(self.isExcuteMDM==NO){
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        [self.appPrefs setObject:currentTime forKey:@"BACKGROUND_TIME"];
        NSLog(@"백그라운드로 내려간시간 : %@", currentTime);
        
        [self.appPrefs synchronize];
    }
    
    /*
    if(self.isMDM){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSLog(@"authToken : %@", [prefs objectForKey:@"MDM_AUTH_TOKEN"]);
        
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
//            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//                                                              [alert dismissViewControllerAnimated:YES completion:nil];
//                                                              exit(0);
//                                                          }];
//            [alert addAction:okButton];
//            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    }
    */
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_applicationDidEnterBackground" object:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        // 작업이 오래 걸리는 API를 백그라운드 스레드에서 실행한다.
        [rmq disconnectMQServer];
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog();
    [self dataNetworkCheck];
    
    if([[MFSingleton sharedInstance] isMDM]){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *authToken = [prefs objectForKey:@"MDM_AUTH_TOKEN"];
        NSString *urlString = [NSString stringWithFormat:@"https://mdm.hhi.co.kr/mdm_admin_server/mdmApi/enterWorkApp?authToken=%@&osType=IOS", authToken];
        NSLog(@"MDM Url : %@", urlString);
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString] options:NSDataReadingUncached error:&error];
        
        NSString *returnStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[returnStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if(![dataDic objectForKey:@"result"]){
            NSLog(@"MDM 업무앱 실행정책이 적용되지 않았습니다.");
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MDM 업무앱 실행정책이 적용되지 않았습니다.", @"MDM 업무앱 실행정책이 적용되지 않았습니다.") message:nil preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
//                                                             handler:^(UIAlertAction * action) {
//                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
//                                                                 exit(0);
//                                                             }];
//            [alert addAction:okButton];
//            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"MDM 업무앱 실행정책이 적용되었습니다.");
        }
         
    }
    
    if(self.isLogin){
        //포그라운드로 올라올때 웹서비스 호출
//        SyncChatInfo *sync = [[SyncChatInfo alloc] init];
//        [sync syncChatRoom];
        
        NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
        NSLog(@"포그라운드 올라왔을 경우 뷰 확인 : %@", currentClass);
        if([currentClass isEqualToString:@"ChatListViewController"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshChatList" object:nil];
        }
        
        tCount = 0;
        endTCount = 10;
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if([self.networkStatus integerValue]==2||[self.networkStatus integerValue]==3){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                    [rmq connectMQServer:nil];
                });
            }
        });
    }
}

-(void)handleTimer:(NSTimer *)timer {
    tCount++;
    if (tCount==endTCount) {
        NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
        NSLog(@"앱을 실행했는데 인트로에서 멈춰있을 경우 뷰 확인 : %@", currentClass);
        if([currentClass isEqualToString:@"IntroViewController"]){
            NSLog(@"메인으로 진입");
            [IntroViewController nextPage];
        } 
        [myTimer invalidate];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog();
    @try{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_applicationDidBecomeActive" object:nil];
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog();
    self.isChatViewing = NO;
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.strings = nil;
    
    [self.appPrefs removeObjectForKey:@"BACKGROUND_TIME"];
    [self.appPrefs synchronize];
    
    if([[MFSingleton sharedInstance] isMDM]){
        self.isExcuteMDM = NO;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *authToken = [prefs objectForKey:@"MDM_AUTH_TOKEN"];
        NSString *urlString = [NSString stringWithFormat:@"https://mdm.hhi.co.kr/mdm_admin_server/mdmApi/exitWorkApp?authToken=%@&osType=IOS", authToken];
        NSLog(@"MDM Url : %@", urlString);
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString] options:NSDataReadingUncached error:&error];
        
        NSString *returnStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[returnStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if([dataDic objectForKey:@"result"]){
            NSLog(@"MDM 업무앱 종료정책이 적용되었습니다.");
        } else {
            NSLog(@"MDM 업무앱 종료정책이 적용되지 않았습니다.");
            
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MDM 업무앱 종료정책이 적용되지 않았습니다.", @"MDM 업무앱 종료정책이 적용되지 않았습니다.") message:nil preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//                                                              [alert dismissViewControllerAnimated:YES completion:nil];
//                                                              exit(0);
//                                                          }];
//            [alert addAction:okButton];
//            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
         
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        [rmq disconnectMQServer];
    });
}


#pragma mark - MDM
-(void)getMDMExageInfo:(NSString*)command{
    NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];

    if (stringURLScheme) {
        self.isExcuteMDM = YES;
        NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=%@",command];
        [urlString appendFormat:@"&caller=%@", stringURLScheme];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
            if(success) self.mdmCallAPI = @"enterWorkApp";
        }];
        
    }
    else{
        NSLog(@"현재 앱에 URL Scheme 이 지정되어 있지 않아 호출할 수 없습니다. URL Scheme 지정해야 결과를 응답받을 수 있습니다.");
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"현재 앱에 URL Scheme 이 지정되어 있지 않아 호출할 수 없습니다. URL Scheme 지정해야 결과를 응답받을 수 있습니다.", @"현재 앱에 URL Scheme 이 지정되어 있지 않아 호출할 수 없습니다. URL Scheme 지정해야 결과를 응답받을 수 있습니다.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}
//-(void)enterWorkApp{
//    self.mdmCallAPI = @"enterWorkApp";
//
//    NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
//
//    NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=enterWorkApp"];
//    [urlString appendFormat:@"&caller=%@", stringURLScheme];
//
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
//}
- (void)exitWorkApp{
//    NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
//
//    NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=exitWorkApp"];
//
//    [urlString appendFormat:@"&caller=%@", stringURLScheme];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [prefs objectForKey:@"MDM_AUTH_TOKEN"];
    NSString *urlString = [NSString stringWithFormat:@"https://mdm.hhi.co.kr/mdm_admin_server/mdmApi/exitWorkApp?authToken=%@&osType=IOS", authToken];
    NSError *error;
     
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString] options:NSDataReadingUncached error:&error];
    NSString *returnStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[returnStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if([dataDic objectForKey:@"result"]){
        NSLog(@"MDM 업무앱 종료정책이 적용되었습니다.");
//        exit(0);
        [self exitApp];
    } else {
        NSLog(@"MDM 업무앱 종료정책이 적용되지 않았습니다.");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MDM 업무앱 종료정책이 적용되지 않았습니다.", @"MDM 업무앱 종료정책이 적용되지 않았습니다.") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [alert dismissViewControllerAnimated:YES completion:nil];
//                                                          exit(0);
                                                            [self exitApp];
                                                      }];
        [alert addAction:okButton];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

-(void)exitApp{
    self.isExcuteMDM = NO;
    exit(0);
//    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    NSLog(@"application::openURL::sourceApplication=%@",sourceApplication);
//    NSLog(@"url=%@",url);
    return YES;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [SVProgressHUD dismiss];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
//    NSInteger statusCode = [HTTPresponse statusCode];
    
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    
    if([methodName isEqualToString:@"MLogout"]){
        NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
        
        _mdmCallAPI = @"exitWorkApp";
        NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=exitWorkApp"];
        
        [urlString appendFormat:@"&caller=%@", stringURLScheme];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

#pragma mark
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
//    NSLog(@"%s",__FUNCTION__);
    NSLog(@"url query : %@", [url query]);
    
    NSDictionary *paramDic = [MFUtil getParametersByString:[url query]];
    NSLog(@"openURL paramDic : %@", paramDic);
    
    if([[paramDic objectForKey:@"call"] isEqualToString:[[MFSingleton sharedInstance] callScheme]]){
        NSString *userId = [[paramDic objectForKey:@"ID"] uppercaseString];
        [self.appPrefs setObject:userId forKey:@"USERID"];
        [self.appPrefs setObject:[paramDic objectForKey:@"PWD"] forKey:[self setPreferencesKey:@"USERPWD"]];
        [self.appPrefs setObject:[paramDic objectForKey:@"ID"] forKey:[self setPreferencesKey:@"DBNAME"]];
        [self.appPrefs setObject:[paramDic objectForKey:@"DEVICE_ID"] forKey:[self setPreferencesKey:@"DVCID"]];
        [self.appPrefs synchronize];
        
        if([self.appPrefs objectForKey:@"USERID"]!=nil&&![[self.appPrefs objectForKey:@"USERID"] isEqual:@""]&&![[self.appPrefs objectForKey:@"USERID"] isEqual:@"(null)"]){
            //로컬DB 세팅하기 위해
            if([self.appPrefs objectForKey:[self setPreferencesKey:@"SETLOCALDB"]]==nil||[[self.appPrefs objectForKey:[self setPreferencesKey:@"SETLOCALDB"]] isEqual:@""]||[[self.appPrefs objectForKey:[self setPreferencesKey:@"SETLOCALDB"]] isEqual:@"(null)"]){
                [self.appPrefs setObject:@"NOT_SET" forKey:[self setPreferencesKey:@"SETLOCALDB"]];
                [self.appPrefs synchronize];
            }
            
            if([self.appPrefs objectForKey:[self setPreferencesKey:@"DBNAME"]]!=nil&&![self.appPrefs isEqual:@""]&&![self.appPrefs isEqual:@"(null)"]) self.dbHelper = [[MFDBHelper alloc] init:@"1" userId:nil];//[[MFDBHelper alloc] init];
            
            if([self.appPrefs objectForKey:[self setPreferencesKey:@"IMGQUALITY"]]==nil||[[self.appPrefs objectForKey:[self setPreferencesKey:@"IMGQUALITY"]] isEqual:@""]||[[self.appPrefs objectForKey:[self setPreferencesKey:@"IMGQUALITY"]] isEqual:@"(null)"]){
                [self.appPrefs setObject:@"HIGH" forKey:[self setPreferencesKey:@"IMGQUALITY"]];
                [self.appPrefs synchronize];
            }
            
            if([self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWPOST"]]==nil||[[self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWPOST"]] isEqual:@""]||[[self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWPOST"]] isEqual:@"(null)"]){
                [self.appPrefs setObject:@"1" forKey:[self setPreferencesKey:@"NOTINEWPOST"]];
                [self.appPrefs synchronize];
            }
            
            if([self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWCOMM"]]==nil||[[self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWCOMM"]] isEqual:@""]||[[self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWCOMM"]] isEqual:@"(null)"]){
                [self.appPrefs setObject:@"1" forKey:[self setPreferencesKey:@"NOTINEWCOMM"]];
                [self.appPrefs synchronize];
            }
            
            if([self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWCHAT"]]==nil||[[self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWCHAT"]] isEqual:@""]||[[self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWCHAT"]] isEqual:@"(null)"]){
                [self.appPrefs setObject:@"1" forKey:[self setPreferencesKey:@"NOTINEWCHAT"]];
                [self.appPrefs synchronize];
            }
        }
        
        if([paramDic objectForKey:@"AUTO_LOGIN_DATE"]!=nil&&![[paramDic objectForKey:@"AUTO_LOGIN_DATE"] isEqual:@""]&&![[paramDic objectForKey:@"AUTO_LOGIN_DATE"] isEqual:@"(null)"]){
            if([self.appPrefs objectForKey:[self setPreferencesKey:@"AUTOLOGINDATE"]]!=nil){
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                formatter.dateFormat = @"yyyy-MM-dd";
                NSDate *savedDate = [formatter dateFromString:[self.appPrefs objectForKey:[self setPreferencesKey:@"AUTOLOGINDATE"]]];
                
                NSDate *newDate = [formatter dateFromString:[paramDic objectForKey:@"AUTO_LOGIN_DATE"]];
                
                NSCalendar *sysCalendar = [NSCalendar currentCalendar];
                unsigned int unitFlags = NSCalendarUnitDay;
                NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:savedDate toDate:newDate options:0];//날짜 비교해서 차이값 추출
                NSInteger date = dateComp.day;
                
                if(date>=0){
                    NSLog(@"자동로그인 날짜 변경");
                    [self.appPrefs setObject:[paramDic objectForKey:@"AUTO_LOGIN_DATE"] forKey:[self setPreferencesKey:@"AUTOLOGINDATE"]];
                    //if(self.isMDM) [self getMDMExageInfo:@"queries_getStatus_getRichStatus_enterWorkApp"];
                    
                } else {
//                        NSLog(@"자동로그인 날짜 변경없음");
                }
            } else {
                [self.appPrefs setObject:[paramDic objectForKey:@"AUTO_LOGIN_DATE"] forKey:[self setPreferencesKey:@"AUTOLOGINDATE"]];
            }
            [self.appPrefs synchronize];
            
        } else {
            //터치원이 자동로그인을 사용하지 않아서 AUTO_LOGIN_DATE값이 null일때
            NSDate *today = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd";
            NSString *snsDate = [formatter stringFromDate:today];
            [self.appPrefs setObject:snsDate forKey:[self setPreferencesKey:@"AUTOLOGINDATE"]];
            [self.appPrefs synchronize];
            
            NSLog(@"인트로 이동");
//            IntroViewController *ivc = (IntroViewController *)[UIViewController currentViewController];
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            IntroViewController *ivc = (IntroViewController *)[storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
//            [ivc viewDidLoad];
        }
        
    } else if([[paramDic objectForKey:@"call"] isEqualToString:@"hhi.mobile.ios.sns.ShareEx"]){
        //로그인체크 로직
        if(self.isLogin){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ShareSelectViewController *destination = (ShareSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareSelectViewController"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
            navController.modalTransitionStyle = UIModalPresentationNone;
            navController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (topRootViewController.presentedViewController)
            {
                topRootViewController = topRootViewController.presentedViewController;
            }
            [topRootViewController presentViewController:navController animated:YES completion:nil];
            
        } else {
            [self.appPrefs setObject:@"SHARE_INFO" forKey:@"SHARE_INFO"];
            [self.appPrefs synchronize];
        }
        
    } else {
        NSLog(@"MDM에서 올라왔다 !");
        self.isExcuteMDM = NO;
        
        NSArray * param = [[url query] componentsSeparatedByString:@"&"];
        NSMutableArray *params = [NSMutableArray arrayWithArray:param];
        [params removeObject:@""];
        param = params;
        NSMutableString * resultMDMAgent = [NSMutableString string];
        
        if ([param count]==1) {
            NSString * value = [[[param objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
            
            if ([_mdmCallAPI isEqualToString:@"exitWorkApp"]) {
                if (![value isEqualToString:@"1"]) {
                    [resultMDMAgent appendString:@"MDM 업무앱 종료정책이 적용 되지 않았습니다.\n"];
                }else{
                    //exit(0);
                     [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(exitApp) userInfo:nil repeats:NO];
                }
            } else{
                if (![value isEqualToString:@"1"]) {
                    [resultMDMAgent appendString:@"MDM 업무앱 실행정책이 적용 되지 않았습니다.\n"];
                }
            }
            
        }else{
            NSMutableDictionary *mdmResultDic = [NSMutableDictionary dictionary];
            
            for (NSString * str in param) {
                if ([[str componentsSeparatedByString:@"="] count] == 2) {
                    NSString * key = [[str componentsSeparatedByString:@"="] objectAtIndex:0];
                    NSString * value = [[str componentsSeparatedByString:@"="] objectAtIndex:1];
                    
                    [mdmResultDic setObject:value forKey:key];
                    
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
                        } else if([value isEqualToString:@"2"]){
                            //NSLog(@"[MDM] MDM 활성화");
                        }
                        
                    } else if ([[key lowercaseString] isEqualToString:@"result"]) {
                        if (![value isEqualToString:@"1"]) {
                            [resultMDMAgent appendString:@"MDM 업무앱 실행정책이 적용 되지 않았습니다.\n"];
                        }
//                        else {
//                            if ([_mdmCallAPI isEqualToString:@"enterWorkApp"]) {
//                                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_MDMExcuteNextPage" object:nil];
//                            }
//                        }
                        
                    } else if([[key lowercaseString] isEqualToString:@"authtoken"]){
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        [prefs setObject:value forKey:@"MDM_AUTH_TOKEN"];
                        [prefs synchronize];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MDMIntroNotification" object:nil];
        }
    }
    return YES;
}

#pragma mark - NORMAL PUSH
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [FIRMessaging messaging].APNSToken = deviceToken;
    
    if (@available(iOS 13.0, *)) {
        self.appDeviceToken = [self stringFromDeviceToken:deviceToken];
        
    } else {
        self.appDeviceToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        self.appDeviceToken = [self.appDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
//    NSLog(@"prev pushid : %@", [self.appPrefs objectForKey:[self setPreferencesKey:@"PUSHID1"]]);
//    NSLog(@"curr pushid : %@", self.appDeviceToken);
 
//    if([self.appPrefs objectForKey:@"PUSH_ID1"]==nil){
//        [self.appPrefs setObject:self.appDeviceToken forKey:[self setPreferencesKey:@"PUSHID1"]];
//        [self.appPrefs synchronize];
//    }
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushIDChangeNotification" object:nil]; //주석
        
//    if(![[self.appPrefs objectForKey:[self setPreferencesKey:@"PUSHID1"]] isEqualToString:self.appDeviceToken]){
//        NSLog(@"푸시아이디 바뀜");
//
//
//        [self.appPrefs setObject:self.appDeviceToken forKey:[self setPreferencesKey:@"PUSHID1"]];
//        [self.appPrefs synchronize];
//
//        NSString *dlqUrl = @"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish";
//        NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[self.appPrefs objectForKey:@"COMP_NO"], [self.appPrefs objectForKey:@"USERID"], [self.appPrefs objectForKey:[self setPreferencesKey:@"DVCID"]]];
//
//        NSDictionary *emptyDict = [NSDictionary dictionary];
//        NSString* emptyJson = nil;
//        NSData* emptyData = [NSJSONSerialization dataWithJSONObject:emptyDict options:kNilOptions error:nil];
//        emptyJson = [[NSString alloc] initWithData:emptyData encoding:NSUTF8StringEncoding];
//
//        NSMutableDictionary *dlqDict = [NSMutableDictionary dictionary];
//        [dlqDict setObject:[self.appPrefs objectForKey:@"COMP_NO"] forKey:@"COMP_NO"];
//        [dlqDict setObject:@"1" forKey:@"APP_NO"];
//        [dlqDict setObject:[[MFSingleton sharedInstance] appType] forKey:@"APP_TYPE"];
//        [dlqDict setObject:@"i" forKey:@"DVC_OS"];
//        [dlqDict setObject:[[MFSingleton sharedInstance] dvcType] forKey:@"DVC_TYPE"];
//        [dlqDict setObject:[self.appPrefs objectForKey:[self setPreferencesKey:@"PUSHID1"]] forKey:@"PUSH_ID"];
//        [dlqDict setObject:[self.appPrefs objectForKey:@"USERID"] forKey:@"USER_ID"];
//        [dlqDict setObject:[self.appPrefs objectForKey:[self setPreferencesKey:@"DVCID"]]forKey:@"DVC_ID"];
//        [dlqDict setObject:mfpsId forKey:@"QUEUE_NAME"];
//        NSString* dlqJson = nil;
//        NSData* dlqData = [NSJSONSerialization dataWithJSONObject:dlqDict options:kNilOptions error:nil];
//        dlqJson = [[NSString alloc] initWithData:dlqData encoding:NSUTF8StringEncoding];
//        dlqJson = [dlqJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
//
//        NSMutableDictionary *dlqDict2 = [NSMutableDictionary dictionary];
//        [dlqDict2 setObject:dlqDict forKey:@"properties"];
//        [dlqDict2 setObject:@"UPDATE_USER_INFO" forKey:@"routing_key"];
//        [dlqDict2 setObject:dlqJson forKey:@"payload"];
//        [dlqDict2 setObject:@"string" forKey:@"payload_encoding"];
//        NSString* dlqJson2 = nil;
//        NSData* dlqData2 = [NSJSONSerialization dataWithJSONObject:dlqDict2 options:kNilOptions error:nil];
//        dlqJson2 = [[NSString alloc] initWithData:dlqData2 encoding:NSUTF8StringEncoding];
//
//        MFURLSession *dlqSession = [[MFURLSession alloc]initWithURL:[NSURL URLWithString:dlqUrl] option:dlqJson2];
//        [dlqSession start];
//    }
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

- (void)application:application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    NSLog(@"%@", error);
    self.appDeviceToken = @"-";
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    NSLog("무슨차이일까");
//    [self receiveNotification:userInfo]; //활성화 시 백그라운드에 푸시2개 들어옴
//}

- (void) receiveNotification:(NSDictionary *)userInfo{
    if (@available(iOS 11.0, *)) {
        NSLog("available iOS11");
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if(settings.authorizationStatus == UNAuthorizationStatusAuthorized) isPush = YES; // 푸시 허용
            else if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) isPush = NO; // 푸시 허용 안함
            else if(settings.authorizationStatus == UNAuthorizationStatusDenied) isPush = NO; // 푸시 허용 안함
        }];
    } else {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
            UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
            if (currentSettings.types == UIUserNotificationTypeNone) isPush = NO; // 푸시 허용 안함
            else isPush = YES; // 푸시 허용
        }
    }
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
//        if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
//            UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
//            if (currentSettings.types == UIUserNotificationTypeNone) isPush = NO; // 푸시 허용 안함
//            else isPush = YES; // 푸시 허용
//        }
//    } else {
//        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        center.delegate = self;
//        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
//            if(settings.authorizationStatus == UNAuthorizationStatusAuthorized) isPush = YES; // 푸시 허용
//            else if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) isPush = NO; // 푸시 허용 안함
//            else if(settings.authorizationStatus == UNAuthorizationStatusDenied) isPush = NO; // 푸시 허용 안함
//        }];
//    }
    
       if(userInfo != nil){
           NSString *message = [userInfo objectForKey:@"msg"];
   //        NSLog(@"MESSAGE : %@", message);
           
           NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
           NSError *error;
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
           
           //미디어 접근권한 푸시 테스트
//           NSString *json = @"{\"MESSAGE\":\"-\",\"RESULT\":\"SUCCESS\",\"TYPE\":\"SYSTEM_MSG\",\"SUB_TYPE\":\"SYSMSG_CHANGE_PERMISSION\", \"DATASET\":[{\"CUSER_NO\":120818, \"PRM_TY\":\"1\", \"PRM_NM\":\"MediaPermission\", \"PRM_STATUS\":true},{\"CUSER_NO\":120818, \"PRM_TY\":\"1\", \"PRM_NM\":\"FilePermission\", \"PRM_STATUS\":false}]}";
//           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
           
           NSDate *today = [NSDate date];
           NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
           [dateFormatter setDateFormat:@"yyMMdd-HHmmssSSS"];
           NSString *currentTime = [dateFormatter stringFromDate:today];
           
           NSLog(@"payload dict : %@", dict);
           
           NSString *pushType = [dict objectForKey:@"TYPE"];
           if([pushType isEqualToString:@"ADD_CHAT"]){
               NSArray *dataSet = [dict objectForKey:@"DATASET"];
               NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
               NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
               NSString *myUserNo = [self.appPrefs objectForKey:[self setPreferencesKey:@"CUSERNO"]];
               NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
               NSString *userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
               NSString *content = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
               NSLog(@"pushType : %@, roomNo : %@, contentType : %@", pushType, roomNo, contentType);

               if(![contentType isEqualToString:@"SYS"]){
                   NSString *sqlString = [self.dbHelper getRoomNoti:roomNo];
                   NSString *roomNoti = [self.dbHelper selectString:sqlString];
                   if(roomNoti==nil) roomNoti = @"1";
                   
                   NSString *contentMsg=@"";
                   if([contentType isEqualToString:@"IMG"]){
                       contentMsg = NSLocalizedString(@"chat_receive_image", @"chat_receive_image");
                       
                   } else if([contentType isEqualToString:@"VIDEO"]){
                       contentMsg = NSLocalizedString(@"chat_receive_video", @"chat_receive_video");

                   } else if([contentType isEqualToString:@"TEXT"]){
                       if([[self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWCHAT"]] isEqualToString:@"0"]){
                           contentMsg = NSLocalizedString(@"new_chat_no_prev", @"new_chat_no_prev");
                       } else {
                           contentMsg = content;
                       }
                       
                   } else if([contentType isEqualToString:@"FILE"]){
                       contentMsg = NSLocalizedString(@"chat_receive_file", @"chat_receive_file");

                   } else if([contentType isEqualToString:@"INVITE"]){
                       contentMsg = NSLocalizedString(@"chat_receive_invite", @"chat_receive_invite");
                   }

                   /*
                   if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                       if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive ) {
                           NSLog( @"INACTIVE" );
                           if([roomNoti isEqualToString:@"1"]){
                               UNMutableNotificationContent *notice = [UNMutableNotificationContent new];
                               notice.title = userName;
                               notice.body = contentMsg;
                               notice.userInfo = userInfo;
                               notice.threadIdentifier = currentTime;
//                               notice.categoryIdentifier = @"Hi-SNS";
                               if(isPush==1){
                                   AudioServicesPlaySystemSound(1007);
                                   AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                               }
                               UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Hi-SNS" content:notice trigger:nil];
                               UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                               [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                                   if (error != nil) {}
                               }];
                           }
                           
                       } else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground ) {
                           NSLog( @"BACKGROUND" );
                           if([roomNoti isEqualToString:@"1"]){
                               UNMutableNotificationContent *notice = [UNMutableNotificationContent new];
                               notice.title = userName;
                               notice.body = contentMsg;
                               notice.userInfo = userInfo;
                               notice.threadIdentifier = currentTime;
                               if(isPush==1){
                                   AudioServicesPlaySystemSound(1007);
                                   AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                               }
   
                               UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Hi-SNS" content:notice trigger:nil];
                               UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                               [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                                   if (error != nil) {

                                   }
                               }];
                           }
                       } else {
                           NSLog( @"FOREGROUND" );
                           if([roomNoti isEqualToString:@"1"]){
                               UNMutableNotificationContent *notice = [UNMutableNotificationContent new];
                               notice.title = userName;
                               notice.body = contentMsg;
                               notice.userInfo = userInfo;
                               notice.threadIdentifier = currentTime;
                               if(isPush==1){
                                   AudioServicesPlaySystemSound(1007);
                                   AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                               }

                               UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Hi-SNS" content:notice trigger:nil];
                               UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                               [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                                   if (error != nil) {

                                   }
                               }];
                           }
                       }
                   }
                    */
               }
               
           } else if([pushType isEqualToString:@"NEW_POST"]){
               NSArray *dataSet = [dict objectForKey:@"DATASET"];
               NSString *snsName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
               NSString *snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NO"];
               NSNumber *writerNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NO"];
               //NSString *writerId = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_ID"];
               NSString *writerNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NM"]];
               //NSNumber *postNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_NO"];
               NSString *summary = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SUMMARY"]];

               NSString *myUserNo = [self.appPrefs objectForKey:[self setPreferencesKey:@"CUSERNO"]];

               /*
               NSString *postNoti =  [self.dbHelper selectString:[self.dbHelper getPostNoti:snsNo]];
               if([postNoti isEqualToString:@"1"]||postNoti==nil){
                   if(![[NSString stringWithFormat:@"%@", writerNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                       NSString *noticeMsg = @"";
                       if([[self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWPOST"]] isEqualToString:@"0"]){
                           noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post1", @"new_post1"), writerNm];
                       } else {
                           noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post1_3", @"new_post1_3"), writerNm, summary]; //내용표시해야함
                       }
                       
                       UNMutableNotificationContent *notice = [UNMutableNotificationContent new];
                       notice.title = snsName;
                       notice.body = noticeMsg;
                       notice.userInfo = userInfo;
                       notice.threadIdentifier = currentTime;
                       
                       if(isPush==1){
                           AudioServicesPlaySystemSound(1007);
                           AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                       }
                       UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Hi-SNS" content:notice trigger:nil];
                       UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                       [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                           if (error != nil) { }
                       }];
                   }
               }
                */

           } else if([pushType isEqualToString:@"NEW_POST_COMMENT"]){
               NSArray *dataSet = [dict objectForKey:@"DATASET"];
               NSString *snsName =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
               NSString *snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NO"];
               //NSNumber *writerNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NO"];
               //NSString *writerId = [[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_ID"];
               NSString *writerNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"POST_WRITER_NM"]];
               //NSNumber *postNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_NO"];
               NSNumber *cWriterNo = [[dataSet objectAtIndex:0] objectForKey:@"NEW_COMMENT_USER_NO"];
               NSString *cWriterNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"NEW_COMMENT_USER_NM"]];
               //NSString *cWriterId = [[dataSet objectAtIndex:0] objectForKey:@"NEW_COMMENT_USER_ID"];
               NSString *summary = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SUMMARY"]];
               
               NSString *isTag = [NSString stringWithFormat:@"%@",[[dataSet objectAtIndex:0] objectForKey:@"IS_TAG"]];
               NSString *jsonTag = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"TARGET_LIST"]];
               NSData *jsonData = [jsonTag dataUsingEncoding:NSUTF8StringEncoding];
               NSError *error;
               NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
               NSString *myName = [jsonDict objectForKey:[self.appPrefs objectForKey:@"USERID"]];

               NSString *myUserNo = [self.appPrefs objectForKey:[self setPreferencesKey:@"CUSERNO"]];

               /*
               NSString *commNoti = [self.dbHelper selectString:[self.dbHelper getCommentNoti:snsNo]];
               if([commNoti isEqualToString:@"1"]||commNoti==nil){
                   AVAudioSession * session = [AVAudioSession sharedInstance];
                   [session setCategory: AVAudioSessionCategoryPlayback error: nil];

                   if(![[NSString stringWithFormat:@"%@", cWriterNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                       
                       if([isTag isEqualToString:@"0"]){
                           NSString *noticeMsg = @"";
                           if([[self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWCOMM"]] isEqualToString:@"0"]){
                               noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment1", @"new_post_comment1"), cWriterNm, writerNm];
                           } else {
                               noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment1_3", @"new_post_comment1_3"), cWriterNm, summary]; //내용표시해야함
                           }
                           
                           UNMutableNotificationContent *notice = [UNMutableNotificationContent new];
                           notice.title = snsName;
                           notice.body = noticeMsg;
                           notice.userInfo = userInfo;
                           notice.threadIdentifier = currentTime;
                           
                           if(isPush==1){
                               AudioServicesPlaySystemSound(1007);
                               AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                           }
                           UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Hi-SNS" content:notice trigger:nil];
                           UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                           [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                               if (error != nil) {
                                   
                               }
                           }];

                       } else {
                           NSString *noticeMsg = @"";
                           if([[self.appPrefs objectForKey:[self setPreferencesKey:@"NOTINEWCOMM"]] isEqualToString:@"0"]){
                               noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment2", @"new_post_comment2"), cWriterNm, myName];
                           } else {
                               noticeMsg = [NSString stringWithFormat:NSLocalizedString(@"new_post_comment2_3", @"new_post_comment2_3"), cWriterNm, myName, summary]; //내용표시해야함
                           }
                           
                           UNMutableNotificationContent *notice = [UNMutableNotificationContent new];
                           notice.title = snsName;
                           notice.body = noticeMsg;
                           notice.userInfo = userInfo;
                           notice.threadIdentifier = currentTime;
                           
                           if(isPush==1){
                               AudioServicesPlaySystemSound(1007);
                               AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                           }
                           UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Hi-SNS" content:notice trigger:nil];
                           UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                           [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                               if (error != nil) {
                                   
                               }
                           }];
                       }

                   }
               }
                */
               
           } else if([pushType isEqualToString:@"NEW_TASK"]){
               NSArray *dataSet = [dict objectForKey:@"DATASET"];
               NSString *snsName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
               NSString *snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NO"];
               NSNumber *writerNo = [[dataSet objectAtIndex:0] objectForKey:@"TASK_WRITER_NO"];
               NSString *writerNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"TASK_WRITER_NM"]];

               NSString *myUserNo = [self.appPrefs objectForKey:[self setPreferencesKey:@"CUSERNO"]];

               /*
               NSString *postNoti = [self.dbHelper selectString:[self.dbHelper getPostNoti:snsNo]];
               if([postNoti isEqualToString:@"1"]||postNoti==nil){
                   if(![[NSString stringWithFormat:@"%@", writerNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                       NSString *noticeMsg = [NSString stringWithFormat:@"%@님이 새로운 업무를 생성하였습니다.", writerNm];
                       UNMutableNotificationContent *notice = [UNMutableNotificationContent new];
                       notice.title = snsName;
                       notice.body = noticeMsg;
                       notice.userInfo = userInfo;
                       notice.threadIdentifier = currentTime;
                       
                       if(isPush==1){
                           AudioServicesPlaySystemSound(1007);
                           AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                       }
                       UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Hi-SNS" content:notice trigger:nil];
                       UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                       [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                           if (error != nil) {
                               
                           }
                       }];
                   }
               }
                */

           } else if([pushType isEqualToString:@"EDIT_TASK"]){
               NSArray *dataSet = [dict objectForKey:@"DATASET"];
               NSString *snsName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
               NSString *snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NO"];
               NSNumber *writerNo = [[dataSet objectAtIndex:0] objectForKey:@"TASK_WRITER_NO"];
               NSString *writerNm =  [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"TASK_WRITER_NM"]];

               NSString *myUserNo = [self.appPrefs objectForKey:[self setPreferencesKey:@"CUSERNO"]];

               /*
               NSString *postNoti = [self.dbHelper selectString:[self.dbHelper getPostNoti:snsNo]];
               if([postNoti isEqualToString:@"1"]||postNoti==nil){
                   if(![[NSString stringWithFormat:@"%@", writerNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                       NSString *noticeMsg = [NSString stringWithFormat:@"%@님이 업무를 수정하였습니다.", writerNm];
                       UNMutableNotificationContent *notice = [UNMutableNotificationContent new];
                       notice.title = snsName;
                       notice.body = noticeMsg;
                       notice.userInfo = userInfo;
                       notice.threadIdentifier = currentTime;
                       
                       if(isPush==1){
                           AudioServicesPlaySystemSound(1007);
                           AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                       }
                       UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Hi-SNS" content:notice trigger:nil];
                       UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                       [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                           if (error != nil) {
                               
                           }
                       }];
                   }
               }
                */

           } else if([pushType isEqualToString:@"FORCE_DELETE_SNS"]){
               //게시판 강제탈퇴 푸시
           } else if([pushType isEqualToString:@"DELETE_SNS"]){
               //게시판삭제 푸시
           } else if([pushType isEqualToString:@"APPROVE_SNS"]){
               //게시판 가입 승인 푸시
           
           } else if([pushType isEqualToString:@"SYSTEM_MSG"]){
               NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
               NSString *myUserNo = [self.appPrefs objectForKey:[self setPreferencesKey:@"CUSERNO"]];
               
               NSString *subType = [dict objectForKey:@"SUB_TYPE"];
               if([subType isEqualToString:@"SYSMSG_CHANGE_PERMISSION"]){
                   NSArray *dataSet = [dict objectForKey:@"DATASET"];
                   
                   NSMutableArray *statusTrueArr = [[NSMutableArray alloc] init];
                   NSMutableArray *statusFalseArr = [[NSMutableArray alloc] init];
                   NSString *grantMsg;
                   NSString *revokeMsg;
                   NSString *resultMsg = @"";
                   
                   for(int i=0; i<dataSet.count; i++){
                       NSString *prmUserNo = [[dataSet objectAtIndex:i] objectForKey:@"CUSER_NO"];
                       if([[NSString stringWithFormat:@"%@", prmUserNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                           NSString *prmNm = [[dataSet objectAtIndex:i] objectForKey:@"PRM_NM"];
                           NSString *prmStatus = [[dataSet objectAtIndex:i] objectForKey:@"PRM_STATUS"];
                           if([prmNm isEqualToString:@"MediaPermission"]){
                               if([prmStatus isEqual:@YES]) {
                                   [statusTrueArr addObject:NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
                                   [prefs setObject:@"1" forKey:@"MEDIA_AUTH"];
                               
                               } else if([prmStatus isEqual:@NO]) {
                                   [statusFalseArr addObject:NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
                                   [prefs setObject:@"0" forKey:@"MEDIA_AUTH"];
                               }
                               
                               [prefs synchronize];
                               [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshProfilePush" object:nil];
                               
                           } /*else if([prmNm isEqualToString:@"FilePermission"]){ //임의로 만든거임
                               if([prmStatus isEqual:@YES]) {
                                   [statusTrueArr addObject:@"파일 업로드 권한"];
                               
                               } else if([prmStatus isEqual:@NO]) {
                                   [statusFalseArr addObject:@"파일 업로드 권한"];
                               }
                           }*/
                       }
                   }
                   
                   if(statusTrueArr.count>0){
                       NSString *trueStr = [[statusTrueArr valueForKey:@"description"] componentsJoinedByString:@", "];
                       grantMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_grant_msg", @"user_permission_grant_msg"), trueStr];
                   }
                   
                   if(statusFalseArr.count>0){
                       NSString *falseStr = [[statusFalseArr valueForKey:@"description"] componentsJoinedByString:@", "];
                       revokeMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_revoke_msg", @"user_permission_revoke_msg"), falseStr];
                   }
                   
                   if(grantMsg!=nil&&revokeMsg!=nil) resultMsg = [NSString stringWithFormat:@"%@ \n%@", grantMsg, revokeMsg];
                   else if(grantMsg!=nil&&revokeMsg==nil) resultMsg = grantMsg;
                   else if(grantMsg==nil&&revokeMsg!=nil) resultMsg = revokeMsg;
                   
                   NSLog(@"resultMSG : %@", resultMsg);
                   
                   /*
                   UNMutableNotificationContent *notice = [UNMutableNotificationContent new];
                   notice.title = NSLocalizedString(@"user_permission_change", @"user_permission_change");
                   notice.body = resultMsg;
                   notice.userInfo = userInfo;
                   notice.threadIdentifier = currentTime;
                   
                   if(isPush==1){
                       AudioServicesPlaySystemSound(1007);
                       AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                   }
                   UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Hi-SNS" content:notice trigger:nil];
                   UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                   [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                       if (error != nil) { }
                   }];
                    */
               
               } else if([subType isEqualToString:@"SYSMSG_CHANGE_EASY_PWD"]){
//               - 비밀번호 변경 시 푸시
//               {"MESSAGE":"-","RESULT":"SUCCESS","TYPE":"SYSTEM_MSG","SUB_TYPE":"SYSMSG_CHANGE_EASY_PWD","EASY_PWD_FLAG":"Y","EASY_PWD":"000000"}
                   NSString *easyPwdFlag = [dict objectForKey:@"EASY_PWD_FLAG"];
                   NSString *easyPwd = [dict objectForKey:@"EASY_PWD"];
                   self.simplePwdFlag = easyPwdFlag;
                   self.simplePwd = easyPwd;
               
               } else if([subType isEqualToString:@"SYSMSG_CHANGE_LOGIN_MOBILE_USER"]){
                   NSString *currUserId = [self.appPrefs objectForKey:@"USERID"];
                   NSString *userId = [dict objectForKey:@"USER_ID"];
                   NSString *currDvcId = [self.appPrefs objectForKey:[self setPreferencesKey:@"DVCID"]];
                   NSString *dvcId = [dict objectForKey:@"DEVICE_ID"];
                   if([currUserId isEqualToString:userId] && ![currDvcId isEqualToString:dvcId]){
                       NSString *userNm = [NSString urlDecodeString:[self.appPrefs objectForKey:[self setPreferencesKey:@"USERNM"]]];
                       UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"system_change_login_user", @"system_change_login_user"), userNm, userId] message:nil preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         exit(0);
                                                                     }];
                       [alert addAction:okButton];
                       [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                   }
               }
           }
       }
       
       // set a member variable to tell the new delegate that this is background
       PushReceivedHandler *pushHandle = [[PushReceivedHandler alloc]init];
       [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationReceived" object:nil userInfo:userInfo];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog("FORE/BACK GROUND userInfo : %@", userInfo);
    [self receiveNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetch:(void (^)(UIBackgroundFetchResult result))handler{
    NSLog("userInfo : %@", userInfo);
    
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
    {
        return;
    }
//    NSLog( @"HANDLE PUSH, didReceiveRemoteNotification: %@", userInfo );
    
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
    {
        NSLog( @"INACTIVE" );
        self.inactivePushInfo = userInfo;
        //completionHandler( UIBackgroundFetchResultNewData );
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:userInfo];
        handler(UIBackgroundFetchResultNewData);
    }
    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
    {
        NSLog( @"BACKGROUND" );
        self.inactivePushInfo = userInfo;
        //completionHandler( UIBackgroundFetchResultNewData );
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:userInfo];
        handler(UIBackgroundFetchResultNewData);
    }
    else
    {
        NSLog( @"FOREGROUND" );
        //completionHandler( UIBackgroundFetchResultNewData );
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:userInfo];
        handler(UIBackgroundFetchResultNewData);
    }
}
*/

#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:notification.request.content.userInfo];
    NSLog( @"Handle push from foreground %@", notification.request.content.userInfo );
    
//    completionHandler(UNNotificationPresentationOptionAlert); 변경해보자 밑에걸로
    [self receiveNotification:notification.request.content.userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog();
    
    //푸시 노티 클릭
    self.inactivePostPushInfo = [[NSDictionary alloc]init];
    self.inactiveChatPushInfo = [[NSDictionary alloc]init];
    self.inactivePushInfo = [[NSDictionary alloc] init];
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        self.inactivePushInfo = response.notification.request.content.userInfo;
        
        if(self.inactivePushInfo.count>0){
            NSLog(@"INACTIVE : %@", self.inactivePushInfo);
//            NSString *message = [self.inactivePushInfo objectForKey:@"MESSAGE"];
            NSString *message = [self.inactivePushInfo objectForKey:@"msg"];
            
            NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            
            NSString *pushType = [dict objectForKey:@"TYPE"];
            if([pushType isEqualToString:@"NEW_POST"]){
                self.inactivePostPushInfo = self.inactivePushInfo;
                
                self.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                PostDetailViewController *vc = (PostDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                
                NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
                NSString *postDetailClass = NSStringFromClass([vc class]);
                
                vc.fromSegue = @"NOTI_POST_DETAIL";
                vc.notiPostDic = dict;
                
                self.inactivePostPushInfo = nil;
                
                if(![currentClass isEqualToString:postDetailClass]){
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self.window.rootViewController presentViewController:nav animated:YES completion:NULL];
                }
                
            } else if([pushType isEqualToString:@"NEW_POST_COMMENT"]){
                self.inactivePostPushInfo = self.inactivePushInfo;
                
                self.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                PostDetailViewController *vc = (PostDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                
                NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
                NSString *postDetailClass = NSStringFromClass([vc class]);
                
                vc.fromSegue = @"NOTI_POST_DETAIL";
                vc.notiPostDic = dict;
                
                self.inactivePostPushInfo = nil;
                
                if(![currentClass isEqualToString:postDetailClass]){
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self.window.rootViewController presentViewController:nav animated:YES completion:NULL];
                }
                
            } else if([pushType isEqualToString:@"ADD_CHAT"]){
                
                self.inactiveChatPushInfo = self.inactivePushInfo;
                self.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
                
                NSArray *dataSet = [dict objectForKey:@"DATASET"];
                NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];

                NSString *sqlString = [self.dbHelper getRoomInfo:roomNo];
                NSMutableArray *roomChatArr = [self.dbHelper selectMutableArray:sqlString];

                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

                RightSideViewController *rightViewController = (RightSideViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
                CGRect screen = [[UIScreen mainScreen]bounds];
                CGFloat screenWidth = screen.size.width;
                CGFloat screenHeight = screen.size.height;
                rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);

                if(roomChatArr.count>0){
                    NSString *roomNoti = [[roomChatArr objectAtIndex:0]objectForKey:@"ROOM_NOTI"];
                    NSString *roomName = [NSString urlDecodeString:[[roomChatArr objectAtIndex:0]objectForKey:@"ROOM_NM"]];
                    NSString *roomType = [[roomChatArr objectAtIndex:0]objectForKey:@"ROOM_TYPE"];

                    if([roomType isEqualToString:@"0"]){
                        NotiChatViewController *vc = (NotiChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];

                        vc.roomNo = roomNo;
                        vc.roomNoti = roomNoti;
                        vc.roomName = roomName;
                        rightViewController.roomNo = roomNo;
                        rightViewController.roomNoti = roomNoti;
                        rightViewController.roomName = roomName;
                        rightViewController.roomType = roomType;

                        LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:vc leftViewController:nil rightViewController:rightViewController];
                        container.fromSegue = @"APNS_NOTI_CHAT_DETAIL";
                        [container setNavigationItemTitle:[NSString urlDecodeString:vc.roomName]];

                        self.navigationController.navigationBar.topItem.title = @"";

                        NSString *sqlString2 = [self.dbHelper updateRoomNewChat:0 roomNo:roomNo];
                        [self.dbHelper crudStatement:sqlString2];

                        NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
                        NSString *chatDetailClass = NSStringFromClass([vc class]);

                        vc.fromSegue = @"NOTI_CHAT_DETAIL";

                        NSUserDefaults *classPref = [NSUserDefaults standardUserDefaults];
                        [classPref setObject:currentClass forKey:@"CURR_CLASS"];
                        [classPref synchronize];

                        if(![currentClass isEqualToString:chatDetailClass]){
                            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
                            nav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self.window.rootViewController presentViewController:nav animated:YES completion:NULL];
                        }

                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatList" object:nil userInfo:self.inactiveChatPushInfo];

                    } else {
                        ChatViewController *vc = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];

                        vc.roomNo = roomNo;
                        vc.roomNoti = roomNoti;
                        vc.roomName = roomName;
                        rightViewController.roomNo = roomNo;
                        rightViewController.roomNoti = roomNoti;
                        rightViewController.roomName = roomName;
                        rightViewController.roomType = roomType;

                        LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:vc leftViewController:nil rightViewController:rightViewController];
                        container.fromSegue = @"APNS_NOTI_CHAT_DETAIL";
                        [container setNavigationItemTitle:[NSString urlDecodeString:vc.roomName]];

                        self.navigationController.navigationBar.topItem.title = @"";

                        NSString *sqlString2 = [self.dbHelper updateRoomNewChat:0 roomNo:roomNo];
                        [self.dbHelper crudStatement:sqlString2];

                        NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
                        NSString *chatDetailClass = NSStringFromClass([vc class]);

                        vc.fromSegue = @"NOTI_CHAT_DETAIL";
                        vc.notiChatDic = dict;

                        NSUserDefaults *classPref = [NSUserDefaults standardUserDefaults];
                        [classPref setObject:currentClass forKey:@"CURR_CLASS"];
                        [classPref synchronize];

                        if(![currentClass isEqualToString:chatDetailClass]){
                            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
                            nav.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self.window.rootViewController presentViewController:nav animated:YES completion:NULL];
                        }

                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatList" object:nil userInfo:self.inactiveChatPushInfo];
                    }
                }
                
            } else if([pushType isEqualToString:@"NEW_TASK"]){
                self.inactivePostPushInfo = self.inactivePushInfo;
                
            } else if([pushType isEqualToString:@"EDIT_TASK"]){
                self.inactivePostPushInfo = self.inactivePushInfo;
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti_NewTaskPush" object:nil userInfo:self.inactivePostPushInfo];
                
            } else if([pushType isEqualToString:@"FORCE_DELETE_SNS"]){
                //게시판 강제탈퇴 푸시
                
            } else if([pushType isEqualToString:@"DELETE_SNS"]){
                //게시판삭제 푸시
                
            } else if([pushType isEqualToString:@"APPROVE_SNS"]){
                //게시판 가입 승인 푸시
                
            } else if([pushType isEqualToString:@"SYSTEM_MSG"]){
                
            }
            
        }
        
//        completionHandler(UNNotificationPresentationOptionAlert);
        completionHandler();
        
    } else if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        self.inactivePushInfo = response.notification.request.content.userInfo;
        NSLog(@"BACKGROUND : %@", self.inactivePushInfo);
    }
    
    self.inactivePushInfo = response.notification.request.content.userInfo;
    
}




#pragma mark - background Notification
//- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification{
//    NSLog(@"applicationDidBecomeActive notification : %@",notification.userInfo);
//}

- (void)noti_RmqConnect:(NSNotification *)notification{
    NSLog();
    
    NSString *userID = [self.appPrefs objectForKey:@"USERID"];
    if(userID!=nil && ![userID isEqualToString:@""]){
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusNotReachable) {
//                NSLog(@"네트워크 사용 할 수 없음");
            } else if (status == AFNetworkReachabilityStatusUnknown){
//                NSLog(@"네트워크 상태 알 수 없음");
            } else {
                if(self.isLogin){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                        if(notification.userInfo!=nil){
                            [rmq connectMQServer:notification.userInfo];
                        } else {
                            [rmq connectMQServer:nil];
                        }
                    });
                }
            }
        }];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_RmqConnect" object:nil];
    }
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
