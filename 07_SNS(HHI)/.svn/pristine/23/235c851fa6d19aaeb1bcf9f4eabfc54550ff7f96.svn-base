//
//  PostDetailViewController.h
//  mfinity_sns
//
//  Created by hilee on 07/02/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PostModifyTableViewController.h"
#import "MFURLSession.h"
#import "MFURLSessionUpload.h"
#import "MFFileCompress.h"

#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "WebViewController.h"
#import "UIDevice-Hardware.h"
#import "JSQMessagesInputToolbar.h"
#import "CustomHeaderViewController.h"
#import "MFTextView.h"
#import "TOCropViewController.h"
#import "HISImageViewer.h"
#import "TTTAttributedLabel.h"
#import "SDAVAssetExportSession.h"

@interface PostDetailViewController : UIViewController <UITextViewDelegate, MFURLSessionDelegate, MFURLSessionUploadDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSXMLParserDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UIGestureRecognizerDelegate, JSQMessagesInputToolbarDelegate, MFTextViewDelegate, TOCropViewControllerDelegate, UITableViewDataSourcePrefetching, TTTAttributedLabelDelegate, SDAVAssetExportSessionDelegate, UIDocumentPickerDelegate> {
    BOOL isRefresh;
    HISImageViewer *imageViewer;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet JSQMessagesInputToolbar *inputToolbar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;

//댓글 첨부 미리보기
@property (strong, nonatomic) IBOutlet UIView *attachContainer;
@property (strong, nonatomic) IBOutlet UIImageView *attachImgView;
@property (strong, nonatomic) IBOutlet UIButton *attachDeleteBtn;

@property (nonatomic, strong) NSString *isEdit;

@property (strong, nonatomic) UIButton *mediaButton;
@property BOOL isFlag;

@property (nonatomic,strong) NSDictionary *postInfo;
@property (nonatomic,strong) NSDictionary *postDetailInfo;
@property (nonatomic,strong) NSMutableArray *contentArray;
@property (nonatomic,strong) NSMutableArray *commentArray;

@property (nonatomic,strong) NSMutableDictionary *imageUrlDictionary;
@property (nonatomic,strong) NSMutableDictionary *fileDictionary;
@property (nonatomic,strong) NSIndexPath *indexPath;

@property (strong, nonatomic) NSMutableArray *commFileArr;
@property (strong, nonatomic) NSMutableArray *commFilePathArr;
@property (strong, nonatomic) NSMutableArray *commFileThumbPathArr;

@property (nonatomic,strong) NSString *_snsNo;
@property (nonatomic,strong) NSString *_snsName;
@property (nonatomic,strong) NSString *_postNo;
@property (nonatomic,strong) NSString *_postDate;
@property (nonatomic,strong) NSString *_readCnt;
@property (nonatomic,strong) NSString *_commCnt;
@property (nonatomic,strong) NSString *_isRead;
@property (nonatomic,strong) NSString *fromSegue;
@property (nonatomic,strong) NSDictionary *notiPostDic;

@property (nonatomic, assign) TOCropViewCroppingStyle croppingStyle;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGRect croppedFrame;
@property (nonatomic, assign) NSInteger angle;

@end
