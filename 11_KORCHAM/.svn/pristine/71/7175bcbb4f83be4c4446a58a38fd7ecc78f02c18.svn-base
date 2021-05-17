//
//  MFPHLibGirdViewController.m
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 9. 1..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFPHLibGridViewController.h"
#import "MFPHLibGridCell.h"
@interface MFPHLibGridViewController ()
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSMutableArray *imageArray;

@end

@implementation MFPHLibGridViewController

static NSString * const reuseIdentifier = @"MFPHLibGridCell";
static CGSize AssetGridThumbnailSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[MFPHLibGridCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MFPHLibGridCell" bundle:nil] forCellWithReuseIdentifier:@"MFPHLibGridCell"];
    // Do any additional setup after loading the view.
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    selectCount = 0;
    self.imageArray = [NSMutableArray array];
    self.buttonArray = [NSMutableArray array];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    titleLabel.text =  NSLocalizedString(@"사진 올리기", @"사진 올리기");
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    

    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"첨부   ", @"첨부   ")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(rightSideMenuButtonPressed:)];

}
-(void)rightSideMenuButtonPressed:(id)sender {
    for(UIButton *button in self.buttonArray){
        PHAsset *asset = self.assetsFetchResults[button.tag];
        NSLog(@"asset : %@",asset);
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.synchronous = YES;
        option.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
            //this block will be called synchronously
            [self.imageArray addObject:result];
        }];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:self.imageArray forKey:@"IMG_LIST"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getImageNotification"
                                                            object:nil
                                                          userInfo:userInfo];
        
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateCachedAssets];
}
-(void)dealloc{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"self.assetsFetchResults.count : %ld",(unsigned long)self.assetsFetchResults.count);
    return self.assetsFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   PHAsset *asset = self.assetsFetchResults[(self.assetsFetchResults.count-1)-indexPath.item];
    
    MFPHLibGridCell *cell = (MFPHLibGridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectButton.tag = (self.assetsFetchResults.count-1)-indexPath.item;
    [cell.selectButton addTarget:self action:@selector(touchedSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    cell.representedAssetIdentifier = asset.localIdentifier;
        // Request an image for the asset from the PHCachingImageManager.
    [self.imageManager requestImageForAsset:asset
                                 targetSize:AssetGridThumbnailSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  // Set the cell's thumbnail image if it's still showing the same asset.
                                  if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                      cell.thumbnailImage = result;
                                  }
                              }];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *asset = self.assetsFetchResults[(self.assetsFetchResults.count-1)-indexPath.item];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (!result) {
            return;
        }
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.image = result;
        JTSImageViewController *jtsImageViewer = [[JTSImageViewController alloc]
                                                  initWithImageInfo:imageInfo
                                                  mode:JTSImageViewControllerMode_Image
                                                  backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        
        
        [jtsImageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
        
    }];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */
- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * scale, CGRectGetHeight(self.view.bounds) * scale);
    return targetSize;
}


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    //return CGSizeMake(106, 106);
    return CGSizeMake(screenWidth/3, screenWidth/3);
}

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */
#pragma mark - <PHPhotoLibraryChangeObserver>
-(void)photoLibraryDidChange:(PHChange *)changeInstance{
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges == nil) {
        return;
    }
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        
        UICollectionView *collectionView = self.collectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
            // Reload the collection view if the incremental diffs are not available
            [collectionView reloadData];
            
        } else {
            /*
             Tell the collection view to animate insertions and deletions if we
             have incremental diffs.
             */
            [collectionView performBatchUpdates:^{
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
            } completion:NULL];
        }
        
        [self resetCachedAssets];
    });
}
- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}
- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}
- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}
- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }
    
    return assets;
}
-(void)touchedSelectButton:(UIButton *)sender{
    UIButton *button = sender;
    int buttonIndex=0;
    BOOL isAlready = NO;
    
    for (int i=0; i<self.buttonArray.count; i++) {
        if ([self.buttonArray[i] isEqual:sender]) {
            [self.buttonArray removeObject:sender];
            isAlready = YES;
            buttonIndex = i;
        }
    }
    
    if (!isAlready) {
        if (self.buttonArray.count>0) {
            UIButton *tmpButton = self.buttonArray[0];
            tmpButton.backgroundColor = [UIColor blackColor];
            [self.buttonArray removeAllObjects];
            
        }
            [self.buttonArray addObject:sender];
            button.backgroundColor = [UIColor redColor];
        
        
    }else{
        button.backgroundColor = [UIColor blackColor];
    }
    
    /*
    for (int i=0; i<self.buttonArray.count; i++) {
        if ([self.buttonArray[i] isEqual:sender]) {
            [self.buttonArray removeObject:sender];
            isAlready = YES;
            buttonIndex = i;
        }
    }
    if (!isAlready) {
   
        [self.buttonArray addObject:sender];
        button.backgroundColor = [UIColor redColor];
        //[button setTitle:[NSString stringWithFormat:@"%ld",(unsigned long)self.buttonArray.count] forState:UIControlStateNormal];
        
    }else{
        button.backgroundColor = [UIColor blackColor];
        //[button setTitle:@"B" forState:UIControlStateNormal];
        for (int i=0; i<self.buttonArray.count; i++) {
            UIButton *tmp = self.buttonArray[i];
            if (i>=buttonIndex) {
                NSString *index = tmp.titleLabel.text;
                [tmp setTitle:[NSString stringWithFormat:@"%d",[index intValue]-1] forState:UIControlStateNormal];
            }
        }
    }
    */
    
    
    self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%ld",(unsigned long)self.buttonArray.count];
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}

@end
