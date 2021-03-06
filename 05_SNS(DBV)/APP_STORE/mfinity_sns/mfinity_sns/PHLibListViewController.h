//
//  MFPHLibListViewController.h
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 8. 31..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "MFUtil.h"
#import "PHLibGridViewController.h"
#import "MFPhotoLibTableViewCell.h"

@interface PHLibListViewController : UITableViewController<PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSMutableArray *sectionFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) NSString *mediaType;

@property (nonatomic, strong) NSString *fromSegue;
@property (nonatomic, strong) NSString *listType;

@end
