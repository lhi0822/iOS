//
//  TeamListViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 8..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "MFUtil.h"
#import "MFURLSession.h"
#import "MFDBHelper.h"
#import "SVProgressHUD.h"
#import "VCFloatingActionButton.h"

#import "PostWriteTableViewController.h"
#import "SearchViewController.h"
#import "NewsFeedViewController.h"

#import "MFGroupCell.h"

//#import "AMQPChannel.h"
//#import "AMQPConnection.h"
//#import "AMQPExchange.h"
//#import "AMQPQueue.h"
//#import "AMQPConsumer.h"
//#import "AMQPConsumerThread.h"
//#import "AMQPMessage.h"
//#import "amqp_framing.h"
//#import "amqp.h"

#import <sqlite3.h>

@interface TeamListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFURLSessionDelegate, UIGestureRecognizerDelegate, floatMenuDelegate> {
    NSUInteger taskId;
}

@property (strong, nonatomic) UITextField *searchField;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (strong, nonatomic) NSArray *normalDataArray; //weak면 되고, strong이면 안된다?
@property (weak, nonatomic) NSArray *projectDataArray;

@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, assign) BOOL notiClick;

@property (weak, nonatomic) NSString *fromSegue;
@property (nonatomic,strong) NSDictionary *pushPostDic;
@property (nonatomic,strong) NSDictionary *pushChatDic;

@property (nonatomic,strong) NSMutableArray *boardImgArr;

@property (strong, nonatomic) IBOutlet UIButton *createBtn;

@property (strong, nonatomic) IBOutlet UIView *segContainer;
@property (strong, nonatomic) IBOutlet UISegmentedControl *boardSegment;
@property int selectBoardKind;

@end
