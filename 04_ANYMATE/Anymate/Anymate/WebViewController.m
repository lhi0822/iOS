//
//  WebViewController.m
//  Anymate
//
//  Created by Kyeong In Park on 12. 12. 14..
//  Copyright (c) 2012년 Kyeong In Park. All rights reserved.
//

#import "WebViewController.h"
#import "SettingViewController.h"
#import "AppDelegate.h"
#import "WebViewAdditions.h"
#import "UnpreventableUILongPressGestureRecognizer.h"
#import "LoginViewController.h"
#import "FileViewerController.h"
#import "SVProgressHUD.h"


@interface WebViewController () {
    NSString *appName;
    WKWebView *empty;
    float expectedBytes;
    NSFileManager *fileManager;
}

@end

@implementation WebViewController
@synthesize compName = _compName;
@synthesize urlString = _urlString;
//@synthesize progressView;
@synthesize selectedImageURL;

-(void)viewWillAppear:(BOOL)animated{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!appDelegate.isLoad){
        if(@available(iOS 11, *)){
            self.createdWKWebViews = [NSMutableArray array];
            [self initWKWebView];
        } else {
            [self initUIWebView];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationItem.hidesBackButton = YES;
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationController.navigationBar.topItem.title = _compName;
    self.navigationController.navigationController.title = _compName;
    naviBar.topItem.title = _compName;
    naviBar.hidden = YES;
    [naviBar setTintColor:[appDelegate myRGBfromHex:@"#19385b"]];
    [toolBar setTintColor:[appDelegate myRGBfromHex:@"#1f5289"]];
    
    fileManager = [NSFileManager defaultManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    [self.locationManager requestAlwaysAuthorization];
    
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *osVersion = myDevice.systemVersion;
    if ([osVersion intValue]<7) {
        [self.progressView setFrame:CGRectMake(self.progressView.frame.origin.x,
                                               self.progressView.frame.origin.y-65,
                                               self.progressView.frame.size.width,
                                               self.progressView.frame.size.height)];
    }
    
//    if(@available(iOS 11, *)){
//        self.createdWKWebViews = [NSMutableArray array];
//        [self initWKWebView];
//    } else {
//        [self initUIWebView];
//    }
}

-(void)viewDidAppear:(BOOL)animated{
    if ([UIApplication sharedApplication].applicationIconBadgeNumber !=0) {
        if([self.isBadge isEqualToString:@"1"]){
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        } else {
            NSLog(@"WebViewController isBadge 0");
        }
    }
    self.navigationController.navigationBar.topItem.title = _compName;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isSetPush) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:appDelegate.urlString]]];
        appDelegate.isSetPush = NO;
    }
}

- (void)initUIWebView{
    NSLog(@"%s", __func__);
    
    NSString *page_url = _urlString;
    
//    CGRect webViewRect = CGRectMake(self.webViewFrame.frame.origin.x, self.webViewFrame.frame.origin.y-[UIApplication sharedApplication].statusBarFrame.size.height, self.webViewFrame.frame.size.width, self.webViewFrame.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height);
    CGRect webViewRect = CGRectMake(self.webViewFrame.frame.origin.x, self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, self.webViewFrame.frame.size.width, self.webViewFrame.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height);
    self.uiWebView = [[UIWebView alloc] initWithFrame:webViewRect];
    
    self.uiWebView.scalesPageToFit = YES;
    self.uiWebView.mediaPlaybackRequiresUserAction = NO;
    self.uiWebView.allowsInlineMediaPlayback = YES;
    self.uiWebView.delegate = self;
    
    self.uiWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    
    UnpreventableUILongPressGestureRecognizer *longPressRecognizer = [[UnpreventableUILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.allowableMovement = 20;
    longPressRecognizer.minimumPressDuration = 1.0f;
    [self.uiWebView addGestureRecognizer:longPressRecognizer];
    
    [self.uiWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:page_url]]];
    [self.webViewFrame addSubview:_uiWebView];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isLoad = YES;
}

