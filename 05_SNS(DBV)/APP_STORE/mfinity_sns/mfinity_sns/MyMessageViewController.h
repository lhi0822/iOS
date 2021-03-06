//
//  MyMessageViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 4..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MFUtil.h"
#import "MFURLSession.h"
#import "UITextView+Placeholder.h"
#import <AVFoundation/AVFoundation.h>
#import "MFTextView.h"

@interface MyMessageViewController : UIViewController<UITextFieldDelegate, MFURLSessionDelegate, UINavigationControllerDelegate, MFTextViewDelegate>

//@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (strong, nonatomic) IBOutlet UITextField *textView;

@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *msgCount;
@property (strong, nonatomic) IBOutlet MFTextView *msgTextView;

@property (strong, nonatomic) NSString *statusMsg;
@property (strong, nonatomic) NSString *fromSegue;
@property (strong, nonatomic) NSString *changeRoomNo;

@end
