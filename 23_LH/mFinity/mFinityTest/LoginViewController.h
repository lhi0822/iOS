//
//  LoginViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntegrateLoginViewController.h"

#import "SSLVPNConnect.h"
//#import "NFilterHandler.h"
#import "NFilterNum.h"
#import "NFilterChar.h"
#import "SampleUtils.h"

@interface LoginViewController : IntegrateLoginViewController<UITextFieldDelegate, UIAlertViewDelegate,NSURLConnectionDataDelegate, NFilterCharDelegate, NFilterNumDelegate, NFilterToolbar2Delegate>{
    UIActivityIndicatorView *myIndicator;
    IBOutlet UIImageView *imageView;
    
    IBOutlet UITextField *txtID;
    IBOutlet UITextField *txtPWD;
    IBOutlet UIButton *saveID;
    IBOutlet UILabel *label3;
    IBOutlet UIButton *btnLogin;
    IBOutlet UILabel *versionLabel;
    
    BOOL isButtonClick;
    BOOL isSaveId;
    BOOL isAutoLogin;
    BOOL isHideKeyboard;
}

@property NFilterNum *numPad;
@property NFilterChar *charPad;

@property UIViewController *lg;

@property BOOL isCustomKeypad;
@property BOOL isSupportLandscape;
@property BOOL isCloseKeypad;
@property BOOL isCustomKeypadToolbar;

@property (weak, nonatomic) IBOutlet UIImageView *logoView;

-(IBAction)LoginButton;
-(void)Login;
-(IBAction)textFieldDoneEditing:(id)sender;
-(IBAction)backgroundTouch:(id)sender;
-(IBAction)saveIdButton:(id)sender;

@end
