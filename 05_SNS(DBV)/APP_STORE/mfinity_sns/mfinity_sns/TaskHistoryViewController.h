//
//  TaskHistoryViewController.h
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 23..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFURLSession.h"
#import "AppDelegate.h"
#import "MFUtil.h"

@interface TaskHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFURLSessionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSString *taskNo;
@property (nonatomic,strong) NSString *lastHistNo;
@property (nonatomic,strong) NSMutableArray *dataSetArr;
@property (nonatomic,strong) NSString *createUserNo;

@end
