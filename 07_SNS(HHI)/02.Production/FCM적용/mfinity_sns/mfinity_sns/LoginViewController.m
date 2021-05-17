//
//  LoginViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "LoginViewController.h"
#import "RMQServerViewController.h"
#import "MyViewController.h"
#import "MFDBHelper.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface LoginViewController (){
    RMQServerViewController *rmq;
    NSString *returnCode;
    AppDelegate *appDelegate;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.hidesBackButton = YES;
    
    self.idTextField.placeholder = NSLocalizedString(@"msg4", @"");
    [self.idTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    self.pwTextField.placeholder = NSLocalizedString(@"msg5", @"");
    
//    self.idTextField.text = @"BP15214";
//    self.pwTextField.text = @"feel100101";
    
    self.navigationController.navigationBarHidden = YES;
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.verLabel.text = [NSString stringWithFormat:@"v %@", version];
    
    isHideKeyboard = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)login {
    [self.view endEditing:YES];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"chkUsrLoginNotAuth"]];
    
    userId = self.idTextField.text;
    userPwd = self.pwTextField.text;
    dvcId = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]];//[MFUtil getUUID];
    
    UIDevice *device = [UIDevice currentDevice];
    dvcKind = [device modelName];
    dvcOs = device.systemName;
    pushId1 = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"PUSHID1"]];
    appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    isRooted = [MFUtil isRooted]?@"Y":@"N";
#if TARGET_IPHONE_SIMULATOR
    isRooted = @"N";
#endif
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:userId forKey:@"USER_ID"];
    
    legacyNm = [[MFSingleton sharedInstance] legacyName]; //appDelegate.legacy_name;
    
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
    
    cpnCode = [appDelegate.appPrefs objectForKey:@"CPN_CODE"];
    
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    NSLog(@"LOGIN userId : %@, usrPwd : %@", userId, userPwd);
    
    NSString *paramString = [NSString stringWithFormat:@"usrId=%@&usrPwd=%@&dvcId=%@&dvcOs=%@&appVersion=%@&dvcKind=%@&isRooted=%@&pushId1=%@&pushId2=-&legacyNm=%@&compNo=%@&appType=%@&dvcType=%@&dvcVer=%@", userId, userPwd, dvcId, dvcOs, appVersion, dvcKind, isRooted, pushId1, legacyNm, compNo, [[MFSingleton sharedInstance] appType], [[MFSingleton sharedInstance] dvcType],dvcVer];
    
    if([legacyNm isEqualToString:@"ANYMATE"]){
        paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"&cpnCode=%@&compNo=10&carrier=%@&extRam=%@&extTotVol=%@&extUseVol=%@&useVol=%@", cpnCode, carrier, extRam, extTotVol, extUseVol, useVol]];
        
    } else if([legacyNm isEqualToString:@"HHI"]){
        
    }
    
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}


