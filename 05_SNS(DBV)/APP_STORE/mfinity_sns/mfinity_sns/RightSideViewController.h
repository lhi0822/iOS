//
//  RightSideViewController
//  mfinity_sns
//
//  Created by hilee on 2017. 5. 30..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessageData.h"
#import "MFURLSession.h"

@interface RightSideViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, MFURLSessionDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) BOOL slideOutAnimationEnabled;
@property (strong, nonatomic) NSMutableArray *userArr;
@property (nonatomic, assign) BOOL isSysChat;

@property (nonatomic, strong) NSString *DBName;
@property (nonatomic, strong) NSString *DBPath;

@property (strong, nonatomic) NSString *roomNo;
@property (strong, nonatomic) NSString *roomNoti;
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSString *roomType;

- (void)readFromDatabase;

@end
