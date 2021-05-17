//
//  PdfViewController.m
//  mFinity
//
//  Created by hilee on 28/11/2018.
//  Copyright © 2018 Jun hyeong Park. All rights reserved.
//

#import "PdfViewController.h"

@interface PdfViewController () {
    MFinityAppDelegate *appDelegate;
}

@end

@implementation PdfViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"닫기", @"")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(rightSideMenuButtonPressed:)];
    
    
    if (!_isTabBar) {
        self.hidesBottomBarWhenPushed = YES;
    }else{
        self.hidesBottomBarWhenPushed = NO;
    }
    
    UIWebView *webView = [[UIWebView alloc]init];
    webView.contentMode = UIViewContentModeScaleAspectFit;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    [_scrollView setScrollEnabled:YES];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    
    _scrollView.contentSize = webView.frame.size;
    [_scrollView addSubview:webView];
    _webView = webView;
    
    _webView.scalesPageToFit = YES;
    
    [_scrollView setMaximumZoomScale:3.0f];
    [_scrollView setMinimumZoomScale:1.0f];
    
    NSLog(@"fileUrl : %@", self.fileUrl);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [_webView loadRequest:request];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
