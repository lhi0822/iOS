//
//  MFPHLibListViewController.m
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 8. 31..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFPHLibListViewController.h"
#import "AAPLAssetGridViewController.h"

#define IS_OS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
@interface MFPHLibListViewController ()

@end

@implementation MFPHLibListViewController
static CGSize AssetGridThumbnailSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:@"486996"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    titleLabel.text =  NSLocalizedString(@"사진 선택", @"사진 선택");
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"닫기", @"닫기")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(leftSideMenuButtonPressed:)];
    
    AssetGridThumbnailSize = CGSizeMake(50,50);
    self.imageManager = [[PHCachingImageManager alloc] init];
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    
    self.sectionFetchResults = [NSMutableArray array];
    for (PHCollection *collection in smartAlbums) {
        NSLog(@"collection.localizedTitle : %@",collection.localizedTitle);
        if ([collection.localizedTitle isEqualToString:@"모든 사진"] ||
            [collection.localizedTitle isEqualToString:@"즐겨찾는 사진"] ||
            [collection.localizedTitle isEqualToString:@"스크린샷"] ||
            [collection.localizedTitle isEqualToString:@"최근 추가된 항목"]) {
                [self.sectionFetchResults addObject:collection];
        }
        
        if (IS_OS_9_OR_LATER && [collection.localizedTitle isEqualToString:@"Favorites"]) {
            [self.sectionFetchResults addObject:collection];
        }
        
        
    }
    
    
    for (PHCollection *collection in topLevelUserCollections) {
        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        if(assetsFetchResult.count>0){
            [self.sectionFetchResults addObject:collection];
        }
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    
     
}
-(void)dealloc{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)leftSideMenuButtonPressed:(id)sender {
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
    MFPhotoLibTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MFPhotoLibTableViewCell" forIndexPath:indexPath];
    
    PHCollection *collection = self.sectionFetchResults[indexPath.row];
    cell.libNameLabel.text = NSLocalizedString(collection.localizedTitle, @"") ;
    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    @try {
        
        cell.photoCountLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)assetsFetchResult.count];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        PHAsset *asset = assetsFetchResult[assetsFetchResult.count-1];
        [self.imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      // Set the cell's thumbnail image if it's still showing the same asset.
                                      //NSLog(@"info : %@",info);
                                      cell.thumnailImage.image = result;
                                      
                                  }];
    } @catch (NSException *exception) {
        NSLog(@"exception : %@",exception);
    }
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    PHCollection *collection = self.sectionFetchResults[indexPath.row];
    [self performSegueWithIdentifier:@"PUSH_PHGRID_VIEW" sender:collection];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


-(void)photoLibraryDidChange:(PHChange *)changeInstance{

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    /*
    MFPHLibGridViewController *destination = segue.destinationViewController;
    PHCollection *collection = sender;
    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    destination.assetCollection = assetCollection;
    destination.assetsFetchResults = assetsFetchResult;
    */
    AAPLAssetGridViewController *destination = segue.destinationViewController;
    PHCollection *collection = sender;
    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    destination.assetCollection = assetCollection;
    destination.assetsFetchResults = assetsFetchResult;
}


@end