- (void)initWKWebView{
    NSString *page_url = _urlString;
    NSLog(@"initWKWebView urlString : %@", page_url);
    
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userController = [[WKUserContentController alloc]init];
    [self setMfnpMethod:userController];
    
    WKProcessPool *wkProcessPool = [[WKProcessPool alloc] init];
    WKPreferences *wkPreferences = [[WKPreferences alloc] init];
    
    wkPreferences.javaScriptEnabled = YES;
    wkPreferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    webViewConfig.processPool = wkProcessPool;
    webViewConfig.preferences = wkPreferences;
    
    webViewConfig.userContentController = userController;
    
    WKWebsiteDataStore *ds = [WKWebsiteDataStore nonPersistentDataStore];
    //로그인 시 저장한 세션쿠키 웹뷰에 적용
    
    if (@available(iOS 11.0, *)) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookies) {
            [ds.httpCookieStore setCookie:cookie completionHandler:nil];
        }
        webViewConfig.websiteDataStore = ds;
    }
            
    CGRect webViewRect = CGRectMake(self.webViewFrame.frame.origin.x, 0, self.webViewFrame.frame.size.width, self.webViewFrame.frame.size.height);
    self.webView = [[WKWebView alloc] initWithFrame:webViewRect configuration:webViewConfig];

    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;

    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webViewFrame addSubview:_webView];
    
    if ([[page_url substringToIndex:7] isEqualToString:@"http://"]||[[page_url substringToIndex:8] isEqualToString:@"https://"]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:page_url]]];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs removeObjectForKey:@"PUSH_DICT"];
        [prefs synchronize];
    }
    
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.africau.edu/images/default/sample.pdf"]]];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gw.dbvalley.com/m/mail/?mode=downLoad&fiid=MTBeNjE0MDMyXjIzNjY1MjI=&flag=1"]]];
    
//    NSString *file = @"http://gw.dbvalley.com/m/mail/?mode=downLoad&fiid=MTBeNjE0MDMyXjIzNjY1MjI=&flag=1";
////    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:file]];
////    [req setHTTPMethod:@"POST"];
////    [req setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
////    [self.webView loadRequest:req];
//
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:file]];
//    NSLog(@"extension : %@", [self mimeTypeForData:data]);
//    [self.webView loadData:data MIMEType:[self mimeTypeForData:data] characterEncodingName:@"" baseURL:[NSURL URLWithString:file]];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isLoad = YES;
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    
    return interactionController;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isPush && !appDelegate.isSetting) {
        NSLog(@"appDelegate.isPush && !appDelegate.isSetting");
        if ([UIApplication sharedApplication].applicationIconBadgeNumber !=0) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:appDelegate.pushURL]]];
        appDelegate.isPush = NO;
    }else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    }
}
- (void)applicationWillEnterForeground:(NSNotification *)notification{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
//    NSLog(@"webview applicationWillEnterForeground");
}
- (void)applicationDidEnterBackground:(NSNotification *)notification{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
//    NSLog(@"webview applicationDidEnterBackground");
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float y = ((UIScrollView *)[self.webView.subviews objectAtIndex:0]).contentOffset.y;
    if (y>1) {
        if (toolBar.frame.origin.y+y > 504) {
            [toolBar setFrame:CGRectMake(toolBar.frame.origin.x, toolBar.frame.origin.y+y, toolBar.frame.size.width, toolBar.frame.size.height)];
        }
    }else {
        [toolBar setFrame:CGRectMake(toolBar.frame.origin.x, 504, toolBar.frame.size.width, toolBar.frame.size.height)];
    }
}

-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
-(void)moveToPage{
    NSLog(@"moveToPage");
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[appDelegate.pushURL substringToIndex:7] isEqualToString:@"http://"]&&![[appDelegate.pushURL substringToIndex:8] isEqualToString:@"https://"]) {
        NSLog(@"url형식이 아니라면11");
        appDelegate.pushURL = [[prefs objectForKey:@"URL"] stringByAppendingString:appDelegate.pushURL];
    }
    
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:appDelegate.pushURL]]];
    
    [prefs removeObjectForKey:@"PUSH_DICT"];
    [prefs synchronize];
}

