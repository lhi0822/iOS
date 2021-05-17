//
//  CertificateViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 19..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntegrateLoginViewController.h"
@interface CertificateViewController : IntegrateLoginViewController<UITextFieldDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate>{
    UIActivityIndicatorView *myIndicator;
    IBOutlet UIImageView *imageView;
    IBOutlet UITextField *certField;
    IBOutlet UITextField *compNoField;
    IBOutlet UIButton *btnCert;
    IBOutlet UILabel *label1;
    IBOutlet UILabel *label2;
    IBOutlet UILabel *label3;
    IBOutlet UIImageView *infoImageView;
    
    BOOL isButtonClick;
    BOOL isHideKeyboard;
}
-(IBAction) certificator;
-(NSString *)isValue:(NSString *)name;
-(IBAction) textFieldDoneEditing:(id)sender;
@end
