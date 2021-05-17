//
//  MediaAccessViewController.m
//  mfinity_sns
//
//  Created by hilee on 2020/06/18.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "MediaAccessViewController.h"


@interface MediaAccessViewController (){
    AppDelegate *appDelegate;
    CGFloat screenWidth;
}

@end

@implementation MediaAccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    screenWidth = screen.size.width;
    //NSLog(@"screenWidth : %f", screenWidth);
    
    [_scrollView setFrame:CGRectMake(0, 0, screenWidth, screen.size.height-44)];
    [_container setFrame:CGRectMake(0, 0, screenWidth, screen.size.height-44)];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
    
    self.titleLbl.text = NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media");
    
    self.accessView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.accessView.layer.borderWidth = 0.3;
    
    self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.contentView.layer.borderWidth = 0.3;
    
    self.remarkView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.remarkView.layer.borderWidth = 0.3;
//    self.remarkView.userInteractionEnabled = YES;
    
    self.remarkTxtView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"user_permission_reason_hint", @"user_permission_reason_hint") attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}];
    
    if([self.authVal isEqualToString:@"1"]) {
        self.valueLbl.text = NSLocalizedString(@"user_permission_grant", @"user_permission_grant");
        self.valueLbl.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        [self.accessBtn setTitle:NSLocalizedString(@"user_permission_revoke_btn", @"user_permission_revoke_btn") forState:UIControlStateNormal];
    } else {
        self.valueLbl.text = NSLocalizedString(@"user_permission_revoke", @"user_permission_revoke");
        self.valueLbl.textColor = [UIColor redColor];
        [self.accessBtn setTitle:NSLocalizedString(@"user_permission_grant_btn", @"user_permission_grant_btn") forState:UIControlStateNormal];
    }
    
    if(screenWidth <= 350) self.noticeLbl.font = [UIFont systemFontOfSize:13];
    else self.noticeLbl.font = [UIFont systemFontOfSize:14];
    self.noticeLbl.text = NSLocalizedString(@"user_permission_info", @"user_permission_info");
    
    self.accessBtn.layer.cornerRadius = self.accessBtn.frame.size.width/30;
    self.accessBtn.clipsToBounds = YES;
    self.accessBtn.userInteractionEnabled = YES;
    [self.accessBtn addTarget:self action:@selector(accessBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
//    self.accessBtn.layer.borderColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]].CGColor;
//    self.accessBtn.layer.borderWidth = 0.5;
    
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentSize = _container.frame.size;
    _scrollView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnScrollView:)];
    [self.scrollView setUserInteractionEnabled:YES];
    [self.scrollView addGestureRecognizer:tap];
}

- (void)tapOnScrollView:(UITapGestureRecognizer*)tap{
    [self.remarkTxtView endEditing:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.remarkTxtView endEditing:YES];
}

-(void)accessBtnClick{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"sendApprovalPermission"]];
    NSString *userId = [[self.dataArr objectAtIndex:0] objectForKey:@"CUSER_ID"];
    NSString *dvcId = [appDelegate.appPrefs objectForKey:@"DVC_ID"];
    NSLog(@"dvcId : %@", dvcId);
    
    NSString *jobHour = @"";
    NSString *alertMsg;
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    //권한이 적용되어있으면 해제, 해제되어있으면 적용
    if([_authVal isEqualToString:@"1"]) {
        jobHour = @"2";
        alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_revoke_alert_hhi", @"user_permission_revoke_alert_hhi"), appName];
    } else {
        jobHour = @"1";
        alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_grant_alert_hhi", @"user_permission_grant_alert_hhi"), appName];
    }
        
    NSString *remark = self.remarkTxtView.text;
    NSString *rmSpace = [remark stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(rmSpace.length <= 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_require_remark", @"user_permission_require_remark") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertMsg message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                            NSString *paramString = [NSString stringWithFormat:@"userId=%@&jobHour=%@&dvcId=%@&remark=%@&prmTy=1", userId, jobHour, dvcId, remark];
                                                            NSLog(@"paramString : %@", paramString);
                                                            
                                                            MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
                                                            session.delegate = self;
                                                            [session start];
                                                         }];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        
        [alert addAction:okButton];
        [alert addAction:cancelButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - MFURLSession Delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    appDelegate.errorExecCnt = 0;
    
    NSString *wsName = [[session.url absoluteString] lastPathComponent];
    if (error!=nil || ![error isEqualToString:@"(null)"]) {
        NSDictionary *dic = session.returnDictionary;
        NSLog(@"dic ! : %@", dic);
        if ([wsName isEqualToString:@"sendApprovalPermission"]) {
            if ([[dic objectForKey:@"RESULT"] isEqualToString:@"SUCCESS"]) {
                NSString *alertMsg;
                if([_authVal isEqualToString:@"1"]){
                    alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_revoke_ws_msg_hhi", @"user_permission_revoke_ws_msg_hhi"), NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
                } else {
                    alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_grant_ws_msg_hhi", @"user_permission_grant_ws_msg_hhi"), NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
                }
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertMsg message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                NSString *errorCode = [[dic objectForKey:@"MESSAGE"] objectForKey:@"ERROR_CODE"];
                //NSString *errorMsg = [[dic objectForKey:@"MESSAGE"] objectForKey:@"ERROR_MSG"];
                
                NSString *alertMsg = @"";
                if([errorCode isEqualToString:@"E_01"]){
                    if([_authVal isEqualToString:@"1"]){
                        alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_revoke_ws_msg1", @"user_permission_revoke_ws_msg1"), NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
                    } else {
                        alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_grant_ws_msg1", @"user_permission_grant_ws_msg1"), NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
                    }
                    
                    
                } else if([errorCode isEqualToString:@"E_02"]){
                    alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_grant_ws_msg2", @"user_permission_grant_ws_msg2"), NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
                
                } else if([errorCode isEqualToString:@"E_03"]){
                    alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_revoke_ws_msg2", @"user_permission_revoke_ws_msg2"), NSLocalizedString(@"user_permission_title_media", @"user_permission_title_media")];
                
                } else if([errorCode isEqualToString:@"E_04"]){
                    alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_error_E_04", @"user_permission_error_E_04")];
                
                } else if([errorCode isEqualToString:@"E_04_01"]){
                    alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_error_E_04_01", @"user_permission_error_E_04_01"), _exCompNm];
                
                } else if([errorCode isEqualToString:@"E_04_02"]){
                    if([_authVal isEqualToString:@"1"]){
                        alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_error_E_04_02_revoke", @"user_permission_error_E_04_02_revoke")];
                    } else {
                        alertMsg = [NSString stringWithFormat:NSLocalizedString(@"user_permission_error_E_04_02_grant", @"user_permission_error_E_04_02_grant")];
                    }
                       
                } else {
                    alertMsg = [NSString stringWithFormat:@"%@ [%@]", NSLocalizedString(@"exception_msg_exception", @"exception_msg_exception"), errorCode];
                }
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertMsg message:nil preferredStyle:UIAlertControllerStyleAlert];
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
-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    [SVProgressHUD dismiss];
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
        //[self callGetProfile];
    }
}

@end
