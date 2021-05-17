//
//  AttachViewController.m
//  mfinity_sns
//
//  Created by hilee on 2020/06/26.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "AttachViewController.h"
#import "AttachCollectionViewCell.h"

@interface AttachViewController (){
    NSArray *collectionArr;
}

@end

@implementation AttachViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog();
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    collectionArr = [[NSArray alloc] initWithObjects:@"카메라", @"사진", @"동영상", @"파일", nil];
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

// 컬렉션 크기 설정
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    @try{
        return CGSizeMake(60, 80);

    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

// 컬렉션 뷰 셀 갯수
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    @try{
        return collectionArr.count;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

// 컬렉션과 컬렉션 height 간격
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 0;
//}

// 컬렉션과 컬렉션 width 간격
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 40;
    
}

// 컬렉션 뷰 셀 설정
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    @try{
        [self.collectionView registerNib:[UINib nibWithNibName:@"AttachCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"AttachCollectionViewCell"];
        AttachCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttachCollectionViewCell" forIndexPath:indexPath];
       
        if(indexPath.item==0) {
            cell.imageView.image = [UIImage imageNamed:@"menu_camera.png"];
        } else if(indexPath.item==1){
            cell.imageView.image = [UIImage imageNamed:@"menu_album.png"];
        } else if(indexPath.item==2){
            cell.imageView.image = [UIImage imageNamed:@"menu_movie.png"];
        } else if(indexPath.item==3){
            cell.imageView.image = [UIImage imageNamed:@"menu_file.png"];
        }
        cell.label.text = [collectionArr objectAtIndex:indexPath.item];

        return cell;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
 }

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.item==0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SelectMedia" object:@"CAMERA"];
        
    } else if(indexPath.item==1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SelectMedia" object:@"PHOTO"];
        
    } else if(indexPath.item==2){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SelectMedia" object:@"VIDEO"];
    
    } else if(indexPath.item==3){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SelectMedia" object:@"FILE"];
    }
}

@end
