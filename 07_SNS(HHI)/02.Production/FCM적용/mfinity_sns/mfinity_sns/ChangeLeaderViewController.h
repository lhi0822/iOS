//
//  ChangeLeaderViewController.h
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 10..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatUserListCell.h"
#import "MFURLSession.h"

@interface ChangeLeaderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFURLSessionDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong)NSString *fromSegue;
@property (nonatomic, strong)NSString *snsNo;
@property (nonatomic, strong)NSString *leaderNo;
@property (strong, nonatomic) NSDictionary *snsInfoDic;

@property (strong, nonatomic) NSMutableArray *dataSetArray;

@end
