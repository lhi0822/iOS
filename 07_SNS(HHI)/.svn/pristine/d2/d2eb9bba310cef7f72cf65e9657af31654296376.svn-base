//
//  DeptListViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 13..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFUtil.h"
#import "MFURLSession.h"
#import "AppDelegate.h"

//#import "STCollapseTableView.h"
#import "SVProgressHUD.h"
#import "ChatUserListCell.h"

#import <sqlite3.h>

@interface DeptListViewController : UIViewController <UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, MFURLSessionDelegate, UIAlertViewDelegate> {
    
}

@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSString *deptNo;
@property (nonatomic, strong)NSMutableArray *sectionArray;
@property (nonatomic, strong)NSMutableDictionary *rowDictionary;
@property (nonatomic, strong)NSMutableArray *sectionsStates;
@property (nonatomic, strong)NSMutableDictionary *rowCheckDictionary;
@property (nonatomic, strong)NSMutableDictionary *sectionCheckDictionary;

@property (nonatomic, strong)NSMutableDictionary *testDic;
@property (nonatomic, strong)NSMutableDictionary *testDic2;
@property (nonatomic, strong)NSMutableDictionary *testRowDic;

@property (nonatomic, assign)BOOL exclusiveSections;
@property (nonatomic, assign)BOOL shouldHandleHeadersTap;


@property (nonatomic, strong)NSMutableArray *dataSetArray;
@property (nonatomic, strong)NSMutableArray *dataSetViewArray;
@property (nonatomic, strong)NSMutableDictionary *dataSetDictionary;
@property (nonatomic, strong)NSMutableArray *arrowArray;
@property (nonatomic, strong)NSMutableArray *checkArray;

@property (nonatomic, strong)NSString *searchText;

@property (nonatomic, strong)NSString *fromSegue;
@property (nonatomic, strong)NSString *roomNo;
@property (nonatomic, strong)NSArray *userArr;
@property (nonatomic, strong)NSString *snsName;

@property (nonatomic, strong)NSMutableArray *existUserArr;

@end
