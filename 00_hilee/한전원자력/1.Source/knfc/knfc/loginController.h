//
//  loginController.h
//  knfc
//
//  Created by 최형준 on 2015. 1. 19..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface loginController : UIViewController <UIAlertViewDelegate> {
    UITextField *txtid, *txtpwd;
    UIButton *btnlogin;
    IBOutlet UIButton *btncheck;
    IBOutlet UIButton *device_btn;
    BOOL savecheck;
}
@property (nonatomic,retain) IBOutlet UITextField *txtid, *txtpwd;
@property (nonatomic, retain) IBOutlet UIButton *btnlogin;
@property (nonatomic, retain) IBOutlet UIButton *device_btn;
@property (nonatomic, retain) IBOutlet UIView * red_view;
@property (nonatomic, retain) IBOutlet UIView * motp_view;

@property (weak, nonatomic) IBOutlet UIImageView *otpImgView;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mobileImgView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

- (IBAction)btnloginPress:(id)sender;
- (IBAction)btncheckPress:(id)sender;
- (IBAction)btnAddPress:(id)sender;

@end

@interface NSString(URLEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
+ (NSString *)urlDecodeString:(NSString *)str;
@end
