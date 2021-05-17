//
//  PostWriteViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 8..
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
#import "AppDelegate.h"
#import "MFUtil.h"
#import "MFURLSession.h"
#import "MFURLSessionUpload.h"
#import "UITextView+Placeholder.h"
#import <AVFoundation/AVFoundation.h>

@interface PostWriteViewController : UIViewController <UITextViewDelegate, MFURLSessionDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSXMLParserDelegate, MFURLSessionUploadDelegate, UIAlertViewDelegate, MFMessageComposeViewControllerDelegate> {
    int uploadCount;
}

@property (strong, nonatomic) NSString *fromSegue;

@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) NSString *snsNo;
@property (strong, nonatomic) NSString *snsName;
@property (strong, nonatomic) NSString *postNo;

@property (strong, nonatomic) NSMutableArray *contentImageArray;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *imageIndexArray;
@property (strong, nonatomic) NSMutableArray *imageFileNameArray;

@property (weak, nonatomic) PHPhotoLibrary *photoLibrary;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;

@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *photoButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *videoButton;

- (IBAction)photo:(id)sender;
- (IBAction)video:(id)sender;
- (IBAction)otherFile:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *button;

@end
