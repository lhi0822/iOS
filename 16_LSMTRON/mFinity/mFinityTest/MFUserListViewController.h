//
//  MFUserListViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 5..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MFinityAppDelegate;
@interface MFUserListViewController : UIViewController<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,NSURLConnectionDataDelegate>{
    
    MFinityAppDelegate *appDelegate;
    
    NSMutableData *receiveData;
    NSMutableArray *searchUserInfoArray;
    NSMutableDictionary *userInfoDictionary;
    NSMutableDictionary *deptInfoDictionary;
    
    IBOutlet UISearchBar *_searchBar;
    IBOutlet UITableView *myTableView;
    
    BOOL searching;
    BOOL letUserSelectRow;
    BOOL isAll;
}
- (void)leftButtonClick:(UISegmentedControl *)sender;
- (void)rightButtonClick:(UISegmentedControl *)sender;
@end
