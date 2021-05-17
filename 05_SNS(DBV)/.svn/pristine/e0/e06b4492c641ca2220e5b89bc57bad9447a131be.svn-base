//
//  PostModifyViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 18..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SVProgressHUD.h"
#import "SCLAlertView.h"
#import <HTMLKit/HTMLKit.h>
#import "MFUtil.h"
#import "MFURLSessionUpload.h"
#import "UITextView+Placeholder.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "MFURLSession.h"
#import "MFURLSessionUpload.h"
#import "PHLibListViewController.h"


@interface PostModifyViewController : UIViewController <MFURLSessionDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSXMLParserDelegate, MFURLSessionUploadDelegate, MFMessageComposeViewControllerDelegate, UITextViewDelegate> {
    int uploadCount;
}

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) NSString *isEdit;

@property (strong, nonatomic) NSString *snsNo;
@property (strong, nonatomic) NSString *postNo;
@property (strong, nonatomic) NSDictionary *commDic;
@property (strong, nonatomic) NSDictionary *postDic;

@property (strong, nonatomic) UIImagePickerController *picker;

@property (strong, nonatomic) NSMutableArray *contentImageArray;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *imageIndexArray;
@property (strong, nonatomic) NSMutableArray *imageFileNameArray;

@property (strong, nonatomic) NSString *fromSegue;
@property (strong, nonatomic) NSString *taskNo;

@end
