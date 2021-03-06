//
//  TaskFileCollectionViewCell.m
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 13..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "TaskFileCollectionViewCell.h"
#import "MFDBHelper.h"
#import "AppDelegate.h"

@implementation TaskFileCollectionViewCell {
    AppDelegate *appDelegate;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setUpCellWithImgArray:(NSArray *)array { //TASK WIRTE & EDIT
    @try{
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        CGFloat xbase = 10;
        CGFloat width = 90;
        
        for(UIView *subview in [self.scrollView subviews]) {
            [subview removeFromSuperview];
        }
        
        [self.scrollView setScrollEnabled:YES];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        
        for(int i = 0; i < [array count]; i++) {
//            UIImage *image = [array objectAtIndex:i];
//            UIView *custom = [self createCustomViewWithImage: image];
//            custom.tag = i+1;
            
            
            UIView *custom;
            if([[array objectAtIndex:i] isKindOfClass:NSClassFromString(@"NSString")]){
                NSString *imgUrl = [array objectAtIndex:i];
                custom = [self createCustomViewWithUrl:imgUrl];
                custom.tag = i+1;
                
            } else {
                UIImage *image = [array objectAtIndex:i];
                custom = [self createCustomViewWithImage: image];
                custom.tag = i+1;
            }
            
            self.images = array;
            
            if([self.fromSegue isEqualToString:@"TASK_WRITE_FILE_CELL"]){
                UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(custom.frame.size.width-32, custom.frame.size.height-32, 30, 30)];
                button.layer.cornerRadius = button.frame.size.width/2;
                button.clipsToBounds = YES;
                button.contentMode = UIViewContentModeScaleAspectFill;
                button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                button.layer.borderWidth = 0.3;
                button.tag = i+1;
                [button setTitle:@"X" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(imgDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
                [custom addSubview:button];
            }
            
            [self.scrollView addSubview:custom];
            [custom setFrame:CGRectMake(xbase, 7, width, 90)];
            xbase += 10 + width;
        }
        
        [self.scrollView setContentSize:CGSizeMake(xbase, self.scrollView.frame.size.height)];
        self.scrollView.delegate = self;
        
    } @catch(NSException *exception){
        
    }
    
}

- (void)setUpCellWithArray:(NSArray *)array { //TASK DETAIL
    @try{
        CGFloat xbase = 10;
        CGFloat width = 90;
        
        for(UIView *subview in [self.scrollView subviews]) {
            [subview removeFromSuperview];
        }
        
        [self.scrollView setScrollEnabled:YES];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        
        for(int i = 0; i < [array count]; i++) {
            //        UIImage *image = [array objectAtIndex:i];
            //        UIView *custom = [self createCustomViewWithImage: image];
            //        [self.scrollView addSubview:custom];
            //        [custom setFrame:CGRectMake(xbase, 7, width, 90)];
            //        xbase += 10 + width;
            
            UIView *custom;
            if([[array objectAtIndex:i] isKindOfClass:NSClassFromString(@"NSString")]){
                NSString *imgUrl = [array objectAtIndex:i];
                custom = [self createCustomViewWithUrl:imgUrl];
                custom.tag = i+1;
                
            } else {
                UIImage *image = [array objectAtIndex:i];
                custom = [self createCustomViewWithImage: image];
                custom.tag = i+1;
            }
            
            
            if([self.fromSegue isEqualToString:@"TASK_WRITE_FILE_CELL"]){
                UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(custom.frame.size.width-32, custom.frame.size.height-32, 30, 30)];
                button.layer.cornerRadius = button.frame.size.width/2;
                button.clipsToBounds = YES;
                button.contentMode = UIViewContentModeScaleAspectFill;
                button.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
                button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                button.layer.borderWidth = 0.3;
                button.tag = i+1;
                [button setTitle:@"X" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(imgDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
                [custom addSubview:button];
            }
            
            [self.scrollView addSubview:custom];
            [custom setFrame:CGRectMake(xbase, 7, width, 90)];
            custom.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            custom.layer.borderWidth = 0.3;
            xbase += 10 + width;
        }
        
        [self.scrollView setContentSize:CGSizeMake(xbase, self.scrollView.frame.size.height)];
        self.scrollView.delegate = self;
    } @catch(NSException *exception){
        
    }
    
}

- (UIImage *)checkFileType:(NSString *)filePath{
    @try{
        UIImage *resultImg = nil;
        
        NSString *fileName = @"";
        @try{
            NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
            fileName = [filePath substringFromIndex:range.location+1];
            
        } @catch (NSException *exception) {
            fileName = filePath;
            NSLog(@"Exception : %@", exception);
        }
        
        NSRange range2 = [fileName rangeOfString:@"." options:NSBackwardsSearch];
        NSString *fileExt = [[fileName substringFromIndex:range2.location+1] lowercaseString];
        
        if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
            resultImg = [UIImage imageNamed:@"file_img.png"];
            
        } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
            resultImg = [UIImage imageNamed:@"file_movie.png"];
            
        } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
            resultImg = [UIImage imageNamed:@"file_music.png"];
            
        } else if([fileExt isEqualToString:@"psd"]){
            resultImg = [UIImage imageNamed:@"file_psd.png"];
            
        } else if([fileExt isEqualToString:@"ai"]){
            resultImg = [UIImage imageNamed:@"file_ai.png"];
            
        } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
            resultImg = [UIImage imageNamed:@"file_word.png"];
            
        } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
            resultImg = [UIImage imageNamed:@"file_ppt.png"];
            
        } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
            resultImg = [UIImage imageNamed:@"file_excel.png"];
            
        } else if([fileExt isEqualToString:@"pdf"]){
            resultImg = [UIImage imageNamed:@"file_pdf.png"];
            
        } else if([fileExt isEqualToString:@"txt"]){
            resultImg = [UIImage imageNamed:@"file_txt.png"];
            
        } else if([fileExt isEqualToString:@"hwp"]){
            resultImg = [UIImage imageNamed:@"file_hwp.png"];
            
        } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
            resultImg = [UIImage imageNamed:@"file_zip.png"];
            
        } else {
            resultImg = [UIImage imageNamed:@"file_document.png"];
        }
        
        return resultImg;
        
    } @catch(NSException *exception){
        
    }
    
}

