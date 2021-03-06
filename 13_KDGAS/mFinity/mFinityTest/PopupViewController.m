//
//  PopupViewController.m
//  mFinity_KDGas
//
//  Created by hilee on 2020/12/03.
//  Copyright © 2020 Jun hyeong Park. All rights reserved.
//

#import "PopupViewController.h"
#import "MainViewController.h"

@interface PopupViewController () {
    MFinityAppDelegate *appDelegate;
}

@end


@implementation PopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    [self initWKWebView];
}

- (void)initWKWebView{
    NSLog(@"%s", __func__);
    
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
    
    CGRect webViewRect = CGRectMake(0, 0, self.webViewFrame.frame.size.width, self.webViewFrame.frame.size.height);
    self.wkWebView = [[WKWebView alloc] initWithFrame:webViewRect configuration:webViewConfig];

    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    self.wkWebView.scrollView.bounces = NO;

    self.wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webViewFrame addSubview:self.wkWebView];
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@",appDelegate.main_url];
//    NSString *urlString = [[NSString alloc] initWithFormat:@"http://192.168.0.153:7001/dataservice41"];
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MAIN_NOTICE.jsp?cuser_no=%@&notice_no=%@",urlString, appDelegate.user_no, self.noticeNo]]]];
}

- (NSDictionary *)getParametersByString:(NSString *)query{
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

#pragma mark - WKWebView Delegate Method
-(void)webViewDidClose:(WKWebView *)webView{
    NSLog(@"%s",__FUNCTION__);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"keyPath : %@",keyPath);
    NSLog(@"object : %@",object);
    NSLog(@"self.webView : %@",self.wkWebView);
    if ([keyPath isEqualToString:@"estimatedProgress"] /*&& object == self.webView*/) {
        NSLog(@"estimatedProgress : %f", self.wkWebView.estimatedProgress);
        
    } else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setMfnpMethod:(WKUserContentController *)userController{
    [userController addScriptMessageHandler:self name:@"windowClose"];
    [userController addScriptMessageHandler:self name:@"executeNoticeClose"];
}

#pragma mark
#pragma mark WKWebView Set MFNP
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"message name : %@",message.name);
    NSLog(@"message body : %@",message.body);
    
    NSString *mfnpName = [NSString stringWithString:message.name];
    NSString *mfnpParam = [NSString stringWithString:message.body];
    if (![mfnpParam isEqualToString:@""]) {
        
    }
    
    if ([mfnpName isEqualToString:@"windowClose"]||[mfnpName isEqualToString:@"executeNoticeClose"]) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSDictionary *resultDic = [self getParametersByString:message.body];
        NSLog(@"resultDic : %@", resultDic);
        if([[resultDic objectForKey:@"flag"] isEqual:@"true"]){
            [prefs setObject:[resultDic objectForKey:@"notice_no"] forKey:[NSString stringWithFormat:@"HIDENOTICE_%@", [resultDic objectForKey:@"notice_no"]]];
        }
        [prefs synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PopupClose" object:nil];
    }
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation : %@",error);
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailProvisionalNavigation : %@",error);
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"message : %@",message);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NULL
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"취소", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"취소", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"%s : %@",__FUNCTION__,webView.URL);
}
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSLog(@"Action webView.URL : %@", webView.URL);
    decisionHandler(WKNavigationActionPolicyAllow);
};
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"Response webView.URL : %@", webView.URL);
//    if (@available(iOS 11.0, *)) {  //available on iOS 11+
//        WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
//        [cookieStore getAllCookies:^(NSArray* cookies) {
//            if (cookies.count > 0) {
//                for (NSHTTPCookie *cookie in cookies) {
//                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//                }
//
//                decisionHandler(WKNavigationResponsePolicyAllow);
//            }
//        }];
//    } else {
//        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
//
//        NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
//
//        for (NSHTTPCookie *cookie in cookies) {
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//        }
//
        decisionHandler(WKNavigationResponsePolicyAllow);
//    }
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"%s",__FUNCTION__);
    [self.wkWebView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(NSString *result, NSError *error)
     {
        [self.webViewFrame setFrame:CGRectMake(self.view.frame.size.width/2-(self.webViewFrame.frame.size.width/2), self.view.frame.size.height/2-([result floatValue]/2), self.webViewFrame.frame.size.width, [result floatValue])];
     }];
}

-(NSString *)splitString:(UILabel *)label :(NSString *)text{
    int maxWidth;
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    NSLog(@"screenwidth : %f",screenWidth);
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        maxWidth = 700;
    }else{
        if (screenWidth>320) {
            maxWidth = 300;
        }else{
            maxWidth = 275;
        }
    }
    
    CGRect aboutRect = [text //높이를 구할 NSString
                        boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName:label.font}
                        context:nil];
    CGFloat strikeWidth = aboutRect.size.width;
    NSString *editText = @"";
    if (strikeWidth>maxWidth) {
        NSArray *arr = [text componentsSeparatedByString:@" "];
        
        for (int i=0; i<=arr.count-2; i++) {
            NSString *tmp = arr[i];
            
            editText = [editText stringByAppendingString:tmp];
            if (i!=arr.count-2) {
                editText = [editText stringByAppendingString:@" "];
            }
            
        }
        
    }else{
        editText = text;
    }
    
    aboutRect = [editText //높이를 구할 NSString
                 boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
                 options:NSStringDrawingUsesLineFragmentOrigin
                 attributes:@{NSFontAttributeName:label.font}
                 context:nil];
    strikeWidth = aboutRect.size.width;
    
    if (strikeWidth>maxWidth) {
        editText = [self splitString:label :editText];
    }
    return editText;
}

- (void)evaluateJavaScript:(NSString *)jsCommand{
    NSLog(@"jsCommand : %@",jsCommand);
    //if (IS_OS_8_OR_LATER) {
    [self.wkWebView evaluateJavaScript:jsCommand completionHandler:^(NSString *result, NSError *error)
     {
         NSLog(@"%s result : %@",__FUNCTION__,result);
         NSLog(@"%s error : %@",__FUNCTION__,error);
         
     }];
}


@end
