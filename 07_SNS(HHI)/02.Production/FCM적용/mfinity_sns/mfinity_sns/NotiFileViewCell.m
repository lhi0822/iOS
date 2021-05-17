//
//  NotiFileViewCell.m
//  mfinity_sns
//
//  Created by hilee on 14/05/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "NotiFileViewCell.h"

@implementation NotiFileViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.fileUserImg.layer.cornerRadius = self.fileUserImg.frame.size.width/2;
    self.fileUserImg.clipsToBounds = YES;
    self.fileUserImg.contentMode = UIViewContentModeScaleAspectFill;
    self.fileUserImg.backgroundColor = [UIColor clearColor];
    self.fileUserImg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.fileUserImg.layer.borderWidth = 0.3;
    
    self.notiFileView.layer.cornerRadius = self.notiFileView.frame.size.width/40;
    self.notiFileView.clipsToBounds = YES;
    self.notiFileView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.notiFileView.layer.borderWidth = 0.3;
    
    self.fileContainerView.layer.cornerRadius = self.notiFileView.frame.size.width/40;
    self.fileContainerView.clipsToBounds = YES;
    self.fileContainerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.fileContainerView.layer.borderWidth = 0.3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