#pragma mark - UIWebView Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView{
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    self.progressView.hidden = NO;
    self.progressView.progress = 0.0f;
    
    NSURL *url = [request URL];
    NSString *urlString = [url absoluteString];
    
    if (UIWebViewNavigationTypeLinkClicked == navigationType || UIWebViewNavigationTypeOther == navigationType) {
        if([[url scheme]isEqualToString:@"anymate"]){
            NSString *host = [[request URL] host];
            if([host isEqualToString:@"getGpsLocation"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getGpsLocation:callBackFunc :userSpecific];

            }
            return NO;
        }
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *homeString = [NSString stringWithFormat:@"%@/m/",[prefs objectForKey:@"URL"]];
    NSString *homeString2 = [NSString stringWithFormat:@"%@/m/main/",[prefs objectForKey:@"URL"]];
//    NSString *homeString = @"http://gw.dbvalley.com/m/main/?mode=login&event=logOut";
//    NSString *homeString2 = @"http://gw.dbvalley.com/m/main/?mode=login&event=logoff";
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSLog(@"urlString : %@", urlString);
    appDelegate.urlString = @"";
    if ([urlString isEqualToString:homeString] || [urlString isEqualToString:homeString2]) {
        appDelegate.isLogout = YES;
//        [self.navigationController popViewControllerAnimated:NO];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *destination = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navController animated:NO completion:nil];
        
    }
    NSString *itms = [[urlString componentsSeparatedByString:@"://"] objectAtIndex:0];
//    if ([itms isEqualToString:@"itms-services"]) { //itms-services 앱스토어에서 리젝
    if ([itms rangeOfString:@"itms-service"].location != NSNotFound) {
        self.progressView.hidden = YES;
    }
    
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)wv{
    self.progressView.hidden = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%s error : %@",__FUNCTION__,error);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[error userInfo]objectForKey:@"NSErrorFailingURLStringKey"]]];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingString:@"/failedData"];
    [data writeToFile:filePath atomically:YES];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    
//    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
//    NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    NSString *folderPath = [documentPath stringByAppendingFormat:@"/%@", appName];
//    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", [[[error userInfo]objectForKey:@"NSErrorFailingURLStringKey"] lastPathComponent]]];
//    NSLog(@"filePath : %@", filePath);
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL issue = [fileManager isReadableFileAtPath:folderPath];
//    if (issue) {
//    } else{
//        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    [data writeToFile:filePath atomically:YES];
//    
//    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    self.progressView.hidden = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    if (error.code == 102) {
        if (url)
        {
            self.doic = [UIDocumentInteractionController interactionControllerWithURL:url];
            self.doic.delegate = self;

            // Action Sheet 호출
            if([self.doic presentOptionsMenuFromRect:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) inView:self.view animated:YES]){

            } else {
                NSLog(@"There is no app for this file");
            }
        }
    }else if(error.code == -999){
        return;
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    NSLog(@"%s", __func__);
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pt = [gestureRecognizer locationInView:self.uiWebView];
        
        // convert point from view to HTML coordinate system
        // 뷰의 포인트 위치를 HTML 좌표계로 변경한다.
        CGSize viewSize = [self.uiWebView frame].size;
        CGSize windowSize = [self.uiWebView windowSize];
        CGFloat f = windowSize.width / viewSize.width;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
            pt.x = pt.x * f;
            pt.y = pt.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [self.uiWebView scrollOffset];
            pt.x = pt.x * f + offset.x;
            pt.y = pt.y * f + offset.y;
        }
        [self openContextualMenuAt:pt];
    }
}
- (void)openContextualMenuAt:(CGPoint)pt{
    // Load the JavaScript code from the Resources and inject it into the web page
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"JSTools" ofType:@"js"];
    NSLog(@"js path : %@",path);
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"pt : %f, %f",pt.x,pt.y);
    NSLog(@"jsCode : %@",jsCode);
    [self.uiWebView stringByEvaluatingJavaScriptFromString:jsCode];
    
    // get the Tags at the touch location
    NSString *tags = [self.uiWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%li,%li);",(long)pt.x,(long)pt.y]];
    NSString *tagsHREF = [self.uiWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MyAppGetLinkHREFAtPoint(%li,%li);",(long)pt.x,(long)pt.y]];
    NSString *tagsSRC = [self.uiWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"MyAppGetLinkSRCAtPoint(%li,%li);",(long)pt.x,(long)pt.y]];
    
    NSLog(@"tags : %@",tags);
    NSLog(@"href : %@",tagsHREF);
    NSLog(@"src : %@",tagsSRC);
    
    if (!_actionActionSheet) {
        _actionActionSheet = nil;
    }
    _actionActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];
    
    selectedLinkURL = @"";
    self.selectedImageURL = @"";
    
    // If an image was touched, add image-related buttons.
    if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
        self.selectedImageURL = tagsSRC;
        
        if (_actionActionSheet.title == nil) {
        }
        
        [_actionActionSheet addButtonWithTitle:@"Save Image"];
    }
    // If a link is pressed add image buttons.
    if ([tags rangeOfString:@",A,"].location != NSNotFound){
        selectedLinkURL = tagsHREF;
        
        //_actionActionSheet.title = tagsHREF;
        [_actionActionSheet addButtonWithTitle:@"Open Link"];
    }
    
    if (_actionActionSheet.numberOfButtons > 0) {
        [_actionActionSheet addButtonWithTitle:@"Cancel"];
        _actionActionSheet.cancelButtonIndex = (_actionActionSheet.numberOfButtons-1);
        
        [_actionActionSheet showInView:self.uiWebView];
    }
}

