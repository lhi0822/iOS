//
//  LongChatReceiveViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2018. 4. 4..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "LongChatReceiveViewCell.h"

@implementation LongChatReceiveViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userImg.layer.cornerRadius = self.userImg.frame.size.width/2;
    self.userImg.clipsToBounds = YES;
    self.userImg.contentMode = UIViewContentModeScaleAspectFill;
    self.userImg.backgroundColor = [UIColor clearColor];
    self.userImg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImg.layer.borderWidth = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
