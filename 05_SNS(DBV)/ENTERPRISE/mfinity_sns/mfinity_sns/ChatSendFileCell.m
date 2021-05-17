//
//  ChatSendFileCell.m
//  mfinity_sns
//
//  Created by hilee on 15/03/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "ChatSendFileCell.h"

@implementation ChatSendFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.fileContainer.layer.cornerRadius = self.fileContainer.frame.size.width/40;
    self.fileContainer.clipsToBounds = YES;
//    self.fFileContainer.contentMode = UIViewContentModeScaleAspectFill;
//    self.fFileContainer.backgroundColor = [UIColor whiteColor];
//    self.fFileContainer.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    self.fFileContainer.layer.borderWidth = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
