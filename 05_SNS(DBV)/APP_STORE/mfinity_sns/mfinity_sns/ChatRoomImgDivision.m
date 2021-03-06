//
//  ChatRoomImgDivision.m
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 14..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatRoomImgDivision.h"
#import <QuartzCore/QuartzCore.h>
#import "MFDBHelper.h"
#import "MFUtil.h"

#define MIN_WIDTH 50
#define EXPAND_SIZE 60

#define MIN_IMG_WIDTH 45
#define MIN_IMG_HEIGHT 90


@implementation ChatRoomImgDivision{
    
}

- (void)roomImgSetting:(NSMutableArray *)array :(NSString *)memberCnt{
    NSLog(@"[mem : %@] array : %@", memberCnt, array);
    UIImage *img1 = [[UIImage alloc]init];
    UIImage *img2 = [[UIImage alloc]init];
    UIImage *img3 = [[UIImage alloc]init];
    UIImage *img4 = [[UIImage alloc]init];
    
    if([memberCnt integerValue] < 3){
        if(array.count == 1){
//            img1 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:0] num:nil];
            img1 = [self getImageFromData:[array objectAtIndex:0]];
            
        } else {
            img1 = [UIImage imageNamed:@"profile_default.png"];
        }
        [self oneImageSetting:img1];
        
    } else if([memberCnt integerValue] == 3){
        if(array.count == 2){
//            img1 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:0] num:nil];
//            img2 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:1] num:nil];
            img1 = [self getImageFromData:[array objectAtIndex:0]];
            img2 = [self getImageFromData:[array objectAtIndex:1]];
            
        } else if(array.count == 1){
//            img1 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:0] num:nil];
            img1 = [self getImageFromData:[array objectAtIndex:0]];
            img2 = [UIImage imageNamed:@"profile_default.png"];
            
        } else {
            img1 = [UIImage imageNamed:@"profile_default.png"];
            img2 = [UIImage imageNamed:@"profile_default.png"];
        }
        [self twoImagesDivision:img1 :img2];
        
    } else if ([memberCnt integerValue] == 4){
        if(array.count == 3){
//            img1 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:0] num:nil];
//            img2 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:1] num:nil];
//            img3 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:2] num:nil];
            img1 = [self getImageFromData:[array objectAtIndex:0]];
            img2 = [self getImageFromData:[array objectAtIndex:1]];
            img3 = [self getImageFromData:[array objectAtIndex:2]];
            
        } else if(array.count == 2){
//            img1 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:0] num:nil];
//            img2 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:1] num:nil];
            img1 = [self getImageFromData:[array objectAtIndex:0]];
            img2 = [self getImageFromData:[array objectAtIndex:1]];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            
        } else if(array.count == 1){
//            img1 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:0] num:nil];
            img1 = [self getImageFromData:[array objectAtIndex:0]];
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
//            img1 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:0] num:nil];
//            img2 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:1] num:nil];
//            img3 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:2] num:nil];
//            img4 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:3] num:nil];
            img1 = [self getImageFromData:[array objectAtIndex:0]];
            img2 = [self getImageFromData:[array objectAtIndex:1]];
            img3 = [self getImageFromData:[array objectAtIndex:2]];
            img4 = [self getImageFromData:[array objectAtIndex:3]];
            
        } else if(array.count == 3){
//            img1 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:0] num:nil];
//            img2 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:1] num:nil];
//            img3 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:2] num:nil];
            img1 = [self getImageFromData:[array objectAtIndex:0]];
            img2 = [self getImageFromData:[array objectAtIndex:1]];
            img3 = [self getImageFromData:[array objectAtIndex:2]];
            img4 = [UIImage imageNamed:@"profile_default.png"];
            
        } else if(array.count == 2){
//            img1 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:0] num:nil];
//            img2 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:1] num:nil];
            img1 = [self getImageFromData:[array objectAtIndex:0]];
            img2 = [self getImageFromData:[array objectAtIndex:1]];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            img4 = [UIImage imageNamed:@"profile_default.png"];
            
        } else if(array.count == 1){
//            img1 = [MFUtil saveThumbImage:@"Profile" path:[array objectAtIndex:0] num:nil];
            img1 = [self getImageFromData:[array objectAtIndex:0]];
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
}

-(UIImage*)getImageFromData:(NSString *)imgPath{
    UIImage *image = nil;
    
    if([imgPath rangeOfString:@"https://"].location != NSNotFound || [imgPath rangeOfString:@"http://"].location != NSNotFound){
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
        
    } else {
        image = nil;
    }
    
    return image;
}

/*
- (void)roomImgSetting:(NSString *)imgPath :(NSMutableArray *)array :(NSString *)memberCnt{
    
    UIImage *img1 = [[UIImage alloc]init];
    UIImage *img2 = [[UIImage alloc]init];
    UIImage *img3 = [[UIImage alloc]init];
    UIImage *img4 = [[UIImage alloc]init];
    
//    NSString *tmpPath = NSTemporaryDirectory();
//    for(int i=0; i<array.count; i++){
//        //프로필이미지가 로컬에 있는지 확인, 없으면 로컬에 저장
//        NSString *fileName = [[array objectAtIndex:i] lastPathComponent];
//        NSString *chkFile = [tmpPath stringByAppendingPathComponent:fileName];
//        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:chkFile];
//        if(!fileExists){
//            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
//            NSData *imageData = UIImagePNGRepresentation(thumbImage);
//
//            NSString *thumbImgPath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
//            [imageData writeToFile:thumbImgPath atomically:YES];
//        }
//    }
    
    if([memberCnt integerValue] == 3){
        if(array.count == 2){
            //img1 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:0] lastPathComponent]]]]];
            img1 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            //img2 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:1] lastPathComponent]]]]];
            img2 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:1]];
        } else if(array.count == 1){
            //img1 = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
            img1 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [UIImage imageNamed:@"profile_default.png"];
        } else {
            img1 = [UIImage imageNamed:@"profile_default.png"];
            img2 = [UIImage imageNamed:@"profile_default.png"];
        }
        [self twoImagesDivision:img1 :img2];
        
    } else if ([memberCnt integerValue] == 4){
        if(array.count == 3){
//            img1 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:0] lastPathComponent]]]]];
//            img2 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:1] lastPathComponent]]]]];
//            img3 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:2] lastPathComponent]]]]];
            
            img1 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:2]];
            
        } else if(array.count == 2){
//            img1 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:0] lastPathComponent]]]]];
//            img2 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:1] lastPathComponent]]]]];
            
            img1 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            
        } else if(array.count == 1){
//            img1 = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
            
            img1 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:0]];
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
//            img1 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:0] lastPathComponent]]]]];
//            img2 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:1] lastPathComponent]]]]];
//            img3 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:2] lastPathComponent]]]]];
//            img4 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:3] lastPathComponent]]]]];
            
            img1 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:2]];
            img4 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:3]];
            
        } else if(array.count == 3){
//            img1 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:0] lastPathComponent]]]]];
//            img2 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:1] lastPathComponent]]]]];
//            img3 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:2] lastPathComponent]]]]];
            
            img1 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:2]];
            img4 = [UIImage imageNamed:@"profile_default.png"];
        } else if(array.count == 2){
//            img1 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:0] lastPathComponent]]]]];
//            img2 = [UIImage imageWithData:[NSData dataWithContentsOfFile:[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[[array objectAtIndex:1] lastPathComponent]]]]];
            
            img1 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:0]];
            img2 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:1]];
            img3 = [UIImage imageNamed:@"profile_default.png"];
            img4 = [UIImage imageNamed:@"profile_default.png"];
        } else if(array.count == 1){
//            img1 = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:[imgPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
            
            img1 = [MFUtil saveThumbImage:@"Profile" :[array objectAtIndex:0]];
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
}
*/

- (UIImage *)oneImageSetting:(UIImage *)image1{
    self.returnImg = [[UIImage alloc]init];
    
    image1 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_WIDTH) :image1];
    self.returnImg = image1;
    return image1;
}

- (UIImage *)twoImagesDivision:(UIImage *)image1 :(UIImage *)image2 {
    self.returnImg = [[UIImage alloc]init];
    
    image1 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_HEIGHT) :image1];
    image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_HEIGHT) :image2];
    
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
    
    //Add image to view
//    self.resultImg.image = finalImage;
//    self.resultImg.layer.cornerRadius = self.resultImg.frame.size.width/2;
//    self.resultImg.clipsToBounds = YES;
//    self.resultImg.contentMode = UIViewContentModeScaleAspectFit;
    
    self.returnImg = finalImage;
    return finalImage;
}

- (UIImage *)threeImagesDivision:(UIImage *)image1 :(UIImage *)image2 :(UIImage *)image3 {
    self.returnImg = [[UIImage alloc]init];
    
    image1 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_HEIGHT, MIN_IMG_WIDTH) :image1];
    image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image2];
    image3 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image3];
    
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
    
    image1 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image1];
    image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image2];
    image3 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image3];
    image4 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(MIN_IMG_WIDTH, MIN_IMG_WIDTH) :image4];
    
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

@end
