//
//  NotiChatViewCell.m
//  mfinity_sns
//
//  Created by hilee on 10/05/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "NotiChatViewCell.h"

@implementation NotiChatViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.notiUserImg.layer.cornerRadius = self.notiUserImg.frame.size.width/2;
    self.notiUserImg.clipsToBounds = YES;
    self.notiUserImg.contentMode = UIViewContentModeScaleAspectFill;
    self.notiUserImg.backgroundColor = [UIColor clearColor];
    self.notiUserImg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.notiUserImg.layer.borderWidth = 0.3;
    
    self.notiView.layer.cornerRadius = self.notiView.frame.size.width/40;
    self.notiView.clipsToBounds = YES;
    self.notiView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.notiView.layer.borderWidth = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
