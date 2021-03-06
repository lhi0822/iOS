//
//  ProfilePostViewController.h
//  ARSegmentPager
//
//  Created by August on 15/3/28.
//  Copyright (c) 2015年 August. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSegmentPageController.h"
#import "AppDelegate.h"
#import "MFURLSession.h"
#import "NewsFeedViewCell.h"

#import "TTTAttributedLabel.h"

@interface ProfilePostViewController : UITableViewController<ARSegmentControllerDelegate, MFURLSessionDelegate, TTTAttributedLabelDelegate>

@property (nonatomic,weak) NSString *lastPostNo;
@property (nonatomic,strong) NSMutableArray *dataSetArray;
@property (strong,nonatomic) NSString *userNo;
@property (strong,nonatomic) NSString *userNm;
@property (strong,nonatomic) NSString *userImgPath;

@end