#pragma mark - WKWebViewDelegate Method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"keyPath : %@",keyPath);
//    NSLog(@"object : %@",object);
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
//        NSLog(@"estimatedProgress : %f", self.webView.estimatedProgress);
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

- (void)setMfnpMethod:(WKUserContentController *)userController{
    NSLog(@"%s",__FUNCTION__);
    [userController addScriptMessageHandler:self name:@"getGpsLocation"];
}
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"message name : %@",message.name);
    NSLog(@"message body : %@",message.body);
    NSString *mfnpName = [NSString stringWithString:message.name];
    NSString *mfnpParam = [NSString stringWithString:message.body];

    if([mfnpName isEqualToString:@"getGpsLocation"]){
        NSDictionary *dic = [self getParameters:mfnpParam];
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getGpsLocation:callBackFunc :userSpecific];
    }
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation : %@",error);
    [self.progressView setHidden:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
    NSLog(@"%s error : %@",__FUNCTION__,error);
    NSLog(@"%s error : %@",__FUNCTION__,[error userInfo]);
    NSLog(@"%s error : %@",__FUNCTION__,[[error userInfo]objectForKey:@"NSErrorFailingURLStringKey"]);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[error userInfo]objectForKey:@"NSErrorFailingURLStringKey"]]];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingString:@"/failedData"];
    [data writeToFile:filePath atomically:YES];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    if (error.code == 102) {
        if (url){
            self.doic = [UIDocumentInteractionController interactionControllerWithURL:url];
            self.doic.delegate = self;

            // Action Sheet 호출
            if([self.doic presentOptionsMenuFromRect:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) inView:self.view animated:YES]){

            } else {
                NSLog(@"There is no app for this file");
            }
        }
    }else if(error.code == -999){
        return;
    }
    
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"%s error : %@",__FUNCTION__,error);
//    NSLog(@"%s error : %@",__FUNCTION__,[error userInfo]);
//    NSLog(@"%s error : %@",__FUNCTION__,[[error userInfo]objectForKey:@"NSErrorFailingURLStringKey"]);
//
//    [self.progressView setHidden:YES];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
//
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[error userInfo]objectForKey:@"NSErrorFailingURLStringKey"]]];
//    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    filePath = [filePath stringByAppendingString:@"/failedData"];
//    [data writeToFile:filePath atomically:YES];
//    NSURL *url = [NSURL fileURLWithPath:filePath];
//
//    if (error.code == 102) {
//        if (url){
//            self.doic = [UIDocumentInteractionController interactionControllerWithURL:url];
//            self.doic.delegate = self;
//
//            // Action Sheet 호출
//            if([self.doic presentOptionsMenuFromRect:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) inView:self.view animated:YES]){
//
//            } else {
//                NSLog(@"There is no app for this file");
//            }
//        }
//    }else if(error.code == -999){
//        return;
//    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"message : %@",message);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:appName message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:appName message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    self.progressView.hidden = NO;
    self.progressView.progress = 0.0f;
    
    NSURL *url = webView.URL;
    NSString *urlString = [url absoluteString];
    
    NSLog(@"111 urlString : %@", urlString);
    
    if([[url scheme]isEqualToString:@"anymate"]){
        NSString *host = [url host];
        if([host isEqualToString:@"getGpsLocation"]){
            NSDictionary *dic = [self getParameters:[url query]];
            NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
            NSString *userSpecific = [dic objectForKey:@"userSpecific"];
            [self getGpsLocation:callBackFunc :userSpecific];
        }
        
    } else if([[url scheme] isEqualToString:@"tel"] || [[url scheme]isEqualToString:@"sms"]){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
            
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *homeString = [NSString stringWithFormat:@"%@/m/",[prefs objectForKey:@"URL"]];
    NSString *homeString2 = [NSString stringWithFormat:@"%@/m/main/",[prefs objectForKey:@"URL"]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

//    NSLog(@"_urlString : %@", _urlString);
//    NSLog(@"homeString : %@, homeString2 : %@", homeString, homeString2);
    
    appDelegate.urlString = @"";
    if ([urlString isEqualToString:homeString] || [urlString isEqualToString:homeString2]) {
        appDelegate.isLogout = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSString *itms = [[urlString componentsSeparatedByString:@"://"] objectAtIndex:0];
//    if ([itms isEqualToString:@"itms-services"]) { //itms-services 앱스토어에서 리젝
    if ([itms rangeOfString:@"itms-service"].location != NSNotFound) {
        self.progressView.hidden = YES;
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
//    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
//    }];
    NSLog(@"Action webView.URL : %@", webView.URL);
    decisionHandler(WKNavigationActionPolicyAllow);
};

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"Response webView.URL : %@", webView.URL);
    
    NSString *ext = [navigationResponse.response.suggestedFilename pathExtension];
    NSLog(@"ext : %@", ext);
    
    if([ext isEqualToString:@"jpg"]||[ext isEqualToString:@"jpeg"]||[ext isEqualToString:@"gif"]||[ext isEqualToString:@"png"]||[ext isEqualToString:@"tiff"]||[ext isEqualToString:@"bmp"]||[ext isEqualToString:@"heic"]||[ext isEqualToString:@"docx"]||[ext isEqualToString:@"doc"]||[ext isEqualToString:@"pptx"]||[ext isEqualToString:@"ppt"]||[ext isEqualToString:@"xls"]||[ext isEqualToString:@"xlsx"]||[ext isEqualToString:@"pdf"]||[ext isEqualToString:@"txt"]||[ext isEqualToString:@"html"]){
        
        if([[webView.URL.absoluteString lowercaseString] rangeOfString:@"mode=download"].location!=NSNotFound){
            NSRange range = [navigationResponse.response.suggestedFilename rangeOfString:@"." options:NSBackwardsSearch];
            NSString *fileName = [navigationResponse.response.suggestedFilename substringToIndex:range.location];
            NSURL *downLoadUrl = webView.URL;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FileViewerController *destination = (FileViewerController *)[storyboard instantiateViewControllerWithIdentifier:@"FileViewerController"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
            navController.modalTransitionStyle = UIModalPresentationNone;
            navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            destination.fileUrl = downLoadUrl;
            destination.fileName = fileName;
            [self presentViewController:navController animated:YES completion:nil];
            
            decisionHandler(WKNavigationResponsePolicyCancel);
            
        } else {
            decisionHandler(WKNavigationResponsePolicyAllow);
        }
        
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:appName message:NSLocalizedString(@"file_not_support", @"file_not_support") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleCancel
        handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            [SVProgressHUD show];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *downLoadUrl = navigationResponse.response.URL;
                NSLog(@"downLoadUrl : %@", downLoadUrl);
                [self fileDownloadHandler:downLoadUrl fileName:navigationResponse.response.suggestedFilename completion:^(NSString *path) {
                    NSLog(@"완료!!! : %@", path);
                    [SVProgressHUD dismiss];
                                NSURL *url = [NSURL fileURLWithPath:path];
                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
                                self.doic = [UIDocumentInteractionController interactionControllerWithURL:url];
                                self.doic.delegate = self;

                                // Action Sheet 호출
                                if([self.doic presentOptionsMenuFromRect:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) inView:self.view animated:YES]){

                                } else {
                                    NSLog(@"There is no app for this file");
                                }
                            }];
            });

            
            /*
            if ([downLoadUrl.absoluteString rangeOfString:@"http:/"].location!=NSNotFound||[downLoadUrl.absoluteString rangeOfString:@"https:/"].location!=NSNotFound) {
                [[UIApplication sharedApplication] openURL:navigationResponse.response.URL options:@{} completionHandler:nil];

            } else {
                NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *filePath = [documentPath stringByAppendingFormat:@"/%@", appName];
                filePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@", navigationResponse.response.suggestedFilename]];

                NSURL *url = [NSURL fileURLWithPath:filePath];
                UIDocumentInteractionController *doic = [UIDocumentInteractionController interactionControllerWithURL:url];
                doic.delegate = self;

                // Action Sheet 호출
                if([doic presentOptionsMenuFromRect:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) inView:self.view animated:YES]){
                    NSLog(@"webView URL ! : %@", webView.URL);
                    NSLog(@"path : %@", navigationResponse.response.URL);
                    [self.progressView setHidden:NO];

                    
                    NSURLRequest *request = [NSURLRequest requestWithURL:downLoadUrl];
                    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
                        if (!taskData) {
                            NSLog(@"error : %@", error);

                        } else {
                            BOOL issue = [fileManager isReadableFileAtPath:filePath];
                            if (issue) {
                            } else{
                                [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
                            }
                            NSLog(@"down filePath : %@", filePath);
                            [taskData writeToFile:filePath atomically:YES];
                        }
                        [self.progressView setHidden:YES];
                    }];
                    [task resume];
                } else {
                    NSLog(@"There is no app for this file");
                }
            }
             */
        }];
        
        [alert addAction:cancelButton];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
       
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self.progressView setHidden:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}

