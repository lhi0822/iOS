//
//  floatTableViewCell.m
//  floatingButtonTrial
//
//  Created by Giridhar on 26/03/15.
//  Copyright (c) 2015 Giridhar. All rights reserved.
//

#import "floatTableViewCell.h"

@implementation floatTableViewCell
@synthesize imgView, title, overlay, bgColorView, titleTxtView;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    overlay = [UIView new];
    overlay.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
    //[title addSubview:overlay];
    [titleTxtView addSubview:overlay];
    
    //self.imgView.layer.cornerRadius = 45/2;
    //self.imgView.layer.masksToBounds = YES;
    
//    self.title.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithWhite:0.8 alpha:0.8];
//    self.title.layer.cornerRadius = 3.f;
//    self.title.layer.masksToBounds = YES;
//    self.title.textColor = [UIColor blackColor];
    self.titleTxtView.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithWhite:0.8 alpha:0.8];
    self.titleTxtView.layer.cornerRadius = 3.f;
    self.titleTxtView.layer.masksToBounds = YES;
    self.titleTxtView.textColor = [UIColor blackColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    self.contentView.transform = CGAffineTransformMakeRotation(-M_PI);
    
    self.bgColorView.backgroundColor = [UIColor whiteColor];
    self.bgColorView.layer.cornerRadius = self.bgColorView.frame.size.width/2;
    self.bgColorView.clipsToBounds = YES;
    self.bgColorView.contentMode = UIViewContentModeScaleAspectFill;
}


-(void)setTitle:(NSString*)txt andImage:(UIImage*)img
{
//    self.title.text = txt;
//    
//    CGFloat width = ceil([self.title.text sizeWithAttributes:@{NSFontAttributeName: self.title.font}].width);
//    
//    CGFloat height = ceil([self.title.text sizeWithAttributes:@{NSFontAttributeName: self.title.font}].height);
//    
//    overlay.frame = CGRectMake(CGRectGetMaxX(self.title.frame), CGRectGetMaxY(self.title.frame), width, height);
//    
//    
//    
//    self.imgView.image = img;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