- (IBAction)next:(id)sender {
    if ([self.idTextField.text isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"msg1", @"msg1") message:NSLocalizedString(@"msg7", @"msg7") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        if ([self.pwTextField.text isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"msg1", @"msg1") message:NSLocalizedString(@"msg8", @"msg8") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else{
            [self login];
        }
    }
}

- (void)loginConnectServer :(NSDictionary *)dataSet {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
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

-(void)resultLogin :(NSDictionary *)dataSet{
    //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSString *isUpgrade = [dataSet objectForKey:@"IS_UPGRADE"];
    NSString *deployURL = [dataSet objectForKey:@"DEPLOY_URL"];
    if([isUpgrade isEqualToString:@"UPGRADE"]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"최신 버전이 업데이트 되었습니다.\n지금 설치하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                             NSURL *browser = [NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",deployURL]];
                                                             [[UIApplication sharedApplication] openURL:browser options:@{} completionHandler:nil];
                                                         }];
        
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        
        [alert addAction:okButton];
        [alert addAction:cancelButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if([isUpgrade isEqualToString:@"DOWNGRADE"]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"미배포버전이 설치되어있습니다.\n다운그레이드 하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                             NSURL *browser = [NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",deployURL]];
                                                             [[UIApplication sharedApplication] openURL:browser options:@{} completionHandler:nil];
                                                         }];
        
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 
                                                                 [self loginConnectServer:dataSet];
                                                                 //appDelegate.dbHelper = [[MFDBHelper alloc] init:[[NSUserDefaults standardUserDefaults] objectForKey:@"USER_ID"]];
                                                                 
                                                                 UITabBarController *rootViewController = [MFUtil setDefualtTabBar];
                                                                 [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
                                                                 
                                                                 //채팅 탭 배지카운트 표시============================================================
                                                                 //SqlSelectHelper *selectHelper = [[SqlSelectHelper alloc]init];
                                                                 // NSMutableArray *selectArr = [selectHelper selectRoomList];
                                                                 //MFDBHelper *dbHelper = [[MFDBHelper alloc]init];
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
                                                                 
                                                                 //                                                         UINavigationController *nav = [rootViewController.viewControllers objectAtIndex:3];
                                                                 //                                                         MyViewController *vc = [nav.childViewControllers objectAtIndex:0];
                                                                 //
                                                                 //                                                         vc.infoDic = dataSet;
                                                             }];
        
        [alert addAction:okButton];
        [alert addAction:cancelButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        [self loginConnectServer:dataSet];
        //appDelegate.dbHelper = [[MFDBHelper alloc] init:[[NSUserDefaults standardUserDefaults] objectForKey:@"USER_ID"]];
        
        UITabBarController *rootViewController = [MFUtil setDefualtTabBar];
        rootViewController.selectedIndex = 0;
        
        
        //채팅 탭 배지카운트 표시============================================================
        //SqlSelectHelper *selectHelper = [[SqlSelectHelper alloc]init];
        //NSMutableArray *selectArr = [selectHelper selectRoomList];
        //MFDBHelper *dbHelper = [[MFDBHelper alloc]init];
        NSMutableArray *selectArr = [appDelegate.dbHelper selectRoomList];
        //NSLog(@"selectArr : %@", selectArr);
        
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
        
        //        UINavigationController *nav = [rootViewController.viewControllers objectAtIndex:3];
        //        MyViewController *vc = [nav.childViewControllers objectAtIndex:0];
        //
        //        vc.infoDic = dataSet;
        
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
    }
}

- (void)anymateLogin{
    if ([returnCode isEqualToString:@"250"]) {
        [self resultLogin:self.dataSetDic];
    }/*else if([returnCode isEqualToString:@"444"]){
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
      }*/ else{
          UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"로그인 실패", @"로그인 실패") message:NSLocalizedString(@"로그인 정보가 일치하지 않습니다.", @"로그인 정보가 일치하지 않습니다.") preferredStyle:UIAlertControllerStyleAlert];
          UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
          [alert addAction:okButton];
          [self presentViewController:alert animated:YES completion:nil];
      }
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
    if([session start]) {
        //[SVProgressHUD show];
    }
}

