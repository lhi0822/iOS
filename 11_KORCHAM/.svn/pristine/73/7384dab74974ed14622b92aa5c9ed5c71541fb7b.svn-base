//
//  MFPHLibGirdViewController.h
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 9. 1..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "JTSImageViewController.h"
#import "NSIndexSet+Convenience.h"
#import "UICollectionView+Convenience.h"
#import "UIBarButtonItem+Badge.h"
@interface MFPHLibGridViewController : UICollectionViewController<PHPhotoLibraryChangeObserver>{
    int selectCount;
}
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;
@end
