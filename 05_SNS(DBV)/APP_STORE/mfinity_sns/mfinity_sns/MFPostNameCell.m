//
//  MFPostNameCell.m
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 8. 26..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFPostNameCell.h"

@implementation MFPostNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.profileImageButton.layer.cornerRadius = self.profileImageButton.frame.size.width/2;
    self.profileImageButton.clipsToBounds = YES;
    self.profileImageButton.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageButton.backgroundColor = [UIColor clearColor];
    self.profileImageButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.profileImageButton.layer.borderWidth = 0.3;
    
    self.userTypeLabel.layer.cornerRadius = self.userTypeLabel.frame.size.width/2;
    self.userTypeLabel.clipsToBounds = YES;
    self.userTypeLabel.contentMode = UIViewContentModeScaleAspectFill;
    self.userTypeLabel.backgroundColor = [UIColor clearColor];
    self.userTypeLabel.textColor = [UIColor redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
