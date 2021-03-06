//
//  ChatListViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 13..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFUtil.h"
#import "ChatListViewCell.h"
#import "AppDelegate.h"
#import "SWTableViewCell.h"
#import "MFURLSession.h"
#import "SVProgressHUD.h"
#import <sqlite3.h>
#import "ChatMessageData.h"
#import "ChatViewController.h"
#import "UIDevice-Hardware.h"
#import "LGSideMenuController.h"
#import "ChatRoomImgDivision.h"
#import "VCFloatingActionButton.h"

#import "SyncChatInfo.h"

@interface ChatListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UIAlertViewDelegate, UIScrollViewDelegate, MFURLSessionDelegate, floatMenuDelegate> {
    int pPno;
    BOOL isRefresh;
    BOOL isDragging;
    UILabel                                 *lbRefreshTime;
    UIImageView                             *ivRefreshArrow;
    UIActivityIndicatorView                 *spRefresh;
    NSString                                *refreshTime;
    
    int prevBadgeCnt;
    
    NSUInteger taskId;
}

//- (void)setupWithType;

@property (strong, nonatomic) NSMutableArray *chatArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ChatListViewCell *chatListCell;
@property (strong, nonatomic) NSString *roomNoti;
- (IBAction)createChat:(id)sender;
- (void)noti_NewChatRoom:(NSNotification *)notification;

@property (nonatomic, strong) NSString *DBName;
@property (nonatomic, strong) NSString *DBPath;

@property (nonatomic, assign) NSInteger currentChatSQLIndex;
@property (nonatomic, assign) NSInteger currentChatRowIndex;

@property (weak, nonatomic) NSString *myUserNo;

//- (void)checkAndCreateDatabase; // 파일이 있는지 체크하고 없으면 생성하는 메소드
- (void)readFromDatabase; // 데이터베이스에서 데이터를 읽어오는 메소드

@property (strong, nonatomic) NSMutableDictionary *chatDict;
@property (strong, nonatomic) NSString *nRoomNo;
@property (strong, nonatomic) NSString *nRoomName;

@property (strong, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) NSString *recvRoomNo;
@property (strong, nonatomic) NSString *recvRoomNm;
@property (strong, nonatomic) NSString *deleteRoomNo;

@property (strong, nonatomic) NSString *fromSegue;
@property (strong, nonatomic) NSDictionary *profileChatDic;

@property (nonatomic, assign) BOOL notiClick;

@property (strong, nonatomic) NSString *badgeRoomNo;
@property (strong, nonatomic) NSMutableArray *tempArr;

@property (nonatomic,strong) NSDictionary *pushPostDic;
@property (nonatomic,strong) NSDictionary *pushChatDic;

//- (void)startLoading;
//- (void)stopLoading;
//- (void)deleteLoading;


@end
