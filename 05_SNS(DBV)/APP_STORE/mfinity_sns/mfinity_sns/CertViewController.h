//
//  CertViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <sys/mount.h>

#import "MFURLSession.h"
#import "MFUtil.h"
#import "AppDelegate.h"

#import "SVProgressHUD.h"
#import "UIDevice-Hardware.h"

#import "LoginViewController.h"
#import "MFSingleton.h"

@interface CertViewController : UIViewController <MFURLSessionDelegate, UITextFieldDelegate> {
    BOOL isHideKeyboard;
}

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *userPwd;
@property (strong, nonatomic) NSString *dvcId;
@property (weak, nonatomic) IBOutlet UITextField *compTextField;
@property (weak, nonatomic) IBOutlet UITextField *authTextField;
@property (nonatomic, weak) IBOutlet UIImageView *backGroundImageView;

@property (strong, nonatomic) IBOutlet UIButton *authButton;

- (IBAction)authenticate:(id)sender;

@end
