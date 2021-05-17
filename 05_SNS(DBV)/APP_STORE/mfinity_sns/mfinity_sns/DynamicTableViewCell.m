//
//  DynamicTableViewCell.m
//  DynamicCellHeight
//
//  Created by Timo Josten on 08/07/15.
//  Copyright (c) 2015 mkswap.net. All rights reserved.
//

#import "DynamicTableViewCell.h"

@implementation DynamicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.txtLabel setNumberOfLines:0];
    [self.txtLabel setTextAlignment:NSTextAlignmentLeft];
}

@end
