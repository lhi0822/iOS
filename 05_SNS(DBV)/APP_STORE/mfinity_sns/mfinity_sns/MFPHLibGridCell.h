//
//  MFPHLibGridCell.h
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 8. 31..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFPHLibGridCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (strong, nonatomic) IBOutlet UIImageView *selectImg;
@property (strong, nonatomic) IBOutlet UIView *touchArea;
@property (strong, nonatomic) IBOutlet UIView *borderView;
@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *livePhotoBadgeImage;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

@end
