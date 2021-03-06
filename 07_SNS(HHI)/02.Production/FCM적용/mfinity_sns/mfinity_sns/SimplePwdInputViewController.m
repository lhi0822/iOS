//
//  SimplePwdInputViewController.m
//  mfinity_sns
//
//  Created by hilee on 2020/07/01.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "SimplePwdInputViewController.h"
#import "SDiOSVersion.h"

@interface SimplePwdInputViewController (){
    AppDelegate *appDelegate;
    int padCnt;
    NSString *pwd;
    NSString *checkPwd;
    NSMutableArray *pwdArr;
    BOOL isCheck;
    int PAD_FONT_SIZE;
}

@end

@implementation SimplePwdInputViewController

//-(UIStatusBarStyle)preferredStatusBarStyle{
//    if (@available(iOS 12.0, *)) {
////        if(UIUserInterfaceStyleDark) return UIStatusBarStyleLightContent;
////        else return UIStatusBarStyleDefault;
//        return UIStatusBarStyleLightContent;
//    } else {
//        return UIStatusBarStyleDefault;
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    
    BOOL isZoom = [SDiOSVersion isZoomed];
    NSLog(@"줌이면 1, 아니면 0 = %d", isZoom);
    if(isZoom){
        self.titleLbl.font = [UIFont boldSystemFontOfSize:20];
        self.contentLbl.font = [UIFont systemFontOfSize:15];
//        self.padHeightConstraint.constant = 290;
        PAD_FONT_SIZE = 20;
    } else {
        self.titleLbl.font = [UIFont boldSystemFontOfSize:24];
        self.contentLbl.font = [UIFont systemFontOfSize:17];
//        self.padHeightConstraint.constant = 291;
        PAD_FONT_SIZE = 23;
    }
    
    if(_isSimpleLogin==YES) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
 
//        if([[MFUtil getDevPlatformNumber] intValue]<=6){
        if([[MFUtil getDevPlatformNumber] intValue]<10){
//            if(isZoom)  _topConstraint.constant = 10;
//            else  _topConstraint.constant = 30;
            _topConstraint.constant = 30;
            _bottomConstraint.constant = 0;
        }
        
        if([appDelegate.simplePwd isEqualToString:@"000000"]){
            self.titleLbl.text = NSLocalizedString(@"simple_set_new_pwd", @"simple_set_new_pwd");
            self.contentLbl.text = [NSString stringWithFormat:NSLocalizedString(@"simple_pwd_info3", @"simple_pwd_info3"), [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]],  [appDelegate.appPrefs objectForKey:@"USERID"]];
        } else {
            self.titleLbl.text = NSLocalizedString(@"simple_pwd_title2", @"simple_pwd_title2");
            self.contentLbl.text = [NSString stringWithFormat:NSLocalizedString(@"simple_pwd_info1", @"simple_pwd_info1"), [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]], [appDelegate.appPrefs objectForKey:@"USERID"]];
        }
        
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"myinfo_set_simple_pwd", @"myinfo_set_simple_pwd")];
        self.navigationController.navigationBar.topItem.title = @"";
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClick)];
        
//        if([[MFUtil getDevPlatformNumber] intValue]<=6){
        if([[MFUtil getDevPlatformNumber] intValue]<10){
            if(isZoom){
                _topConstraint.constant = 5;
                self.padHeightConstraint.constant = 270;
            } else{
                _topConstraint.constant = 10;
                self.padHeightConstraint.constant = 291;
            }
            _bottomConstraint.constant = 0;
        } else {
            _topConstraint.constant = 50;
        }
        
        self.titleLbl.text = NSLocalizedString(@"simple_set_new_pwd", @"simple_set_new_pwd");
        self.contentLbl.text = [NSString stringWithFormat:NSLocalizedString(@"simple_pwd_info3", @"simple_pwd_info3"), [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]],  [appDelegate.appPrefs objectForKey:@"USERID"]];
    }
    
    padCnt = 0;
    pwd = @"";
    checkPwd = @"";
    pwdArr = [[NSMutableArray alloc] init];
    isCheck = NO;
    
//    self.titleLbl.font = [UIFont boldSystemFontOfSize:24];
//    self.contentLbl.font = [UIFont systemFontOfSize:17];
    
