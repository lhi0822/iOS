//
//  SampleUtils.m
//  new_sample
//
//  Created by bhchae on 2016. 7. 18..
//  Copyright © 2016년 bhchae. All rights reserved.
//

#import "SampleUtils.h"

@implementation SampleUtils

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 10, 10);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
