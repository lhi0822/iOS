//
//  MymenuViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFBarcodeScannerViewController.h"
#import "MFinityAppDelegate.h"
#import "DownloadListViewController.h"
#import "UIViewController+MJPopupViewController.h"
@interface MFTableViewController : UIViewController<MFBarcodeScannerDelegate,UIImagePickerControllerDelegate, UIAlertViewDelegate,NSURLConnectionDataDelegate,DownloadListDelegate>{
    
    NSString *methodType;
    
    IBOutlet UITableView *myTableView;
	IBOutlet UIImageView *imageView;
    
    MFinityAppDelegate *appDelegate;
    
    
    NSMutableData *receiveData;
    NSMutableData *fileData;
    NSMutableArray *menuArray;
    
    NSNumber *totalFileSize;
    BOOL isCommonDownload;
    
    BOOL isTabBar;
    BOOL isDMS;
    
    NSString *currentAppNo;
    NSString *currentAppVersion;
    NSString *nativeAppMenuNo;
    NSString *nativeAppURL;
    NSString *nativeAppVersion;
    NSString *paramString;
    
    NSString *menuKind;
    NSString *menuType;
    
    NSString *kind;
}
@property (nonatomic,strong) NSString *urlString;
@end
