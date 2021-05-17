//
//  TaskModifyViewController.h
//  mfinity_sns
//
//  Created by hilee on 10/12/2018.
//  Copyright © 2018 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
#import "MFTextView.h"
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SVProgressHUD.h"

#import "AppDelegate.h"
#import "MFUtil.h"
#import "MFURLSession.h"
#import "MFURLSessionUpload.h"
#import "UITextView+Placeholder.h"
#import <AVFoundation/AVFoundation.h>
#import "TaskInfoTableViewCell.h"

@interface TaskModifyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MFURLSessionDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, MFTextViewDelegate, NSXMLParserDelegate, MFURLSessionUploadDelegate, UIAlertViewDelegate, TaskInfoTableViewCellDelegate> {
    int uploadCount;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *photoButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *videoButton;

- (IBAction)photo:(id)sender;
- (IBAction)video:(id)sender;

@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) NSString *snsNo;
@property (strong, nonatomic) NSString *snsName;
@property (strong, nonatomic) NSString *taskNo;

@property (strong, nonatomic) NSMutableArray *contentImageArray;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *imageIndexArray;
@property (strong, nonatomic) NSMutableArray *imageFilePathArray;

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic,strong) NSMutableArray *mImgArray;
@property (nonatomic,strong) NSString *imageStr;

@property (weak, nonatomic) NSString *fromSegue;
@property (weak, nonatomic) NSDictionary *taskInfoDic;

@property (nonatomic, strong) PHAsset *asset;
@property (strong, nonatomic) NSMutableArray *assetArray;

@end
