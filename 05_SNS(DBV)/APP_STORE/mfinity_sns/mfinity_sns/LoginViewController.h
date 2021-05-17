//
//  LoginViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MFURLSession.h"
#import "MFUtil.h"
#import "SVProgressHUD.h"
#import "CertViewController.h"
#import "SVProgressHUD.h"
#import "MFSingleton.h"


@interface LoginViewController : UIViewController <MFURLSessionDelegate, UITextFieldDelegate, NSURLConnectionDataDelegate> {
    BOOL isHideKeyboard;
    
    NSString *dvcId;
    NSString *dvcKind;
    NSString *dvcOs;
    NSString *appVersion;
    NSString *dvcVer;
    NSString *carrier;
    NSString *extRam;
    NSString *extTotVol;
    NSString *extUseVol;
    NSString *useVol;
    NSString *pushId1;
    NSString *isRooted;
    NSString *userId;
    NSString *userPwd;
    NSString *legacyNm;
    NSString *cpnCode;
    
}

@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwTextField;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (nonatomic, weak) IBOutlet UIImageView *backGroundImageView;

@property (strong, nonatomic) IBOutlet UILabel *verLabel;

@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) NSDictionary *dataSetDic;

- (IBAction)next:(id)sender;

@end
