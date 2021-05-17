//
//  ChatSendViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 4. 21..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatSendViewCell.h"

@implementation ChatSendViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.imgMessage.layer.cornerRadius = self.imgMessage.frame.size.width/15;
    self.imgMessage.clipsToBounds = YES;
    self.imgMessage.contentMode = UIViewContentModeScaleAspectFill;
    self.imgMessage.backgroundColor = [UIColor clearColor];
    
    //self.msgContentView.backgroundColor = [UIColor clearColor];
    //self.msgContentView.font = [UIFont systemFontOfSize:13];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
