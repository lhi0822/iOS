//
//  ChatListViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 13..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatListViewCell.h"

@implementation ChatListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.chatImage.layer.cornerRadius = self.chatImage.frame.size.width/2;
    self.chatImage.clipsToBounds = YES;
    self.chatImage.contentMode = UIViewContentModeScaleAspectFill;
    self.chatImage.backgroundColor = [UIColor clearColor];
    self.chatImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.chatImage.layer.borderWidth = 0.3;
    
    self.chatAlarm.image = [UIImage imageNamed:@"icon_alarm_off2"];
    
    self.nChatLabel.layer.cornerRadius = self.nChatLabel.frame.size.width/2;
    self.nChatLabel.clipsToBounds = YES;
    self.nChatLabel.contentMode = UIViewContentModeScaleAspectFill;
    
    self.myLabel.layer.cornerRadius = self.myLabel.frame.size.width/2;
    self.myLabel.clipsToBounds = YES;
    //self.myLabel.contentMode = UIViewContentModeScaleAspectFill;
    self.myLabel.contentMode = UIViewContentModeCenter;
    
    self.userCount.layer.cornerRadius = self.userCount.frame.size.width/8;
    self.userCount.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
