//
//  PhotoViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 27..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController<NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIScrollViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate>{
    IBOutlet UIScrollView *_scrollView;
    UIImageView *_imageView;
    UIActivityIndicatorView *myIndicator;
	UIAlertView *progressAlertView;
    UIProgressView *progressView;
    NSString *mode;
    BOOL _isWebApp;
}
@property (nonatomic, assign)BOOL isWebApp;
@property (nonatomic, strong)NSString *imagePath;
-(void)rightBtnClick;
@end
