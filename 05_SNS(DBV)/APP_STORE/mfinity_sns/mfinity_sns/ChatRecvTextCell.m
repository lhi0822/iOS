//
//  ChatRecvTextCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 4. 18..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatRecvTextCell.h"

@implementation ChatRecvTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userImgView.layer.cornerRadius = self.userImgView.frame.size.width/2;
    self.userImgView.clipsToBounds = YES;
    self.userImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImgView.backgroundColor = [UIColor clearColor];
    self.userImgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImgView.layer.borderWidth = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
}

@end
