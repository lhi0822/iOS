//
//  NotiInviteViewCell.m
//  mfinity_sns
//
//  Created by hilee on 13/05/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "NotiInviteViewCell.h"

@implementation NotiInviteViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.inviteUserImg.layer.cornerRadius = self.inviteUserImg.frame.size.width/2;
    self.inviteUserImg.clipsToBounds = YES;
    self.inviteUserImg.contentMode = UIViewContentModeScaleAspectFill;
    self.inviteUserImg.backgroundColor = [UIColor clearColor];
    self.inviteUserImg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.inviteUserImg.layer.borderWidth = 0.3;
    
    self.inviteNotiView.layer.cornerRadius = self.inviteNotiView.frame.size.width/40;
    self.inviteNotiView.clipsToBounds = YES;
    self.inviteNotiView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.inviteNotiView.layer.borderWidth = 0.3;
    
    self.joinButton.layer.cornerRadius = self.joinButton.frame.size.width/20;
    self.joinButton.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
