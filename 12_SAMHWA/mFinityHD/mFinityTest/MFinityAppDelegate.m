//
//  AppDelegate.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "MFinityAppDelegate.h"

#import "MainViewController.h"
#import "Notice_PushViewController.h"
#import "MFTableViewController.h"
#import "SettingViewController.h"
#import "EmptyViewController.h"
#import "WebViewController.h"
#import "SecurityManager.h"
#import "SVProgressHUD.h"
#import "KeychainItemWrapper.h"
#import "UIDevice-Hardware.h"

#import "LoginViewController.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation MFinityAppDelegate
@synthesize main_url = _main_url;
@synthesize appDeviceToken = _appDeviceToken;
@synthesize AES256Key = _AES256Key;
@synthesize AES256Key2 = _AES256Key2;
@synthesize menu_title = _menu_title;
@synthesize target_url = _target_url;
@synthesize noticeTabBarNumber = _noticeTabBarNumber;



-(void)loginErrorToLogFile:(NSString *)title :(NSException *)exception{
   //로그인이력 저장
   NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
   formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
   NSString *today = [formatter stringFromDate:[NSDate date]];
   NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
   NSString *compFolder = [documentFolder stringByAppendingFormat:@"/com.samhwa.sm2ezSmartHD/10"];
//   NSLog(@"compFolder : %@", compFolder);
   
   NSFileManager *fileManager = [NSFileManager defaultManager];
   BOOL issue = [fileManager isReadableFileAtPath:compFolder];
   if (issue) { }
   else {
      [fileManager createDirectoryAtPath:compFolder withIntermediateDirectories:YES attributes:nil error:nil];
   }
   NSString *fileName = [NSString stringWithFormat:@"%@/SAMHWA.log", compFolder];
   NSString *modelName = [[UIDevice currentDevice] modelName];
   
   NSString *content = [NSString stringWithFormat:@"[ %@ ] %@ \nUSER_ID : %@ (%@) \nDVC_ID : %@ \nDVC_TY : %@ \nDVC_OS : %@ \nAPP_VER : %@ \nERROR : %@\n\n\n", today, title, self.user_id, self.user_no, [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"], modelName, [[UIDevice currentDevice] systemVersion], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], exception];
   
   NSError* error = nil;
   if(![fileManager fileExistsAtPath:fileName]) {
      [content writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
      
   } else {
      NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
      [fileHandle seekToEndOfFile];
      [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
      [fileHandle closeFile];
   }
    
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;

        [mailCont setSubject:[NSString stringWithFormat:@"[삼화페인트] %@_Log", self.user_id]];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"hilee@dbvalley.com"]];
//        [mailCont setMessageBody:@"Don't ever want to give you up" isHTML:NO];
        
        NSLog(@"fileName : %@", fileName);
        
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileName];
        [mailCont addAttachmentData:data mimeType:@"log" fileName:fileName];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:mailCont animated:YES completion:nil];
    
    } else {
        NSString *recipients = @"mailto:?cc=&subject=";
        NSString *body = @"&body=";
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email] options:@{} completionHandler:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark
#pragma mark Application Delegate

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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
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
                _receivePushNo = [dictionary objectForKey:@"pushNo"];
                _receiveDevNo = [dictionary objectForKey:@"devNo"];
                NSLog(@"receiveMenuNo : %@",_receiveMenuNo);
            }
        }
    }
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    
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

    introViewController = [[IntroViewController alloc]init];
    _navigationController = [[UINavigationController alloc]initWithRootViewController:introViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //Initialize
    _isAES256 = YES;
    _demo = @"NOT DEMO";
    //_appNo = @"91";
    //_host = @"http://svr001.ezsmart.co.kr:1698";
    //_host = @"http://ezpro1.mfrontiers.com:1598";

    _AES256Key = @"E3Z2S1M5A9R8T1F3E2E4L31504081532";
    _AES256Key2 = @"E3Z2S1M5A9R8T1F3";
    _moreCount = @"20";
    _paramString = @"";
    
    goLoginView = NO;
    
    //Initialize end
    MainViewController *viewController1 = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    Notice_PushViewController *viewController2 = [[Notice_PushViewController alloc] initWithNibName:@"Notice_PushViewController" bundle:nil];
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
    self.window.rootViewController = _navigationController;
    [self.window makeKeyAndVisible];
    
    

    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    NSLog(@"completionHandler : %@",completionHandler);
    completionHandler(UIBackgroundFetchResultNewData);
}
- (BOOL)application:application handleOpenURL:(NSURL *)url{
    //외부 앱에서 URL call 했을때 호출되는 델리게이트 메소드
    //이부분에 인자값으로 넘어오는 url을 파싱해서 사용하면
    //파라미터처럼 사용할 수 있음
    
    return YES;
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

- (void) setTabBar:(NSDictionary *)dic {

    if (_naviFontColor == nil) {
        _naviFontColor = _mainFontColor;
    }

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
        
        // doing this results in an easier to read unselected state then the default iOS 7 one
        //[[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],NSForegroundColorAttributeName : [self myRGBfromHex:_tabFontColor]} forState:UIControlStateNormal];
        
        
        /*
        if (_tabFontColor == nil) {
            NSLog(@"_tabFontColor == nil");
            [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[self myRGBfromHex:_mainFontColor]} forState:UIControlStateSelected];
            [self.tabBarController.tabBar setSelectedImageTintColor:[self myRGBfromHex:_mainFontColor]];
        }else{
            NSLog(@"_tabFontColor != nil");
            [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[self myRGBfromHex:_tabFontColor]} forState:UIControlStateSelected];
            [self.tabBarController.tabBar setSelectedImageTintColor:[self myRGBfromHex:_tabFontColor]];
        }*/
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
    UINavigationController *noticeView = [[UINavigationController alloc] initWithRootViewController:[[Notice_PushViewController alloc]init]];
    //UINavigationController *noticeView = [[UINavigationController alloc] initWithRootViewController:[[NoticeViewController alloc]init]];
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
                      [UIImage imageNamed:@"main.png"],
                      [UIImage imageNamed:@"notice.png"],
                      [UIImage imageNamed:@"mymenu.png"],
                      [UIImage imageNamed:@"setting.png"],
                      [UIImage imageNamed:@"logout.png"],
                      [UIImage imageNamed:@"home.png"],
                      [UIImage imageNamed:@"user.png"],
                      [UIImage imageNamed:@"favorite.png"],
                      [UIImage imageNamed:@"message.png"],
                      [UIImage imageNamed:@"search.png"],
                      [UIImage imageNamed:@"etc.png"],nil];


    NSMutableArray *setTabs = [[NSMutableArray alloc] init];
    NSMutableArray *tabNumbers = [[NSMutableArray alloc]init];
    NSMutableArray *titles = [[NSMutableArray alloc]init];
    NSMutableArray *urls = [[NSMutableArray alloc]init];
    NSMutableArray *tabs = [[NSMutableArray alloc]init];
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
    if ([_menu_title isEqualToString:@"Exit"]) {
        _pre_tabID = ([prefs integerForKey:@"startTabNumber"]+1)%5;
        _target_url = [urlArray objectAtIndex:([prefs integerForKey:@"startTabNumber"]+1)%5];
        _menu_title = [_titleArray objectAtIndex:([prefs integerForKey:@"startTabNumber"]+1)%5];
        self.tabBarController.selectedIndex = ([prefs integerForKey:@"startTabNumber"]+1)%5;
    }else{
        self.tabBarController.selectedIndex = [prefs integerForKey:@"startTabNumber"];
    }
    

}
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return YES;
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
    
    if (![temp isEqual:exit]) {
        _pre_tabID = tabIndex;
    }
    if ([temp isEqual:exit]) {
        self.tabBarController.selectedIndex = _pre_tabID;
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
    NSLog(@"MFinityAppDelegate didFailWithError : %@",error);
    [SVProgressHUD dismiss];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    NSLog(@"MFinityAppDelegate statusCode : %ld",(long)statusCode);
    
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    
    if([methodName isEqualToString:@"GetExecuteMenuInfo"]){
        if(statusCode == 404 || statusCode == 500){
            [SVProgressHUD dismiss];
        }
    }else{
        exit(0);
    }
  
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"MFinityAppDelegate didReceiveData");
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    
    if([methodName isEqualToString:@"GetExecuteMenuInfo"]){
        [self.receiveData appendData:data];
    }else{
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"str : %@",[str AES256DecryptWithKeyString:_AES256Key]);
    }
    
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"MFinityAppDelegate connectionDidFinishLoading");
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

    }else if([methodName isEqualToString:@"MLogout"]){
        [SVProgressHUD dismiss];
        if(goLoginView){
            //로그인화면으로 이동
            LoginViewController *lc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            lc.modalPresentationStyle = UIModalPresentationFullScreen;
            lc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self.window setRootViewController:lc];
            
        } else{
            exit(0);
        }
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
        NSArray *nvcChild = [_tabBarController selectedViewController].childViewControllers;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ExecutePush" object:[nvcChild objectAtIndex:nvcChild.count-1] userInfo:_userInfo];
     
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
        }
        else {
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
            //NSString *message = [aps valueForKey:@"alert"];
            
            if ([type isEqualToString:@"M1"]) {
                //NSString *message = [aps valueForKey:@"alert"];
                if ([type2 isEqualToString:@"DEL_MENU"]) {
                    contentsMessage = NSLocalizedString(@"message122", @"");
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                        [alert dismissViewControllerAnimated:YES completion:nil];
                        
                        [SVProgressHUD show];
                        goLoginView = YES;
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",self.main_url]]];
                        [request setHTTPMethod:@"POST"];
                        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
                        [conn start];
                        
                    }];
                    [alert addAction:okButton];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                    
                }else if ([type2 isEqualToString:@"DEL_DEVICE"]) {
                    contentsMessage = NSLocalizedString(@"message123", @"");
                    alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                    alertView.tag = 101;
                    
                }else if ([type2 isEqualToString:@"SUS_DEVICE"]) {
                    contentsMessage = NSLocalizedString(@"message124", @"");
                    alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                    alertView.tag = 101;
                    
                }else if ([type2 isEqualToString:@"DEL_USER"]) {
                    contentsMessage = NSLocalizedString(@"message125", @"");
                    alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                    alertView.tag = 101;
                    
                }else if ([type2 isEqualToString:@"SUS_USER"]) {
                    contentsMessage = NSLocalizedString(@"message126", @"");
                    alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                    alertView.tag = 101;
                }
                NSLog(@"message121 : %@",contentsMessage);
                
            }else if ([type isEqualToString:@"M2"]) {
                [self removeData];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message152", @"") message:NSLocalizedString(@"message153", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
            }else if([type isEqualToString:@"E"]){
                _userInfo = userInfo;
                if (_isLogin) {
                    alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:[aps valueForKey:@"alert"] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                    alertView.tag = 104;
                }else{
                    _receivePush = YES;
                    _receiveMenuNo = [userInfo objectForKey:@"menuNo"];
                    _receivePushNo = [userInfo objectForKey:@"pushNo"];
                    _receiveDevNo = [userInfo objectForKey:@"devNo"];
                }
            }
            else if([type isEqualToString:@"notice"]||[type isEqualToString:@"P1"]){
                alertView = [[UIAlertView alloc]initWithTitle:@"Notice" message:[aps valueForKey:@"alert"] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 102;
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:userInfo];
                alertView = [[UIAlertView alloc]initWithTitle:@"Message" message:[aps valueForKey:@"alert"] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 103;
            }
            [alertView show];
        }
        
        
    }else if(state == UIApplicationStateBackground){
        if ([type isEqualToString:@"M2"]) {
            [self removeData];
        }else if ([type isEqualToString:@"M1"]) {
            //NSString *message = [aps valueForKey:@"alert"];
            UIAlertView *alertView;
            if ([type2 isEqualToString:@"DEL_MENU"]) {
                contentsMessage = NSLocalizedString(@"message122", @"");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    
                    [SVProgressHUD show];
                    goLoginView = YES;
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",self.main_url]]];
                    [request setHTTPMethod:@"POST"];
                    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
                    [conn start];
                    
                }];
                [alert addAction:okButton];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                
            }else if ([type2 isEqualToString:@"DEL_DEVICE"]) {
                contentsMessage = NSLocalizedString(@"message123", @"");
                alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 101;
                [alertView show];
                
            }else if ([type2 isEqualToString:@"SUS_DEVICE"]) {
                contentsMessage = NSLocalizedString(@"message124", @"");
                alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 101;
                [alertView show];
                
            }else if ([type2 isEqualToString:@"DEL_USER"]) {
                contentsMessage = NSLocalizedString(@"message125", @"");
                alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 101;
                [alertView show];
                
            }else if ([type2 isEqualToString:@"SUS_USER"]) {
                contentsMessage = NSLocalizedString(@"message126", @"");
                alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 101;
                [alertView show];
            }
            NSLog(@"message121 : %@",contentsMessage);
            
        }else if([type isEqualToString:@"E"]){
            _userInfo = userInfo;
            if (_isLogin) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:[aps valueForKey:@"alert"] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 104;
                [alertView show];
            }else{
                _receivePush = YES;
                _receiveMenuNo = [userInfo objectForKey:@"menuNo"];
                _receivePushNo = [userInfo objectForKey:@"pushNo"];
                _receiveDevNo = [userInfo objectForKey:@"devNo"];
            }
            
        }
    }else if(state == UIApplicationStateInactive){
        
        if([type isEqualToString:@"M1"]){
            if(_isLogin){
                if ([type2 isEqualToString:@"DEL_MENU"]) {
                    contentsMessage = NSLocalizedString(@"message122", @"");
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                        [alert dismissViewControllerAnimated:YES completion:nil];
                        
                        [SVProgressHUD show];
                        goLoginView = YES;
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",self.main_url]]];
                        [request setHTTPMethod:@"POST"];
                        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
                        [conn start];
                        
                    }];
                    [alert addAction:okButton];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                    
                }else if ([type2 isEqualToString:@"DEL_DEVICE"]) {
                    contentsMessage = NSLocalizedString(@"message123", @"");
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                    alertView.tag = 101;
                    [alertView show];
                    
                }else if ([type2 isEqualToString:@"SUS_DEVICE"]) {
                    contentsMessage = NSLocalizedString(@"message124", @"");
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                    alertView.tag = 101;
                    [alertView show];
                    
                }else if ([type2 isEqualToString:@"DEL_USER"]) {
                    contentsMessage = NSLocalizedString(@"message125", @"");
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                    alertView.tag = 101;
                    [alertView show];
                    
                }else if ([type2 isEqualToString:@"SUS_USER"]) {
                    contentsMessage = NSLocalizedString(@"message126", @"");
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:contentsMessage delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                    alertView.tag = 101;
                    [alertView show];
                }
                NSLog(@"message121 : %@",contentsMessage);
            }
            
        }else if ([type isEqualToString:@"M2"]) {
            [self removeData];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message152", @"") message:NSLocalizedString(@"message153", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }else if([type isEqualToString:@"E"]){
            _userInfo = userInfo;
            if (_isLogin) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:[aps valueForKey:@"alert"] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"message51", @""), nil];
                alertView.tag = 104;
                [alertView show];
            }else{
                _receivePush = YES;
                _receiveMenuNo = [userInfo objectForKey:@"menuNo"];
                _receivePushNo = [userInfo objectForKey:@"pushNo"];
                _receiveDevNo = [userInfo objectForKey:@"devNo"];
            }
            
        }
    }
    
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    NSLog(@"%s notification : %@",__FUNCTION__,notification.request.content.userInfo);
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    [self receiveNotification:userInfo];
    
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler
{
    NSLog(@"response.notification.request.content.userInfo : %@",response.notification.request.content.userInfo);
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
    {
        NSLog( @"INACTIVE" );
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        [self receiveNotification:userInfo];
        
    }
    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
    {
        NSLog( @"BACKGROUND" );
        //self.inactivePushInfo = response.notification.request.content.userInfo;
        //completionHandler( UNNotificationPresent );
    }
    //self.inactivePushInfo = response.notification.request.content.userInfo;
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil userInfo:response.notification.request.content.userInfo];
    
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
	NSLog(@"appDeviceToken : %@", self.appDeviceToken);
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
    [self receiveNotification:userInfo];
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    /*
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
     [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result){}];
     }else{
     [self receiveNotification:userInfo];
     }
     */
}
#pragma mark
#pragma mark Util Method
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
    [prefs removeObjectForKey:@"UserInfo_ID"];
    [prefs removeObjectForKey:@"isSave"];
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
