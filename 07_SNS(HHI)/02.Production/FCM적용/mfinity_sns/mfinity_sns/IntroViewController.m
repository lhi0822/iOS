//
//  IntroViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "IntroViewController.h"
#import "MFUtil.h"
#import "MFDBHelper.h"
#import "SimplePwdInputViewController.h"
#import "DetectTouchWindow.h"
#import "SyncChatInfo.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface IntroViewController () {
    NSString *returnCode;
    AppDelegate *appDelegate;
    
    NSMutableDictionary *dictForMDM;
    SDImageCache *imgCache;
    
    RMQServerViewController *rmq;
}
@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.ipAddr = [MFUtil getIPAddress];
    NSLog(@"ip address : %@", appDelegate.ipAddr);
    
    /*
    NSString *dbName = @"A383333";
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDir = [documentPaths objectAtIndex:0];
//    NSString *exFolder = [documentsDir stringByAppendingFormat:@"/EX_DB/"];
    NSString *exFolder = @"/private/var/mobile/EX_DB";
    NSString *localDbPath = [NSString stringWithFormat:@"%@.db", [exFolder stringByAppendingPathComponent:dbName]];
    NSLog(@"localDbPath : %@", localDbPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:exFolder];
    if (issue) {
        
    }else{
        NSLog(@"만들엇어?");
        [fileManager createDirectoryAtPath:exFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSError *error;
    if ([fileManager fileExistsAtPath:localDbPath]) {
        NSLog(@"외부경로에 디비 있음");
    } else {
        NSLog(@"외부 경로에 디비 없음");
    }
    */
    
//    NSString *currentTime = @"20190101000000";
//    [appDelegate.appPrefs setObject:currentTime forKey:@"INSTALL_DATE"];
//    NSLog(@"임시설치날짜 : %@", currentTime);
//    [appDelegate.appPrefs synchronize];
    
    self.navigationController.navigationBarHidden = YES;
    self.introBg.image = [UIImage imageNamed:@"intro.png"];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.verLabel.text = [NSString stringWithFormat:@"v %@", version];
    
    imgCache = [SDImageCache sharedImageCache];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    [imgCache makeDiskCachePath:cachePath];
    
    NSLog(@"INTRO DVC_ID : %@", [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]);
    
    if([[MFSingleton sharedInstance] isMDM]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MDMIntroNotification:) name:@"MDMIntroNotification" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_MDMExcuteNextPage:) name:@"noti_MDMExcuteNextPage" object:nil];
        dictForMDM = [NSMutableDictionary dictionary];
    }
    
    [self setTimer]; //PushIDChangeNotification로 옮김
}

-(void)setTimer{
    count = 0;
    endCount = 1;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PushIDChangeNotification:) name:@"PushIDChangeNotification" object:nil];
}

- (void)PushIDChangeNotification:(NSNotification *)notification{
    NSLog(@"기존 : %@",[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]]);
    NSLog(@"현재 : %@",appDelegate.fcmToken);
    
    @try{
        
    } @catch (NSException *exception) {
       NSLog(@"Exception : %@", exception);
    }
//    if(![[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]] isEqualToString:appDelegate.appDeviceToken] || [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]]==nil || [[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]] isEqual:@"(null)"]){
    if(![[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]] isEqualToString:appDelegate.fcmToken] || [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]]==nil || [[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]] isEqual:@"(null)"]){
        NSLog(@"푸시아이디 바뀜");

        NSLog(@"fcmToken : %@", appDelegate.fcmToken);
//        [appDelegate.appPrefs setObject:appDelegate.appDeviceToken forKey:[appDelegate setPreferencesKey:@"PUSHID1"]];
        [appDelegate.appPrefs setObject:appDelegate.fcmToken forKey:[appDelegate setPreferencesKey:@"PUSHID1"]];
        [appDelegate.appPrefs synchronize];

        NSString *dlqUrl = @"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish";
        NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];

        NSDictionary *emptyDict = [NSDictionary dictionary];
        NSString* emptyJson = nil;
        NSData* emptyData = [NSJSONSerialization dataWithJSONObject:emptyDict options:kNilOptions error:nil];
        emptyJson = [[NSString alloc] initWithData:emptyData encoding:NSUTF8StringEncoding];

        NSMutableDictionary *dlqDict = [NSMutableDictionary dictionary];
        [dlqDict setObject:[appDelegate.appPrefs objectForKey:@"COMP_NO"] forKey:@"COMP_NO"];
        [dlqDict setObject:@"1" forKey:@"APP_NO"];
        [dlqDict setObject:[[MFSingleton sharedInstance] appType] forKey:@"APP_TYPE"];
        [dlqDict setObject:@"i" forKey:@"DVC_OS"];
        [dlqDict setObject:[[MFSingleton sharedInstance] dvcType] forKey:@"DVC_TYPE"];
        [dlqDict setObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]] forKey:@"PUSH_ID"];
        [dlqDict setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"USER_ID"];
        [dlqDict setObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]forKey:@"DVC_ID"];
        [dlqDict setObject:mfpsId forKey:@"QUEUE_NAME"];
        NSString* dlqJson = nil;
        NSData* dlqData = [NSJSONSerialization dataWithJSONObject:dlqDict options:kNilOptions error:nil];
        dlqJson = [[NSString alloc] initWithData:dlqData encoding:NSUTF8StringEncoding];
        dlqJson = [dlqJson urlEncodeUsingEncoding:NSUTF8StringEncoding];

        NSMutableDictionary *dlqDict2 = [NSMutableDictionary dictionary];
        [dlqDict2 setObject:dlqDict forKey:@"properties"];
        [dlqDict2 setObject:@"UPDATE_USER_INFO" forKey:@"routing_key"];
        [dlqDict2 setObject:dlqJson forKey:@"payload"];
        [dlqDict2 setObject:@"string" forKey:@"payload_encoding"];
        NSString* dlqJson2 = nil;
        NSData* dlqData2 = [NSJSONSerialization dataWithJSONObject:dlqDict2 options:kNilOptions error:nil];
        dlqJson2 = [[NSString alloc] initWithData:dlqData2 encoding:NSUTF8StringEncoding];

        MFURLSession *dlqSession = [[MFURLSession alloc]initWithURL:[NSURL URLWithString:dlqUrl] option:dlqJson2];
        [dlqSession start];
    }
