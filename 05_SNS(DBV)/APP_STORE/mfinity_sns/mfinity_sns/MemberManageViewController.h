//
//  MemberManageViewController.h
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 15..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MFURLSession.h"

@interface MemberManageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFURLSessionDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *snsNo;
@property (strong, nonatomic) NSString *snsName;
@property (strong, nonatomic) NSString *fromSegue;
@property (strong, nonatomic) NSString *snsKind;
@property (strong, nonatomic) NSDictionary *snsInfoDic;

//@property (strong, nonatomic) NSMutableArray *userNoArr;
@property (strong, nonatomic) NSArray *userListArr;
@property (weak, nonatomic) IBOutlet UISegmentedControl *approveSeg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segViewConstraint;

@end
