/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller displaying a grid of assets.
 */

#import "AAPLAssetGridViewController.h"
#import "AAPLGridViewCell.h"
#import "AAPLAssetViewController.h"
#import "NSIndexSet+Convenience.h"
#import "UICollectionView+Convenience.h"
#import "JTSImageViewController.h"
#import "MFUtil.h"

@import PhotosUI;

@interface AAPLAssetGridViewController () <PHPhotoLibraryChangeObserver>{
    int selectCount;
}
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;
@end


@implementation AAPLAssetGridViewController

static NSString * const CellReuseIdentifier = @"Cell";
static CGSize AssetGridThumbnailSize;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    @try{
        self.imageManager = [[PHCachingImageManager alloc] init];
        [self resetCachedAssets];
        selectCount = 0;
        self.imageArray = [NSMutableArray array];
        self.buttonArray = [NSMutableArray array];
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)rightSideMenuButtonPressed:(id)sender {
    //NSLog(@"buttonArray : %@",self.buttonArray);
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    @try{
        NSLog();
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"popup_camera2", @"popup_camera2")];
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"올리기", @"올리기")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(rightSideMenuButtonPressed:)];
        self.navigationItem.rightBarButtonItems = @[rightButton];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    @try{
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
        AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
        
        // Add button to the navigation bar if the asset collection supports adding content.
        if (!self.assetCollection || [self.assetCollection canPerformEditOperation:PHCollectionEditOperationAddContent]) {
            self.navigationItem.rightBarButtonItem = self.addButton;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Begin caching assets in and around collection view's visible rect.
    [self updateCachedAssets];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Configure the destination AAPLAssetViewController.
    if ([segue.destinationViewController isKindOfClass:[AAPLAssetViewController class]]) {
        @try{
            AAPLAssetViewController *assetViewController = segue.destinationViewController;
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
            assetViewController.asset = self.assetsFetchResults[indexPath.item];
            assetViewController.assetCollection = self.assetCollection;
            
        } @catch(NSException *exception){
            NSLog(@"Exception : %@", exception);
        }
    }
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    @try{
        // Check if there are changes to the assets we are showing.
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
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    @try{
        //PHAsset *asset = self.assetsFetchResults[indexPath.item];
        PHAsset *asset = self.assetsFetchResults[(self.assetsFetchResults.count-1)-indexPath.item];
        // Dequeue an AAPLGridViewCell.
        AAPLGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
        cell.representedAssetIdentifier = asset.localIdentifier;
        [cell.selectButton addTarget:self action:@selector(touchedSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        /*
         // Add a badge to the cell if the PHAsset represents a Live Photo.
         if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
         // Add Badge Image to the cell to denote that the asset is a Live Photo.
         UIImage *badge = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
         cell.livePhotoBadgeImage = badge;
         }
         */
        [self.imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                      if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                          cell.thumbnailImage = result;
                                      }
                                  }];
        
        return cell;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
-(void)touchedSelectButton:(UIButton *)sender{
    UIButton *button = sender;
    int buttonIndex=0;
    BOOL isAlready = NO;
    
    @try{
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
            [button setTitle:[NSString stringWithFormat:@"%ld",self.buttonArray.count] forState:UIControlStateNormal];
            
        }else{
            button.backgroundColor = [UIColor blackColor];
            [button setTitle:@"B" forState:UIControlStateNormal];
            for (int i=0; i<self.buttonArray.count; i++) {
                UIButton *tmp = self.buttonArray[i];
                if (i>=buttonIndex) {
                    NSString *index = tmp.titleLabel.text;
                    [tmp setTitle:[NSString stringWithFormat:@"%d",[index intValue]-1] forState:UIControlStateNormal];
                }
            }
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * scale, CGRectGetHeight(self.view.bounds) * scale);
    return targetSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    @try{
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
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    @try{
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
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
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

#pragma mark - Actions

- (IBAction)handleAddButtonItem:(id)sender {
    // Create a random dummy image.
    CGRect rect = rand() % 2 == 0 ? CGRectMake(0, 0, 400, 300) : CGRectMake(0, 0, 300, 400);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0f);
    [[UIColor colorWithHue:(float)(rand() % 100) / 100 saturation:1.0 brightness:1.0 alpha:1.0] setFill];
    UIRectFillUsingBlendMode(rect, kCGBlendModeNormal);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Add it to the photo library
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        if (self.assetCollection) {
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
            [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error creating asset: %@", error);
        }
    }];
}

@end


