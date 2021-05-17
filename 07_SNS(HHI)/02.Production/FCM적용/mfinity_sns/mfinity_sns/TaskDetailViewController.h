//
//  TaskDetailViewController.h
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 12..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "JSQMessagesInputToolbar.h"
#import "MFURLSession.h"
#import "TaskFileCollectionViewCell.h"
#import "CustomHeaderViewController.h"
#import "WebViewController.h"
#import "SVProgressHUD.h"
#import "MFTextView.h"

@interface TaskDetailViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, JSQMessagesInputToolbarDelegate, UITextViewDelegate, MFURLSessionDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, MFTextViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet JSQMessagesInputToolbar *inputToolbar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionBottomConstraint;

@property (nonatomic,strong) NSDictionary *taskInfo;
@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,strong) NSString *_snsNo;
@property (nonatomic,strong) NSString *_snsName;
@property (nonatomic,strong) NSString *_taskNo;
@property (nonatomic,strong) NSString *_taskDate;
@property (nonatomic,strong) NSString *_readCnt;
@property (nonatomic,strong) NSString *fromSegue;

@property (nonatomic, strong) NSString *isEdit;

@property (nonatomic,weak) NSString *lastHistNo;
@property (nonatomic,strong) NSDictionary *notiTaskDic;

@end
