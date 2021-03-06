//
//  PHLibGirdViewController.m
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 9. 1..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "PHLibGridViewController.h"
#import "PostDetailViewController.h"
#import "AppDelegate.h"

@interface MFPHLibGridViewController () {
    NSString *orgFilename;
    NSInteger currentSelectedIndex;
    UIButton *currentBtn;
    AppDelegate *appDelegate;
    int imgCnt;
}
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *assetArray;
@property (nonatomic, strong) NSMutableArray *tmpButtonArray;



@end

@implementation MFPHLibGridViewController

static NSString * const reuseIdentifier = @"MFPHLibGridCell";
static CGSize AssetGridThumbnailSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"####gridType : %@", self.gridType);
    
    @try{
        [self.collectionView registerNib:[UINib nibWithNibName:@"MFPHLibGridCell" bundle:nil] forCellWithReuseIdentifier:@"MFPHLibGridCell"];
        // Do any additional setup after loading the view.
        self.imageManager = [[PHCachingImageManager alloc] init];
        [self resetCachedAssets];
        selectCount = 0;
        self.imageArray = [NSMutableArray array];
        self.buttonArray = [NSMutableArray array];
        self.tmpButtonArray = [NSMutableArray array];
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        if([self.gridType isEqualToString:@"PHOTO"]){
            self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"popup_camera2", @"popup_camera2")];
        } else if([self.gridType isEqualToString:@"VIDEO"]){
            self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"popup_video2", @"popup_video2")];
        }
        
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"done", @"done")
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(rightSideMenuButtonPressed:)];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_NewPostPush:(NSNotification *)notification {
    if(notification.userInfo!=nil){
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
        
        @try{
            NSString *message = [notification.userInfo objectForKey:@"MESSAGE"];
            NSDictionary *dict = [NSDictionary dictionary];
            if(message!=nil){
                NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            } else {
                dict = notification.userInfo;
            }
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PostDetailViewController *vc = (PostDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            vc.fromSegue = @"NOTI_POST_DETAIL";
            vc.notiPostDic = dict;
            [self presentViewController:nav animated:YES completion:nil];
            
        } @catch(NSException *exception){
            NSLog(@"Exception : %@", exception);
        }
    }
    appDelegate.inactivePostPushInfo=nil;
}

-(void)rightSideMenuButtonPressed:(id)sender {
    self.assetArray = [NSMutableArray array];
    imgCnt = 0;
    NSLog(@"tmpButtonArray(%lu) : %@", self.tmpButtonArray.count, self.tmpButtonArray);
    
    @try{
        int count = (int)self.tmpButtonArray.count;
        for(int i=0; i<self.tmpButtonArray.count; i++){
            self.useAsset = [self.tmpButtonArray objectAtIndex:i];
            [self.assetArray addObject:self.useAsset];
            
            PHImageRequestOptions *option = [PHImageRequestOptions new];
            option.synchronous = YES;
            option.networkAccessAllowed = YES;
            
            //targetSize를 viewSize로 주니 빠름
            [[PHImageManager defaultManager] requestImageForAsset:self.useAsset targetSize:self.view.frame.size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
                if(result){
                    imgCnt++;
                    [self.imageArray addObject:result];
                } else {
                    NSLog(@"리턴 이미지 없음");
                }
                
                if(imgCnt==count){
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:self.imageArray forKey:@"IMG_LIST"];
                    [userInfo setObject:self.assetArray forKey:@"ASSET_LIST"];
                    [userInfo setObject:@"0" forKey:@"ASSET_ALLOC"];
                    
//                    NSLog(@"image userInfo : %@", userInfo);
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        self.imageArray = [NSMutableArray array];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getImageNotification" object:nil userInfo:userInfo];
                    }];
                }
                
            }];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    //    self.gridImgArr = [NSMutableArray array];
    //
    //    for(int i=0; i<self.assetsFetchResults.count; i++){
    //        PHAsset *asset = self.assetsFetchResults[i];
    //
    //        float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    //        if (ver >= 9.0) {
    //            NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
    //            orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    //        } else {
    //            PHImageRequestOptions *option = [PHImageRequestOptions new];
    //            option.synchronous = YES;
    //            option.networkAccessAllowed = YES;
    //            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
    //                NSURL* fileURL = [info objectForKey:@"PHImageFileURLKey"];
    //                orgFilename = [[NSFileManager defaultManager] displayNameAtPath:[fileURL path]];
    //            }];
    //        }
    //
    //        //NSLog(@"orgFilename : %@", orgFilename);
    //
    //        NSRange range = [orgFilename rangeOfString:@"." options:NSBackwardsSearch];
    //        NSString *fileExt = [[orgFilename substringFromIndex:range.location+1] lowercaseString];
    //
    //        if([fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"jpeg"]){
    //            [self.gridImgArr addObject:asset];
    //        }
    //    }
    
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

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    @try{
        PHAsset *asset = self.assetsFetchResults[(self.assetsFetchResults.count-1)-indexPath.item];
        //NSLog(@"asset : %@", asset);
        
        //        NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
        //        [resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //            PHAssetResource *resource = obj;
        //
        //            NSRange range = [resource.uniformTypeIdentifier rangeOfString:@"." options:NSBackwardsSearch];
        //            NSString *fileExt = [[resource.uniformTypeIdentifier substringFromIndex:range.location+1] lowercaseString];
        //
        //            if (asset.mediaType==PHAssetMediaTypeImage) {
        //                if([fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"jpeg"]){
        //
        //                }
        //            }
        //        }];
        
        //PHAsset *asset = self.gridImgArr[(self.gridImgArr.count-1)-indexPath.item];
        MFPHLibGridCell *cell = (MFPHLibGridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        //NSLog(@"gridType : %@", self.gridType);
        
        cell.selectButton.tag = 0;
        cell.selectImg.tag = 0;
        cell.borderView.tag = 0;
        cell.buttonView.tag = 0;
        cell.buttonView.gestureRecognizers = nil;
        
        if([self.gridType isEqualToString:@"PHOTO"]){
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            
            cell.selectButton.tag = [[NSString stringWithFormat:@"10%lu",(self.assetsFetchResults.count-1)-indexPath.item] integerValue];
            
            cell.selectImg.tag = [[NSString stringWithFormat:@"20%lu",(self.assetsFetchResults.count-1)-indexPath.item] integerValue];
            cell.borderView.tag = [[NSString stringWithFormat:@"30%lu",(self.assetsFetchResults.count-1)-indexPath.item] integerValue];
            
            cell.buttonView.tag = [[NSString stringWithFormat:@"40%lu",(self.assetsFetchResults.count-1)-indexPath.item] integerValue];
            [cell.buttonView setUserInteractionEnabled:YES];

            [cell.selectButton addTarget:self action:@selector(touchedSelectButton:) forControlEvents:UIControlEventTouchUpInside];
            [cell.buttonView addGestureRecognizer:tap];
            
            cell.timeLabel.textColor = [UIColor lightGrayColor];
            
             if([self.fromSegue isEqualToString:@"MY_PHLIB_MODAL"]||[self.fromSegue isEqualToString:@"BOARD_PHLIB_MODAL"]||[self.fromSegue isEqualToString:@"POST_DETAIL_PHLIB_MODAL"]){
                 [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                                   options:0
                                                             resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info){
                      float dataSize = ((CGFloat)imageData.length)/1024/1024;
                      if(dataSize<=20){
                          cell.selectButton.hidden = NO;
                          cell.timeLabel.hidden = YES;
                          cell.borderView.alpha = 1.0;
                          cell.borderView.backgroundColor = [UIColor clearColor];
                          cell.timeLabel.text = @"";
                          
                          for (int i=0; i<self.buttonArray.count; i++) {
                              if ([[self.buttonArray objectAtIndex:i] intValue] == [[[NSString stringWithFormat:@"%ld", cell.selectButton.tag] substringFromIndex:2] intValue] ) {
                                  cell.selectButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                                  [cell.selectButton setImage:[UIImage imageNamed:@"checkbox_blue.png"] forState:UIControlStateNormal];
                                  cell.selectButton.alpha = 1.0f;
                                  
                                  [cell.selectImg.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                                  [cell.selectImg.layer setBorderWidth: 2.0];
                                  
                                  cell.borderView.alpha = 1.0;
                                  cell.borderView.backgroundColor = [UIColor clearColor];
                                  [cell.borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                                  [cell.borderView.layer setBorderWidth: 2.0];
                                  //break;
                                  
                              } else{
                                  cell.selectButton.backgroundColor = [UIColor blackColor];
                                  [cell.selectButton setImage:nil forState:UIControlStateNormal];
                                  [cell.selectButton setTitle:nil forState:UIControlStateNormal];
                                  cell.selectButton.alpha = 0.5f;
                                  
                                  [cell.selectImg.layer setBorderColor: [[UIColor clearColor] CGColor]];
                                  [cell.selectImg.layer setBorderWidth: 0.0];
                                  
                                  cell.borderView.alpha = 1.0;
                                  cell.borderView.backgroundColor = [UIColor clearColor];
                                  [cell.borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                                  [cell.borderView.layer setBorderWidth: 0.0];
                              }
                          }
                      } else{
                          cell.timeLabel.hidden = NO;
                          cell.selectButton.hidden = YES;
                          [cell.selectButton removeTarget:self action:@selector(touchedSelectButton:) forControlEvents:UIControlEventAllEvents];
                          [cell.buttonView removeGestureRecognizer:tap];
    
                          cell.timeLabel.text = @"업로드용량초과";
                          
                          cell.borderView.alpha = 0.7;
                          cell.borderView.backgroundColor = [UIColor blackColor];
                          [cell.borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                          [cell.borderView.layer setBorderWidth: 0.0];
                      }
                  }];
                 
             } else {
                 [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                                   options:0
                                                             resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info){
                 float dataSize = ((CGFloat)imageData.length)/1024/1024;
                 
                 if(dataSize<=20){
                     cell.selectButton.hidden = NO;
                     cell.timeLabel.hidden = YES;
                     cell.borderView.alpha = 1.0;
                     cell.borderView.backgroundColor = [UIColor clearColor];
                     cell.timeLabel.text = @"";
                     
                     for (int i=0; i<self.buttonArray.count; i++) {
                         if ([[self.buttonArray objectAtIndex:i] intValue] == [[[NSString stringWithFormat:@"%ld", cell.selectButton.tag] substringFromIndex:2] intValue] ) {
                             cell.selectButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                             [cell.selectButton setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
                             cell.selectButton.alpha = 1.0f;
                             
                             [cell.selectImg.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                             [cell.selectImg.layer setBorderWidth: 2.0];
                             
                             cell.borderView.alpha = 1.0;
                             [cell.borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                             [cell.borderView.layer setBorderWidth: 2.0];
                             
                             break;
                             
                         } else{
                             cell.selectButton.backgroundColor = [UIColor blackColor];
                             [cell.selectButton setTitle:@"" forState:UIControlStateNormal];
                             cell.selectButton.alpha = 0.5f;
                             
                             [cell.selectImg.layer setBorderColor: [[UIColor clearColor] CGColor]];
                             [cell.selectImg.layer setBorderWidth: 0.0];
                             
                             cell.borderView.alpha = 1.0;
                             [cell.borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                             [cell.borderView.layer setBorderWidth: 0.0];
                         }
                     }
                 } else {
                     cell.timeLabel.hidden = NO;
                     cell.selectButton.hidden = YES;
                     [cell.selectButton removeTarget:self action:@selector(touchedSelectButton:) forControlEvents:UIControlEventAllEvents];
                     [cell.buttonView removeGestureRecognizer:tap];
                     
                     cell.timeLabel.text = @"업로드용량초과";
                     
                     cell.borderView.alpha = 0.7;
                     cell.borderView.backgroundColor = [UIColor blackColor];
                     [cell.borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                     [cell.borderView.layer setBorderWidth: 0.0];
                 }
               }];
                 
             }


        } else if([self.gridType isEqualToString:@"VIDEO"]){
            cell.timeLabel.hidden = NO;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            
            double videoTime = round(asset.duration);
            int seconds = (int)videoTime % 60;
            int minutes = (int)(videoTime / 60) % 60;
            int hours = videoTime / 3600;
            
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:0 resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @try {
                        NSURL *URL = [(AVURLAsset *)avAsset URL];
                        
                         NSData *data = [NSData dataWithContentsOfURL:URL];
//                         NSLog(@"비디오 크기 : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);
                         
                         float dataSize = ((CGFloat)data.length)/1024/1024;
                         if(dataSize<=80){
                             cell.selectButton.tag = [[NSString stringWithFormat:@"10%lu",(self.assetsFetchResults.count-1)-indexPath.item] integerValue];
                             
                             cell.selectImg.tag = [[NSString stringWithFormat:@"20%lu",(self.assetsFetchResults.count-1)-indexPath.item] integerValue];
                             cell.borderView.tag = [[NSString stringWithFormat:@"30%lu",(self.assetsFetchResults.count-1)-indexPath.item] integerValue];
                             
                             cell.buttonView.tag = [[NSString stringWithFormat:@"40%lu",(self.assetsFetchResults.count-1)-indexPath.item] integerValue];
                             [cell.buttonView setUserInteractionEnabled:YES];
                             [cell.buttonView addGestureRecognizer:tap];
                             
                             cell.selectButton.hidden = NO;
                             [cell.selectButton addTarget:self action:@selector(touchedSelectButton:) forControlEvents:UIControlEventTouchUpInside];
                             
                             cell.borderView.backgroundColor = [UIColor clearColor];
                             
                             cell.timeLabel.textColor = [UIColor whiteColor];
                             
                             if(hours<1){
                                 cell.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
                             } else {
                                 cell.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
                             }
                             
                             for (int i=0; i<self.buttonArray.count; i++) {
                                 if ([[self.buttonArray objectAtIndex:i] intValue] == [[[NSString stringWithFormat:@"%ld", cell.selectButton.tag] substringFromIndex:2] intValue] ) {
                                     cell.selectButton.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                                     [cell.selectButton setImage:[UIImage imageNamed:@"checkbox_blue.png"] forState:UIControlStateNormal];
                                     cell.selectButton.alpha = 1.0f;
                                     
                                     [cell.selectImg.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                                     [cell.selectImg.layer setBorderWidth: 2.0];
                                     
                                     cell.borderView.alpha = 1.0;
                                     cell.borderView.backgroundColor = [UIColor clearColor];
                                     [cell.borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                                     [cell.borderView.layer setBorderWidth: 2.0];
                                     //break;
                                 } else{
                                     cell.selectButton.backgroundColor = [UIColor blackColor];
                                     [cell.selectButton setImage:nil forState:UIControlStateNormal];
                                     [cell.selectButton setTitle:nil forState:UIControlStateNormal];
                                     cell.selectButton.alpha = 0.5f;
                                     
                                     [cell.selectImg.layer setBorderColor: [[UIColor clearColor] CGColor]];
                                     [cell.selectImg.layer setBorderWidth: 0.0];
                                     
                                     cell.borderView.alpha = 1.0;
                                     cell.borderView.backgroundColor = [UIColor clearColor];
                                     [cell.borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                                     [cell.borderView.layer setBorderWidth: 0.0];
                                 }
                             }
                         } else {
                             cell.selectButton.hidden = YES;
                             [cell.selectButton removeTarget:self action:@selector(touchedSelectButton:) forControlEvents:UIControlEventAllEvents];
                             [cell.buttonView removeGestureRecognizer:tap];
                             
                             cell.timeLabel.text = @"업로드용량초과";
                             cell.timeLabel.textColor = [UIColor lightGrayColor];
                             
                             cell.borderView.alpha = 0.7;
                             cell.borderView.backgroundColor = [UIColor blackColor];
                             [cell.borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                             [cell.borderView.layer setBorderWidth: 0.0];
                         }
                    } @catch (NSException *exception) {
                        NSLog(@"Exception : %@", exception);
                    }
                    
                });
            }];
        }
        
        cell.representedAssetIdentifier = asset.localIdentifier;
        // Request an image for the asset from the PHCachingImageManager.
        [self.imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      // Set the cell's thumbnail image if it's still showing the same asset.
                                      if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                          CGRect screen = [[UIScreen mainScreen]bounds];
                                          CGFloat screenWidth = screen.size.width;
                                          cell.thumbnailImage = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(screenWidth/3, screenWidth/3) :result];
                                      }
                                  }];
        
        return cell;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    @try{
        PHAsset *asset = self.assetsFetchResults[(self.assetsFetchResults.count-1)-indexPath.item];
        //PHAsset *asset = self.gridImgArr[(self.gridImgArr.count-1)-indexPath.item];
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
            
            jtsImageViewer.modalPresentationStyle = UIModalPresentationFullScreen;
            [jtsImageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
        }];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark <UICollectionViewDelegate>
- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    //CGSize targetSize;
    //dispatch_async(dispatch_get_main_queue(), ^{
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * scale, CGRectGetHeight(self.view.bounds) * scale);
    
    //});
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
    //PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:(PHFetchResult *)self.gridImgArr];
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
        //self.gridImgArr = (NSMutableArray *)[collectionChanges fetchResultAfterChanges];
        
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
        //PHAsset *asset = self.gridImgArr[indexPath.item];
        [assets addObject:asset];
    }
    
    return assets;
}

- (void)handleTapGesture:(UITapGestureRecognizer*)tap {
    NSInteger index = [[[NSString stringWithFormat:@"%ld", tap.view.tag] substringFromIndex:2] integerValue];
    //UIButton *button = (UIButton *)[self.collectionView viewWithTag:index];
    
    UIButton *button = (UIButton *)[self.collectionView viewWithTag:[[NSString stringWithFormat:@"10%ld", (long)index] integerValue]];
    [self touchedSelectButton:button];
}

-(void)touchedSelectButton:(UIButton *)sender{
    @try{
        UIButton *button = sender;
        NSNumber *buttonTag = [NSNumber numberWithInteger:[[[NSString stringWithFormat:@"%ld", sender.tag] substringFromIndex:2] integerValue]];
        
        orgFilename = nil;
        PHAsset *asset = self.assetsFetchResults[[buttonTag integerValue]];
        NSLog(@"셀렉트 했을 때 ASSET : %@", asset);
        
        float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (ver >= 9.0) {
            NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
            orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
        } else {
            PHImageRequestOptions *option = [PHImageRequestOptions new];
            option.synchronous = YES;
            option.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
                NSURL* fileURL = [info objectForKey:@"PHImageFileURLKey"];
                orgFilename = [[NSFileManager defaultManager] displayNameAtPath:[fileURL path]];
            }];
        }
        
        int buttonIndex=0;
        BOOL isAlready = NO;
        for (int i=0; i<self.buttonArray.count; i++) {
            if ([[self.buttonArray objectAtIndex:i] isEqual:buttonTag]) {
                [self.buttonArray removeObject:buttonTag];
                [self.tmpButtonArray removeObject:asset];
                
                isAlready = YES;
                buttonIndex = i;
            }
        }
        
        if([self.fromSegue isEqualToString:@"MY_PHLIB_MODAL"]||[self.fromSegue isEqualToString:@"BOARD_PHLIB_MODAL"]){
            [self.buttonArray addObject:buttonTag];
            self.tmpButtonArray = [[NSMutableArray alloc] initWithObjects:asset, nil];
            
            button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
            [button setImage:[UIImage imageNamed:@"checkbox_blue.png"] forState:UIControlStateNormal];
            button.alpha = 1.0f;
            
            UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",buttonTag] integerValue]];
            borderView.alpha = 1.0;
            [borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
            [borderView.layer setBorderWidth: 2.0];
            
            if([self.gridType isEqualToString:@"PHOTO"]){
                for (int i=0; i<self.buttonArray.count-1; i++) {
                    UIButton *tmp = (UIButton *)[self.collectionView viewWithTag:[[NSString stringWithFormat:@"10%@", [self.buttonArray objectAtIndex:i]] integerValue]];
                    //NSLog(@"tmp : %@", tmp);
                    tmp.backgroundColor = [UIColor blackColor];
                    [tmp setImage:nil forState:UIControlStateNormal];
                    [tmp setTitle:nil forState:UIControlStateNormal];
                    tmp.alpha = 0.5f;
                    
                    UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",[self.buttonArray objectAtIndex:i]] integerValue]];
                    borderView.alpha = 1.0;
                    [borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                    [borderView.layer setBorderWidth: 0.0];
                }
                
            } else if([self.gridType isEqualToString:@"VIDEO"]){
                
            }
            
        } else if([self.fromSegue isEqualToString:@"CHAT_PHLIB_MODAL"]){
            if([self.gridType isEqualToString:@"PHOTO"]){
                if(self.buttonArray.count < 5){
                    if (!isAlready) {
                        [self.buttonArray addObject:buttonTag];
                        [self.tmpButtonArray addObject:asset];
                        
                        button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                        [button setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.buttonArray.count] forState:UIControlStateNormal];
                        button.alpha = 1.0f;
                        
                        UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",buttonTag] integerValue]];
                        borderView.tag = [[NSString stringWithFormat:@"30%@",buttonTag] integerValue];
                        borderView.alpha = 1.0;
                        [borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                        [borderView.layer setBorderWidth: 2.0];
                        
                    } else{
                        button.backgroundColor = [UIColor blackColor];
                        [button setTitle:@"" forState:UIControlStateNormal];
                        button.alpha = 0.5f;
                        
                        UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",buttonTag] integerValue]];
                        //NSLog(@"해제했을때 : %@", borderView);
                        borderView.tag = [[NSString stringWithFormat:@"30%@",buttonTag] integerValue];
                        borderView.alpha = 1.0;
                        [borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                        [borderView.layer setBorderWidth: 0.0];
                        
                        for (int i=0; i<self.buttonArray.count; i++) {
                            UIButton *tmp = (UIButton *)[self.collectionView viewWithTag:[[NSString stringWithFormat:@"10%@", [self.buttonArray objectAtIndex:i]] integerValue]];
                            
                            if (i>=buttonIndex) {
                                NSString *index = tmp.titleLabel.text;
                                [tmp setTitle:[NSString stringWithFormat:@"%d", [index intValue]-1] forState:UIControlStateNormal];
                            }
                        }
                    }
                    
                } else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"사진은 한번에 최대 5장까지 선택할 수 있습니다.", @"사진은 한번에 최대 5장까지 선택할 수 있습니다.") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            } else if([self.gridType isEqualToString:@"VIDEO"]){
                [self.buttonArray addObject:buttonTag];
                self.tmpButtonArray = [[NSMutableArray alloc] initWithObjects:asset, nil];
                
                button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                [button setImage:[UIImage imageNamed:@"checkbox_blue.png"] forState:UIControlStateNormal];
                button.alpha = 1.0f;
                
                UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",buttonTag] integerValue]];
                borderView.alpha = 1.0;
                [borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                [borderView.layer setBorderWidth: 2.0];
                
                for (int i=0; i<self.buttonArray.count-1; i++) {
                    UIButton *tmp = (UIButton *)[self.collectionView viewWithTag:[[NSString stringWithFormat:@"10%@", [self.buttonArray objectAtIndex:i]] integerValue]];
                    //NSLog(@"tmp : %@", tmp);
                    tmp.backgroundColor = [UIColor blackColor];
                    [tmp setImage:nil forState:UIControlStateNormal];
                    [tmp setTitle:nil forState:UIControlStateNormal];
                    tmp.alpha = 0.5f;
                    
                    UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",[self.buttonArray objectAtIndex:i]] integerValue]];
                    borderView.alpha = 1.0;
                    [borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                    [borderView.layer setBorderWidth: 0.0];
                }
            }
        } else if([self.fromSegue isEqualToString:@"TASK_PHLIB_MODAL"]){
            if([self.gridType isEqualToString:@"PHOTO"]){
                if(self.buttonArray.count < 5){
                    if (!isAlready) {
                        [self.buttonArray addObject:buttonTag];
                        [self.tmpButtonArray addObject:asset];
                        
                        button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                        [button setTitle:[NSString stringWithFormat:@"%ld",self.buttonArray.count] forState:UIControlStateNormal];
                        button.alpha = 1.0f;
                        
                        UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",buttonTag] integerValue]];
                        borderView.alpha = 1.0;
                        [borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                        [borderView.layer setBorderWidth: 2.0];
                        
                    } else{
                        button.backgroundColor = [UIColor blackColor];
                        [button setTitle:@"" forState:UIControlStateNormal];
                        button.alpha = 0.5f;
                        
                        UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",buttonTag] integerValue]];
                        borderView.alpha = 1.0;
                        [borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                        [borderView.layer setBorderWidth: 0.0];
                        
                        for (int i=0; i<self.buttonArray.count; i++) {
                            UIButton *tmp = (UIButton *)[self.collectionView viewWithTag:[[NSString stringWithFormat:@"10%@", [self.buttonArray objectAtIndex:i]] integerValue]];
                            
                            if (i>=buttonIndex) {
                                NSString *index = tmp.titleLabel.text;
                                [tmp setTitle:[NSString stringWithFormat:@"%d", [index intValue]-1] forState:UIControlStateNormal];
                            }
                        }
                    }
                    
                } else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"첨부파일은 한번에 최대 5개까지 선택할 수 있습니다.", @"첨부파일은 한번에 최대 5개까지 선택할 수 있습니다.") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            } else if([self.gridType isEqualToString:@"VIDEO"]){
                [self.buttonArray addObject:buttonTag];
                self.tmpButtonArray = [[NSMutableArray alloc] initWithObjects:asset, nil];
                
                button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                [button setImage:[UIImage imageNamed:@"checkbox_blue.png"] forState:UIControlStateNormal];
                button.alpha = 1.0f;
                
                UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",buttonTag] integerValue]];
                borderView.alpha = 1.0;
                [borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                [borderView.layer setBorderWidth: 2.0];
                
                for (int i=0; i<self.buttonArray.count-1; i++) {
                    UIButton *tmp = (UIButton *)[self.collectionView viewWithTag:[[NSString stringWithFormat:@"10%@", [self.buttonArray objectAtIndex:i]] integerValue]];
                    //NSLog(@"tmp : %@", tmp);
                    tmp.backgroundColor = [UIColor blackColor];
                    [tmp setImage:nil forState:UIControlStateNormal];
                    [tmp setTitle:nil forState:UIControlStateNormal];
                    tmp.alpha = 0.5f;
                    
                    UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",[self.buttonArray objectAtIndex:i]] integerValue]];
                    borderView.alpha = 1.0;
                    [borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                    [borderView.layer setBorderWidth: 0.0];
                }
            }
            
        } else if([self.fromSegue isEqualToString:@"POST_DETAIL_PHLIB_MODAL"]){
            if([self.gridType isEqualToString:@"PHOTO"]){
                [self.buttonArray addObject:buttonTag];
                self.tmpButtonArray = [[NSMutableArray alloc] initWithObjects:asset, nil];
                
                button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                [button setImage:[UIImage imageNamed:@"checkbox_blue.png"] forState:UIControlStateNormal];
                button.alpha = 1.0f;
                
                UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",buttonTag] integerValue]];
                borderView.alpha = 1.0;
                borderView.backgroundColor = [UIColor clearColor];
                [borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                [borderView.layer setBorderWidth: 2.0];
                
                for (int i=0; i<self.buttonArray.count-1; i++) {
                    UIButton *tmp = (UIButton *)[self.collectionView viewWithTag:[[NSString stringWithFormat:@"10%@", [self.buttonArray objectAtIndex:i]] integerValue]];
                    //NSLog(@"tmp : %@", tmp);
                    tmp.backgroundColor = [UIColor blackColor];
                    [tmp setImage:nil forState:UIControlStateNormal];
                    [tmp setTitle:nil forState:UIControlStateNormal];
                    tmp.alpha = 0.5f;
                    
                    UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",[self.buttonArray objectAtIndex:i]] integerValue]];
                    borderView.alpha = 1.0;
                    //borderView.backgroundColor = [UIColor blackColor];
                    [borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                    [borderView.layer setBorderWidth: 0.0];
                    
                }
                
            } else if([self.gridType isEqualToString:@"VIDEO"]){
                [self.buttonArray addObject:buttonTag];
                self.tmpButtonArray = [[NSMutableArray alloc] initWithObjects:asset, nil];
                
                button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                [button setImage:[UIImage imageNamed:@"checkbox_blue.png"] forState:UIControlStateNormal];
                button.alpha = 1.0f;
                
                UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",buttonTag] integerValue]];
                borderView.alpha = 1.0;
                [borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                [borderView.layer setBorderWidth: 2.0];
                
                for (int i=0; i<self.buttonArray.count-1; i++) {
                    UIButton *tmp = (UIButton *)[self.collectionView viewWithTag:[[NSString stringWithFormat:@"10%@", [self.buttonArray objectAtIndex:i]] integerValue]];
                    //NSLog(@"tmp : %@", tmp);
                    tmp.backgroundColor = [UIColor blackColor];
                    [tmp setImage:nil forState:UIControlStateNormal];
                    [tmp setTitle:nil forState:UIControlStateNormal];
                    tmp.alpha = 0.5f;
                    
                    UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",[self.buttonArray objectAtIndex:i]] integerValue]];
                    borderView.alpha = 1.0;
                    [borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                    [borderView.layer setBorderWidth: 0.0];
                }
            }
            
        } else {
            if([self.gridType isEqualToString:@"PHOTO"]){
                if(self.buttonArray.count < 5){
                    if (!isAlready) {
                        [self.buttonArray addObject:buttonTag];
                        [self.tmpButtonArray addObject:asset];
                        
                        button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                        [button setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)self.buttonArray.count] forState:UIControlStateNormal];
                        button.alpha = 1.0f;
                        
                        UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"20%@",buttonTag] integerValue]];
                        [borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                        [borderView.layer setBorderWidth: 2.0];
                        
                    } else{
                        button.backgroundColor = [UIColor blackColor];
                        [button setTitle:@"" forState:UIControlStateNormal];
                        button.alpha = 0.5f;
                        
                        UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"20%@",buttonTag] integerValue]];
                        [borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                        [borderView.layer setBorderWidth: 0.0];
                        
                        for (int i=0; i<self.buttonArray.count; i++) {
                            UIButton *tmp = (UIButton *)[self.collectionView viewWithTag:[[NSString stringWithFormat:@"10%@", [self.buttonArray objectAtIndex:i]] integerValue]];
                            
                            if (i>=buttonIndex) {
                                NSString *index = tmp.titleLabel.text;
                                [tmp setTitle:[NSString stringWithFormat:@"%d",[index intValue]-1] forState:UIControlStateNormal];
                            }
                        }
                    }
                    
                } else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"사진은 한번에 최대 5장까지 선택할 수 있습니다.", @"사진은 한번에 최대 5장까지 선택할 수 있습니다.") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            } else if([self.gridType isEqualToString:@"VIDEO"]){
                [self.buttonArray addObject:buttonTag];
                self.tmpButtonArray = [[NSMutableArray alloc] initWithObjects:asset, nil];
                
                button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                [button setImage:[UIImage imageNamed:@"checkbox_blue.png"] forState:UIControlStateNormal];
                button.alpha = 1.0f;
                
                UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",buttonTag] integerValue]];
                borderView.alpha = 1.0;
                [borderView.layer setBorderColor: [[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] CGColor]];
                [borderView.layer setBorderWidth: 2.0];
                
                for (int i=0; i<self.buttonArray.count-1; i++) {
                    UIButton *tmp = (UIButton *)[self.collectionView viewWithTag:[[NSString stringWithFormat:@"10%@", [self.buttonArray objectAtIndex:i]] integerValue]];
                    //NSLog(@"tmp : %@", tmp);
                    tmp.backgroundColor = [UIColor blackColor];
                    [tmp setImage:nil forState:UIControlStateNormal];
                    [tmp setTitle:nil forState:UIControlStateNormal];
                    tmp.alpha = 0.5f;
                    
                    UIView *borderView = (UIView *)[self.view viewWithTag:[[NSString stringWithFormat:@"30%@",[self.buttonArray objectAtIndex:i]] integerValue]];
                    borderView.alpha = 1.0;
                    [borderView.layer setBorderColor: [[UIColor clearColor] CGColor]];
                    [borderView.layer setBorderWidth: 0.0];
                }
            }
        }
        

        if(self.buttonArray.count == 0) [self.navigationItem.rightBarButtonItem setEnabled:NO];
        else [self.navigationItem.rightBarButtonItem setEnabled:YES];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}
@end
