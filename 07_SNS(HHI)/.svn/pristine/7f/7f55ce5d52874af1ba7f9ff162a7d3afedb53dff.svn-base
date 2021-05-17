//
//  AppVersionViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 6. 21..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "AppVersionViewController.h"

@interface AppVersionViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation AppVersionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"myinfo_version", @"myinfo_version")];
    
    UIImage *appIcon = [UIImage imageNamed:@"appVerIcon.png"];
    
    self.appImgView.image = appIcon;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"system_info_version", @"system_info_version"), version] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[MFUtil myRGBfromHex:@"000000"]}];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:attrStr];
    self.appVer.attributedText = str;
    
    /*
     if) upgrade : 새 업데이트가 있습니다. 업데이트 하기.
     else if) downgrade : 현재 미배포 버전이 설치되어 있습니다. 다운그레이드 하기.
     else) none : 현재 최신 버전입니다.
     */
    
    NSString *updateBtnTitle = nil;
    if([appDelegate.compareAppVer isEqualToString:@"UPGRADE"]){
        updateBtnTitle = @"최신버전 업데이트";
        [self.updateBtn setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
        [self.updateBtn addTarget:self action:@selector(updateBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    } else if([appDelegate.compareAppVer isEqualToString:@"DOWNGRADE"]){
        updateBtnTitle = @"다운그레이드 하기";
        [self.updateBtn setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
        [self.updateBtn addTarget:self action:@selector(updateBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        updateBtnTitle = NSLocalizedString(@"system_info_message1", @"system_info_message1");
        [self.updateBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    [self.updateBtn setTitle:updateBtnTitle forState:UIControlStateNormal];
    
    self.updateBtn.layer.borderWidth = 0.3;
    self.updateBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)updateBtnClick{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"지금 설치하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         
                                                         NSURL *browser = [NSURL URLWithString:[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", appDelegate.downAppUrl]];
                                                         [[UIApplication sharedApplication] openURL:browser options:@{} completionHandler:nil];
                                                     }];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                         }];
    
    [alert addAction:okButton];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
