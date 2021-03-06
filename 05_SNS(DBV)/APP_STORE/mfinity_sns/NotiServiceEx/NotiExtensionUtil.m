//
//  NotiExtensionUtil.m
//  NotiServiceEx
//
//  Created by hilee on 23/10/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "NotiExtensionUtil.h"

#define NOTI_GRP_NAME @"group.hhi.sns.push"

#define MIN_WIDTH 50
#define EXPAND_SIZE 60

#define MIN_IMG_WIDTH 45
#define MIN_IMG_HEIGHT 90

@implementation NotiExtensionUtil


- (void)roomImgSetting:(NSMutableArray *)array :(NSString *)memberCnt{
    UIImage *img1 = [[UIImage alloc]init];
    UIImage *img2 = [[UIImage alloc]init];
    UIImage *img3 = [[UIImage alloc]init];
    UIImage *img4 = [[UIImage alloc]init];
    
    /*
    if([memberCnt integerValue] < 3){
        if(array.count == 1){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            
        } else {
            img1 = [UIImage imageNamed:@"profile_default.png"];
        }
        [self oneImageSetting:img1];
        
    } else if([memberCnt integerValue] == 3){
        if(array.count == 2){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            
        } else if(array.count == 1){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [UIImage imageNamed:@"profile_default.png"];
            
        } else {
            img1 = [UIImage imageNamed:@"profile_default.png"];
            img2 = [UIImage imageNamed:@"profile_default.png"];
        }
        [self twoImagesDivision:img1 :img2];
        
    } else if ([memberCnt integerValue] == 4){
        if(array.count == 3){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [self saveThumbImage:@"Profile" :[array objectAtIndex:2]];
            
        } else if(array.count == 2){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            
        } else if(array.count == 1){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [UIImage imageNamed:@"profile_default.png"];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            
        } else {
            img1 = [UIImage imageNamed:@"profile_default.png"];
            img2 = [UIImage imageNamed:@"profile_default.png"];
            img3 = [UIImage imageNamed:@"profile_default.png"];
        }
        [self threeImagesDivision:img1 :img2 :img3];
        
    } else if ([memberCnt integerValue] > 4){
        if(array.count == 4){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [self saveThumbImage:@"Profile" :[array objectAtIndex:2]];
            img4 = [self saveThumbImage:@"Profile" :[array objectAtIndex:3]];
            
        } else if(array.count == 3){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [self saveThumbImage:@"Profile" :[array objectAtIndex:2]];
            img4 = [UIImage imageNamed:@"profile_default.png"];
            
        } else if(array.count == 2){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            img4 = [UIImage imageNamed:@"profile_default.png"];
            
        } else if(array.count == 1){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [UIImage imageNamed:@"profile_default.png"];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            img4 = [UIImage imageNamed:@"profile_default.png"];
            
        } else {
            img1 = [UIImage imageNamed:@"profile_default.png"];
            img2 = [UIImage imageNamed:@"profile_default.png"];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            img4 = [UIImage imageNamed:@"profile_default.png"];
        }
        [self fourImagesDivision:img1 :img2 :img3 :img4];
    }
     */
}

- (void)roomImgSetting:(NSString *)imgPath :(NSMutableArray *)array :(NSString *)memberCnt{
    
    UIImage *img1 = [[UIImage alloc]init];
    UIImage *img2 = [[UIImage alloc]init];
    UIImage *img3 = [[UIImage alloc]init];
    UIImage *img4 = [[UIImage alloc]init];
    
    /*
    if([memberCnt integerValue] == 3){
        if(array.count == 2){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
        } else if(array.count == 1){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [UIImage imageNamed:@"profile_default.png"];
        } else {
            img1 = [UIImage imageNamed:@"profile_default.png"];
            img2 = [UIImage imageNamed:@"profile_default.png"];
        }
        [self twoImagesDivision:img1 :img2];
        
    } else if ([memberCnt integerValue] == 4){
        if(array.count == 3){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [self saveThumbImage:@"Profile" :[array objectAtIndex:2]];
            
        } else if(array.count == 2){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            
        } else if(array.count == 1){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [UIImage imageNamed:@"profile_default.png"];
            img3 = [UIImage imageNamed:@"profile_default.png"];
        } else {
            img1 = [UIImage imageNamed:@"profile_default.png"];
            img2 = [UIImage imageNamed:@"profile_default.png"];
            img3 = [UIImage imageNamed:@"profile_default.png"];
        }
        [self threeImagesDivision:img1 :img2 :img3];
        
    } else if ([memberCnt integerValue] > 4){
        if(array.count == 4){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [self saveThumbImage:@"Profile" :[array objectAtIndex:2]];
            img4 = [self saveThumbImage:@"Profile" :[array objectAtIndex:3]];
            
        } else if(array.count == 3){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [self saveThumbImage:@"Profile" :[array objectAtIndex:2]];
            img4 = [UIImage imageNamed:@"profile_default.png"];
        } else if(array.count == 2){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [self saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            img4 = [UIImage imageNamed:@"profile_default.png"];
        } else if(array.count == 1){
            img1 = [self saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [UIImage imageNamed:@"profile_default.png"];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            img4 = [UIImage imageNamed:@"profile_default.png"];
        } else {
            img1 = [UIImage imageNamed:@"profile_default.png"];
            img2 = [UIImage imageNamed:@"profile_default.png"];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            img4 = [UIImage imageNamed:@"profile_default.png"];
        }
        [self fourImagesDivision:img1 :img2 :img3 :img4];
    }
     */
}

