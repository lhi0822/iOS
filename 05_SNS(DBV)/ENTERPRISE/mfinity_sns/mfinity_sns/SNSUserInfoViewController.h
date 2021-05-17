//
//  SNSUserInfoViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 23..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MFURLSession.h"
#import "MFUserCell.h"

@interface SNSUserInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFURLSessionDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *snsNo;
@property (nonatomic, strong) NSString *snsName;
@property (nonatomic, strong) NSString *snsLeader;

@property (strong, nonatomic) NSMutableArray *dataSetArray;
@property (strong, nonatomic) NSDictionary *snsInfoDic;
//@property (strong, nonatomic) NSMutableArray *memberArr;

@end
