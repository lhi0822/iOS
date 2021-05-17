//
//  DownloadListViewController.h
//  downloadTest
//
//  Created by Park on 2014. 6. 25..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFUtil.h"
@protocol MFDownloadDelegate;

@interface MFDownloadViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate>
@property (assign, nonatomic) id <MFDownloadDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSMutableArray *downloadMenuTitleList;
@property (nonatomic, strong) NSMutableArray *downloadVerArray;
@property (nonatomic, strong) NSMutableArray *downloadUrlArray;
@property (nonatomic, strong) NSMutableArray *downloadNoArray;
@property (nonatomic, assign) BOOL isBackTouch;
@property (nonatomic, strong) NSString *saveFilePath;

@property (nonatomic, strong) NSString *naviBarColor;
@property (nonatomic, strong) NSString *naviFontColor;
@property (nonatomic, strong) NSString *naviIsShadow;
@property (nonatomic, strong) NSString *naviShadowColor;
@property (nonatomic, strong) NSString *naviShadowOffset;
@property (nonatomic, strong) NSString *backGroundImagePath;
@property (nonatomic, strong) NSString *fontColor;
@end

@protocol MFDownloadDelegate <NSObject>
@optional
- (void)errorButtonClicked:(MFDownloadViewController *)secondDetailViewController;
- (void)cancelButtonClicked:(MFDownloadViewController *)secondDetailViewController;
@end