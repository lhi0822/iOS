//
//  contentViewController.h
//  knfc
//
//  Created by 최형준 on 2015. 1. 21..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface contentViewController : UIViewController {
    UIWebView *webView;
    NSString *surl, *stitle;
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *surl, *stitle;

@end