//    [self setTimer];
    [self callWebService];
}

-(void)handleTimer:(NSTimer *)timer {
    count++;
    
    userId = [appDelegate.appPrefs objectForKey:@"USERID"];
    userPwd = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERPWD"]];
    
    legacyNm = [[MFSingleton sharedInstance] legacyName]; //appDelegate.legacy_name;
    
    if([[MFSingleton sharedInstance] isMDM]){
        NSURL *url = [NSURL URLWithString:@"com.gaia.mobikit.apple://"];

        if (![[UIApplication sharedApplication] canOpenURL:url]) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"MDM이 설치되지 않았습니다." preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];

                NSURL *url = [NSURL URLWithString:@"https://mdm.hhi.co.kr/mdm_admin_server/download"];
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                    exit(0);
                }];
            });
            
        }else{
            if (count==endCount) {
                [self loginCheck];
                [myTimer invalidate];
            }
        }
    } else {
        if (count==endCount) {
            [self loginCheck];
            [myTimer invalidate];
        }
    }
}

- (void)loginCheck{
    if([legacyNm isEqualToString:@"HHI"]){
        //테스트로그인
//        userId = @"BP15214";
//        userPwd = @"feel100101";
//        dvcId = @"B2C088E3-FBC5-4EF5-9CE4-9DA65A0A61A7";
//        [appDelegate.appPrefs setObject:userId forKey:@"USERID"];
//        [appDelegate.appPrefs setObject:userPwd forKey:[appDelegate setPreferencesKey:@"USERPWD"]];
//        [appDelegate.appPrefs setObject:dvcId forKey:[appDelegate setPreferencesKey:@"DVCID"]];
//        [appDelegate.appPrefs setObject:@"CA" forKey:@"CPN_CODE"];
//        [appDelegate.appPrefs setObject:appDelegate.appDeviceToken forKey:[appDelegate setPreferencesKey:@"PUSHID1"]];
//        [appDelegate.appPrefs setObject:@"2021-01-07" forKey:[appDelegate setPreferencesKey:@"AUTOLOGINDATE"]];
//        [appDelegate.appPrefs synchronize];
        
        if([[MFSingleton sharedInstance] autoLogin]){
//            [appDelegate.appPrefs setObject:@"2019-04-28" forKey:[appDelegate setPreferencesKey:@"AUTOLOGINDATE"]];
//            [appDelegate.appPrefs synchronize];
            
            NSLog(@"AUTO_LOGIN_DATE : %@", [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"AUTOLOGINDATE"]]);
            
            //오늘날짜
            NSDate *today = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd";
            
            if([appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"AUTOLOGINDATE"]]==nil||[[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"AUTOLOGINDATE"]] isEqual:@""]||[[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"AUTOLOGINDATE"]] isEqual:@"(null)"]||[[appDelegate.appPrefs objectForKey:@"{@AUTO_LOGIN_DATE}"] isEqual:@""]){
                NSString *snsDate = [formatter stringFromDate:today];
                [appDelegate.appPrefs setObject:snsDate forKey:[appDelegate setPreferencesKey:@"AUTOLOGINDATE"]];
                [appDelegate.appPrefs synchronize];
            }
            
            //1.자동로그인 시작 날짜
            NSDate *startDate = [formatter dateFromString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"AUTOLOGINDATE"]]];
            
            //2.자동로그인 시작날짜로부터 30일
            NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
//            NSLog(@"자동로그인 기간 : %d",[[MFSingleton sharedInstance] autoLoginDate]);
            dayComponent.day = [[MFSingleton sharedInstance] autoLoginDate];
            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            NSDate *endDate = [theCalendar dateByAddingComponents:dayComponent toDate:startDate options:0];
            
            //3.자동로그인30일과 오늘 날짜 비교
            NSCalendar *sysCalendar = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSCalendarUnitDay;
            NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:today toDate:endDate options:0];//날짜 비교해서 차이값 추출
            NSInteger date = dateComp.day;
            
            if(date>=0){
                NSLog(@"자동로그인 유효");
                
                if(userId!=nil&&userPwd!=nil&&![userId isEqualToString:@""]&&![userPwd isEqualToString:@""]){
                    NSLog(@"터치원 정보있음 1");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushIDChangeNotification" object:nil];
//                    [self callWebService];
                    
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"login_not_info", @"login_not_info") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",[[MFSingleton sharedInstance] callScheme]]] options:@{} completionHandler:^(BOOL success) {
                                                                             if(!success){
                                                                                 NSURL *browser;
                                                                                 if([[[MFSingleton sharedInstance] appType] isEqualToString:@"DEV"]) browser = [NSURL URLWithString:@"https://dev.hhi.co.kr:44175/deploy"];
                                                                                 else if([[[MFSingleton sharedInstance] appType] isEqualToString:@"ENT"]) browser = [NSURL URLWithString:@"https://touch1.hhi.co.kr/deploy"];
                                                                                 [[UIApplication sharedApplication] openURL:browser options:@{} completionHandler:^(BOOL success) {
                                                                                     exit(0);
                                                                                 }];
                                                                                 
                                                                             } else {
                                                                                 NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
                                                                                 NSString *callUrl = [NSString stringWithFormat:@"%@://?call=%@&", [[MFSingleton sharedInstance] callScheme],stringURLScheme];
                                                                                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callUrl] options:@{} completionHandler:^(BOOL success) {
                                                                                     exit(0);
                                                                                 }];
                                                                             }
                                                                             
                                                                         }];
                                                                     }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            } else {
                NSLog(@"자동로그인 만료");
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"auto_login_expired", @"auto_login_expired") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     
                                                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",[[MFSingleton sharedInstance] callScheme]]] options:@{} completionHandler:^(BOOL success) {
                                                                         if(!success){
                                                                             NSURL *browser;
                                                                             if([[[MFSingleton sharedInstance] appType] isEqualToString:@"DEV"]) browser = [NSURL URLWithString:@"https://dev.hhi.co.kr:44175/deploy"];
                                                                             else if([[[MFSingleton sharedInstance] appType] isEqualToString:@"ENT"]) browser = [NSURL URLWithString:@"https://touch1.hhi.co.kr/deploy"];
                                                                             [[UIApplication sharedApplication] openURL:browser options:@{} completionHandler:^(BOOL success) {
                                                                                 exit(0);
                                                                             }];
                                                                             
                                                                         } else {
                                                                             NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
                                                                             NSString *callUrl = [NSString stringWithFormat:@"%@://?call=%@&", [[MFSingleton sharedInstance] callScheme],stringURLScheme];
                                                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callUrl] options:@{} completionHandler:^(BOOL success) {
                                                                                 exit(0);
                                                                             }];
                                                                         }
                                                                         
                                                                     }];
                                                                 }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else {
            if(userId!=nil&&userPwd!=nil&&![userId isEqualToString:@""]&&![userPwd isEqualToString:@""]){
                NSLog(@"터치원 정보있음 2");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PushIDChangeNotification" object:nil];
//                [self callWebService];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"login_not_info", @"login_not_info") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",[[MFSingleton sharedInstance] callScheme]]] options:@{} completionHandler:^(BOOL success) {
                                                                         if(!success){
                                                                             NSURL *browser;
                                                                             if([[[MFSingleton sharedInstance] appType] isEqualToString:@"DEV"]) browser = [NSURL URLWithString:@"https://dev.hhi.co.kr:44175/deploy"];
                                                                             else if([[[MFSingleton sharedInstance] appType] isEqualToString:@"ENT"]) browser = [NSURL URLWithString:@"https://touch1.hhi.co.kr/deploy"];
                                                                             [[UIApplication sharedApplication] openURL:browser options:@{} completionHandler:^(BOOL success) {
                                                                                 exit(0);
                                                                             }];
                                                                             
                                                                         } else {
                                                                             NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
                                                                             NSString *callUrl = [NSString stringWithFormat:@"%@://?call=%@&", [[MFSingleton sharedInstance] callScheme],stringURLScheme];
                                                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callUrl] options:@{} completionHandler:^(BOOL success) {
                                                                                 exit(0);
                                                                             }];
                                                                         }
                                                                         
                                                                     }];
                                                                 }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushIDChangeNotification" object:nil];
