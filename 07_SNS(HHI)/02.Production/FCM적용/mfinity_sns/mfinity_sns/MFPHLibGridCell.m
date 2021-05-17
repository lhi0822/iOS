//
//  MFPHLibGridCell.m
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 8. 31..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFPHLibGridCell.h"
@interface MFPHLibGridCell()

@end
@implementation MFPHLibGridCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectButton.layer.cornerRadius = self.selectButton.frame.size.width/2;
    self.selectButton.clipsToBounds = YES;
    self.selectButton.contentMode = UIViewContentModeScaleAspectFill;
    self.selectButton.alpha = 0.5f;
    //self.selectButton.backgroundColor = [UIColor clearColor];
    
    //[self.borderView.layer setBorderColor: [[UIColor redColor] CGColor]];
    //[self.borderView.layer setBorderWidth: 2.0];
    
    //self.selectButton.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    //self.selectButton = [self pointInside:CGPointMake(5, 5) withEvent:UIEventTypeTouches];

}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selectImg.image = nil;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.selectImg.image = thumbnailImage;
}

- (void)setLivePhotoBadgeImage:(UIImage *)livePhotoBadgeImage {
    _livePhotoBadgeImage = livePhotoBadgeImage;
}

@end
