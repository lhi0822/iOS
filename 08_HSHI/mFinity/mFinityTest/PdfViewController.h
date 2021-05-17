//
//  PdfViewController.h
//  mFinity
//
//  Created by hilee on 28/11/2018.
//  Copyright © 2018 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"

@interface PdfViewController : UIViewController <UINavigationBarDelegate, UIScrollViewDelegate>{
    UIWebView *_webView;
    IBOutlet UIScrollView *_scrollView;
    
}

@property (strong, nonatomic) NSString *fileUrl;
@property (nonatomic, assign) BOOL isTabBar;

@end

