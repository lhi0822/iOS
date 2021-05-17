//
//  ChatSendTextCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 4. 21..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatSendTextCell.h"

@implementation ChatSendTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.dateLabel.layer.cornerRadius = self.dateLabel.frame.size.width/10;
    self.dateLabel.clipsToBounds = YES;
//    self.imgMessage.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
