//
//  MFGroupCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 8..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "MFGroupCell.h"

@implementation MFGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.snsImageView.layer.cornerRadius = self.snsImageView.frame.size.width/6;
    self.snsImageView.clipsToBounds = YES;
    self.snsImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.snsImageView.backgroundColor = [UIColor clearColor];
    self.snsImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.snsImageView.layer.borderWidth = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
