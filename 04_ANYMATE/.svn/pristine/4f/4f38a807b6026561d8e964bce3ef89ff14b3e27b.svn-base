//
//  IntroViewController.m
//  Anymate
//
//  Created by hilee on 2017. 12. 26..
//  Copyright © 2017년 Kyeong In Park. All rights reserved.
//

#import "IntroViewController.h"
#import "LoginViewController.h"
#import "UrlSettingViewController.h"

@interface IntroViewController () {
    int count;
    int endCount;
    NSTimer *myTimer;
}

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    
    [self setTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setTimer{
    count = 0;
    endCount = 1;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

-(void)handleTimer:(NSTimer *)timer {
    count++;
    if(count == endCount){
        [self performSegueWithIdentifier:@"PUSH_LOGIN_VIEW" sender:self];
        [myTimer invalidate];
    }
}

- (void)dealloc {
    [_imgView release];
    [super dealloc];
}
@end
