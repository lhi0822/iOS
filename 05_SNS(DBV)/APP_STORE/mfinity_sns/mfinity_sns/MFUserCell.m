//
//  MFUserCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 16..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "MFUserCell.h"

@implementation MFUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width/2;
    self.userImageView.clipsToBounds = YES;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImageView.backgroundColor = [UIColor clearColor];
    self.userImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImageView.layer.borderWidth = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
