//
//  ProfileFileViewController.h
//  mfinity_sns
//
//  Created by hilee on 02/04/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSegmentPageController.h"
#import "AppDelegate.h"
#import "MFURLSession.h"

@interface ProfileFileViewController : UICollectionViewController <ARSegmentControllerDelegate, MFURLSessionDelegate>

@property (nonatomic,weak) NSString *lastPostNo;
@property (nonatomic,strong) NSMutableArray *dataSetArray;
@property (strong,nonatomic) NSString *userNo;
@property (strong,nonatomic) NSString *userNm;

@end
