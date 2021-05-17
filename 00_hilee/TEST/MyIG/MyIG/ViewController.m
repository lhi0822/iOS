//
//  ViewController.m
//  MyIG
//
//  Created by hilee on 2020/04/21.
//  Copyright © 2020 hilee. All rights reserved.
//

#import "ViewController.h"

#import "TxtTableViewCell.h"
#import "ImgTableViewCell.h"

#import "UIImageView+WebCache.h"

@interface ViewController (){
    NSMutableArray *imgArr;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    MIURLSession *getInfo = [[MIURLSession alloc]initWithURL:[NSURL URLWithString:dlqUrl] option:dlqJson2];
//    [getInfo start];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 20;
    
    
    imgArr = [NSMutableArray array];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/67/5722/20200327/120818/20200327-155207906.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/6045/20200413/1609/20200413-085538518.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/5985/20200410/120818/20200410-143148254.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/5980/20200410/120818/20200410-110829867.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/5901/20200406/120819/20200406_180110.jpg"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/5856/20200403/120818/20200403-182329801.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/5839/20200402/120819/20200402_161748.jpg"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/16/6241/20200422/120818/20200422-091948262.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/67/5722/20200327/120818/20200327-155207906.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/16/6241/20200422/120818/20200422-091951677.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/16/6241/20200422/120818/20200422-091956256.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/16/6241/20200422/120818/20200422-091957284.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/16/6241/20200422/120818/20200422-091957661.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/67/5820/20200401/120818/20200401-155042561.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/67/5722/20200327/120818/20200327-155207906.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/6045/20200413/1609/20200413-085538518.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/67/5722/20200327/120818/20200327-155207906.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/6045/20200413/1609/20200413-085538518.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/5985/20200410/120818/20200410-143148254.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/5980/20200410/120818/20200410-110829867.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/5901/20200406/120819/20200406_180110.jpg"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/5856/20200403/120818/20200403-182329801.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/5839/20200402/120819/20200402_161748.jpg"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/16/6241/20200422/120818/20200422-091948262.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/67/5722/20200327/120818/20200327-155207906.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/16/6241/20200422/120818/20200422-091951677.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/16/6241/20200422/120818/20200422-091956256.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/16/6241/20200422/120818/20200422-091957284.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/16/6241/20200422/120818/20200422-091957661.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/67/5820/20200401/120818/20200401-155042561.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/67/5722/20200327/120818/20200327-155207906.png"];
    [imgArr addObject:@"https://touch1.hhi.co.kr/snsService/snsUpload/post/10/19/6045/20200413/1609/20200413-085538518.png"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return imgArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    TxtTableViewCell *cell = (TxtTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TxtTableViewCell"];
//    if (cell == nil) {
//        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"TxtTableViewCell" owner:self options:nil];
//
//        for (id currentObject in topLevelObject) {
//            if ([currentObject isKindOfClass:[TxtTableViewCell class]]) {
//                cell = (TxtTableViewCell *) currentObject;
//                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//            }
//        }
//    }
//
//    cell.txtLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    ImgTableViewCell *imgCell = (ImgTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ImgTableViewCell"];
    if (imgCell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ImgTableViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[ImgTableViewCell class]]) {
                imgCell = (ImgTableViewCell *) currentObject;
                [imgCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    NSString *url = [imgArr objectAtIndex:indexPath.row];
    imgCell.imgView.image = nil;
    imgCell.imgView.tag = indexPath.row;
    
//    imgCell.imgView.image = [UIImage imageNamed:@"watermark.png"];
    imgCell.imgView.clipsToBounds = YES;
    
    
    [imgCell.imgView imageFromURL:url completion:^(UIImage *newImg) {
        if(!imgCell.finishReload){
            imgCell.finishReload = YES;
            
//            [imgCell.imgView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 300)];
//            imgCell.imgHeightConstraint.constant = newImg.size.height;
        
//            [imgCell.imgView.widthAnchor constraintEqualToAnchor:imgCell.imgView.heightAnchor multiplier:newImg.size.width / newImg.size.height].active = YES;
//            [imgCell.imgView setFrame:AVMakeRectWithAspectRatioInsideRect(newImg.size, imgCell.imgView.frame)];
            
            [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:url]
                               placeholderImage:[UIImage imageNamed:@"watermark.png"]
                                        options:0
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                imgCell.imgView.contentMode = UIViewContentModeScaleToFill;
                
//                if(image.size.width>self.tableView.frame.size.width-20){
//                    NSLog(@"???");
                    imgCell.imgView.image = newImg;
//                }
//                imgCell.imgView.image = image;
            }];
            
//            [self.tableView beginUpdates];
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//////            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:imgCell.imgView.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//            [self.tableView endUpdates];
        }
    }];
     
    
    /*
    [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:url]
                                   placeholderImage:[UIImage imageNamed:@"watermark.png"]
                                            options:0
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                    if(image.size.width>self.tableView.frame.size.width-20){
//                        NSLog(@"???");
//                        image = [self getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width-20];
//                    }
//                    imgCell.imgView.image = image;
        
//                    [self.tableView beginUpdates];
//                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        ////            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:imgCell.imgView.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//                    [self.tableView endUpdates];
                }];
    */
    
    return imgCell;
}

/*
- (void)imageFromURL:(NSString *)imgUrl completion:(void (^)(UIImage *))completion{
     NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:imgUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         if(error!=nil) NSLog(@"ERROR : %@", error);
 
         dispatch_async(dispatch_get_main_queue(), ^{
             UIImage *image = [UIImage imageWithData:data];
//             NSLog(@"orgWidth : %f / orgHeight : %f", image.size.width, image.size.height);
//
             CGFloat oldWidth = image.size.width;
             CGFloat oldHeight = image.size.height;
             CGFloat scaleFactor=1;
             scaleFactor = self.view.frame.size.width / oldWidth;

             CGFloat newHeight = oldHeight * scaleFactor;
             CGFloat newWidth = oldWidth * scaleFactor;
             CGSize newSize = CGSizeMake(newWidth, newHeight);

             UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
             [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
             UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
//
//             NSLog(@"11 newWidth : %f / newHeight : %f", newImage.size.width, newImage.size.height);
//             NSLog(@"11 imgView W : %f / H : %f", self.frame.size.width, self.frame.size.height);

             completion(newImage);
         });
     }];
     [task resume];
 }
*/

-(UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    
    scaleFactor = width / oldWidth;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end



@implementation UIImageView (resize)

 - (void)imageFromURL:(NSString *)imgUrl completion:(void (^)(UIImage *))completion{
     if(self.image==nil) self.image = [UIImage imageNamed:@"watermark.png"];
 
     NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:imgUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         if(error!=nil) NSLog(@"ERROR : %@", error);
 
         dispatch_async(dispatch_get_main_queue(), ^{
             UIImage *image = [UIImage imageWithData:data];
//             NSLog(@"orgWidth : %f / orgHeight : %f", image.size.width, image.size.height);
//
             CGFloat oldWidth = image.size.width;
             CGFloat oldHeight = image.size.height;
             CGFloat scaleFactor=1;
             scaleFactor = self.frame.size.width / oldWidth;
//             NSLog(@"self.frame.size.width : %f", self.frame.size.width);

             CGFloat newHeight = oldHeight * scaleFactor;
             CGFloat newWidth = oldWidth * scaleFactor;
             CGSize newSize = CGSizeMake(newWidth, newHeight);

             UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
             [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
             UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
//
//             NSLog(@"11 newWidth : %f / newHeight : %f", newImage.size.width, newImage.size.height);
//             NSLog(@"11 imgView W : %f / H : %f", self.frame.size.width, self.frame.size.height);
             
//             self.image = image;
             self.image = newImage;
             
             
//             [self setFrame:AVMakeRectWithAspectRatioInsideRect(newImage.size, self.frame)];
//             [self.widthAnchor constraintEqualToAnchor:self.heightAnchor multiplier:newImage.size.width / newImage.size.height].active = YES;
             
             [self setNeedsLayout];
             completion(newImage);
         });
     }];
     [task resume];
 }
    
@end

