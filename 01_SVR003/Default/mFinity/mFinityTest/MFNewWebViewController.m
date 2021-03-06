//
//  MFNewWebViewController.m
//  mFinity
//
//  Created by hilee on 2018. 10. 30..
//  Copyright © 2018년 Jun hyeong Park. All rights reserved.
//

#import "MFNewWebViewController.h"

@interface MFNewWebViewController ()

@end

@implementation MFNewWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    
    //label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = @"New Web";
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = label;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", @"") style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClick)];
    
    //[self initWKWebView];
    //[webViewFrame addSubview:self.webView];
    //[self.webView reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)leftButtonClick{
    [self.delegate closeButtonClick:self];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webView) {
        //NSLog(@"estimatedProgress : %f", self.webView.estimatedProgress);
        [self.progressView setProgress:self.webView.estimatedProgress];
        /*
         if(self.webView.estimatedProgress >= 1.0f) {
         [self.progressView setHidden:YES];
         }*/
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)initWKWebView{
    NSLog(@"%s",__FUNCTION__);
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userController = [[WKUserContentController alloc]init];
    //[self setMfnpMethod:userController];
    webViewConfig.userContentController = userController;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGRect webViewRect = CGRectMake(webViewFrame.frame.origin.x, webViewFrame.frame.origin.y, screenWidth, screenHeight);
    
    self.webView = [[WKWebView alloc] initWithFrame:webViewRect configuration:self.configuration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.scrollView.bounces = NO;
    //NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    //[self.webView loadRequest:self.startRequest];
    /*
     if ([[page_url substringToIndex:7] isEqualToString:@"http://"]||[[page_url substringToIndex:8] isEqualToString:@"https://"]) {
     
     NSURL *nsurl=[NSURL URLWithString:page_url];
     NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
     [self.webView loadRequest:self.startRequest];
     
     
     }else{
     NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
     NSString *filePath = [NSString stringWithFormat:@"file://%@",self.startRequest];
     if ([[[UIDevice currentDevice] systemVersion] intValue] >= 9) {
     [self.webView loadFileURL:[NSURL URLWithString:filePath] allowingReadAccessToURL:[NSURL fileURLWithPath:documentsDir]];
     }else{
     [self.webView loadHTMLString:filePath baseURL:[NSURL fileURLWithPath:documentsDir]];
     }
     }
     */
    [webViewFrame addSubview:self.webView];
    
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
