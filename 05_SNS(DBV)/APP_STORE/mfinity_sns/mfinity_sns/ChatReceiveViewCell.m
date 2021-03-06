//
//  ChatReceiveViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 4. 18..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatReceiveViewCell.h"

@implementation ChatReceiveViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.rAvatarImage.layer.cornerRadius = self.rAvatarImage.frame.size.width/2;
    self.rAvatarImage.clipsToBounds = YES;
    self.rAvatarImage.contentMode = UIViewContentModeScaleAspectFill;
    self.rAvatarImage.backgroundColor = [UIColor clearColor];
    self.rAvatarImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.rAvatarImage.layer.borderWidth = 0.3;
    
    self.rImageMessage.layer.cornerRadius = self.rImageMessage.frame.size.width/6;
    self.rImageMessage.clipsToBounds = YES;
    self.rImageMessage.contentMode = UIViewContentModeScaleAspectFill;
    self.rImageMessage.backgroundColor = [UIColor clearColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

@end