#pragma mark - MFURLSession
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error {
    [SVProgressHUD dismiss];
    NSLog(@"session.returnDictionary : %@", session.returnDictionary);
    
    if (error==nil) {
        if ([[session.returnDictionary objectForKey:@"RESULT"] isEqualToString:@"SUCCESS"]) {
            NSArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
            //NSLog(@"dataSets : %@", dataSets);
            NSDictionary *dataSet = [dataSets objectAtIndex:0];
            self.dataSetDic = [[NSDictionary alloc]initWithDictionary:dataSet];
            
            if([[dataSet objectForKey:@"RESULT_CODE"] intValue] == 1){
                //SUCCEED
                [appDelegate.appPrefs setObject:userId forKey:@"USERID"];
                [appDelegate.appPrefs setObject:userPwd forKey:[appDelegate setPreferencesKey:@"USERPWD"]];
                [appDelegate.appPrefs setObject:[dataSet objectForKey:@"COMP_NM"] forKey:[appDelegate setPreferencesKey:@"COMPNM"]];
                [appDelegate.appPrefs setObject:[dataSet objectForKey:@"COMP_NO"] forKey:@"COMP_NO"];
                [appDelegate.appPrefs setObject:[dataSet objectForKey:@"CUSER_NO"] forKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
                [appDelegate.appPrefs setObject:[dataSet objectForKey:@"USER_NM"] forKey:[appDelegate setPreferencesKey:@"USERNM"]];
                [appDelegate.appPrefs setObject:[dataSet objectForKey:@"DEPT_NO"] forKey:[appDelegate setPreferencesKey:@"DEPTNO"]];
                [appDelegate.appPrefs setObject:userId forKey:[appDelegate setPreferencesKey:@"DBNAME"]];
                [appDelegate.appPrefs synchronize];
                
                if([legacyNm isEqualToString:@"NONE"]){
                    [self resultLogin:dataSet];
                    
                } else if([legacyNm isEqualToString:@"ANYMATE"]){
                    NSString *cpnUrl = [appDelegate.appPrefs objectForKey:@"URL"];
                    //NSString *cpnCode = [prefs objectForKey:@"CPN_CODE"];
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
                    
                    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
                    [SVProgressHUD show];
                    
                } else if([legacyNm isEqualToString:@"HHI"]){
                    [self resultLogin:dataSet];
                }
                
            } else if ([[dataSet objectForKey:@"RESULT_CODE"] intValue] == 3) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"msg1", @"")
                                                                               message:NSLocalizedString(@"비밀번호가 일치하지 않습니다.", @"")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [appDelegate.appPrefs removeObjectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
                                                                     [appDelegate.appPrefs removeObjectForKey:@"USERID"];
                                                                     [appDelegate.appPrefs synchronize];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
                //[SVProgressHUD showErrorWithStatus:@"비밀번호가 일치하지 않습니다."];
                
            } else if ([[dataSet objectForKey:@"RESULT_CODE"] intValue] == 4) {
                //NOTCERT
                if([legacyNm isEqualToString:@"NONE"]){
                    [self performSegueWithIdentifier:@"CERT_VIEW_PUSH" sender:self];
                }
                
            } else if([[dataSet objectForKey:@"RESULT_CODE"] intValue] == 10){
                //등록된 기기와 일치하지않은 기기입니다. 등록된 기기를 삭제하고 새로 등록하시겠습니까?
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
                                                                               message:NSLocalizedString([dataSet objectForKey:@"RESULT"], [dataSet objectForKey:@"RESULT"])
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [appDelegate.appPrefs removeObjectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
                                                                     [appDelegate.appPrefs removeObjectForKey:@"USERID"];
                                                                     [appDelegate.appPrefs synchronize];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"msg1", @"")
                                                                           message:NSLocalizedString([session.returnDictionary objectForKey:@"MESSAGE"], [dataSet objectForKey:@"MESSAGE"])
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [appDelegate.appPrefs removeObjectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
                                                                 [appDelegate.appPrefs removeObjectForKey:@"USERID"];
                                                                 [appDelegate.appPrefs synchronize];
                                                                 
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"msg1", @"")
                                                                       message:error
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [appDelegate.appPrefs removeObjectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
                                                             [appDelegate.appPrefs removeObjectForKey:@"USERID"];
                                                             [appDelegate.appPrefs synchronize];
                                                             
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
    
    if (error.code == -1003) {
        NSString *errorMessage = [NSString stringWithFormat:@"정보가 올바르지 않습니다.\n%@\nURL을 확인하세요.",[appDelegate.appPrefs objectForKey:@"URL"]];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"로그인 오류", @"로그인 오류") message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"exception_msg_unknownhostexception", @"exception_msg_unknownhostexception") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *absoluteString = connection.currentRequest.URL.absoluteString;
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
        
        //appDelegate.appVersion = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //[self resultLogin];
    [SVProgressHUD dismiss];
    [self anymateLogin];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CERT_VIEW_PUSH"]) {
        //UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
        //self.navigationItem.backBarButtonItem = left;
        self.navigationController.navigationBar.topItem.title = @"";
        
        CertViewController *vc =[segue destinationViewController];
        vc.userID = self.idTextField.text;
        vc.userPwd = self.pwTextField.text;
    }
}

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
//        if(isHideKeyboard){
//            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 50, self.view.frame.size.width, self.view.frame.size.height)];
//            isHideKeyboard = NO;
//        }
    }else if([notification name]==UIKeyboardWillHideNotification){
//        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50,self.view.frame.size.width, self.view.frame.size.height)];
//        isHideKeyboard = YES;
    }
    [UIView commitAnimations];
}
- (void)_removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


@end
