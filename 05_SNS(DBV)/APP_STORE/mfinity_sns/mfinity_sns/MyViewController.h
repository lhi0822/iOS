//
//  MyViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 8..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <MessageUI/MessageUI.h>

#import "AppDelegate.h"
#import "MFDBHelper.h"
#import "MFUtil.h"
#import "MFURLSession.h"
#import "MFURLSessionUpload.h"

#import "IntroViewController.h"
#import "TOCropViewController.h"



@interface MyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MFURLSessionUploadDelegate, UIAlertViewDelegate, MFURLSessionDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate, TOCropViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *imgView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *profileImgView;
@property (strong, nonatomic) IBOutlet UIButton *editImgButton;
@property (strong, nonatomic) IBOutlet UIImageView *profileBgImgView;
@property (strong, nonatomic) IBOutlet UIButton *editBgButton;
@property (strong, nonatomic) IBOutlet UIButton *editIcon;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *editSpaceConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *editWidthConstraint;

@property (strong, nonatomic) NSDictionary *infoDic;
@property (strong, nonatomic) NSMutableArray *profileKeyArr;
@property (strong, nonatomic) NSMutableArray *profileValArr;
@property (strong, nonatomic) NSMutableArray *accountKeyArr;
@property (strong, nonatomic) NSMutableArray *accountValArr;
@property (strong, nonatomic) NSMutableArray *notiKeyArr;
@property (strong, nonatomic) NSMutableArray *settingKeyArr;
@property (strong, nonatomic) NSMutableArray *appInfoKeyArr;
@property (strong, nonatomic) NSMutableArray *dataManageKeyArr;

@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *imageFileNameArray;

@property (nonatomic, strong) PHAsset *asset;
@property (strong, nonatomic) NSMutableArray *assetArray;

@property (strong, nonatomic) UIImagePickerController *picker;

@property (strong, nonatomic) NSString *fromSegue;

@property (nonatomic, assign) TOCropViewCroppingStyle croppingStyle;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGRect croppedFrame;
@property (nonatomic, assign) NSInteger angle;

@property (nonatomic,strong) NSDictionary *pushPostDic;
@property (nonatomic,strong) NSDictionary *pushChatDic;

@end