//        [self callWebService];
    }
}
-(void)enterWorkApp{
    appDelegate.mdmCallAPI = @"enterWorkApp";

//    NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
//    NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=enterWorkApp"];
//    [urlString appendFormat:@"&caller=%@", stringURLScheme];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {}];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [prefs objectForKey:@"MDM_AUTH_TOKEN"];
    NSString *urlString = [NSString stringWithFormat:@"https://mdm.hhi.co.kr/mdm_admin_server/mdmApi/enterWorkApp?authToken=%@&osType=IOS", authToken];
    NSLog(@"MDM Url : %@", urlString);
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString] options:NSDataReadingUncached error:&error];
    
}

-(void)getMDMExageInfo:(NSString*)command{
    NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
    if (stringURLScheme) {
        appDelegate.isExcuteMDM = YES;
        NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=%@",command];
        [urlString appendFormat:@"&caller=%@", stringURLScheme];
        NSLog(@"INTRO MDM urlString : %@",urlString);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    }
    else{
        NSLog(@"현재 앱에 URL Scheme 이 지정되어 있지 않아 호출할 수 없습니다. URL Scheme 지정해야 결과를 응답받을 수 있습니다.");

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"현재 앱에 URL Scheme 이 지정되어 있지 않아 호출할 수 없습니다. URL Scheme 지정해야 결과를 응답받을 수 있습니다." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
+ (void)nextPage {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([appDelegate.appPrefs objectForKey:@"USERID"] != nil) {
        UITabBarController *rootViewController = appDelegate.tabBarController; 
        //rootViewController.selectedIndex = 0; //처음에 보여질 탭 설정
    
        NSLog(@"LASTTABITEM : %@", [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"LASTTABITEM"]]);

        //TABARR를 가져와서 라스트아이템이 몇번째에 있는지 확인, 그 인덱스를 처음 시작할때 사용하면 됨
        NSArray *tabArr = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"TABITEM"]];
        NSUInteger tabIdx = [tabArr indexOfObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"LASTTABITEM"]]];
        rootViewController.selectedIndex = tabIdx;
        
        //채팅 탭 배지카운트 표시============================================================
        NSMutableArray *selectArr = [appDelegate.dbHelper selectRoomList];
        
        int badgeCnt=0;
        for(int i=0; i<selectArr.count; i++){
            int notReadCnt = [[[selectArr objectAtIndex:i]objectForKey:@"NOT_READ_COUNT"] intValue];
            badgeCnt+=notReadCnt;
        }
        
        NSUInteger tabCount = rootViewController.tabBar.items.count;
        for(int i=0; i<tabCount; i++){
            if([rootViewController.tabBar.items objectAtIndex:i].tag == 3){
                if(badgeCnt>0 && badgeCnt<100) {
                    [rootViewController.tabBar.items objectAtIndex:i].badgeValue = [NSString stringWithFormat:@"%d", badgeCnt];
                    //[rootViewController.tabBar.items objectAtIndex:2].badgeColor = [MFUtil myRGBfromHex:@"FB8C26"];
                    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) [rootViewController.tabBar.items objectAtIndex:i].badgeColor = [MFUtil myRGBfromHex:@"FB8C26"];
                } else if(badgeCnt==0){
                    [rootViewController.tabBar.items objectAtIndex:i].badgeValue = nil;
                } else {
                    [rootViewController.tabBar.items objectAtIndex:i].badgeValue = @"99+";
                    //[rootViewController.tabBar.items objectAtIndex:2].badgeColor = [MFUtil myRGBfromHex:@"FB8C26"];
                    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) [rootViewController.tabBar.items objectAtIndex:i].badgeColor = [MFUtil myRGBfromHex:@"FB8C26"];
                }
            }
        }
        //=============================================================================

        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
//        rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self presentViewController:rootViewController animated:YES completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if([appDelegate.appPrefs objectForKey:@"SHARE_INFO"]!=nil){
                [rootViewController presentViewController:[MFUtil showToShareView] animated:YES completion:nil];
            }
        });
    }
}

