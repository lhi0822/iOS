//
//  ChatRecvVideoCell.m
//  mfinity_sns
//
//  Created by hilee on 30/01/2020.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "ChatRecvVideoCell.h"

@implementation ChatRecvVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userImgView.layer.cornerRadius = self.userImgView.frame.size.width/2;
    self.userImgView.clipsToBounds = YES;
    self.userImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImgView.backgroundColor = [UIColor clearColor];
    self.userImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImgView.layer.borderWidth = 0.3;
    
    self.imgMessage.layer.cornerRadius = self.imgMessage.frame.size.width/15;
    self.imgMessage.clipsToBounds = YES;
    self.imgMessage.contentMode = UIViewContentModeScaleAspectFill;
    self.imgMessage.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