//hilee Custom
-(UIView *)createCustomViewWithUrl:(NSString *)imgUrl {
    @try{
        UIView *custom = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 90)];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 90, 90)];
        UILabel *fileNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, imageView.frame.size.height-40, imageView.frame.size.width-20, 30)];
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake((imageView.frame.size.width/2)-(30/2), fileNameLabel.frame.origin.y-30, 30, 30)];
        
        NSString *fileName = @"";
        @try{
            NSRange range = [imgUrl rangeOfString:@"/" options:NSBackwardsSearch];
            fileName = [imgUrl substringFromIndex:range.location+1];
            
        } @catch (NSException *exception) {
            fileName = imgUrl;
            NSLog(@"Exception : %@", exception);
        }
        
        NSRange range2 = [fileName rangeOfString:@"." options:NSBackwardsSearch];
        NSString *fileExt = [[fileName substringFromIndex:range2.location+1] lowercaseString];
        
        if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
            
            imageView.hidden=NO;
            imageView2.hidden=YES;
            fileNameLabel.hidden=YES;
            
            UIImage *attachImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90):[MFUtil saveThumbImage:@"Task" path:imgUrl num:nil]];
            
            [imageView setImage:attachImg];
            [custom addSubview:imageView];
            
        } else {
            imageView.hidden=YES;
            imageView2.hidden=NO;
            fileNameLabel.hidden=NO;
            
            fileNameLabel.text = [imgUrl lastPathComponent];
            [fileNameLabel setFont:[UIFont systemFontOfSize:11]];
            fileNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            
            UIImage *fileImg = [self checkFileType:imgUrl];
            [imageView2 setImage:fileImg];
            
            [custom addSubview:imageView2];
            [custom addSubview:fileNameLabel];
        }
        [custom setBackgroundColor:[UIColor clearColor]];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [custom addGestureRecognizer:singleFingerTap];
        
        return custom;
        
    } @catch(NSException *exception){
        
    }
    
}

-(UIView *)createCustomViewWithImage:(UIImage *)image {
    @try{
        UIView *custom = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 90)];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 90, 90)];
        [imageView setImage:[MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90):image]];
        
        [custom addSubview:imageView];
        [custom setBackgroundColor:[UIColor clearColor]];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [custom addGestureRecognizer:singleFingerTap];
        
        return custom;
        
    } @catch(NSException *exception){
        
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //[self containingScrollViewDidEndDragging:scrollView];
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    UIView *selectedView = (UIView *)recognizer.view;
    [_cellDelegate cellSelected:selectedView];
}

-(void)imgDeleteClick:(UIButton *)sender{
    @try{
//        NSLog(@"imgDeleteClick images : %@", self.images);
        NSLog(@"sender.tag : %lu", sender.tag);
        NSLog(@"array : %@", self.images);
        
//        if(_isEdit){
            [_cellDelegate editImgDeleteClick:sender :self.images :self.imgDataArr :self.imgNameArr]; //업무 수정
//        } else {
//            [_cellDelegate imgDeleteClick:sender]; //업무 생성
//        }
    } @catch(NSException *exception){
        
    }
}

@end
