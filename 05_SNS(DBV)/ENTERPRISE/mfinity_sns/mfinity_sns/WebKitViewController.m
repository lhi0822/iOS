//
//  WebKitViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 4..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "WebKitViewController.h"
#import "AppDelegate.h"

@interface WebKitViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation WebKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"Anymate", @"Anymate")];
    
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [button setImage:[self getScaledImage:[UIImage imageNamed:@"logo_anymate.png"] scaledToMaxWidth:50.0f] forState:UIControlStateNormal];
    //    button.adjustsImageWhenDisabled = NO;
    //    button.frame = CGRectMake(0, 0, 50, 50);
    //
    //    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    //    self.navigationItem.leftBarButtonItem = customBarItem;
    self.navigationItem.hidesBackButton = YES;
    
    NSString *url;
    NSString *legacyNm = [[MFSingleton sharedInstance] legacyName]; //appDelegate.legacy_name;
    if([legacyNm isEqualToString:@"NONE"]){
        url = @"http://gw.dbvalley.com/m";
    } else if([legacyNm isEqualToString:@"ANYMATE"]){
        url = [NSString stringWithFormat:@"%@/m/main/?mode=portal",[appDelegate.appPrefs objectForKey:@"URL"]];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]];
    [self.webView loadRequest:request];
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
        [appDelegate.appPrefs setObject:@"4" forKey:[appDelegate setPreferencesKey:@"LASTTABITEM"]];
    } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
        
    }
    [appDelegate.appPrefs synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
