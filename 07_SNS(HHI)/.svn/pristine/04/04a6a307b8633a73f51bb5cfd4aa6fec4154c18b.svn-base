//
//  ChatReceiveFileCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 11..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatReceiveFileCell.h"

@implementation ChatReceiveFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.fAvatarImage.layer.cornerRadius = self.fAvatarImage.frame.size.width/2;
    self.fAvatarImage.clipsToBounds = YES;
    self.fAvatarImage.contentMode = UIViewContentModeScaleAspectFill;
    self.fAvatarImage.backgroundColor = [UIColor clearColor];
    self.fAvatarImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.fAvatarImage.layer.borderWidth = 0.3;
    
    self.fFileContainer.layer.cornerRadius = self.fFileContainer.frame.size.width/40;
    self.fFileContainer.clipsToBounds = YES;
    self.fFileContainer.contentMode = UIViewContentModeScaleAspectFill;
    self.fFileContainer.backgroundColor = [UIColor clearColor];
    self.fFileContainer.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.fFileContainer.layer.borderWidth = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
