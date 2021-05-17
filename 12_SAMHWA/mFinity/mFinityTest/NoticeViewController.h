//
//  TempNoticeViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"
#import "PullRefreshTableView.h"
#import "sqlite3.h"
@interface NoticeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>{
    MFinityAppDelegate *appDelegate;
    
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
	
    NSMutableArray *chatRoomList;
    NSMutableArray *messageList;
	NSMutableDictionary *pushList;
    NSMutableDictionary *badgeList;
    NSDictionary *noticeList;
    
    
    NSString *icon_count;
	NSString *notice_no;
	NSString *notice_title;
	NSString *notice_date;
	NSString *badge;
    NSString *roomNo;
    int pno;
    BOOL noticeViewFlag;
    BOOL isDraw;
    
    IBOutlet UITableView *_tableView;
}
@property (nonatomic, assign)BOOL isNotice;
- (void)startLoading;
- (void)stopLoading;
- (void)deleteLoading;
@end