- (void)callWebService{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];//appDelegate.main_url;
    userId = [appDelegate.appPrefs objectForKey:@"USERID"];
    userPwd = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERPWD"]];
    dvcId = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
    
    isRooted = [MFUtil isRooted]?@"Y":@"N";
    pushId1 = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]];
    
    UIDevice *device = [UIDevice currentDevice];
    dvcOs = device.systemName;
    dvcKind = [device modelName];
    
    appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //NSLog(@"appVersion1 : %@", appVersion);
    
    legacyNm = [[MFSingleton sharedInstance] legacyName]; //appDelegate.legacy_name;
    cpnCode = [appDelegate.appPrefs objectForKey:@"CPN_CODE"];
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *ctCarrier = [networkInfo subscriberCellularProvider];
    
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
    //사용 용량
    float availableDisk;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    statfs([[path lastObject] UTF8String], &tStats);
    availableDisk = (float)(tStats.f_bavail * tStats.f_bsize);
    
    dvcVer = device.systemVersion;
    carrier = [ctCarrier carrierName]; if(carrier==nil)carrier = @"-";
    extRam = @"N";
    extTotVol = @"0";
    extUseVol = @"0";
    useVol = [NSString stringWithFormat:@"%0.0f",availableDisk];
    
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrPwd=%@&dvcId=%@&dvcOs=%@&appVersion=%@&dvcKind=%@&isRooted=%@&pushId1=%@&pushId2=-&legacyNm=%@&compNo=%@&appType=%@&dvcType=%@&dvcVer=%@", userId, userPwd, dvcId, dvcOs, appVersion, dvcKind, isRooted, pushId1, legacyNm, compNo, [[MFSingleton sharedInstance] appType], [[MFSingleton sharedInstance] dvcType],dvcVer];
    
    if([legacyNm isEqualToString:@"ANYMATE"]){
        //paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"&cpnCode=%@&compNo=10&dvcVer=%@&carrier=%@&extRam=%@&extTotVol=%@&extUseVol=%@&useVol=%@", cpnCode, dvcVer, carrier, extRam, extTotVol, extUseVol, useVol]];
        paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"&cpnCode=%@&compNo=10&carrier=%@&extRam=%@&extTotVol=%@&extUseVol=%@&useVol=%@", cpnCode, carrier, extRam, extTotVol, extUseVol, useVol]];
    }
    
    NSLog(@"paramString : %@", paramString);
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"chkUsrLogin"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}

- (void)callGetProfile {
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&dvcId=%@", userNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getProfile"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}

-(void)anymateLogin{
    NSString *cpnUrl = [appDelegate.appPrefs objectForKey:@"URL"];
    NSString *_urlString = [NSString stringWithFormat:@"%@/m/main/",cpnUrl];
    NSURL *url2 = [NSURL URLWithString:_urlString];
    
    NSString *paramString2 = [NSString stringWithFormat:@"id=%@&pass=%@&sel_cpn_code=%@&mode=login&token=%@&os_type=I&device_id=%@&model_nm=%@&ver=beacon",userId,userPwd,cpnCode,pushId1,dvcId,dvcKind];
    
    NSData *postData = [paramString2 dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url2];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:10.0];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [urlConnection start];
}

- (void)callChangeDevice{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"changeDevice"]];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:userId forKey:@"USER_ID"];
    
    NSString *paramString = [NSString stringWithFormat:@"dvcId=%@&dvcKind=%@&dvcOs=%@&appVersion=%@&dvcVer=%@&carrier=%@&extRam=%@&extTotVol=%@&extUseVol=%@&useVol=%@&pushId1=%@&pushId2=-&isRooted=%@&usrId=%@&usrPwd=%@&legacyNm=%@&appType=%@&dvcType=%@", dvcId, dvcKind, dvcOs, appVersion, dvcVer, carrier, extRam, extTotVol, extUseVol, useVol, pushId1, isRooted, userId, userPwd, legacyNm, [[MFSingleton sharedInstance] appType], [[MFSingleton sharedInstance] dvcType]];
    
    if([legacyNm isEqualToString:@"ANYMATE"]){
        paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"&cpnCode=%@&compNo=10", cpnCode]];
        
    } else if([legacyNm isEqualToString:@"HHI"]){
        
    }
    
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}
- (void)MDMIntroNotification:(NSNotification *)notification{
    NSLog();
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self introConnectServer:dictForMDM];
        //    [self nextPage];
        [self teamAndUserDataSetting];
        dictForMDM = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MDMIntroNotification" object:nil];
//    });
}

//- (void)noti_MDMExcuteNextPage:(NSNotification *)notification{
//    NSLog(@"%s", __func__);
//    [self introConnectServer:dictForMDM];
////    [self nextPage];
//    [self teamAndUserDataSetting];
//    dictForMDM = [NSMutableDictionary dictionary];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_MDMExcuteNextPage" object:nil];
//}

//-(void)callMediaAuthCheck{
//    NSString *paramString = [NSString stringWithFormat:@"userId=%@&prmTy=1", userId];
//    NSString *urlString = @"https://dev.hhi.co.kr:44175/dataservice41/";
//    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"checkPermission"]];
//    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
//    session.delegate = self;
//    [session start];
//}


