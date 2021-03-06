//
//  BoardCreateViewController.h
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 2..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MFURLSession.h"
#import "MFURLSessionUpload.h"
#import "TOCropViewController.h"

#import "AccessAuthCheck.h"

@interface BoardCreateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MFURLSessionDelegate, MFURLSessionUploadDelegate, TOCropViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *view1;
@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;

@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UIButton *coverEditBtn;

@property (strong, nonatomic) NSArray *keyArray;

@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *imageFileNameArray;

@property (nonatomic, strong) PHAsset *asset;
@property (strong, nonatomic) NSMutableArray *assetArray;

@property (strong, nonatomic) NSString *snsNo;
@property int currSnsKind;
@property (strong, nonatomic) NSString *fromSegue;

@property (strong, nonatomic) NSDictionary *snsInfoDic;

@property (nonatomic, assign) TOCropViewCroppingStyle croppingStyle;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGRect croppedFrame;
@property (nonatomic, assign) NSInteger angle;

@end
