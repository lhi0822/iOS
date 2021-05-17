//
//  NotiExtensionUtil.h
//  NotiServiceEx
//
//  Created by hilee on 23/10/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NotiExtensionUtil : NSObject

@property (strong, nonatomic) NSArray *imgArr;
@property (strong, nonatomic) UIImage *returnImg;

- (void)roomImgSetting:(NSMutableArray *)array :(NSString *)memberCnt;
- (void)roomImgSetting:(NSString *)imgPath :(NSMutableArray *)array :(NSString *)memberCnt;
- (UIImage *)twoImagesDivision:(UIImage *)image1 :(UIImage *)image2;
- (UIImage *)threeImagesDivision:(UIImage *)image1 :(UIImage *)image2 :(UIImage *)image3;
- (UIImage *)fourImagesDivision:(UIImage *)image1 :(UIImage *)image2 :(UIImage *)image3 :(UIImage *)image4;


- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize :(UIImage *)image;
- (UIImage *)getScaledLowImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width;
- (UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;

@end


@interface NSString(URLEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
+ (NSString *)urlDecodeString:(NSString *)str;
@end
