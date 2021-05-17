//
//  MFPHLibGridCell.m
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 8. 31..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFPHLibGridCell.h"
@interface MFPHLibGridCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
@implementation MFPHLibGridCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

- (void)setLivePhotoBadgeImage:(UIImage *)livePhotoBadgeImage {
    _livePhotoBadgeImage = livePhotoBadgeImage;
    
}

@end
