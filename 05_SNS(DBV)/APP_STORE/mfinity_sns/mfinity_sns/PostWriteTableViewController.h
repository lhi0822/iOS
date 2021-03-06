//
//  PostWriteTableViewController.h
//  mfinity_sns
//
//  Created by hilee on 2018. 10. 25..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SVProgressHUD.h"
//#import <HTMLKit/HTMLKit.h>
#import "AppDelegate.h"
#import "MFUtil.h"
#import "MFURLSession.h"
#import "MFURLSessionUpload.h"
#import "UITextView+Placeholder.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TOCropViewController.h"
//#import "SDAVAssetExportSession.h"
//#import "M13ProgressViewRing.h"
#import "MFFileCompress.h"



@interface PostWriteTableViewController : UIViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, MFURLSessionDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MFURLSessionUploadDelegate, UIAlertViewDelegate, TOCropViewControllerDelegate, UIDocumentPickerDelegate> {
    int uploadCount;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;

@property (strong, nonatomic) NSString *fromSegue;

@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIDocumentPickerViewController *docPicker;
@property (strong, nonatomic) NSString *snsNo;
@property (strong, nonatomic) NSString *snsName;
@property (strong, nonatomic) NSString *postNo;

@property (strong, nonatomic) NSMutableArray *contentImageArray;
@property (strong, nonatomic) NSMutableArray *filePathArray;
@property (strong, nonatomic) NSMutableArray *fileNameArray;

@property (weak, nonatomic) PHPhotoLibrary *photoLibrary;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *photoButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *videoButton;

@property (nonatomic, assign) TOCropViewCroppingStyle croppingStyle;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGRect croppedFrame;
@property (nonatomic, assign) NSInteger angle;

- (IBAction)photo:(id)sender;
- (IBAction)video:(id)sender;

@end