- (UIImage *)oneImageSetting:(UIImage *)image1{
    self.returnImg = [[UIImage alloc]init];
    
    image1 = [self imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_WIDTH) :image1];
    self.returnImg = image1;
    return image1;
}

- (UIImage *)twoImagesDivision:(UIImage *)image1 :(UIImage *)image2 {
    self.returnImg = [[UIImage alloc]init];
    
    image1 = [self imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_HEIGHT) :image1];
    image2 = [self imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_HEIGHT) :image2];
    
    CGSize size = CGSizeMake(image1.size.width + image2.size.width, MIN_IMG_HEIGHT);
    UIGraphicsBeginImageContext(size);
    
    if(image1.size.height > image2.size.height){
        [image1 drawInRect:CGRectMake(0, 0, image1.size.width - 1, image1.size.height)];
        [image2 drawInRect:CGRectMake(image1.size.width+1, image1.size.height/2 - image2.size.height/2, image1.size.width, image2.size.height)];
    } else {
        [image1 drawInRect:CGRectMake(0, image2.size.height/2 - image1.size.height/2, image1.size.width - 1, image1.size.height)];
        [image2 drawInRect:CGRectMake(image1.size.width+1, 0, image2.size.width, image2.size.height)];
    }
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.returnImg = finalImage;
    return finalImage;
}