-(void)fileDownloadHandler:(NSURL *)url fileName:(NSString *)fileName completion:(void (^)(NSString *path))completion{
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [documentPath stringByAppendingFormat:@"/%@", appName];
//    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", navigationResponse.response.suggestedFilename]];
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
    BOOL issue = [fileManager isReadableFileAtPath:folderPath];
    if (issue) {
    } else{
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [data writeToFile:filePath atomically:YES];
    completion(filePath);
}

#pragma mark
#pragma mark Location Delegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status==kCLAuthorizationStatusDenied) {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"위치 정보를 가져 오려면 \"Anymate\"가 사용자의 위치에 접근하도록 허용해야 합니다.\n설정 > 개인 정보 보호 > 위치 서비스 > Anymate 에서 설정하실 수 있습니다.", @"위치 접근 허용") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"취소", @"취소") otherButtonTitles:NSLocalizedString(@"확인", @"확인"), nil];
//        alertView.tag = 1001;
//        [alertView show];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:appName message:NSLocalizedString(@"not_auth_location_msg", @"not_auth_location_msg") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok")
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action) { }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    NSLog(@"status : %d",status);
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //위치 정보 가져오는 것 실패
    //NSLog(@"Location Updateing Failed! : %@",error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // CLLocation *)newLocation 여기에 위도경도가 변수에 들어가 있다.
    double latitude;  //더블형
    double longitude;
    
    latitude = newLocation.coordinate.latitude; //위도정보
    longitude =newLocation.coordinate.longitude;//경도 정보
    
    NSString *lbl_laText = [NSString stringWithFormat:@"위도는 : %g",latitude];
    NSString *lbl_loText = [NSString stringWithFormat:@"경도는 : %g",longitude];
    
    
    NSLog(@"%@",lbl_loText);
    NSLog(@"%@",lbl_laText);
}
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error{
    //NSLog(@"didFinishDeferredUpdatesWithError");
}
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    //NSLog(@"didExitRegion");
}

