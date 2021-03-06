//
//  SNSNoticeSetViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 23..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFURLSession.h"

@interface SNSNoticeSetViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFURLSessionDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *notiPostArr;
@property (strong, nonatomic) NSMutableArray *notiCommArr;

@property (strong, nonatomic) NSString *snsNo;
@property (strong, nonatomic) NSString *snsName;

@end
