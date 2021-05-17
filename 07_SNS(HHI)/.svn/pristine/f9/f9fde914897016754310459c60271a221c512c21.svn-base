//
//  PostCommViewCell.m
//  mfinity_sns
//
//  Created by hilee on 07/02/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "PostCommViewCell.h"

@implementation PostCommViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.userTypeLabel.layer.cornerRadius = self.userTypeLabel.frame.size.width/2;
    self.userTypeLabel.clipsToBounds = YES;
    self.userTypeLabel.contentMode = UIViewContentModeScaleAspectFill;
    self.userTypeLabel.backgroundColor = [UIColor clearColor];
    self.userTypeLabel.textColor = [UIColor redColor];
    
    self.commFileBtn.layer.cornerRadius = self.commFileBtn.frame.size.width/45;
    self.commFileBtn.clipsToBounds = YES;
    [self.commFileBtn.layer setBorderWidth:0.5];
    [self.commFileBtn.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.commFileBtn setBackgroundColor:[UIColor clearColor]];
    
    self.commImgView.layer.cornerRadius = self.commFileBtn.frame.size.width/45;
    self.commImgView.clipsToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