- (UIImage *)threeImagesDivision:(UIImage *)image1 :(UIImage *)image2 :(UIImage *)image3 {
    self.returnImg = [[UIImage alloc]init];
    
    image1 = [self imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_HEIGHT, MIN_IMG_WIDTH) :image1];
    image2 = [self imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image2];
    image3 = [self imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image3];
    
    CGSize size = CGSizeMake(image2.size.width + image3.size.width, image1.size.height);
    UIGraphicsBeginImageContext(size);
    
    if(image2.size.height > image3.size.height){
        [image2 drawInRect:CGRectMake(0, 0, image2.size.width - 1, image2.size.height)];
        [image3 drawInRect:CGRectMake(image2.size.width+1, image2.size.height/2 - image3.size.height/2, image2.size.width, image3.size.height)];
    } else {
        [image2 drawInRect:CGRectMake(0, image3.size.height/2 - image2.size.height/2, image2.size.width - 1, image2.size.height)];
        [image3 drawInRect:CGRectMake(image2.size.width+1, 0, image3.size.width, image3.size.height)];
    }
    
    UIImage *secondImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGSize finalSize = CGSizeMake(image1.size.width, image1.size.height + secondImage.size.height);
    UIGraphicsBeginImageContext(finalSize);
    
    [image1 drawInRect:CGRectMake(0 ,0, finalSize.width, image1.size.height - 1)];
    [secondImage drawInRect:CGRectMake(0, image1.size.height+1, finalSize.width, secondImage.size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.returnImg = finalImage;
    return finalImage;
}

- (UIImage *)fourImagesDivision:(UIImage *)image1 :(UIImage *)image2 :(UIImage *)image3 :(UIImage *)image4 {
    self.returnImg = [[UIImage alloc]init];
    
    image1 = [self imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image1];
    image2 = [self imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image2];
    image3 = [self imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image3];
    image4 = [self imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image4];
    
    CGSize firstSize = CGSizeMake(image1.size.width + image2.size.width, MIN_IMG_WIDTH);
    UIGraphicsBeginImageContext(firstSize);
    
    if(image1.size.height > image2.size.height){
        [image1 drawInRect:CGRectMake(0, 0, image1.size.width - 1, image1.size.height)];
        [image2 drawInRect:CGRectMake(image1.size.width+1, image1.size.height/2 - image2.size.height/2, image1.size.width, image2.size.height)];
    } else {
        [image1 drawInRect:CGRectMake(0, image2.size.height/2 - image1.size.height/2, image1.size.width - 1, image1.size.height)];
        [image2 drawInRect:CGRectMake(image1.size.width+1, 0, image2.size.width, image2.size.height)];
    }
    
    UIImage *firstImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGSize secondSize = CGSizeMake(image3.size.width + image4.size.width, MIN_IMG_WIDTH);
    UIGraphicsBeginImageContext(secondSize);
    
    if(image3.size.height > image4.size.height){
        [image3 drawInRect:CGRectMake(0, 0, image3.size.width - 1, image3.size.height)];
        [image4 drawInRect:CGRectMake(image3.size.width+1, image3.size.height/2 - image4.size.height/2, image3.size.width, image4.size.height)];
    } else {
        [image3 drawInRect:CGRectMake(0, image4.size.height/2 - image3.size.height/2, image3.size.width - 1, image3.size.height)];
        [image4 drawInRect:CGRectMake(image3.size.width+1, 0, image4.size.width, image4.size.height)];
    }
    
    UIImage *secondImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGSize finalSize = CGSizeMake(firstImage.size.width, firstImage.size.height + secondImage.size.height);
    UIGraphicsBeginImageContext(finalSize);
    
    [firstImage drawInRect:CGRectMake(0 ,0, finalSize.width, firstImage.size.height - 1)];
    [secondImage drawInRect:CGRectMake(0, firstImage.size.height+1, finalSize.width, secondImage.size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.returnImg = finalImage;
    return finalImage;
}

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    double newCropWidth, newCropHeight;
    
    if(image.size.width < image.size.height){
        if (image.size.width < size.width) {
            newCropWidth = size.width;
        }
        else {
            newCropWidth = image.size.width;
        }
        newCropHeight = (newCropWidth * size.height)/size.width;
    } else {
        if (image.size.height < size.height) {
            newCropHeight = size.height;
        }
        else {
            newCropHeight = image.size.height;
        }
        newCropWidth = (newCropHeight * size.width)/size.height;
    }
    
    double x = image.size.width/2.0 - newCropWidth/2.0;
    double y = image.size.height/2.0 - newCropHeight/2.0;
    
    CGRect cropRect = CGRectMake(x, y, newCropWidth, newCropHeight);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

- (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second
{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [second drawInRect:CGRectMake(firstWidth, 0, secondWidth, secondHeight)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}


-(UIImage *)saveThumbImage :(NSString *)folder :(NSString *)thumbFilePath{
    NSUserDefaults *notiDefaults = [[NSUserDefaults alloc] initWithSuiteName:NOTI_GRP_NAME];
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *savePath = [NSString stringWithFormat:@"/%@/%@/%@/%@/", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [notiDefaults objectForKey:@"COMPNO"], folder];
   
    //NSLog(@"savePath : %@", savePath);
    
    NSString *fileName = [thumbFilePath lastPathComponent];
    NSString *chkFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@", fileName]];
    UIImage *image = nil;
    
    if([thumbFilePath rangeOfString:@"https://"].location != NSNotFound || [thumbFilePath rangeOfString:@"http://"].location != NSNotFound){
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:chkFile];
        if(!fileExists){
            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[thumbFilePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
            NSData *imageData = UIImagePNGRepresentation(thumbImage);
            [imageData writeToFile:chkFile atomically:YES];
        }
        
        NSData *data = [NSData dataWithContentsOfFile:chkFile];
        image = [UIImage imageWithData:data];
        
    } else {
        image = nil;
    }
    
    return image;
}

#pragma mark - IMAGE
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize :(UIImage *)image{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    //UIGraphicsBeginImageContext(targetSize); // this will crop
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)getScaledLowImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    
    scaleFactor = width / oldWidth;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    //Chat, RMQServer, PushReceive 에서는 이걸 사용
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    if (oldWidth < width && oldHeight < height)
        return image;
    
    CGFloat scaleFactorW =1;
    CGFloat scaleFactorH =1;
    
    if (oldWidth > width)
        scaleFactorW = width / oldWidth;
    if(oldHeight > height)
        scaleFactorH = height / oldHeight;
    
    CGFloat scaleFactor = (scaleFactorW<scaleFactorH)?scaleFactorW:scaleFactorH;
    
    
    CGFloat newHeight = oldHeight * scaleFactor;
    //CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(width, newHeight);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

@implementation NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding)));
}
+ (NSString *)urlDecodeString:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                             (CFStringRef)temp,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8));
    return result;
}

@end
