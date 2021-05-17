//
//  contentViewController.m
//  knfc
//
//  Created by 최형준 on 2015. 1. 21..
//  Copyright (c) 2015년 digiquitous. All rights reserved.
//

#import "contentViewController.h"

@interface contentViewController ()

@end

@implementation contentViewController
@synthesize webView, surl, stitle;

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    UIButton *btnback = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnback setImage:[UIImage imageNamed:@"btnback.png"] forState:UIControlStateNormal];
    btnback.frame = CGRectMake(0, 0, 44, 44);
    [btnback addTarget:self action:@selector(btnbackPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftbtn = [[UIBarButtonItem alloc] initWithCustomView:btnback];
    self.navigationItem.leftBarButtonItem = leftbtn;
    
    UILabel *lbltitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    lbltitle.textColor = [UIColor whiteColor];
    lbltitle.font = [UIFont boldSystemFontOfSize:16];
    lbltitle.textAlignment = NSTextAlignmentCenter;
    lbltitle.text = self.stitle;
    [lbltitle sizeToFit];
    
    self.navigationItem.titleView = lbltitle;
    
    [self.webView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height-(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height))];
    self.webView.scrollView.bounces = NO;
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.surl]]];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnbackPress:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else{
        //[self.webView reload];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
