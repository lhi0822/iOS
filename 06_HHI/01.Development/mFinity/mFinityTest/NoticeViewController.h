//
//  NoticeViewController.h
//  mFinityHD
//
//  Created by Park on 2014. 5. 27..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"
#import "PullRefreshTableView.h"
#import "WebViewController.h"
#import "MFBarcodeScannerViewController.h"
#import "ZipArchive.h"
#import "DownloadListViewController.h"
#import "UIViewController+MJPopupViewController.h"

@interface NoticeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,UIAlertViewDelegate,MFBarcodeScannerDelegate,DownloadListDelegate>{
    MFinityAppDelegate *appDelegate;
    
    NSString *menuKind;
    NSString *menuType;
    NSString *nativeAppURL;
    BOOL isDMS;
    BOOL isTabBar;
    NSString *paramString;
    NSString *nativeAppMenuNo;
    NSString *currentAppVersion;
    
    UILabel                                 *lbRefreshTime;
    UIImageView                             *ivRefreshArrow;
    UIActivityIndicatorView                 *spRefresh;
    
    NSString                                *refreshTime;
    BOOL                                    isRefresh;
    BOOL                                    isDragging;
    
    UILabel                                 *lbRefreshTime2;
    UIImageView                             *ivRefreshArrow2;
    UIActivityIndicatorView                 *spRefresh2;
    
    NSString                                *refreshTime2;
    BOOL                                    isRefresh2;
    BOOL                                    isDragging2;
    
    NSMutableData			*receiveData;
	
    NSMutableArray *messageList;
	NSMutableDictionary *pushList;
    NSMutableDictionary *badgeList;
    NSMutableDictionary *noticeList;
    
    
    NSString *icon_count;
	NSString *notice_no;
	NSString *notice_title;
	NSString *notice_date;
	NSString *badge;
    int pPno;
    BOOL noticeViewFlag;
    BOOL isDraw;
    
    IBOutlet UIImageView *_imageView;
    IBOutlet UITableView *_tableView;
}
@property (nonatomic, assign)BOOL isNotice;
- (void)startLoading;
- (void)stopLoading;
- (void)deleteLoading;
@end
