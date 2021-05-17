//
//  NotiPushViewController.h
//  mFinity_HHI
//
//  Created by hilee on 2018. 7. 2..
//  Copyright © 2018년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"
#import "PullRefreshTableView.h"
//#import "WebViewController.h"
#import "WKWebViewController.h"
#import "MFBarcodeScannerViewController.h"
#import "ZipArchive.h"
#import "DownloadListViewController.h"
#import "UIViewController+MJPopupViewController.h"

@interface NotiPushViewController : UIViewController<UITableViewDataSource,NSURLConnectionDataDelegate, UITableViewDelegate, UIScrollViewDelegate,UIAlertViewDelegate,MFBarcodeScannerDelegate,DownloadListDelegate, UIGestureRecognizerDelegate>{
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
    
    NSMutableData            *receiveData;
    
    NSMutableArray *pushList;
    NSMutableDictionary *badgeList;
    NSMutableDictionary *noticeList;
    
    
    NSString *icon_count;
    NSString *notice_no;
    NSString *notice_title;
    NSString *notice_date;
    NSString *badge;
    int nPno;
    int pPno;
    BOOL noticeViewFlag;
    BOOL isDraw;
    
}
@property (strong, nonatomic) IBOutlet UIImageView *bgImgView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *segContainView;
@property (strong, nonatomic) IBOutlet UIButton *noticeBtn;
@property (strong, nonatomic) IBOutlet UIButton *pushBtn;
@property (strong, nonatomic) IBOutlet UILabel *btnLine;

@property (strong, nonatomic) IBOutlet UIView *noticeLine;
@property (strong, nonatomic) IBOutlet UIView *pushLine;
@property (strong, nonatomic) IBOutlet UIView *hideView1;
@property (strong, nonatomic) IBOutlet UIView *hideView2;
@property (strong, nonatomic) IBOutlet UIView *bottomLine1;
@property (strong, nonatomic) IBOutlet UIView *bottomLine2;

@property (nonatomic, strong) NSMutableArray *checkArray;
@property (nonatomic, strong) NSMutableArray *indexArray;
@property (nonatomic, strong) NSMutableDictionary *rowCheckDictionary;


@property (nonatomic, assign)BOOL isNotice;
- (void)startLoading;
- (void)stopLoading;
- (void)deleteLoading;

@end
