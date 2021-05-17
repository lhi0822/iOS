//
//  TeamSelectController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 21..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFUtil.h"
#import "AppDelegate.h"
#import "MFURLSession.h"
#import "MFDBHelper.h"
#import "VCFloatingActionButton.h"
#import <sqlite3.h>

#import "SDWebImageManager.h"

@interface TeamSelectController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFURLSessionDelegate, UIScrollViewDelegate, floatMenuDelegate, UITableViewDataSourcePrefetching, NSURLSessionDelegate> {
    BOOL isRefresh;
    BOOL isDragging;
    UILabel                                 *lbRefreshTime;
    UIImageView                             *ivRefreshArrow;
    UIActivityIndicatorView                 *spRefresh;
    NSString                                *refreshTime;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) CGFloat lastContentOffset;

@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)snsUserInfoClick:(id)sender;
- (IBAction)snsInfoClick:(id)sender;

@property (nonatomic, strong) NSString *DBName;
@property (nonatomic, strong) NSString *DBPath;

@property (nonatomic,weak) NSString *lastPostNo;
@property (nonatomic,strong) NSString *snsNo;
@property (nonatomic,strong) NSString *snsName;
@property (nonatomic,strong) NSString *fromSegue;
@property (nonatomic,strong) NSMutableArray *normalDataArr;
@property (nonatomic,strong) NSMutableArray *projectDataArr;
@property (nonatomic,strong) NSDictionary *snsInfoDic;

@property (nonatomic,weak) NSString *lastTaskNo;

@property int selectBoardKind;

@end
