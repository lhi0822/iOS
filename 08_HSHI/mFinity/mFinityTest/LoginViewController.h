//
//  LoginViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntegrateLoginViewController.h"
#import "AgreementViewController.h"
#import <MessageUI/MessageUI.h>

@interface LoginViewController : IntegrateLoginViewController<UITextFieldDelegate,UIAlertViewDelegate,NSURLConnectionDataDelegate, MFMailComposeViewControllerDelegate>{
    UIActivityIndicatorView *myIndicator;
	IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *infoImageView;
	IBOutlet UIButton		*btnLogin;
    IBOutlet UIButton       *settingButton;
	IBOutlet UITextField	*txtID;
	IBOutlet UITextField	*txtPWD;
    IBOutlet UILabel *label1;
    IBOutlet UILabel *label2;
    IBOutlet UILabel *label3;
    IBOutlet UILabel *label4;
    IBOutlet UILabel *label5;
    IBOutlet UILabel *versionLabel;
    IBOutlet UIButton *saveID;
    IBOutlet UIButton *autoLogin;
    IBOutlet UILabel *autoLoginLbl;
    IBOutlet UIButton *offLine;
    //IBOutlet UISwitch *switchOffLine;
	//IBOutlet UISwitch *switchIdSave;
//    BOOL isButtonClick;
    BOOL isSaveId;
    BOOL isAutoLogin;
    BOOL isOffline;
    BOOL isHideKeyboard;
    IBOutlet UIButton *initPwd;
    
}
//@property (nonatomic,assign)BOOL isButtonClick;
-(IBAction)connInfoSetting:(id)sender;
-(IBAction)connInfoSetting2:(id)sender;
-(IBAction)connInfoSetting3:(id)sender;
-(IBAction)LoginButton;
-(void)Login;
- (IBAction)autoLoginButton:(id)sender;
-(IBAction)textFieldDoneEditing:(id)sender;
-(IBAction)backgroundTouch:(id)sender;
-(IBAction)saveIdButton:(id)sender;
-(IBAction)offLineButton:(id)sender;
-(IBAction)initPwdButton:(id)sender;
@end