-(void)getGpsLocation:(NSString *)callBackFunc :(NSString *)userSpecific {
    // Location Manager 생성
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    NSString *latitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
    NSString *jsCommand;
    if (userSpecific == nil) {
        jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[latitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[longitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else{
        jsCommand = [NSString stringWithFormat:@"%@('%@','%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[latitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[longitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    [self.locationManager stopUpdatingLocation];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    if ([latitude intValue]==0 && [longitude intValue]==0) {
        
    }else{
        if(@available(iOS 11, *)){
            [self evaluateJavaScript:jsCommand];
        } else {
            [self.uiWebView stringByEvaluatingJavaScriptFromString:jsCommand];
        }
    }
    
}
#pragma mark
#pragma mark Util
- (void)evaluateJavaScript:(NSString *)jsCommand{
    NSLog(@"jsCommand : %@",jsCommand);
    //if (IS_OS_8_OR_LATER) {
    [self.webView evaluateJavaScript:jsCommand completionHandler:^(NSString *result, NSError *error)
     {
         NSLog(@"%s result : %@",__FUNCTION__,result);
         NSLog(@"%s error : %@",__FUNCTION__,error);
         
     }];
}

-(NSDictionary *)getParameters:(NSString *)query{
    NSArray *params = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    for (int i=0; i<[params count]; i++) {
        NSArray *tmpArr = [[params objectAtIndex:i] componentsSeparatedByString:@"="];
        NSString *keyString = [NSString urlDecodeString:[tmpArr objectAtIndex:0]];
        NSString *valueString = [NSString urlDecodeString:[tmpArr objectAtIndex:1]];
        [returnDic setObject:valueString forKey:keyString];
    }
    
    return returnDic;
    
}
-(IBAction)goBack:(id)sender{
    if(@available(iOS 11, *)){
        [self.webView goBack];
    } else {
        [self.uiWebView goBack];
    }
}
-(IBAction)goForward:(id)sender{
    if(@available(iOS 11, *)){
        [self.webView goForward];
    } else {
        [self.uiWebView goForward];
    }
}
-(IBAction)refresh:(id)sender{
    if(@available(iOS 11, *)){
        [self.webView reload];
    } else {
        [self.uiWebView reload];
    }
}

BOOL isPop;
-(IBAction)setting:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.isSetting = YES;
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self performSegueWithIdentifier:@"MODAL_SETTING_VIEW" sender:nil];
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    isPop = NO;
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Open Link"]){
        [self.uiWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:selectedLinkURL]]];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Copy Link"]){
        [[UIPasteboard generalPasteboard] setString:selectedLinkURL];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Copy Image"]){
        [[UIPasteboard generalPasteboard] setString:self.selectedImageURL];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save Image"]){
        [self performSelectorOnMainThread:@selector(showStartSaveAlert)
                               withObject:nil
                            waitUntilDone:YES];
    }
}
-(void)showStartSaveAlert{
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.selectedImageURL]];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [conn start];
    if (conn) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
        receiveData = [[NSMutableData data] retain];
    }
}

#pragma mark - NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.progressView setHidden:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:appName message:NSLocalizedString(@"인터넷 환경이 원활하지 않습니다.", @"인터넷 환경이 원활하지 않습니다.") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) { }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.progressView setHidden:NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [receiveData setLength:0];
    expectedBytes = [response expectedContentLength];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receiveData appendData:data];
    float progressive = (float)[receiveData length] / (float)expectedBytes;
//    NSLog(@"progressive : %f", progressive);
    
    [self.progressView setProgress:progressive];
     if(progressive >= 1.0f) {
         [self.progressView setHidden:YES];
     }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self.progressView setHidden:YES];
    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:receiveData], nil, nil, nil);

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:appName message:NSLocalizedString(@"사진이 앨범에 저장되었습니다.", @"사진이 앨범에 저장되었습니다.") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) { }]];
    [self presentViewController:alert animated:YES completion:nil];

    receiveData = nil;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


@implementation UINavigationController (Autorotation2)

-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
@end

