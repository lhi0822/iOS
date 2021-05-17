//
//  ChatSendVideoCell.m
//  mfinity_sns
//
//  Created by hilee on 29/01/2020.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "ChatSendVideoCell.h"

@implementation ChatSendVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
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
