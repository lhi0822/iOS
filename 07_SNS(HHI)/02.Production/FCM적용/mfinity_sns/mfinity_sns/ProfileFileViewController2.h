//
//  ProfileFileViewController2.h
//  mfinity_sns
//
//  Created by hilee on 2017. 10. 13..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchTableViewCell.h"
#import "AppDelegate.h"
#import "MFURLSession.h"

@interface ProfileFileViewController2 : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, MFURLSessionDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,weak) NSString *lastPostNo;
@property (nonatomic,strong) NSMutableArray *dataSetArray;
@property (strong,nonatomic) NSString *userNo;
@property (strong,nonatomic) NSString *userNm;

@end
