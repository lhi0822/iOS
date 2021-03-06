//
//  CustomHeader.m
//  ARSegmentPager
//
//  Created by August on 15/5/20.
//  Copyright (c) 2015年 August. All rights reserved.
//

#import "CustomHeader.h"
#import "UIDevice-Hardware.h"

@interface CustomHeader ()

@end

@implementation CustomHeader

- (BOOL)isIphoneX {
    NSString *platform = [[UIDevice currentDevice] modelName];
    NSRange range = NSMakeRange(7, 1);
    NSString *platformNumber = [platform substringWithRange:range];
    if([platformNumber isEqualToString:@"X"]){
        return YES;
    } else {
        return NO;
    }
    
//    if (CGRectEqualToRect([UIScreen mainScreen].bounds,CGRectMake(0, 0, 375, 812))) {
//        return YES;
//    } else {
//        return NO;
//    }
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    _profileImageButton.layer.cornerRadius = _profileImageButton.frame.size.width/2;
    _profileImageButton.clipsToBounds = YES;
    _profileImageButton.contentMode = UIViewContentModeScaleAspectFit;
    _profileImageButton.backgroundColor = [UIColor whiteColor];
    _profileImageButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _profileImageButton.layer.borderWidth = 0.3;
    
    if([self isIphoneX]){
        self.closeButtonTopHeight.constant = 26;
    } else {
        self.closeButtonTopHeight.constant = 10;
    }
}

- (UIImageView *)backgroundImageView {
    return self.profileBgImgView;
}

- (void)updateHeadPhotoWithTopInset:(CGFloat)inset {
    //    CGFloat ratio = (inset - 64)/200.0;
    //    self.bottomConstraint.constant = ratio * 30 + 10;
    //    self.widthConstraint.constant = 30 + ratio * 50;
}

@end
