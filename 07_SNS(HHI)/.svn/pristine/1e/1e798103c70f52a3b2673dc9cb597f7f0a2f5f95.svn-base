//
//  NewsFeedViewController.h
//  mfinity_sns
//
//  Created by hilee on 31/01/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>

#import "AppDelegate.h"
#import "MFUtil.h"
#import "MFURLSession.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "UIDevice-Hardware.h"

#import "TeamListViewController.h"
#import "PostWriteTableViewController.h"
#import "ChatListViewController.h"
#import "ChatViewController.h"
#import "RightSideViewController.h"
#import "VCFloatingActionButton.h"
#import <sqlite3.h>
#import "SDWebImageManager.h"

#import "NewsFeedViewCell.h"
#import "TTTAttributedLabel.h"


@interface NewsFeedViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,MFURLSessionDelegate,UIScrollViewDelegate,UITextFieldDelegate, floatMenuDelegate, UITableViewDataSourcePrefetching, NSURLSessionDelegate, TTTAttributedLabelDelegate> {
    BOOL isRefresh;
    BOOL isDragging;
    
    NSUInteger taskId;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

//@property (strong, nonatomic) NewsFeedViewCell *feedCell;

@property (strong, nonatomic) IBOutlet UIView *segContainer;
@property (strong, nonatomic) IBOutlet UISegmentedControl *boardSegment;
@property int selectBoardKind;

@property (nonatomic,weak) NSString *lastPostNo;
@property (nonatomic,weak) NSString *lastTaskNo;

@property (nonatomic,weak) NSMutableArray *profileImgArray;
@property (nonatomic,weak) NSMutableArray *contentsImgArray;
@property (nonatomic,weak) NSMutableArray *timeArray;
@property (nonatomic,weak) NSMutableArray *writerNameArray;
@property (nonatomic,weak) NSMutableArray *descriptionArray;
@property (nonatomic,weak) NSMutableArray *cardSizeArray;
@property (nonatomic,weak) NSMutableArray *snsNameArray;

@property (nonatomic,strong) NSMutableArray *normalDataArray;
@property (nonatomic,strong) NSMutableArray *projectDataArray;

@property (strong, nonatomic) IBOutlet UIView *postNewView;

@property (nonatomic,strong) NSDictionary *pushPostDic;
@property (nonatomic,strong) NSDictionary *pushChatDic;

@property (nonatomic,strong) NSString *snsNo;
@property (nonatomic,strong) NSString *snsName;
@property (nonatomic,assign) BOOL isBoard;

@property (nonatomic,strong) NSString *fromSegue;
@property (nonatomic,strong) NSDictionary *pushDict;

@property (nonatomic) CGFloat lastContentOffset;

@property (nonatomic, weak) id<SDWebImageOperation> webImageOperation;

@end

