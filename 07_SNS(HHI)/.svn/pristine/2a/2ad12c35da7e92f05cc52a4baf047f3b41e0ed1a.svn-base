//
//  DynamicFileTableViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 14..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "DynamicFileTableViewCell.h"

@implementation DynamicFileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //self.fileContentView.layer.borderWidth = 1.0f;
    //self.fileContentView.layer.borderColor = [UIColor lightGrayColor];
    
    self.fileContentView.layer.cornerRadius = self.fileContentView.frame.size.width/45;
    self.fileContentView.clipsToBounds = YES;
    [self.fileContentView.layer setBorderWidth:0.5];
    [self.fileContentView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.fileContentView setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
