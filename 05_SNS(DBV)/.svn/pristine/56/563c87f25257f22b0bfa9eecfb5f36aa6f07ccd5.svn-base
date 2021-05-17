//
//  SearchViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 7..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFUtil.h"
#import "MFURLSession.h"
#import "AppDelegate.h"

#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "CollectionViewCell.h"
#import "UIDevice-Hardware.h"


@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFURLSessionDelegate, UIScrollViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UIGestureRecognizerDelegate>{
    int pPno;
    BOOL isRefresh;
    BOOL isDragging;
    UILabel                                 *lbRefreshTime;
    UIImageView                             *ivRefreshArrow;
    UIActivityIndicatorView                 *spRefresh;
    NSString                                *refreshTime;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic,weak) NSString *fromSegue;

@property (nonatomic, strong) NSString *DBName;
@property (nonatomic, strong) NSString *DBPath;

@property (nonatomic,weak) NSString *lastPostNo;
@property (nonatomic,weak) NSMutableArray *profileImgArray;
@property (nonatomic,weak) NSMutableArray *contentsImgArray;
@property (nonatomic,weak) NSMutableArray *timeArray;
@property (nonatomic,weak) NSMutableArray *writerNameArray;
@property (nonatomic,weak) NSMutableArray *descriptionArray;
@property (nonatomic,weak) NSMutableArray *cardSizeArray;
@property (nonatomic,weak) NSMutableArray *snsNameArray;

@property (nonatomic,strong) NSMutableArray *boardDataSetArray;
@property (nonatomic,strong) NSMutableArray *postDataSetArray;

@property (nonatomic,strong) NSString *snsNo;
@property (nonatomic,strong) NSString *snsName;
@property (nonatomic,assign) BOOL isBoard;

//-(void)callGetPostList:(NSString *)searchText;

@property (strong, nonatomic) NSMutableArray *chatArray;
@property (strong, nonatomic) NSMutableArray *tempArr;

@property (nonatomic,strong) NSMutableArray *boardImgArr;

@end
