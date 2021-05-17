//
//  PHLibListViewController.m
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 8. 31..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "PHLibListViewController.h"
#import "AAPLAssetGridViewController.h"
#import "PostDetailViewController.h"
#import "AppDelegate.h"

#define IS_OS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
@interface PHLibListViewController () {
    NSString *orgFilename;
    int videoCount;
    AppDelegate *appDelegate;
}

@end

@implementation PHLibListViewController
static CGSize AssetGridThumbnailSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @try{
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(leftSideMenuButtonPressed:)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
        
        AssetGridThumbnailSize = CGSizeMake(50,50);
        self.imageManager = [[PHCachingImageManager alloc] init];
        
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        
        if([self.listType isEqualToString:@"PHOTO"]){
            self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"popup_camera2", @"popup_camera2")];
            
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType==%d",PHAssetMediaTypeImage];
            
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
            PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
            self.sectionFetchResults = [NSMutableArray array];
            
            PHCollection *collection = [[PHCollection alloc]init];
            
            for (int i=0; i<smartAlbums.count; i++) {
                collection = smartAlbums[i];
                NSLog(@"collectionnnnnn : %@", collection);
                
                PHAssetCollection *assetCollection = smartAlbums[i];
                
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:allPhotosOptions];
                    
//                    NSString *collStr = [NSString stringWithFormat:@"%ld",assetsFetchResult.count];
                    
                    if (assetsFetchResult.count > 0) {
                        [self.sectionFetchResults addObject:collection];
                        
                        //                    [assetsFetchResult enumerateObjectsUsingBlock : ^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                        //                        NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
                        //                        [resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        //                            PHAssetResource *resource = obj;
                        //
                        //                            NSRange range = [resource.uniformTypeIdentifier rangeOfString:@"." options:NSBackwardsSearch];
                        //                            NSString *fileExt = [[resource.uniformTypeIdentifier substringFromIndex:range.location+1] lowercaseString];
                        //
                        //                            if (asset.mediaType==PHAssetMediaTypeImage) {
                        //                                if([fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"jpeg"]){
                        //                                    if(![collStr isEqualToString:@"0"]) [self.sectionFetchResults addObject:collection];
                        //
                        //                                    if (IS_OS_9_OR_LATER && [collection.localizedTitle isEqualToString:@"Favorites"]) {
                        //                                        [self.sectionFetchResults addObject:collection];
                        //                                    }
                        //                                }
                        //                            }
                        //                        }];
                        //
                        //                        *stop = YES;
                        //                    }];
                    }
                }
            }
            
            for (int i=0; i<topLevelUserCollections.count; i++) {
                collection = topLevelUserCollections[i];
                //어플에서 생성된 앨범
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:allPhotosOptions];
                    
                    if(assetsFetchResult.count>0){
                        [self.sectionFetchResults addObject:collection];
                        
                        //                    [assetsFetchResult enumerateObjectsUsingBlock : ^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                        //
                        //                        NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
                        //                        [resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        //                            PHAssetResource *resource = obj;
                        //
                        //                            NSRange range = [resource.uniformTypeIdentifier rangeOfString:@"." options:NSBackwardsSearch];
                        //                            NSString *fileExt = [[resource.uniformTypeIdentifier substringFromIndex:range.location+1] lowercaseString];
                        //
                        //                            if (asset.mediaType==PHAssetMediaTypeImage) {
                        //                                if([fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"jpeg"]){
                        //                                    [self.sectionFetchResults addObject:collection];
                        //                                }
                        //                            }
                        //                        }];
                        //
                        //                        *stop = YES;
                        //                    }];
                    }
                }
            }
            
        } else if([self.listType isEqualToString:@"VIDEO"]){
            self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"동영상 선택", @"동영상 선택")];
            
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType==%d",PHAssetMediaTypeVideo];
            
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
            PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
            self.sectionFetchResults = [NSMutableArray array];
            
            PHCollection *collection = [[PHCollection alloc]init];
            for (int i=0; i<smartAlbums.count; i++) {
                collection = smartAlbums[i];
                PHAssetCollection *assetCollection = smartAlbums[i];
//                NSLog(@"비디오 assetCollection : %@", assetCollection);
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:allPhotosOptions];
                    if (assetsFetchResult.count > 0) {
                        [self.sectionFetchResults addObject:collection];
                    }
                }
            }
            
            for (int i=0; i<topLevelUserCollections.count; i++) {
                collection = topLevelUserCollections[i];
                //어플에서 생성된 앨범
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:allPhotosOptions];
                    
                    if(assetsFetchResult.count>0){
                        [self.sectionFetchResults addObject:collection];
//                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
//                            float imageSize = imageData.length;
//                            imageSize = imageSize/(1024*1024);
//                            NSLog(@"imageSize : %f",imageSize);
//
//                            [self.sectionFetchResults addObject:collection];
//                        }];
                        
//                        [assetsFetchResult enumerateObjectsUsingBlock : ^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
//                            NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
//                            [resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                                PHAssetResource *resource = obj;
//                                [self.sectionFetchResults addObject:collection];
//                            }];
//
//                            *stop = YES;
//                        }];
                    }
                }
            }
        }
        
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
    } @catch(NSException *exception){
        
    }
}


