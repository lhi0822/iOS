//
//  MFPostCommentCell.m
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 8. 29..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFPostCommentCell.h"

@implementation MFPostCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.commentView.frame.size.height, self.commentView.frame.size.width, 1)];
//    lineView.backgroundColor = [UIColor darkGrayColor];
//    [self addSubview:lineView];
//    
//    lineView.layer.borderWidth = 1.0f;
//    lineView.layer.borderColor = [UIColor darkGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
