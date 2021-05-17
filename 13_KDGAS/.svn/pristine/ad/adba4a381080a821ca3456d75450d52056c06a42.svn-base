//
//  SettingViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityAlertView.h"
#import "WebViewController.h"
#import "MFBarcodeScannerViewController.h"
#import "ZipArchive.h"
#import "DownloadListViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "MFinityAppDelegate.h"

@interface SettingViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource,UIAlertViewDelegate, NSURLConnectionDataDelegate,MFBarcodeScannerDelegate,DownloadListDelegate>{
    MFinityAppDelegate *appDelegate;
    
    NSString *menuKind;
    NSString *menuType;
    NSString *nativeAppURL;
    BOOL isDMS;
    BOOL isTabBar;
    NSString *paramString;
    NSString *nativeAppMenuNo;
    NSString *currentAppVersion;
    NSMutableData			*receiveData;
    
    IBOutlet UIImageView *imageView;
    IBOutlet UITableView *myTableView;
    
    UILabel *selAlertTitleLabel;
    UILabel *delAlertTitleLabel;
    UIActivityIndicatorView *myIndicator;
    UIAlertView *progressAlert;
    UIProgressView *progressView;
    
    NSString *indexTitle;
    NSString *deleteTitle;
    
    NSMutableArray *deleteArray;
    NSMutableArray *downloadVerArray;
    NSMutableArray *downloadUrlArray;
    NSMutableArray *downloadNoArray;
	NSMutableArray *array;
    NSMutableArray *menuTitles;
    NSMutableArray *menuArray;
    NSMutableArray *tabNameArray;
    NSMutableArray *webAppURLs;
    NSMutableArray *menuNumbers;
    NSMutableArray *webAppVersions;

    
    NSMutableData *fileData;
	NSNumber *totalFileSize;
    ActivityAlertView *activityAlert;
    
    int connectionCount;
}
@property (nonatomic, strong)    NSArray *iconArray;
- (NSInteger)indexOfString:(NSString*)title;
- (void)barCodeReaderOpen;
@end
