//
//  NotiLongChatViewCell.m
//  mfinity_sns
//
//  Created by hilee on 14/05/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "NotiLongChatViewCell.h"

@implementation NotiLongChatViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    self.longUserImg.layer.cornerRadius = self.longUserImg.frame.size.width/2;
    self.longUserImg.clipsToBounds = YES;
    self.longUserImg.contentMode = UIViewContentModeScaleAspectFill;
    self.longUserImg.backgroundColor = [UIColor clearColor];
    self.longUserImg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.longUserImg.layer.borderWidth = 0.3;

    self.longNotiView.layer.cornerRadius = self.longNotiView.frame.size.width/40;
    self.longNotiView.clipsToBounds = YES;
    self.longNotiView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.longNotiView.layer.borderWidth = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