//    self.noticeLbl.text = NSLocalizedString(@"set_simple_pwd_info3", @"set_simple_pwd_info3");
//    self.noticeLbl.font = [UIFont systemFontOfSize:14];
//    self.noticeLbl.textColor = [UIColor redColor];
    
    UIImage *removeImg = [UIImage imageNamed:@"remove.png"];
    self.imgView1.image = removeImg;
    self.imgView1.tag = 1;
    
    self.imgView2.image = removeImg;
    self.imgView2.tag = 2;
    
    self.imgView3.image = removeImg;
    self.imgView3.tag = 3;
    
    self.imgView4.image = removeImg;
    self.imgView4.tag = 4;
    
    self.imgView5.image = removeImg;
    self.imgView5.tag = 5;
    
    self.imgView6.image = removeImg;
    self.imgView6.tag = 6;
    
    UIImage *backImg = nil;
    if (@available(iOS 13.0, *)) {
        backImg = [UIImage systemImageNamed:@"delete.left.fill"];
        
    } else {
        backImg = [UIImage imageNamed:@"delete_left_fill.png"];
    }
    [self.btnBack setImage:backImg forState:UIControlStateNormal];
    [self.btnBack setTintColor:[UIColor blackColor]];
    
    self.btn1.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btn1 addTarget:self action:@selector(numberPadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn2.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btn2 addTarget:self action:@selector(numberPadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn3.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btn3 addTarget:self action:@selector(numberPadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn4.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btn4 addTarget:self action:@selector(numberPadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn5.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btn5 addTarget:self action:@selector(numberPadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn6.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btn6 addTarget:self action:@selector(numberPadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn7.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btn7 addTarget:self action:@selector(numberPadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn8.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btn8 addTarget:self action:@selector(numberPadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn9.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btn9 addTarget:self action:@selector(numberPadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn0.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btn0 addTarget:self action:@selector(numberPadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnCancel.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    
    self.btnBack.titleLabel.font = [UIFont systemFontOfSize:PAD_FONT_SIZE];
    [self.btnBack addTarget:self action:@selector(numberDelete) forControlEvents:UIControlEventTouchUpInside];
}

-(void)closeButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)numberPadClick:(id)sender{
    UIButton *btn = sender;

    if(padCnt>=0 && padCnt<6){
        padCnt++;
        UIImageView *imgV = [self.view viewWithTag:padCnt];
//        UIImage *pwdImg = [[UIImage imageNamed:@"fiber_manual_record.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *pwdImg = nil;
        if (@available(iOS 13.0, *)) {
            pwdImg = [UIImage systemImageNamed:@"circle.fill"];
            
        } else {
            pwdImg = [[UIImage imageNamed:@"circle_fill.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        imgV.image = pwdImg;
        [imgV setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
        
        [pwdArr addObject:btn.titleLabel.text];
        
        if (pwdArr.count == 6) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(_isSimpleLogin==YES){
                    //간편로그인
                    if([appDelegate.simplePwd isEqualToString:@"000000"]){
                        [self pwdCheckAction:isCheck];
                        
                    } else {
                        pwd = [[pwdArr valueForKey:@"description"] componentsJoinedByString:@""];
                        if([pwd isEqualToString:appDelegate.simplePwd]){
                            NSLog(@"로그인 성공 ! 다음페이지로 이동");
                            [IntroViewController nextPage];
                            
                        } else {
                            NSLog(@"비밀번호 오류 !");
                            [self pwdCheckClear:@"FAIL"];
                        }
                    }
            
                } else {
                    //간편비밀번호 등록
                    [self pwdCheckAction:isCheck];
                    
                }
            });
        }
        
    }
}

-(void)pwdCheckAction:(BOOL)isChecked{
    if(!isChecked) {
        pwd = [[pwdArr valueForKey:@"description"] componentsJoinedByString:@""];
        if([pwd isEqualToString:@"000000"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"simple_pwd_failed1", @"simple_pwd_failed1") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 //[self closeButtonClick];
                                                                 [self pwdCheckClear:@"CLEAR"];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            [self pwdCheckClear:@"CHECK"];
        }
    
    } else {
        checkPwd = [[pwdArr valueForKey:@"description"] componentsJoinedByString:@""];
        
        //두개비번 비교
        NSLog(@"첫번째 : %@ / 두번째 : %@", pwd, checkPwd);
        if([pwd isEqualToString:checkPwd]){
            NSLog(@"일치 ! 비밀번호 설정 웹서비스 호출");
            //변경 또는 설정
            [self callWebService];
            
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"simple_pwd_notmatch", @"simple_pwd_notmatch") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 //[self closeButtonClick];
                                                                [self pwdCheckClear:@"CLEAR"];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }
}

-(void)numberDelete{
    if(padCnt>0) {
        UIImageView *imgV = [self.view viewWithTag:padCnt];
        UIImage *removeImg = [[UIImage imageNamed:@"remove.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imgV.image = removeImg;
        [imgV setTintColor:[UIColor blackColor]];
        
        padCnt--;
        [pwdArr removeLastObject];
    }
}

-(void)pwdCheckClear:(NSString *)mode{
    //CHECK : 비밀번호 확인 , FAIL : 비밀번호 틀림
    if([mode isEqualToString:@"CHECK"]){
        self.contentLbl.text = [NSString stringWithFormat:NSLocalizedString(@"simple_pwd_info2", @"simple_pwd_info2"), [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]], [appDelegate.appPrefs objectForKey:@"USERID"]];
        self.noticeLbl.text = @"";
        
        isCheck = YES;
        
    } else if([mode isEqualToString:@"FAIL"]){
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        self.contentLbl.text = NSLocalizedString(@"simple_pwd_failed2", @"simple_pwd_failed2");
        
        isCheck = YES;
    
    } else if([mode isEqualToString:@"CLEAR"]){
        self.contentLbl.text = [NSString stringWithFormat:NSLocalizedString(@"simple_pwd_info3", @"simple_pwd_info3"), [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]],  [appDelegate.appPrefs objectForKey:@"USERID"]];
        self.contentLbl.font = [UIFont systemFontOfSize:17];
        
        isCheck = NO;
    }
    
    padCnt = 0;
    pwdArr = [[NSMutableArray alloc] init];
    
    for(int i=1; i<7; i++){
        UIImageView *imgV = [self.view viewWithTag:i];
        UIImage *removeImg = [[UIImage imageNamed:@"remove.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imgV.image = removeImg;
        [imgV setTintColor:[UIColor blackColor]];
    }
}

- (void)callWebService {
//    - saveSimplePwd
//    : 비밀번호 설정 웹서비스
//
//    - 파라미터
//    usrNo : 사용자번호("BP15213")
//    dvcId : 기기아이디("qwdnkj12k3h1")
//    easyPwd : 비밀번호("123456")
//    easyPwdFlag : 간편비밀번호 사용여부("Y" or "N")
//
//    - 결과
//    {"MESSAGE":"-","AFFECTED":1,"RESULT":"SUCCESS"}
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *userId = [appDelegate.appPrefs objectForKey:@"USERID"];
    NSString *dvcId = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
    NSString *easyPwd = pwd;
    NSString *easyPwdFlag = appDelegate.simplePwdFlag;
    
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&usrId=%@&dvcId=%@&easyPwd=%@&easyPwdFlag=%@&mode=SET_PWD", userNo, userId, dvcId, easyPwd, easyPwdFlag];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveSimplePwd"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

#pragma mark - MFURLSession delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    if (error != nil) {
       
    } else {
        if(session.returnDictionary != nil){
            @try{
                [SVProgressHUD dismiss];
                NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
                NSLog(@"dic : %@",session.returnDictionary);
                
                if ([result isEqualToString:@"SUCCESS"]) {
                    NSLog(@"비번 설정했다면 플래그 온으로 바꾸기");
                    appDelegate.simplePwdFlag = @"Y";
                    NSString *affected = [session.returnDictionary objectForKey:@"AFFECTED"];
                    
                    NSString *alertMsg;
                    if ([affected intValue]>0) {
                        alertMsg = [NSString stringWithFormat:NSLocalizedString(@"simple_pwd_succeed", @"simple_pwd_succeed"), [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]], [appDelegate.appPrefs objectForKey:@"USERID"]];
                        
                    } else {
                        alertMsg = [NSString stringWithFormat:NSLocalizedString(@"simple_pwd_failed", @"simple_pwd_failed"), [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]], [appDelegate.appPrefs objectForKey:@"USERID"]];
                    }
                    
                    //UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
                    UIViewController *top = [self topViewController];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertMsg message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                        
                                                                            [self closeButtonClick];
                                                                            if(_isSimpleLogin==YES) [IntroViewController nextPage];
                                                                     }];
                    [alert addAction:okButton];
                    [top presentViewController:alert animated:YES completion:nil];
                    
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"simple_pwd_failed", @"simple_pwd_failed"), [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]], [appDelegate.appPrefs objectForKey:@"USERID"]] message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            } @catch (NSException *exception) {
                NSLog(@"Exception : %@", exception);
                [SVProgressHUD dismiss];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"simple_pwd_failed", @"simple_pwd_failed"), [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]], [appDelegate.appPrefs objectForKey:@"USERID"]] message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
}

- (void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error code : %ld", (long)error.code);

    [SVProgressHUD dismiss];
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"simple_pwd_failed", @"simple_pwd_failed"), [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]], [appDelegate.appPrefs objectForKey:@"USERID"]] message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UIViewController *)topViewController{
  return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
  if (rootViewController.presentedViewController == nil) {
    return rootViewController;
  }

  if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
    UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
    return [self topViewController:lastViewController];
  }

  UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
  return [self topViewController:presentedViewController];
}

@end

