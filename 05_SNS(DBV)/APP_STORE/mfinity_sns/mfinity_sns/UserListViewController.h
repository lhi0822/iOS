//
//  UserListViewController.h
//  mfinity_sns
//
//  Created by hilee on 2018. 2. 23..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MFURLSession.h"

@interface UserListViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MFURLSessionDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

@property (nonatomic, strong)NSString *fromSegue;
@property (nonatomic, strong)NSMutableArray *existUserArr;

@property (nonatomic, strong)NSString *roomNo;
@property (nonatomic, strong)NSArray *userArr;
@property (nonatomic, strong)NSString *snsName;

@property (nonatomic,weak) NSString *stSeq;

@property (nonatomic, strong) NSMutableArray *dataSetArray;
@property (nonatomic, strong) NSMutableArray *checkArray;
@property (nonatomic, strong)NSMutableDictionary *rowCheckDictionary;

@end
