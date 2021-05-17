//
//  MyCell.m
//  mFinity
//
//  Created by Jun HyungPark on 2017. 8. 9..
//  Copyright © 2017년 Jun hyeong Park. All rights reserved.
//

#import "MyCell.h"
#define kCellID @"IMG_CELL_ID"
@implementation MyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setMenuArray:(NSArray *)_menuArray{
    UINib* nib = [UINib nibWithNibName:@"TileViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kCellID];
    menuArray = _menuArray;
    NSLog(@"menuArray : %ld",(unsigned long)menuArray.count);
    appDelegate = (MFinityAppDelegate *)[UIApplication sharedApplication].delegate;
}
#pragma mark - Collection view data source
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int cellWidth = [UIScreen mainScreen].bounds.size.width/4;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        return CGSizeMake(cellWidth, 118);
    else
        return CGSizeMake(70, 70);
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return [menuArray count];
    //return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor grayColor];
    UIImageView* imgView = (UIImageView*)[cell.contentView viewWithTag:100];
    NSString *btnIconImagePath = [[menuArray objectAtIndex:indexPath.row] objectForKey:@"V5"];
    UIImage *icon =[[UIImage alloc] init];
    //NSLog(@"btnIconImagePath : %@",btnIconImagePath);
    NSMutableString *btnIconImage = [NSMutableString stringWithString:btnIconImagePath];
    NSString *filename = [btnIconImage lastPathComponent];
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    documentFolder = [documentFolder stringByAppendingPathComponent:@"icon"];
    NSString *filePath = [documentFolder stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSData *decryptData = [data AES256DecryptWithKey:appDelegate.AES256Key];
    icon = [UIImage imageWithData:decryptData];
    
    if (icon==nil) {
        icon = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:btnIconImage]]];
        NSData *data = [NSData dataWithData:UIImagePNGRepresentation(icon)];
        NSData *enryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [enryptData writeToFile:filePath atomically:YES];
        //NSData *data = [NSData dataWithData:UIImagePNGRepresentation(icon)];
        
    }
    if (imgView) imgView.image = icon;
    return cell;
}
#pragma mark - Collection view selection

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"sub%ld - select sz%ld", (long)indexPath.item, (indexPath.item+1));
}
@end
