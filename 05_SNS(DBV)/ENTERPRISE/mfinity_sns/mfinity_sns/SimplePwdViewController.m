//
//  SimplePwdViewController.m
//  mfinity_sns
//
//  Created by hilee on 2020/07/01.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "SimplePwdViewController.h"

@interface SimplePwdViewController (){
    AppDelegate *appDelegate;
}

@end

@implementation SimplePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"myinfo_set_simple_pwd", @"myinfo_set_simple_pwd")];
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.useContainer.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.useContainer.layer.borderWidth = 0.3;
    self.pwdTitleLbl.text = NSLocalizedString(@"myinfo_set_simple_pwd", @"myinfo_set_simple_pwd");
    
    UIImage *img = nil;
    if (@available(iOS 13.0, *)) {
        img = [[UIImage systemImageNamed:@"exclamationmark.circle"] imageWithTintColor:[UIColor redColor] renderingMode:UIImageRenderingModeAlwaysTemplate];

    } else {
        img = [UIImage imageNamed:@"exclamationmark_circle.png"];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", NSLocalizedString(@"myinfo_set_simple_pwd_info", @"myinfo_set_simple_pwd_info")] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];

    textAttachment.image = img;
    textAttachment.bounds = CGRectMake(0, 0, 0, 0);
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString appendAttributedString:attrStringWithImage];
    [attributedString appendAttributedString:attributedString2];
    self.remarkLbl.attributedText = attributedString;
    self.remarkLbl.numberOfLines = 0;
    
    self.setContainer.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.setContainer.layer.borderWidth = 0.3;
    
    
    //로그인때 넘어오는 간편로그인 비밀번호가 있는지 없는지
//    appDelegate.simplePwdFlag = @"Y"; //N:미사용 Y:사용
    
//    if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
//        //현대중공업은 필수
//        [self.pwdSwitch setOn:YES];
//        [self.pwdSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
//
//    } else {
//        [self.pwdSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
//        if([appDelegate.simplePwd isEqualToString:@"Y"]) [self.pwdSwitch setOn:YES];
//        else [self.pwdSwitch setOn:NO];
//    }
    
    
    UIImage *image1 = nil;
    if (@available(iOS 13.0, *)) {
        image1 = [[UIImage systemImageNamed:@"chevron.right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
    } else {
        image1 = [UIImage imageNamed:@"chevron_right.png"];
    }
    [self.pwdSetBtn setTintColor:[UIColor lightGrayColor]];
    [self.pwdSetBtn setImage:image1 forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnSetView:)];
    [self.setContainer setUserInteractionEnabled:YES];
    [self.setContainer addGestureRecognizer:tap];
    
    [self.pwdSwitch setOnTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
    [self.pwdSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    
    NSLog(@"EASY_PASSWD_FLAG : %@", appDelegate.simplePwdFlag);
    
    if([appDelegate.simplePwdFlag isEqualToString:@"Y"]) {
        [self.pwdSwitch setOn:YES];
        
        [self.setContainer setHidden:NO];
        [self.remarkLbl setHidden:NO];
        
    } else {
        [self.pwdSwitch setOn:NO];
        
        [self.setContainer setHidden:YES];
        [self.remarkLbl setHidden:YES];
    }
    
}

- (void)switchToggled:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    
    if(![mySwitch isOn]){
        NSLog(@"사용함->사용안함");
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
//            [mySwitch setOn:YES animated:YES];
            [mySwitch setOn:NO animated:YES];
            [self callSaveSimplePwd:@"N"];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myinfo_set_simple_pwd_unconditional1", @"myinfo_set_simple_pwd_unconditional1") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            [mySwitch setOn:NO animated:YES];
        }
        
        [UIView animateWithDuration:1.0 animations:^{
            [self.setContainer setHidden:YES];
            [self.remarkLbl setHidden:YES];
        }];
        
    } else {
        NSLog(@"사용안함->사용함");
        [mySwitch setOn:YES animated:YES];
        
        [UIView animateWithDuration:1.0 animations:^{
            [self.setContainer setHidden:NO];
            [self.remarkLbl setHidden:NO];
        }];
        
        [self callSaveSimplePwd:@"Y"];
    }
}

- (void)tapOnSetView:(UITapGestureRecognizer*)tap{
    SimplePwdInputViewController *vc = [[SimplePwdInputViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)callSaveSimplePwd:(NSString *)use{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *userId = [appDelegate.appPrefs objectForKey:@"USERID"];
    NSString *dvcId = [appDelegate.appPrefs objectForKey:@"DVC_ID"];
    NSString *easyPwd = @"000000";
    
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&usrId=%@&dvcId=%@&easyPwd=%@&easyPwdFlag=%@&mode=CHANGE_PWD_FLAG", userNo, userId, dvcId, easyPwd, use];
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
        [SVProgressHUD dismiss];
        if(session.returnDictionary != nil){
            @try{
                NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
                NSLog(@"dic : %@",session.returnDictionary);
                
                if ([result isEqualToString:@"SUCCESS"]) {
                    //NSString *affected = [session.returnDictionary objectForKey:@"AFFECTED"];
                    
                }
                
            } @catch (NSException *exception) {
                NSLog(@"Exception : %@", exception);
                [SVProgressHUD dismiss];
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
}

@end