-(void)dealloc{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



-(void)leftSideMenuButtonPressed:(id)sender {
    //[SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sectionFetchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    videoCount=0;
    MFPhotoLibTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    @try {
        PHCollection *collection = self.sectionFetchResults[indexPath.row];
        cell.libNameLabel.text = NSLocalizedString(collection.localizedTitle, @"");
        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        
        if([self.listType isEqualToString:@"PHOTO"]){
            allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType==%d",PHAssetMediaTypeImage];
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:allPhotosOptions];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            PHAsset *asset = assetsFetchResult[assetsFetchResult.count-1];
            
            //        NSLog(@"first asset : %@", asset);
            //        PHAsset *asset;
            //        for(int i=0; i<assetsFetchResult.count; i++){
            //            asset = [assetsFetchResult objectAtIndex:i];
            //
            //            float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
            //            if (ver >= 9.0) {
            //                NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
            //                orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
            //            } else {
            //                PHImageRequestOptions *option = [PHImageRequestOptions new];
            //                option.synchronous = YES;
            //                option.networkAccessAllowed = YES;
            //                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
            //                    NSURL* fileURL = [info objectForKey:@"PHImageFileURLKey"];
            //                    orgFilename = [[NSFileManager defaultManager] displayNameAtPath:[fileURL path]];
            //                }];
            //            }
            //            NSRange range = [orgFilename rangeOfString:@"." options:NSBackwardsSearch];
            //            NSString *fileExt = [[orgFilename substringFromIndex:range.location+1] lowercaseString];
            //
            //            if(![fileExt isEqualToString:@"png"] && ![fileExt isEqualToString:@"jpg"] && ![fileExt isEqualToString:@"jpeg"]){
            //                videoCount++;
            //            }
            //        }
            //        NSLog(@"videoCount : %d", videoCount);
            //        cell.photoCountLabel.text = [NSString stringWithFormat:@"%ld",assetsFetchResult.count-videoCount];
            
            cell.photoCountLabel.text = [NSString stringWithFormat:@"%ld",assetsFetchResult.count];
            
            [self.imageManager requestImageForAsset:asset
                                         targetSize:AssetGridThumbnailSize
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                          //NSLog(@"info : %@",info);
                                          cell.thumnailImage.image = result;
                                      }];
        } else if([self.listType isEqualToString:@"VIDEO"]){
            allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType==%d",PHAssetMediaTypeVideo];
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:allPhotosOptions];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            PHAsset *asset = assetsFetchResult[assetsFetchResult.count-1];
            
            cell.photoCountLabel.text = [NSString stringWithFormat:@"%ld",assetsFetchResult.count];
            
            [self.imageManager requestImageForAsset:asset
                                         targetSize:AssetGridThumbnailSize
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                          //NSLog(@"info : %@",info);
                                          cell.thumnailImage.image = result;
                                      }];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[SVProgressHUD show];
    PHCollection *collection = self.sectionFetchResults[indexPath.row];
    [self performSegueWithIdentifier:@"PHGRID_VIEW_PUSH" sender:collection];
}

-(void)photoLibraryDidChange:(PHChange *)changeInstance{
    
}

- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * scale, CGRectGetHeight(self.view.bounds) * scale);
    return targetSize;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AAPLAssetGridViewController *destination = segue.destinationViewController;
    PHCollection *collection = sender;
    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    
    MFPHLibGridViewController *destination2 = segue.destinationViewController;
    destination2.gridType = self.listType;
    
    if([self.listType isEqualToString:@"PHOTO"]){
        allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType==%d",PHAssetMediaTypeImage];
    } else if([self.listType isEqualToString:@"VIDEO"]){
        allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType==%d",PHAssetMediaTypeVideo];
    }
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:allPhotosOptions];
    destination.assetsFetchResults = assetsFetchResult;
    
    if([segue.identifier isEqualToString:@"PHGRID_VIEW_PUSH"]){
        self.navigationController.navigationBar.topItem.title = @"";
        
        if([self.fromSegue isEqualToString:@"POST_PHLIB_MODAL"]){
            destination2.fromSegue = @"POST_PHLIB_MODAL";
            
        } else if([self.fromSegue isEqualToString:@"MY_PHLIB_MODAL"]){
            destination2.fromSegue = @"MY_PHLIB_MODAL";
            
        } else if([self.fromSegue isEqualToString:@"CHAT_PHLIB_MODAL"]){
            destination2.fromSegue = @"CHAT_PHLIB_MODAL";
            
        } else if([self.fromSegue isEqualToString:@"POST_MODIFY_PHLIB_MODAL"]){
            destination2.fromSegue = @"POST_MODIFY_PHLIB_MODAL";
            
        } else if([self.fromSegue isEqualToString:@"BOARD_PHLIB_MODAL"]){
            destination2.fromSegue = @"BOARD_PHLIB_MODAL";
            
        } else if([self.fromSegue isEqualToString:@"TASK_PHLIB_MODAL"]){
            destination2.fromSegue = @"TASK_PHLIB_MODAL";
        
        } else if([self.fromSegue isEqualToString:@"POST_DETAIL_PHLIB_MODAL"]){
            destination2.fromSegue = @"POST_DETAIL_PHLIB_MODAL";
        }
    }
}

@end