#pragma mark - NSURLSession Delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    NSLog();
    [SVProgressHUD dismiss];
    if (error!=nil&&![error isEqualToString:@""]) {
        [self reconnectFromError];
        
    }else{
        @try{
            NSArray *dataSetArr = [session.returnDictionary objectForKey:@"DATASET"];
            NSString *wsName = [[session.url absoluteString] lastPathComponent];
            NSLog(@"wsName : %@", wsName);
            
            if(dataSetArr.count>0) dictForMDM = [[NSMutableDictionary alloc] initWithDictionary:[dataSetArr objectAtIndex:0]];
            
            if([wsName isEqualToString:@"changePublicPushId"]){
                //            NSLog(@"changePublicPushId");
                
            } else if([wsName isEqualToString:@"getUserSNSLists"]){
                NSLog(@"getUserSNSLists : %@", session.returnDictionary);
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //Run your loop here
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        //stop your HUD here
                        //This is run on the main thread
                        NSMutableArray *normalArr = [session.returnDictionary objectForKey:@"DATASET"];
                        if(normalArr.count>0) {
                            for(int i=0; i<normalArr.count; i++){
                                NSDictionary *dataSet = [normalArr objectAtIndex:i];
                                NSString *snsType = [dataSet objectForKey:@"SNS_TY"];
                                NSString *snsNo = [dataSet objectForKey:@"SNS_NO"];
                                NSString *snsName = [NSString urlDecodeString:[dataSet objectForKey:@"SNS_NM"]];
                                NSString *needAllow = [dataSet objectForKey:@"NEED_ALLOW"];
                                NSString *snsDesc = [NSString urlDecodeString:[dataSet objectForKey:@"SNS_DESC"]];
                                NSString *coverImg = [NSString urlDecodeString:[dataSet objectForKey:@"COVER_IMG"]];
                                NSString *createUserNo = [dataSet objectForKey:@"CREATE_USER_NO"];
                                NSString *createDate = [NSString urlDecodeString:[dataSet objectForKey:@"CREATE_DATE"]];
                                NSString *compNo = [dataSet objectForKey:@"COMP_NO"];
                                NSString *snsKind = [dataSet objectForKey:@"SNS_KIND"];
                                NSString *createUserNm = [NSString urlDecodeString:[dataSet objectForKey:@"CREATE_USER_NM"]];
                                
                                NSString *userList = [NSString urlDecodeString:[dataSet objectForKey:@"USER_LIST"]];
                                NSData *jsonData = [userList dataUsingEncoding:NSUTF8StringEncoding];
                                NSError *error;
                                NSArray *userArr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                                for(int i=0; i<userArr.count; i++){
                                    NSString *sqlStr = [appDelegate.dbHelper insertSnsUser:snsNo userNo:[userArr objectAtIndex:i]];
                                    [appDelegate.dbHelper crudStatement:sqlStr];
                                }
                                
                                if(![coverImg isEqualToString:@""]&&![coverImg isEqualToString:@"null"]&&coverImg!=nil){
                                    UIImage *image = [MFUtil saveThumbImage:@"Cover" path:coverImg num:nil];
                                    if(image!=nil){
                                        UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :image];
                                        [imgCache storeImage:postCover forKey:coverImg toDisk:YES];
                                    }
                                }
                                
                                NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getSnsNo:snsNo]];
                                if(selectArr.count>0){
                                    //POST_NOTI INTEGER DEFAULT 1, COMMENT_NOTI
                                    NSString *sqlString = [appDelegate.dbHelper updateSnsInfo:snsName snsType:snsType needAllow:needAllow snsDesc:snsDesc coverImg:coverImg snsNo:snsNo];
                                    [appDelegate.dbHelper crudStatement:sqlString];
                                    
                                    NSString *sqlString2 = [appDelegate.dbHelper updateSnsMemberInfo:createUserNo createUserNm:createUserNm snsNo:snsNo];
                                    [appDelegate.dbHelper crudStatement:sqlString2];
                                    
                                } else {
                                    NSString *sqlString = [appDelegate.dbHelper insertOrUpdateSns:snsNo snsName:snsName snsType:snsType needAllow:needAllow snsDesc:snsDesc coverImg:coverImg createUserNo:createUserNo createUserNm:createUserNm createDate:createDate compNo:compNo snsKind:snsKind];
                                    [appDelegate.dbHelper crudStatement:sqlString];
                                }
                            }
                        }
                        
                        appDelegate.teamListRefresh = YES;
                        
                        if([appDelegate.simplePwdFlag isEqualToString:@"Y"]){
                            SimplePwdInputViewController *vc = [[SimplePwdInputViewController alloc] init];
                            vc.isSimpleLogin = YES;
                            vc.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self presentViewController:vc animated:YES completion:nil];
                            
                        } else {
                            //메인으로 진입
                            //[self nextPage];
                            [IntroViewController nextPage];
                        }
                    });
                });
                
                
            } else if([wsName isEqualToString:@"getProfile"]){
                            NSLog(@"getProfile : %@", session.returnDictionary);
                NSArray *users = [session.returnDictionary objectForKey:@"DATASET"];
                
                NSString *userNo = [[users objectAtIndex:0] objectForKey:@"CUSER_NO"];
                NSString *userNm = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"USER_NM"]];
                NSString *userMsg = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"PROFILE_MSG"]];
                NSString *userImg = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"PROFILE_IMG"]];
                NSString *userId = [[users objectAtIndex:0] objectForKey:@"CUSER_ID"];
                NSString *phoneNo = [[users objectAtIndex:0] objectForKey:@"PHONE_NO"];
                NSString *deptNo = [[users objectAtIndex:0] objectForKey:@"DEPT_NO"];
                NSString *userBgImg = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"PROFILE_BG_IMG"]];
                
                NSString *deptName = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"DEPT_NM"]];
                NSString *levelName = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"LEVEL_NM"]];
                NSString *dutyName = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"DUTY_NM"]];
                NSString *jobGrpName = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"JOB_GRP_NM"]];
                NSString *exCompNo = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"EX_COMPANY"]];
                NSString *exCompName = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"EX_COMPANY_NM"]];
                NSString *levelNo = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"LEVEL_NO"]];
                NSString *dutyNo = [NSString urlDecodeString:[[users objectAtIndex:0] objectForKey:@"DUTY_NO"]];
                NSString *userType = [[users objectAtIndex:0] objectForKey:@"SNS_USER_TYPE"];
                
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:userNm userImg:userImg userMsg:userMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                [appDelegate.dbHelper crudStatement:sqlString];
                
            } else {
                if ([[session.returnDictionary objectForKey:@"RESULT"] isEqualToString:@"SUCCESS"]) {
                    NSDictionary *dataSet = [[session.returnDictionary objectForKey:@"DATASET"] objectAtIndex:0];
                    
                    NSLog(@"[RESULT_CODE] : %@", [dataSet objectForKey:@"RESULT_CODE"]);
                    //                NSLog(@"[RESULT] : %@", dataSet);
                    
                    if ([[dataSet objectForKey:@"RESULT_CODE"] intValue] == 1) {
                        //세션체크로직
                        appDelegate.sessionFlag = [dataSet objectForKey:@"SESSION_FLAG"]; //@"Y";
                        appDelegate.sessionTerm = [dataSet objectForKey:@"SESSION_TERM"]; //@"40";
                        appDelegate.sessionAlrm = [dataSet objectForKey:@"SESSION_ALRM"]; //@"10";
                        
                        //                    DetectTouchWindow *dt = [[DetectTouchWindow alloc] init];
                        //                    [dt resetIdleTimer];
                        
                        //로그인 결과 넘어오면 바로 1dev 1user 호출하면 됨
                        appDelegate.singleOnlineFlag = [dataSet objectForKey:@"SINGLE_ONLINE_FLAG"]; //@"Y";
                        
                        if([[MFSingleton sharedInstance] singleLogin]){
                            if([appDelegate.singleOnlineFlag isEqualToString:@"Y"]){
                                NSString *urlStr = @"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.topic/publish";
                                NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                                
                                NSMutableDictionary *propDict = [NSMutableDictionary dictionary];
    //                            [propDict setObject:@"2" forKey:@"delivery_mode"];
                                [propDict setValue:@2 forKey:@"delivery_mode"];
                                [propDict setObject:appName forKey:@"reply_to"];
    //                            NSString* propJson = nil;
    //                            NSData* propData = [NSJSONSerialization dataWithJSONObject:propDict options:kNilOptions error:nil];
    //                            propJson = [[NSString alloc] initWithData:propData encoding:NSUTF8StringEncoding];
    //                            propJson = [propJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
                                
                                NSMutableDictionary *payloadDict = [NSMutableDictionary dictionary];
                                [payloadDict setObject:@"SYSTEM_MSG" forKey:@"TYPE"];
                                [payloadDict setObject:@"SYSMSG_CHANGE_LOGIN_MOBILE_USER" forKey:@"SUB_TYPE"];
                                [payloadDict setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"USER_ID"];
                                [payloadDict setObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]] forKey:@"DEVICE_ID"];
                                NSString* payLoadJson = nil;
                                NSData* payLoadData = [NSJSONSerialization dataWithJSONObject:payloadDict options:kNilOptions error:nil];
                                payLoadJson = [[NSString alloc] initWithData:payLoadData encoding:NSUTF8StringEncoding];
                                //payLoadJson = [payLoadJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
                                
                                NSMutableDictionary *dlqDict = [NSMutableDictionary dictionary];
                                [dlqDict setObject:propDict forKey:@"properties"];
                                [dlqDict setObject:[NSString stringWithFormat:@"USER.%@", [appDelegate.appPrefs objectForKey:@"USERID"]] forKey:@"routing_key"];
                                [dlqDict setObject:payLoadJson forKey:@"payload"];
                                [dlqDict setObject:@"string" forKey:@"payload_encoding"];
                                
                                NSString* dlqJson = nil;
                                NSData* dlqData = [NSJSONSerialization dataWithJSONObject:dlqDict options:kNilOptions error:nil];
                                dlqJson = [[NSString alloc] initWithData:dlqData encoding:NSUTF8StringEncoding];
                                NSLog(@"dlqJson : %@", dlqJson);
                                
                                MFURLSession *dlqSession = [[MFURLSession alloc]initWithURL:[NSURL URLWithString:urlStr] option:dlqJson];
                                [dlqSession start];
                            }
                        }
                        
                        //미디어 접근 권한 리턴 처리
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        NSString *permision = [NSString urlDecodeString:[dataSet objectForKey:@"PERMISSIONS"]];
                        NSLog("permision : %@", permision);
                        NSError *error;
                        NSArray *permisionArr = [NSJSONSerialization JSONObjectWithData:[permision dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                        NSLog(@"permisionArr : %@", permisionArr);
                        //                    PERMISSIONS : [{“PRM_TY":"1", "PRM_NM":"MediaPermission", "PRM_STATUS":true, "APPROVAL_DATE":"20/07/08"},{"PRM_TY":"2", "PRM_NM":"", "PRM_STATUS":false, "APPROVAL_DATE":"20/07/08"}]
                        if(permisionArr.count>0){
                            for(int i=0; i<permisionArr.count; i++){
                                NSString *prmNm = [[permisionArr objectAtIndex:i] objectForKey:@"PRM_NM"];
                                if([prmNm isEqualToString:@"MediaPermission"]){
                                    [prefs setObject:[[permisionArr objectAtIndex:i] objectForKey:@"PRM_STATUS"] forKey:@"MEDIA_AUTH"];
                                } else {
                                    
                                }
                            }
                        } else {
                            [prefs setObject:@"0" forKey:@"MEDIA_AUTH"];
                        }
                        [prefs synchronize];
                        
                        //SUCCEED
                        [appDelegate.appPrefs setObject:[dataSet objectForKey:@"COMP_NM"] forKey:[appDelegate setPreferencesKey:@"COMPNM"]];
                        [appDelegate.appPrefs setObject:[dataSet objectForKey:@"COMP_NO"] forKey:@"COMP_NO"];
                        [appDelegate.appPrefs setObject:[dataSet objectForKey:@"CUSER_NO"] forKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
                        [appDelegate.appPrefs setObject:[dataSet objectForKey:@"USER_NM"] forKey:[appDelegate setPreferencesKey:@"USERNM"]];
                        [appDelegate.appPrefs setObject:[dataSet objectForKey:@"DEPT_NM"] forKey:[appDelegate setPreferencesKey:@"DEPTNM"]];
                        [appDelegate.appPrefs setObject:[dataSet objectForKey:@"DEPT_NO"] forKey:[appDelegate setPreferencesKey:@"DEPTNO"]];
                        [appDelegate.appPrefs synchronize];
                        
                        NSLog(@"내정보DB저장");
                        [self callGetProfile];
                        
                        //                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        //                    SyncChatInfo *sync = [[SyncChatInfo alloc] init];
                        //                    [sync syncChatRoom];
                        //                    });
                        
                        if([legacyNm isEqualToString:@"ANYMATE"]){
                            [self anymateLogin];
                            
                        } else if([legacyNm isEqualToString:@"HHI"]){
                            //간편비밀번호에 대한 값 저장
                            NSString *simplePwdFlag = [dataSet objectForKey:@"EASY_PASSWD_FLAG"]; //Y,N //@"Y";
                            NSString *simplePwd = [dataSet objectForKey:@"EASY_PASSWD"]; //간편비밀번호 //@"555555";
                            NSLog(@"simplePwdFlag : %@", simplePwdFlag);
                            appDelegate.simplePwdFlag = simplePwdFlag;
                            appDelegate.simplePwd = simplePwd;
                        }
                        
                        NSString *isUpgrade = [dataSet objectForKey:@"IS_UPGRADE"];
                        appDelegate.compareAppVer = isUpgrade;
                        NSString *deployURL = [dataSet objectForKey:@"DEPLOY_URL"];
                        appDelegate.downAppUrl = deployURL;
                        
                        if([isUpgrade isEqualToString:@"UPGRADE"]){
                            if([legacyNm isEqualToString:@"HHI"]){
                                NSString *msg = NSLocalizedString(@"app_is_upgrade_for_hhi", @"app_is_upgrade_for_hhi");
                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""  message:msg preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                                 handler:^(UIAlertAction * action) {
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                    NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
                                    NSString *callUrl = [NSString stringWithFormat:@"%@://?call=%@&", [[MFSingleton sharedInstance] callScheme],stringURLScheme];
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callUrl] options:@{} completionHandler:^(BOOL success) {exit(0);}];
                                }];
                                [alert addAction:okButton];
                                [self presentViewController:alert animated:YES completion:nil];
                                
                            } else {
                                NSString *msg = NSLocalizedString(@"app_is_upgrade", @"app_is_upgrade");
                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""  message:msg preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                                 handler:^(UIAlertAction * action) {
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                    NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
                                    NSString *callUrl = [NSString stringWithFormat:@"%@://?call=%@&", [[MFSingleton sharedInstance] callScheme],stringURLScheme];
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callUrl] options:@{} completionHandler:^(BOOL success) {exit(0);}];
                                }];
                                
                                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                                 handler:^(UIAlertAction * action) {
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                    [self introConnectServer:dataSet];
                                    [self teamAndUserDataSetting];
                                }];
                                [alert addAction:cancelButton];
                                [alert addAction:okButton];
                                [self presentViewController:alert animated:YES completion:nil];
                            }
                            
                        } else if([isUpgrade isEqualToString:@"DOWNGRADE"]){
                            if([legacyNm isEqualToString:@"HHI"]){
                                NSString *msg = NSLocalizedString(@"app_is_downgrade_for_hhi", @"app_is_downgrade_for_hhi");
                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""  message:msg preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                                 handler:^(UIAlertAction * action) {
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                    NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
                                    NSString *callUrl = [NSString stringWithFormat:@"%@://?call=%@&", [[MFSingleton sharedInstance] callScheme],stringURLScheme];
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callUrl] options:@{} completionHandler:^(BOOL success) {exit(0);}];
                                }];
                                [alert addAction:okButton];
                                [self presentViewController:alert animated:YES completion:nil];
                                
                            } else {
                                NSString *msg = NSLocalizedString(@"app_is_downgrade", @"app_is_downgrade");
                                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""  message:msg preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                                 handler:^(UIAlertAction * action) {
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                    NSString *stringURLScheme = [[NSBundle mainBundle] bundleIdentifier];
                                    NSString *callUrl = [NSString stringWithFormat:@"%@://?call=%@&", [[MFSingleton sharedInstance] callScheme],stringURLScheme];
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callUrl] options:@{} completionHandler:^(BOOL success) {exit(0);}];
                                }];
                                
                                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                                 handler:^(UIAlertAction * action) {
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                    [self introConnectServer:dataSet];
                                    [self teamAndUserDataSetting];
                                }];
                                [alert addAction:cancelButton];
                                [alert addAction:okButton];
                                [self presentViewController:alert animated:YES completion:nil];
                            }
                            
                        } else {
                            appDelegate.isLogin = YES;
                            if([[MFSingleton sharedInstance] isMDM]){
                                //                            [self getMDMExageInfo:@"queries_getStatus_getRichStatus_enterWorkApp"];
                                [self getMDMExageInfo:@"queries_getStatus_getRichStatus"];
                                
                                appDelegate.mdmCallAPI = @"enterWorkApp";
                                
                            } else {
                                [self introConnectServer:dataSet];
                                //                            [self nextPage];
                                [self teamAndUserDataSetting];
                            }
                        }
                        
                    } else if([[dataSet objectForKey:@"RESULT_CODE"] intValue] == 10){
                        //NOTMATCH_DEVICE
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                                       message:NSLocalizedString(@"등록된 기기와 일치하지않은 기기입니다. 등록된 기기를 삭제하고 새로 등록하시겠습니까?", @"")
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            [self callChangeDevice];
                        }];
                        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            exit(0);
                        }];
                        
                        [alert addAction:okButton];
                        [alert addAction:cancelButton];
                        
                        [self presentViewController:alert animated:YES completion:nil];
                        
                    } else{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"msg1", @"")
                                                                                       message:NSLocalizedString([dataSet objectForKey:@"RESULT"], @"msg2")
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                            [appDelegate.appPrefs removeObjectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
                            [appDelegate.appPrefs removeObjectForKey:@"USERID"];
                            [appDelegate.appPrefs synchronize];
                            //[self performSegueWithIdentifier:@"LOGIN_VIEW_PUSH" sender:self]; //로그인화면으로 가지않도록 막음
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            exit(0);
                        }];
                        [alert addAction:okButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    
                } else {
                    NSDictionary *dataSet = [[session.returnDictionary objectForKey:@"DATASET"]objectAtIndex:0];
                    if([dataSet objectForKey:@"RESULT_CODE"] == nil){
                        NSLog(@"백그라운드에 오랫동안 있다가 앱 실행 시에도 발생");
                        //인터넷이 연결되지 않았을 경우 (백그라운드에 오랫동안 있다가 앱 실행 시에도 발생)
                        //                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"exception_msg_unknownhostexception", @"exception_msg_unknownhostexception") preferredStyle:UIAlertControllerStyleAlert];
                        //                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                        //                                                                     handler:^(UIAlertAction * action) {
                        //                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                        //                                                                         [self viewDidLoad];
                        //                                                                     }];
                        //                    [alert addAction:okButton];
                        //                    [self presentViewController:alert animated:YES completion:nil];
                        [self reconnectFromError];
                        
                    } else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:[NSString stringWithFormat:@"RESULT_CODE : %@",[dataSet objectForKey:@"RESULT_CODE"]] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
                        }];
                        [alert addAction:okButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    
                }
            }
            
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
    }
}

