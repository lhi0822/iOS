//
//  ProfileCommViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 11. 23..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSegmentPageController.h"
#import "AppDelegate.h"
#import "MFURLSession.h"

@interface ProfileCommViewController : UITableViewController<ARSegmentControllerDelegate, MFURLSessionDelegate>

@property (nonatomic,weak) NSString *lastPostNo;
@property (nonatomic,strong) NSMutableArray *dataSetArray;
@property (strong,nonatomic) NSString *userNo;
@property (strong,nonatomic) NSString *userNm;

@end
