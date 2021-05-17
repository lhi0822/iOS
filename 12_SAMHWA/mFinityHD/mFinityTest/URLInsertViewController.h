//
//  URLInsertViewController.h
//  mFinity
//
//  Created by Park on 2013. 11. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"

@interface URLInsertViewController : UIViewController<UIAlertViewDelegate, NSURLConnectionDataDelegate,UITextFieldDelegate>{
    IBOutlet UIImageView *_imageView;
    IBOutlet UILabel *hostLabel;
    IBOutlet UILabel *portLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *guideLabel;
    IBOutlet UITextField *nameField;
    IBOutlet UITextField *hostField;
    IBOutlet UITextField *portField;
    MFinityAppDelegate *appDelegate;
    NSString *urlInfo;
    NSMutableData *receiveData;
    BOOL isHideKeyboard;
    IBOutlet UIButton *button;
    IBOutlet UIImageView *infoImageView;
}
@property (nonatomic, strong)NSString *serverName;
@property (nonatomic, strong)NSString *urlAddress;
@property (nonatomic, strong)NSString *urlPort;
@property (nonatomic, assign)BOOL isEdit;
@property (nonatomic, assign)BOOL isAllRemove;
-(IBAction)TestConnection;
-(IBAction) backgroundTouch:(id)sender;
@end