- (void)returnError:(MFURLSession *)session error:(NSError *)error{
    //NSLog(@"Intro error : %ld", (long)error.code);
    //[SVProgressHUD dismiss];
    if(error.code == -1001){
        //Code=-1001 : 요청한 시간이 초과되었습니다.
        
//        count = 0;
//        endCount = 1;
//        myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"INTRO DISPATCH_TIME_NOW>>>>>>>>>>>>>>>>");
//            [SVProgressHUD dismiss];
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"서버에 연결할 수 없습니다." preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
//                                                             handler:^(UIAlertAction * action) {
//                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
//                                                                 exit(0);
//                                                             }];
//            [alert addAction:okButton];
//            [self presentViewController:alert animated:YES completion:nil];
//        });
        
    } else if(error.code == -1009){
        //인터넷/와이파이 X, 연결되었을 경우 웹서비스 호출
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusNotReachable) {
//                NSLog(@"네트워크 사용 할 수 없음");
            } else if (status == AFNetworkReachabilityStatusUnknown){
//                NSLog(@"네트워크 상태 알 수 없음");
            } else {
                if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
//                    NSLog(@"와이파이");
                } else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
//                    NSLog(@"3G/LTE 등 셀룰러 네트워크");
                }
            }
        }];
    }
    
    [self reconnectFromError];
}

