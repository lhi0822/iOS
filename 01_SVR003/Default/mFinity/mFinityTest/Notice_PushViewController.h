//
//  Notice_PushViewController.h
//  TestingVersionEzSmart
//
//  Created by Kyeong In Park on 12. 7. 16..
//  Copyright (c) 2012년 feeldata@feeldata.co.kr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"
#import "PullRefreshTableView.h"
#import "WebViewController.h"
#import "MFBarcodeScannerViewController.h"
#import "ZipArchive.h"
#import "DownloadListViewController.h"
#import "UIViewController+MJPopupViewController.h"

@interface Notice_PushViewController : UIViewController<UITableViewDataSource,NSURLConnectionDataDelegate, UITableViewDelegate, UIScrollViewDelegate,UIAlertViewDelegate,MFBarcodeScannerDelegate,DownloadListDelegate>{
    MFinityAppDelegate *appDelegate;
    
    NSString *menuKind;
    NSString *menuType;
    NSString *nativeAppURL;
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
    //푸시삭제 기능추가(2018.09)
    NSMutableArray *pushList;
    NSMutableDictionary *badgeList;
    NSMutableDictionary *noticeList;
    NSMutableArray *tmpPush;
    
    NSString *icon_count;
	NSString *notice_no;
	NSString *notice_title;
	NSString *notice_date;
	NSString *badge;
    
    int nPno;
    int pPno;
    BOOL noticeViewFlag;
    BOOL isDraw;
    NSString *moreCount;
    
    IBOutlet UIImageView *_imageView;
    IBOutlet UITableView *_tableView;
}

//푸시삭제 기능추가(2018.09)
@property (nonatomic, strong) NSMutableArray *checkArray;
@property (nonatomic, strong) NSMutableArray *indexArray;
@property (nonatomic, strong) NSMutableDictionary *rowCheckDictionary;

@property (nonatomic, assign)BOOL isNotice;
- (void)startLoading;
- (void)stopLoading;
- (void)deleteLoading;
@end
