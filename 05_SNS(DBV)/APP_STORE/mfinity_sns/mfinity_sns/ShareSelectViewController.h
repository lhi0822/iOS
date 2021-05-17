//
//  ShareSelectViewController.h
//  mfinity_sns
//
//  Created by hilee on 20/02/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFUtil.h"
#import "MFGroupCell.h"
#import "MFURLSession.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "MFDBHelper.h"
#import "SearchChatListViewCell.h"

#import "ChatViewController.h"

#import <sqlite3.h>

@interface ShareSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFURLSessionDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIView *segContainer;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property int selectShareKind;
@property (weak, nonatomic) NSArray *normalDataArray;
@property (strong, nonatomic) NSMutableArray *chatArray;
@property (strong, nonatomic) NSMutableArray *tempArr;

@property (strong, nonatomic) NSString *fromSegue;
@property (strong, nonatomic) NSString *currNo;

@end