#pragma mark - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    [prefs removeObjectForKey:@"USER_ID"];
//    [prefs removeObjectForKey:@"DEVICE_ID"];
//    [prefs removeObjectForKey:@"URL"];
//    [prefs removeObjectForKey:@"CPN_CODE"];
//    [prefs synchronize];
//
//    //isLogin = NO;
//    NSLog(@"IntroViewController error : %@",error);
//    if (error.code == -1003) {
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        NSString *errorMessage = [NSString stringWithFormat:@"정보가 올바르지 않습니다.\n%@\nURL을 확인하세요.",[prefs objectForKey:@"URL"]];
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"로그인 오류" message:errorMessage delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
//        [alertView show];
//
//
//    }else{
//        NSLog(@"%s 일시적인 네트워크 오류가 발생했습니다.", __func__);
//        [self setTimer];
//    }
    
    [self reconnectFromError];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *absoluteString = connection.currentRequest.URL.absoluteString;
//    NSLog(@"query : %@",connection.currentRequest.URL.query);
    NSString *query = connection.currentRequest.URL.query;
    NSString *returnString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if (query==nil) {
        returnCode = returnString;
    }else{
        if ([query hasPrefix:@"event=get_version"]) {
            NSLog(@"getVersion");
        }else{
            NSLog(@"getBeacon : %@",returnString);
        }
    }
    
    NSArray *tempArr = [[absoluteString lastPathComponent] componentsSeparatedByString:@"="];
    if ([tempArr count]==1) {
        returnCode = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }else{
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [SVProgressHUD dismiss];
}

