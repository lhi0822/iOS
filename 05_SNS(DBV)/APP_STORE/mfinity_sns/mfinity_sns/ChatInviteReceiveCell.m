//
//  ChatInviteReceiveCell.m
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 23..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "ChatInviteReceiveCell.h"

@implementation ChatInviteReceiveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userImgView.layer.cornerRadius = self.userImgView.frame.size.width/2;
    self.userImgView.clipsToBounds = YES;
    self.userImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImgView.backgroundColor = [UIColor clearColor];
    self.userImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImgView.layer.borderWidth = 0.3;
    
    self.joinButton.layer.cornerRadius = self.joinButton.frame.size.width/20;
    self.joinButton.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
