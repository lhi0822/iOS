//
//  FileViewerController.m
//  Anymate
//
//  Created by hilee on 19/11/2019.
//  Copyright © 2019 Kyeong In Park. All rights reserved.
//

#import "FileViewerController.h"

@interface FileViewerController () {
    float expectedBytes;
    NSURLRequest *request;
    
    NSFileManager *fileManager;
    
}

@end

@implementation FileViewerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    self.navigationController.navigationBar.topItem.title = self.fileName;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"닫기", @"닫기") style:UIBarButtonItemStylePlain target:self action:@selector(rightSideMenuButtonPressed:)];
//    [self.navigationItem.rightBarButtonItem setTintColor:[appDelegate myRGBfromHex:@"19385b"]];
    
    if (@available(iOS 13.0, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        } else {
            self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:@"19385b"];
        }
    } else {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:@"19385b"];
    }
    
    fileManager = [NSFileManager defaultManager];
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;

    self.indicatorView.center = CGPointMake(self.view.center.x, self.view.center.y); //self.view.center;
    [self.indicatorView startAnimating];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_fileUrl];
            
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 60.0f;
    configuration.timeoutIntervalForResource = 60.0f;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
        if (!taskData) {
            NSLog(@"error : %@", error);
        } else {
            NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *filePath = [documentPath stringByAppendingFormat:@"/%@", appName];
            BOOL issue = [fileManager isReadableFileAtPath:filePath];
            if (issue) {
                
            } else{
                [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            filePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@", response.suggestedFilename]];
            [taskData writeToFile:filePath atomically:YES];
//            NSLog(@"filePath : %@", filePath);
            
            NSURL *url = [NSURL fileURLWithPath:filePath];
            [self.webView loadFileURL:url allowingReadAccessToURL:url.URLByDeletingLastPathComponent];
        }
    }];
    [task resume];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc {
    [_webView release];
    [_webView release];
    [_progressView release];
    [super dealloc];
}

#pragma mark - WKWebViewDelegate Method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"estimatedProgress : %f", self.webView.estimatedProgress);
        [self.progressView setProgress:self.webView.estimatedProgress];
        
         if(self.webView.estimatedProgress >= 1.0f) {
         [self.progressView setHidden:YES];
         }
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"message name : %@",message.name);
    NSLog(@"message body : %@",message.body);
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self.progressView setHidden:YES];
    
    NSLog(@"%s error : %@",__FUNCTION__,error);
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self.progressView setHidden:YES];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    self.progressView.hidden = NO;
    self.progressView.progress = 0.0f;
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    decisionHandler(WKNavigationActionPolicyAllow);
};

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    NSLog(@"finish url : %@", webView.URL);
//    NSLog(@"localFilePath : %@", [NSString urlDecodeString:webView.URL.absoluteString]);

    [self.indicatorView setHidesWhenStopped:YES];
    [self.indicatorView stopAnimating];
    
    NSString *localFilePath = [NSString urlDecodeString:webView.URL.absoluteString];
    if([localFilePath rangeOfString:@"file://"].location != NSNotFound){
        localFilePath = [localFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:localFilePath error:&error];
    if(success){
//        NSLog(@"성공");
    } else {
//        NSLog(@"실패");
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", appName]];
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
    [self.progressView setHidden:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}

@end
