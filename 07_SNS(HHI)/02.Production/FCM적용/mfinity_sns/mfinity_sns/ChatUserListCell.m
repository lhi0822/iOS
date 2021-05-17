//
//  ChatUserListCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 13..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatUserListCell.h"

@implementation ChatUserListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.unInstallLbl.text = @"미설치";
    self.unInstallLbl.textColor = [UIColor redColor];
    
    self.favoriteBtn.layer.cornerRadius = self.favoriteBtn.frame.size.width/2;
    self.favoriteBtn.clipsToBounds = YES;
    self.favoriteBtn.contentMode = UIViewContentModeScaleAspectFit;
    self.favoriteBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.favoriteBtn.layer.borderWidth = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
