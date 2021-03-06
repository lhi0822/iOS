//
//  ImageViewerController.m
//  mFinity_HHI
//
//  Created by hilee on 21/08/2019.
//  Copyright © 2019 Jun hyeong Park. All rights reserved.
//

#import "ImageViewerController.h"
#import "MFinityAppDelegate.h"

#define BASEHEIGHT    300.0f
#define NPAGES        3

@interface ImageViewerController () {
    CGFloat lastScale;
    UIActivityIndicatorView *indicator;
    MFinityAppDelegate *appDelegate;
}

@end

@implementation ImageViewerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left setImage:[self getScaledImage:[UIImage imageNamed:@"back.png"] scaledToMaxWidth:21.0f] forState:UIControlStateNormal];
    left.adjustsImageWhenDisabled = NO;
    left.frame = CGRectMake(0, 0, 50, 50);
    left.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 50);
    [left addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = customBarItem;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"ImageViewer";
    self.navigationItem.titleView = titleLabel;
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"ImageViewer", @"ImageViewer")
//                                                                            style:UIBarButtonItemStylePlain target:self action:@selector(leftSideMenuButtonPressed:)];
    
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    indicator.center = CGPointMake(_scrollView.center.x, self.view.center.y+(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height));
//    indicator.center = CGPointMake(self.view.center.x, self.view.center.y);
//    indicator.center = CGPointMake(_scrollView.center.x, _scrollView.center.y-(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height));
    indicator.center = CGPointMake(screenWidth/2, _scrollView.center.y-(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height));
    indicator.color = [UIColor lightGrayColor];
    [indicator startAnimating];
    [self.view addSubview:indicator];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *originImage = nil;
        if([self.imgPath rangeOfString:@"https://"].location != NSNotFound || [self.imgPath rangeOfString:@"http://"].location != NSNotFound){
            originImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
            
        } else {
            NSData *data = [NSData dataWithContentsOfFile:self.imgPath];
            originImage = [UIImage imageWithData:data];
        }
        
        UIImageView *imageView = [[UIImageView alloc]initWithImage:originImage];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        imageView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, _scrollView.frame.size.width, _scrollView.frame.size.height-(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height));
        imageView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height-(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height));
        
        [_scrollView setScrollEnabled:YES];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        
        _scrollView.contentSize = imageView.frame.size;
        [_scrollView addSubview:imageView];
        _imageView = imageView;
        
        [_scrollView setMaximumZoomScale:3.0f];
        [_scrollView setMinimumZoomScale:1.0f];
        
        [indicator stopAnimating];
    });
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width {
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
