//
//  ImgTableViewCell.m
//  MyIG
//
//  Created by hilee on 2020/04/21.
//  Copyright © 2020 hilee. All rights reserved.
//

#import "ImgTableViewCell.h"

@implementation ImgTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _finishReload = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
