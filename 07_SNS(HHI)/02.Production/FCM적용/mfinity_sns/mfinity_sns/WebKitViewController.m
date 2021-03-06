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
    self.webView.delegate = self;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
    
    NSString *url;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *legacyNm = [[MFSingleton sharedInstance] legacyName];
    if([legacyNm isEqualToString:@"NONE"]){
        url = @"http://gw.dbvalley.com/m";
        request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]];
        
    } else if([legacyNm isEqualToString:@"ANYMATE"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"Anymate", @"Anymate")];
        url = [NSString stringWithFormat:@"%@/m/main/?mode=portal",[appDelegate.appPrefs objectForKey:@"URL"]];
        request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]];
    
    } else if([legacyNm isEqualToString:@"HHI"]){
        NSLog(@"workLink : %@", self.workLink);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                                style:UIBarButtonItemStylePlain target:self action:@selector(leftSideMenuButtonPressed:)];
        
        NSString *urlString;
        if([self.workLink isEqualToString:@"(HSE)안전활동 등록"]){
            urlString = [[NSString alloc] initWithFormat:@"https://hse.hhi.co.kr/Pages/WZ/HISNS_IF.aspx"];
            
        }
        
        NSString *paramString = [[NSString alloc]initWithFormat:@"EMP_NO=%@&FILE_URL=%@", [self.paramDic objectForKey:@"EMP_NO"], [self.paramDic objectForKey:@"FILE_URL"]];
        NSLog(@"urlStr : %@", urlString);
        NSLog(@"paramSTRRRR : %@",paramString);
        NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: paramData];
        [request setTimeoutInterval:10.0];
    }
    
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"title : %@", theTitle);
    
    NSString *legacyNm = [[MFSingleton sharedInstance] legacyName];
    if([legacyNm isEqualToString:@"HHI"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:theTitle];
    }
}

@end
