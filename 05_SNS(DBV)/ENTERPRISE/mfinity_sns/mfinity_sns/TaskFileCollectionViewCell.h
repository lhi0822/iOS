//
//  TaskFileCollectionViewCell.h
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 13..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HorizontalScrollCellAction;
@protocol HorizontalScrollDelegate <NSObject>
-(void)cellSelected:(UIView *)view;
-(void)imgDeleteClick:(UIButton *)sender;
-(void)editImgDeleteClick:(UIButton *)sender :(NSArray *)cellImages :(NSMutableArray *)cellImgDataArr :(NSMutableArray *)cellImgNameArr;
@end

@interface TaskFileCollectionViewCell : UICollectionViewCell <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
-(void)setUpCellWithArray:(NSArray *)array;
-(void)setUpCellWithImgArray:(NSArray *)array;

@property (strong, nonatomic) NSString *fromSegue;
@property BOOL isEdit;

@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSMutableArray *imgDataArr;
@property (strong, nonatomic) NSMutableArray *imgNameArr;

@property (nonatomic,strong) id<HorizontalScrollDelegate> cellDelegate;

@end
