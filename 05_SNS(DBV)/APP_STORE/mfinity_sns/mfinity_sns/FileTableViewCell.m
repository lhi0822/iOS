//
//  FileTableViewCell.m
//  mfinity_sns
//
//  Created by hilee on 07/02/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "FileTableViewCell.h"

@implementation FileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.fileButton.layer.cornerRadius = self.fileButton.frame.size.width/45;
    self.fileButton.clipsToBounds = YES;
    [self.fileButton.layer setBorderWidth:0.5];
    [self.fileButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.fileButton setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