- (void)introConnectServer :(NSDictionary *)dataSet {
    NSLog();
    
    /*
     NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    NSArray *snsList = [dataSet objectForKey:@"SNS_LIST"];
    for(int i=0; i<snsList.count; i++){
        NSNumber *snsNo = [[snsList objectAtIndex:i]objectForKey:@"SNS_NO"];
        NSString *itemType = [[snsList objectAtIndex:i]objectForKey:@"ITEM_TYPE"];
        
        if([itemType isEqualToString:@"MEMBER"]){
            [appDelegate.bindQueueArr addObject:[NSString stringWithFormat:@"%@.BOARD.POST.%@.%@", appDelegate.dvcType, compNo, snsNo]];
            [appDelegate.bindQueueArr addObject:[NSString stringWithFormat:@"%@.BOARD.COMMENT.%@.%@", appDelegate.dvcType, compNo, snsNo]];
        }
    }
    
    NSMutableArray *selectArr = [appDelegate.dbHelper selectRoomList];
    for(int i=0; i<selectArr.count; i++){
        NSString *roomNo = [[selectArr objectAtIndex:i]objectForKey:@"ROOM_NO"];
        [appDelegate.bindQueueArr addObject:[NSString stringWithFormat:@"%@.CHAT.%@.%@", appDelegate.dvcType, compNo, roomNo]];
    }
    [appDelegate.appPrefs setObject:appDelegate.bindQueueArr forKey:[appDelegate setPreferencesKey:@"BINDQARR"]];
    [appDelegate.appPrefs synchronize];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"BINDQARR"]] forKey:@"ROUTING_KEY"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RmqConnect" object:nil userInfo:dic];
     */
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RmqConnect" object:nil userInfo:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        rmq = [[RMQServerViewController alloc]init];
        [rmq connectMQServer:nil];
    });
}

#pragma mark - IntroView Data Setting
-(void)teamAndUserDataSetting{
    NSLog();
//    팀룸 로딩하는데 시간이 걸려서 인트로에서 웹서비스 호출하여 로컬 저장.
//    사용자 정보는 프로필을 눌렀을 경우 또는 멤버리스트 볼 경우에 가져오기.
//    getUserSNSLists
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getUserSNSLists"]];
    int snsKind = 1;
    
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    NSString *paramString = [NSString stringWithFormat:@"compNo=%@&usrId=%@&snsKind=%d&searchNm=""&dvcId=%@",compNo, [appDelegate.appPrefs objectForKey:@"USERID"], snsKind, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
//    NSString *paramString = [NSString stringWithFormat:@"compNo=%@&usrId=''&snsKind=%d&searchNm=""&dvcId=%@",compNo, snsKind, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.navigationController.navigationBarHidden = NO;
}

-(void)reconnectFromError{
    if(appDelegate.errorExecCnt<10){ //[[MFSingleton sharedInstance] errorMaxCnt]
        [self setTimer];
        
    } else {
        appDelegate.errorExecCnt = 0;
        [SVProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"exception_msg_unknownhostexception", @"exception_msg_unknownhostexception") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             exit(0);
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    appDelegate.errorExecCnt++;
}

@end
