//
//  WebViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 21..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "WebViewController.h"
#import "WebViewAdditions.h"
#import "MFinityAppDelegate.h"

#import "HDString.h"
#import "sqlite3.h"
#import "UnpreventableUILongPressGestureRecognizer.h"
#import "CustomSegmentedControl.h"
#import "CameraMenuViewController.h"
#import "SignPadViewController.h"
#import "PhotoViewController.h"
#import "FileUploadViewController.h"

#import "UIDevice-Hardware.h"
#import "UIDevice-Capabilities.h"
#import "UIDevice+IdentifierAddition.h"

#import <sys/utsname.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreMotion/CoreMotion.h>
#import <dlfcn.h>
#import <mach/port.h>
#import <mach/kern_return.h>
#include <sys/param.h>
#include <sys/mount.h>

#import "FBEncryptorAES.h"

#import "SVProgressHUD.h"
#import "UIViewController+MJPopupViewController.h"
#import "MFTableViewController.h"
#import "JTSImageViewController.h"


#define DOWNLOAD_ROW_SIZE 140
#define DOWNLOAD_ROW_INCREASE_SIZE 88
#define DOWNLOAD_WIDTH 300
#define DOWNLOAD_HEIGHT 320
//#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] <= 8.0)
#define IS_OS_8_OR_LATER NO
#define TAB_BAR_HEIGHT 49


@interface WebViewController (){
    
}

@end

@implementation WebViewController
#pragma mark
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.webViews = [[NSMutableArray alloc]init];
    
    self.picker.delegate = self;
    
    //모달팝업 완료버튼이 흰색으로 나오는 이슈가 있음
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[UIToolbar.class]]setTintColor:[appDelegate myRGBfromHex:@"#007AFF"]]; //화살표만 바뀜
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[appDelegate myRGBfromHex:@"#007AFF"], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    
    self.navigationItem.hidesBackButton = YES;
    
    [self checkDownload];
    [self initUI];
    [self initNotification];
    //[self initWKWebView];
    if (!IS_OS_8_OR_LATER) {
        [self initUIWebView];
    }
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    motionManager = [[CMMotionManager alloc]init];
    if (_isDMS) {
        NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
        documentPath = [documentPath stringByAppendingPathComponent:@"Application Support"];
        documentPath = [documentPath stringByAppendingPathComponent:@"oracle"];
        documentPath = [documentPath stringByAppendingPathComponent:@"sqlite_db"];
        
        self.dbDirectoryPath = documentPath;
    }else{
        self.dbDirectoryPath = [self makeDBFile];
    }
    
    if (!isViewing) {
        if (IS_OS_8_OR_LATER) {
//            [self initWKWebView];
            isViewing = YES;
        }
        
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HideImageViewer" object:nil];
}
#pragma mark - WKWebView Delegate Method
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    NSString *source = @"window.close=function(){ window.webkit.messageHandlers.exeWindowClose.postMessage(''); };";
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userController addUserScript:cookieScript];
    [userController addScriptMessageHandler:self name:@"exeWindowClose"];
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.userContentController = userController;
    
    _webView = [[WKWebView alloc] initWithFrame:self.webView.frame configuration:configuration];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    [self evaluateJavaScript:source];
    
    [self.webViews addObject:_webView];
    [self.view addSubview:_webView];
    
    return _webView;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webView) {
        //NSLog(@"%f", self.webView.estimatedProgress);
        if(self.webView.estimatedProgress >= 1.0f) {
            [SVProgressHUD dismiss];
        }else{
            [SVProgressHUD show];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark
#pragma mark [WKWebView SET MFNP]
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"message name : %@",message.name);
    NSLog(@"message body : %@",message.body);
    NSString *mfnpName = message.name;
    NSString *mfnpParam = message.body;
    NSDictionary *dic;
    @try{
        dic = [self getParameters:mfnpParam];
    }
    @catch(NSException *e){
        if (![mfnpName isEqualToString:@"exeWindowClose"] || ![mfnpName isEqualToString:@"isWKWebView"]) {
            NSLog(@"[mfnp parameter exception] : %@",e);
        }
    }
    if ([mfnpName isEqualToString:@"executeBackKeyEvent"]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"executeBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        /*
         NSDictionary *dic = [self getParameters:[url query]];
         NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
         NSString *userSpecific = [dic objectForKey:@"userSpecific"];
         [self executeBackKeyEvent:callBackFunc :userSpecific];
         */
        
    }
    else if ([mfnpName isEqualToString:@"executeBarcode"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeBarcode:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeCamera"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeCamera:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeDatagate"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *dbConfigKey = [dic objectForKey:@"dbConfigKey"];
        NSString *sprocName = [dic objectForKey:@"sprocName"];
        NSString *args = [dic objectForKey:@"args"];
        [self executeDataGate:callBackFunc :userSpecific :dbConfigKey :sprocName :args];
    }
    else if ([mfnpName isEqualToString:@"executeExitWebBrowser"]) {
        [self executeExitWebBrowser];
    }
    else if ([mfnpName isEqualToString:@"executeFileUpload"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *fileList = [dic objectForKey:@"fileList"];
        NSError *jsonError;
        NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
        NSString *flag = [dic objectForKey:@"flag"];
        [self executeFileUpload:callBackFunc :userSpecific :json :upLoadPath :flag];
        
        /*
        NSString *fileType = [dic objectForKey:@"fileType"];
        NSString *fileList = [dic objectForKey:@"fileList"];
        NSError *jsonError;
        NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
        [self executeFileUpload:fileType :json :upLoadPath];
        */
        
    }
    else if([mfnpName isEqualToString:@"executeGallery"]){ //181227_추가
        NSLog(@"executeGallery dic : %@", dic);
        [self executeGallery:dic];
        
    }
    else if ([mfnpName isEqualToString:@"executeMenu"]) {
        NSString *menuNo = [dic objectForKey:@"menuNo"];
        [self executeMenu:menuNo];
    }
    else if ([mfnpName isEqualToString:@"executeNonQuery"]) {
        NSString *dbName = [dic objectForKey:@"dbName"];
        NSString *selectStmt = [dic objectForKey:@"sqlStmt"];
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeNonQuery:dbName :selectStmt :callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeNotification"]) {
        NSString *useVibrator = [dic objectForKey:@"useVibrator"];
        NSString *useBeep = [dic objectForKey:@"useBeep"];
        NSString *time = [dic objectForKey:@"time"];
        [self executeNotification:useVibrator :useBeep :time];
    }
    else if ([mfnpName isEqualToString:@"executeProgressDialogStart"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        [self executeProgressDialogStart:[dic objectForKey:@"title"] :[dic objectForKey:@"msg"] :callBackFunc];
    }
    else if ([mfnpName isEqualToString:@"executeProgressDialogStop"]) {
        [self executeProgressDialogStop];
    }
    else if ([mfnpName isEqualToString:@"executePush"]) {
        NSString *msg = [dic objectForKey:@"msg"];
        NSString *userList = [dic objectForKey:@"userList"];
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executePush:callBackFunc :userSpecific :userList :msg];
    }
    else if ([mfnpName isEqualToString:@"executeRecognizeSpeech"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeRecognizeSpeech:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeRetrieve"]) {
        NSString *dbName = [dic objectForKey:@"dbName"];
        NSString *selectStmt = [dic objectForKey:@"selectStmt"];
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeRetrieve:dbName :selectStmt :callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeSignpad"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self executeSignpad:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"executeSms"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *msg = [dic objectForKey:@"msg"];
        NSString *userList = [dic objectForKey:@"userList"];
        [self executeSms:callBackFunc :userSpecific :msg :userList];
    }
    else if ([mfnpName isEqualToString:@"getAccelerometer"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getAccelerometer:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getCheckSession"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getCheckSession:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getConvertImageToBase64"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *imagePath = [dic objectForKey:@"imagePath"];
        [self getConvertImageToBase64:callBackFunc :imagePath];
    }
    else if ([mfnpName isEqualToString:@"getDeviceInfo"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        
        [self getDeviceSpec:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getDeviceSpec"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *specName = [dic objectForKey:@"specName"];
        if (specName!=nil) {
            [self getDeviceSpec:callBackFunc :userSpecific :specName];
        }else{
            [self getDeviceSpec:callBackFunc :userSpecific];
        }
    }
    else if ([mfnpName isEqualToString:@"getFilePath"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getFilePath:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getGpsLocation"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getGpsLocation:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getGyroscope"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getGyroscope:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getMagneticField"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getMagneticField:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getNetworkStatus"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getNetworkStatus:callBackFunc :userSpecific];
    }
    else if([mfnpName isEqualToString:@"getOrientation"]){
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getOrientation:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getProximity"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getProximity:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"getUserInfo"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self getUserInfo:callBackFunc :userSpecific];
    }
    else if ([mfnpName isEqualToString:@"setBackKeyEvent"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        NSString *backkeyMode = [dic objectForKey:@"backkeyMode"];
        [self setBackKeyEvent:callBackFunc :userSpecific :backkeyMode];
    }
    else if ([mfnpName isEqualToString:@"setFileNames"]) {
        NSString *fileList = [dic objectForKey:@"fileList"];
        [self setFileNames:fileList];
    }
    else if ([mfnpName isEqualToString:@"isRoaming"]) {
        NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
        NSString *userSpecific = [dic objectForKey:@"userSpecific"];
        [self isRoaming:callBackFunc :userSpecific];
    }
    else if([mfnpName isEqualToString:@"windowClose"]){
        [self rightBtnClick];
    }
    else if([mfnpName isEqualToString:@"executeLogout"]){
        [self executeLogout];
    }
}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation : %@",error);
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailProvisionalNavigation : %@",error);
}
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"didCommitNavigation : %@",webView);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark UIWebView Delegate Method
-(void) webView:(IMTWebView *)_tmp_webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources {
    [self.progressView setProgress:((float)resourceNumber) / ((float)totalResources)];
    if (resourceNumber == totalResources) {
        _tmp_webView.resourceCount = 0;
        _tmp_webView.resourceCompletedCount = 0;
    }
}
-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    NSLog(@"error : %@",error);
    self.progressView.hidden = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    if (error.code == 102) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"message159", @"message159") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message52", @"message52") style:UIAlertActionStyleCancel
        handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            [SVProgressHUD show];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *downLoadUrl = [NSURL URLWithString:[[error userInfo]objectForKey:@"NSErrorFailingURLStringKey"]];
                NSLog(@"downLoadUrl : %@", downLoadUrl);
                NSString *fileName = [NSString urlDecodeString:[[[error userInfo]objectForKey:@"NSErrorFailingURLStringKey"] lastPathComponent]]; //[NSString urlDecodeString:[downLoadUrl.absoluteString lastPathComponent]];
                [self fileDownloadHandler:downLoadUrl fileName:fileName completion:^(NSString *path) {
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
        }];
        
        [alert addAction:cancelButton];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if(error.code == -999){
        return;
    }
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application{
    NSLog(@"%s", __func__);
    [self.doic dismissMenuAnimated:YES];
//    [self.doic dismissPreviewAnimated:YES];
}
-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
    NSLog(@"%s", __func__);
}

-(void)fileDownloadHandler:(NSURL *)url fileName:(NSString *)fileName completion:(void (^)(NSString *path))completion{
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [documentPath stringByAppendingFormat:@"/%@", appName];
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:folderPath];
    if (issue) {
    } else{
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [data writeToFile:filePath atomically:YES];
    completion(filePath);
}

#pragma mark
#pragma mark [UIWebView SET MFNP]
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"[request URL] : %@",[request URL]);
    //NSLog(@"request url : %@",[[request URL] absoluteURL]);
    
    if (UIWebViewNavigationTypeLinkClicked == navigationType || UIWebViewNavigationTypeOther == navigationType) {
        ////NSLog(@"a tag url : %@",[[request URL] absoluteURL]);
        if ([[[request URL] scheme]isEqualToString:@"ezmovetab"]) {
            self.tabBarController.selectedIndex = [[[request URL] host] intValue]-1;
            return NO;
        }else if([[[request URL] scheme]isEqualToString:@"dbcall"]){
            NSString *_paramString = [[request URL] absoluteString];
            NSArray *paramArray = [_paramString componentsSeparatedByString:@"!@"];
            
            
            NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
            documentPath = [documentPath stringByAppendingPathComponent:@"Application Support"];
            documentPath = [documentPath stringByAppendingPathComponent:@"oracle"];
            documentPath = [documentPath stringByAppendingPathComponent:@"sqlite_db"];
            
            documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
            NSLog(@"appDelegate.user_id : %@",appDelegate.user_id);
            NSString *dbPath = [[paramArray objectAtIndex:4] stringByAppendingPathExtension:@"db"];
            dbPath = [dbPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            documentPath = [documentPath stringByAppendingPathComponent:dbPath];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSLog(@"documentPath : %@",documentPath);
            
            if ([fileManager isReadableFileAtPath:documentPath]) {
                [self oldDbConnection:[paramArray objectAtIndex:1] :[paramArray objectAtIndex:2] :[paramArray objectAtIndex:3] :documentPath];
            }else{
                [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
                [self dismissModalViewControllerAnimated:YES];
            }
            return NO;
            
        }else if([[[request URL] scheme]isEqualToString:@"mfnp"]||[[[request URL] scheme]isEqualToString:@"mfinity"]){
            
            NSString *host = [[request URL] host];
            NSLog(@"host : %@", host);
            NSURL *url = [request URL];
            NSArray *params = [[url query] componentsSeparatedByString:@"&"];
            if ([host isEqualToString:@"camera"]) {
                CameraMenuViewController *vc = [[CameraMenuViewController alloc]init];
                appDelegate.mediaControl = @"camera";
                vc.isWebApp = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }else if([host isEqualToString:@"movetab"]){
                self.tabBarController.selectedIndex = [[[request URL] host] intValue]-1;
            }else if([host isEqualToString:@"dbcall"]){
                
                NSArray *tmpArr = [[params objectAtIndex:0] componentsSeparatedByString:@"="];
                NSString *_paramString = [NSString urlDecodeString:[tmpArr objectAtIndex:1]];
                NSLog(@"paramString : %@",_paramString);
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[_paramString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                
                NSLog(@"jsonDic : %@",jsonDic);
                
                NSBundle *bundle = [NSBundle mainBundle];
                
                NSString *path = [bundle pathForResource:[jsonDic objectForKey:@"db_name"] ofType:@"db"];
                NSLog(@"path : %@",path);
                [self dbConnection:[jsonDic objectForKey:@"gubn"] :[jsonDic objectForKey:@"crud"] :[jsonDic objectForKey:@"query"] :path];
                //[self dbConnection:[dic objectForKey:@"gubn"] :[dic objectForKey:@"crud"] :[dic objectForKey:@"sql"] :path :@"CBResultSql"];
                
            }else if([host isEqualToString:@"gps"]){
                [self getGpsLocation:@"CBLocation" :nil];
                
            }else if([host isEqualToString:@"addressbook"]){
                NSDictionary *dic = [appDelegate contracts];
                NSString *dicString = [NSString stringWithFormat:@"%@",dic];
                NSString *jsCommand = [NSString stringWithFormat:@"CBAddressBook('%@');",[dicString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [self evaluateJavaScript:jsCommand];
                
            }else if([host isEqualToString:@"signpad"]){
                SignPadViewController *vc = [[SignPadViewController alloc]init];
                UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                //[self.navigationController pushViewController:vc animated:YES];
                [self presentViewController:nvc animated:YES completion:nil];
                
            }else if([host isEqualToString:@"photosave"]){
                PhotoViewController *vc = [[PhotoViewController alloc] init];
                vc.imagePath = _imgFileName;
                vc.isWebApp = YES;
                [vc rightBtnClick];
                //[self.navigationController pushViewController:vc animated:YES];
                
            }else if([host isEqualToString:@"barcode"]){
                [self barCodeReaderOpen];
                
            }else if([host isEqualToString:@"blobstring"]){
                
                NSLog(@"[url query] : %@",[url query]);
                NSString *query = [url query];
                NSString *jsCommand = [NSString stringWithFormat:@"receive_blob('%@');",query];
                
                [self evaluateJavaScript:jsCommand];
                
            }else if([host isEqualToString:@"filePath"]){
                //photo 폴더 경로 넘겨주면 됨
                NSString *photoPath =[self getPhotoFilePath];
                photoPath = [photoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *jsCommand = [NSString stringWithFormat:@"CBFilePath('%@','%@');",photoPath,photoPath];
                [self evaluateJavaScript:jsCommand];
                
            }else if([host isEqualToString:@"saveFile"]){
                //
                
            }else if([host isEqualToString:@"executeBackKeyEvent"]){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"executeBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                /*
                 NSDictionary *dic = [self getParameters:[url query]];
                 NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                 NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                 [self executeBackKeyEvent:callBackFunc :userSpecific];
                 */
                
            }else if([host isEqualToString:@"executeBarcode"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeBarcode:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeCamera"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeCamera:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeDatagate"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *dbConfigKey = [dic objectForKey:@"dbConfigKey"];
                NSString *sprocName = [dic objectForKey:@"sprocName"];
                NSString *args = [dic objectForKey:@"args"];
                [self executeDataGate:callBackFunc :userSpecific :dbConfigKey :sprocName :args];
                
            }else if([host isEqualToString:@"executeExitWebBrowser"]){
                [self executeExitWebBrowser];
                
            }else if([host isEqualToString:@"executeFileUpload"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSLog(@"dic : %@", dic);
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *fileList = [dic objectForKey:@"fileList"];
                NSError *jsonError;
                NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
                NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
                NSString *flag = [dic objectForKey:@"flag"];

                [self executeFileUpload:callBackFunc :userSpecific :json :upLoadPath :flag];
                                
                /*
                 NSString *fileType = [dic objectForKey:@"fileType"];
                 NSString *fileList = [dic objectForKey:@"fileList"];
                 NSError *jsonError;
                 NSData *objectData = [fileList dataUsingEncoding:NSUTF8StringEncoding];
                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                 options:NSJSONReadingMutableContainers
                 error:&jsonError];
                 NSString *upLoadPath = [dic objectForKey:@"upLoadPath"];
                 [self executeFileUpload:fileType :json :upLoadPath];
                 */
                
            }else if([host isEqualToString:@"executeGallery"]){ //181227_추가
                NSDictionary *dic = [self getParameters:[url query]];
                NSLog(@"host executeGallery dic : %@", dic);
                [self executeGallery:dic];
                
            }else if([host isEqualToString:@"executeMenu"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *menuNo = [dic objectForKey:@"menuNo"];
                [self executeMenu:menuNo];
                
            }else if([host isEqualToString:@"executeNonQuery"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *dbName = [dic objectForKey:@"dbName"];
                NSString *selectStmt = [dic objectForKey:@"sqlStmt"];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeNonQuery:dbName :selectStmt :callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeNotification"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *useVibrator = [dic objectForKey:@"useVibrator"];
                NSString *useBeep = [dic objectForKey:@"useBeep"];
                NSString *time = [dic objectForKey:@"time"];
                [self executeNotification:useVibrator :useBeep :time];
                
            }else if([host isEqualToString:@"executeProgressDialogStart"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                [self executeProgressDialogStart:[dic objectForKey:@"title"] :[dic objectForKey:@"msg"] :callBackFunc];
                
            }else if([host isEqualToString:@"executeProgressDialogStop"]){
                [self executeProgressDialogStop];
                
            }else if([host isEqualToString:@"executePush"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSLog(@"dic : %@",dic);
                NSString *msg = [dic objectForKey:@"msg"];
                NSString *userList = [dic objectForKey:@"userList"];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executePush:callBackFunc :userSpecific :userList :msg];
                
            }else if([host isEqualToString:@"executeRecognizeSpeech"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeRecognizeSpeech:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeRetrieve"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *dbName = [dic objectForKey:@"dbName"];
                NSString *selectStmt = [dic objectForKey:@"selectStmt"];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeRetrieve:dbName :selectStmt :callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeSignpad"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self executeSignpad:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"executeSms"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *msg = [dic objectForKey:@"msg"];
                NSString *userList = [dic objectForKey:@"userList"];
                [self executeSms:callBackFunc :userSpecific :msg :userList];
                
            }else if([host isEqualToString:@"getAccelerometer"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getAccelerometer:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getCheckSession"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getCheckSession:callBackFunc :userSpecific];
            
            }else if([host isEqualToString:@"getConvertImageToBase64"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *imagePath = [dic objectForKey:@"imagePath"];
                [self getConvertImageToBase64:callBackFunc :imagePath];
                
            }else if([host isEqualToString:@"getDeviceInfo"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getDeviceSpec:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getDeviceSpec"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                NSString *specName = [dic objectForKey:@"specName"];
                if (specName!=nil) {
                    [self getDeviceSpec:callBackFunc :userSpecific :specName];
                }else{
                    [self getDeviceSpec:callBackFunc :userSpecific];
                }
                
            }else if([host isEqualToString:@"getFilePath"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getFilePath:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getGpsLocation"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getGpsLocation:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getGyroscope"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getGyroscope:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getMagneticField"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getMagneticField:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getNetworkStatus"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getNetworkStatus:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getOrientation"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getOrientation:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getProximity"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getProximity:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"getUserInfo"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self getUserInfo:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"setBackKeyEvent"]){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"setBackKeyEvent" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                /*
                 NSDictionary *dic = [self getParameters:[url query]];
                 NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                 NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                 NSString *backkeyMode = [dic objectForKey:@"backkeyMode"];
                 [self setBackKeyEvent:callBackFunc :userSpecific :backkeyMode];
                 */
                
            }else if([host isEqualToString:@"setFileNames"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *fileList = [dic objectForKey:@"fileList"];
                [self setFileNames:fileList];
                
            }else if([host isEqualToString:@"isRoaming"]){
                NSDictionary *dic = [self getParameters:[url query]];
                NSString *callBackFunc = [dic objectForKey:@"callbackFunc"];
                NSString *userSpecific = [dic objectForKey:@"userSpecific"];
                [self isRoaming:callBackFunc :userSpecific];
                
            }else if([host isEqualToString:@"windowClose"]){
                NSLog(@"windowClose");
                [self rightBtnClick];
                
            }else if([host isEqualToString:@"executeLogout"]){
                [self executeLogout];
            }
            return NO;
        }
        else {
            return YES;
        }
    }
    return YES;
}
-(void) webViewDidStartLoad:(UIWebView *)webView {
    //[mywebView addSubview:myIndicator];
    //[myIndicator startAnimating];
    /*
     activityAlert = [[[ActivityAlertView alloc] initWithTitle:nil
     message:@"페이지를 로딩중입니다"
     delegate:self
     cancelButtonTitle:nil
     otherButtonTitles:nil ] autorelease];
     
     [activityAlert show];
     */
    if (!flag) {
        self.progressView.hidden = NO;
        self.progressView.progress = 0.0f;
        flag = YES;
    }
}
-(void) webViewDidFinishLoad:(UIWebView *)webView {
    self.progressView.hidden = YES;
    [mywebView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    if([webView isLoading]){
        //NSLog(@"loading");
    }
    [self.locationManager stopUpdatingLocation];
    
    if ([_type isEqualToString:@"A3"]) {
        NSString *jsCommand = [NSString stringWithFormat:@"defaultlocation('%f', '%f');",self.locationManager.location.coordinate.latitude,self.locationManager.location.coordinate.longitude];
        [self evaluateJavaScript:jsCommand];
        
    }
    //NSLog(@"webView : %@",[webView request]);
    [webView stringByEvaluatingJavaScriptFromString:@"window.open = function (open) { return function  (url, name, features) { window.location.href = url; return window; }; } (window.open);"];
    //[webView stringByEvaluatingJavaScriptFromString:@"window.open = function (open) { return function  (url, name, features) { window.location.href = url; return window; }; } (window.open);"];
    NSString *close = @"window.close=function(){ open('mfinity://windowClose'); };";
    close = [close stringByAppendingString:@"window.self.close=function(){ open('mfinity://windowClose'); };"];
    [webView stringByEvaluatingJavaScriptFromString:close];
}

#pragma mark
#pragma mark Action Event Handler
- (void)errorButtonClicked2:(UploadListViewController *)secondDetailViewController{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)cancelButtonClicked2:(UploadListViewController *)secondDetailViewController{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
- (void)leftButtonClicked2:(UploadListViewController *)aSecondDetailViewController{
    NSLog(@"%s",__FUNCTION__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    if(self.isSync){
        NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
        NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:txtPath error:nil];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:@"SUCCEED" forKey:@"RESULT"];
        NSString *decString = [self getJsonStringByDictionary:dic];
        
        NSLog(@"upload result : %@",decString);
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                               _callbackFunc,
                               _userSpecific,
                               [decString urlEncodeUsingEncoding:NSUTF8StringEncoding]
                               ];
        
        [self evaluateJavaScript:jsCommand];
        self.isSync = NO;
    }else{
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.imageURL = [NSURL URLWithString:appDelegate.target_url];
        
        //    imageInfo.referenceRect = self.bigImageButton.frame;
        //    imageInfo.referenceView = self.bigImageButton.superview;
        
        // Setup view controller
        JTSImageViewController *jtsImageViewer = [[JTSImageViewController alloc]
                                                  initWithImageInfo:imageInfo
                                                  mode:JTSImageViewControllerMode_Image
                                                  backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        
        // Present the view controller.
        [jtsImageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
  
    
}

- (void)cancelButtonClicked:(DownloadListViewController *)aSecondDetailViewController
{
    NSLog(@"cancelButtonClicked");
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    WebViewController *vc = [[WebViewController alloc] init];
    vc.isDMS = _isDMS;
    vc.isTabBar = _isTabBar;
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(goBackAdd:)];
    vc.navigationItem.backBarButtonItem=left;
    if (!_isTabBar) {
        vc.hidesBottomBarWhenPushed = YES;
    }else{
        vc.hidesBottomBarWhenPushed = NO;
    }
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)errorButtonClicked:(DownloadListViewController *)secondDetailViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
-(void)getExecuteMenuInfo:(NSString *)menuNo{
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/GetExecuteMenuInfo",appDelegate.main_url]];
    //NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://192.168.0.54:1598/dataservice41/GetExecuteMenuInfo"]];
    NSString *_paramString = [NSString stringWithFormat:@"menuNo=%@&cuserNo=%@&encType=AES256",menuNo,appDelegate.user_no];
    NSData *paramData = [_paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: paramData];
    [request setTimeoutInterval:30.0];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn!=nil) {
        [SVProgressHUD show];
        receiveData = [[NSMutableData alloc]init];
    }
    [conn start];
}
-(void)pushNotificationReceived:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *alert = [aps objectForKey:@"alert"];
    NSString *type = [userInfo objectForKey:@"type"];
    
    if ([type isEqualToString:@"E"]) {
        NSString *menuNo = [userInfo objectForKey:@"menuNo"];
        [self getExecuteMenuInfo:menuNo];
        
    }else{
        
        @try {
            NSString *jsCommand = [NSString stringWithFormat:@"CBPushMessage('%@');",alert];
            [self evaluateJavaScript:jsCommand];
        }
        @catch (NSException *exception) {
            NSLog(@"msg exception : %@",exception);
        }
        
    }
    
}
- (void)menuHandler{
    if ([menuKind isEqualToString:@"M"]) {
        //SubMenu
        MFTableViewController *subMenuList = [[MFTableViewController alloc]init];
        subMenuList.urlString = @"ezMainMenu2";
        [self.navigationController pushViewController:subMenuList animated:YES];
    }
    else if ([menuKind isEqualToString:@"P"]) {
        //실행메뉴일때
        if ([menuType isEqualToString:@"B1"]) {
            //바코드를 사용하는 메뉴일때
            if ([[[UIDevice currentDevice] modelName] hasPrefix:@"iPad"]) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Barcode" message:NSLocalizedString(@"message88", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                
            }else {
                [self barCodeReaderOpen];
            }
            
        } else if ([menuType isEqualToString:@"B0"]) {
            
            if ([[[UIDevice currentDevice] modelName] hasPrefix:@"iPad"]) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Camera" message:NSLocalizedString(@"message89", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
                
            }else {
                CameraMenuViewController *vc = [[CameraMenuViewController alloc] init];
                appDelegate.uploadURL = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
                //NSLog(@"camera : paramString : %@",appDelegate.uploadURL);
                appDelegate.mediaControl = @"camera";
                //PictureController호출
                [self.navigationController pushViewController:vc animated:YES];
                
            }
            
        } else if([menuType isEqualToString:@"B2"]){
            //Movie
            if ([[[UIDevice currentDevice] modelName] hasPrefix:@"iPad"]) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Video" message:NSLocalizedString(@"message89", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
            }else {
                CameraMenuViewController *vc = [[CameraMenuViewController alloc] init];
                //appDelegate.menu_title = target_url;
                appDelegate.uploadURL = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
                appDelegate.mediaControl = @"video";
                //PictureController호출
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } else if ([menuType isEqualToString:@"C0"]) {
            NSString *url = appDelegate.target_url;
            if([url rangeOfString:@"://"].location==NSNotFound){
                url = [url stringByAppendingString:@"://"];
            }
            
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            NSString *current = [pref objectForKey:appDelegate.menu_no];
            current = [current stringByReplacingOccurrencesOfString:@"." withString:@""];
            NSString *versionFromServer = currentAppVersion;
            versionFromServer = [versionFromServer stringByReplacingOccurrencesOfString:@"." withString:@""];
            url = [url stringByAppendingFormat:@"?%@",paramString];
            if (current.length==3) current = [current stringByAppendingString:@"00"];
            if (versionFromServer.length==3) versionFromServer = [versionFromServer stringByAppendingString:@"00"];
            
            NSLog(@"nativeAppURL : %@",nativeAppURL);
            @try {
                if ([nativeAppURL isEqualToString:@"#"]) {
                    BOOL isInstall = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
                    if (!isInstall) {
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"message95", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                        [alertView show];
                    }
                }else{
                    if ([pref objectForKey:appDelegate.menu_no]==nil) {
                        [pref setValue:currentAppVersion forKey:appDelegate.menu_no];
                        [pref synchronize];
                        NSURL *browser = [NSURL URLWithString:nativeAppURL];
                        [[UIApplication sharedApplication] openURL:browser];
                    }else if ([current intValue]!=[versionFromServer intValue]) {
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message54", @"") message:NSLocalizedString(@"message94", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""),nil];
                        [alertView show];
                    }else if([current intValue]==[versionFromServer intValue]){
                        BOOL isInstall = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
                        if (!isInstall) {
                            NSURL *browser = [NSURL URLWithString:nativeAppURL];
                            [[UIApplication sharedApplication] openURL:browser];
                        }
                    }
                }
            }
            @catch (NSException *exception) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"message95", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                [alertView show];
            }
            
        } else if ([menuType isEqualToString:@"A1"]){
            appDelegate.isMainWebView = NO;
            NSString *passUrl = [NSString stringWithFormat:@"%@?%@",appDelegate.target_url,paramString];
            NSURL *browser = [NSURL URLWithString:passUrl];
            [[UIApplication sharedApplication] openURL:browser];
            
        } else if([menuType isEqualToString:@"A2"]||[menuType isEqualToString:@"D0"]){
            appDelegate.isMainWebView = NO;
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *webAppFolder = [documentFolder stringByAppendingFormat:@"/%@/webapp/%@",appDelegate.comp_no,appDelegate.menu_no];
            NSString *htmlFilePath = [webAppFolder stringByAppendingFormat:@"/%@",appDelegate.target_url];
            if (![paramString isEqualToString:@""]) {
                appDelegate.paramString = paramString;
            }
            
            appDelegate.target_url = htmlFilePath;
            
            NSData *data = [NSData dataWithContentsOfFile:htmlFilePath];
            
            NSPropertyListFormat format;
            NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
            NSMutableDictionary *dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
            NSLog(@"dic : %@",dic);
            if (appDelegate.isOffLine) {
                if ([dic objectForKey:appDelegate.menu_no]!=nil && ![[dic objectForKey:appDelegate.menu_no] isEqualToString:currentAppVersion]) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:appDelegate.menu_title message:NSLocalizedString(@"message113", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                    
                }else if([dic objectForKey:appDelegate.menu_no]==nil){
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:appDelegate.menu_title message:NSLocalizedString(@"message114", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                }else{
                    WebViewController *vc = [[WebViewController alloc] init];
                    vc.isDMS = _isDMS;
                    vc.isTabBar = _isTabBar;
                    if (!_isTabBar) {
                        vc.hidesBottomBarWhenPushed = YES;
                    }else{
                        vc.hidesBottomBarWhenPushed = NO;
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else {
                if (data==nil ||
                    [dic objectForKey:appDelegate.menu_no]==nil ||
                    ![[dic objectForKey:appDelegate.menu_no] isEqualToString:currentAppVersion]) {
                    
                    NSString *lastPath = [nativeAppURL lastPathComponent];
                    NSString *useDownloadURL = nativeAppURL;
                    NSString *temp=@"";
                    lastPath = [lastPath urlEncodeUsingEncoding:NSUTF8StringEncoding];
                    NSArray *pathArray = [useDownloadURL pathComponents];
                    for (int i=0; i<[pathArray count]-1; i++) {
                        temp = [temp stringByAppendingFormat:@"%@",[pathArray objectAtIndex:i]];
                        if ([temp isEqualToString:@"http:"]) {
                            temp = [temp stringByAppendingString:@"//"];
                        }else{
                            temp = [temp stringByAppendingString:@"/"];
                        }
                    }
                    NSMutableArray *_downloadUrlArray = [NSMutableArray array];
                    NSMutableArray *_menuTitles = [NSMutableArray array];
                    NSString *naviteAppDownLoadUrl = [temp stringByAppendingString:lastPath];
                    [_downloadUrlArray addObject:naviteAppDownLoadUrl];
                    [_menuTitles addObject:appDelegate.menu_title];
                    
                    NSFileManager *fileManager = [[NSFileManager alloc]init];
                    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    NSString *compFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
                    NSString *commonFolder = [compFolder stringByAppendingPathComponent:@"webapp"];
                    commonFolder = [commonFolder stringByAppendingPathComponent:@"common"];
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    if ([prefs objectForKey:@"COMMON_DOWNLOAD"]!=nil) {
                        BOOL isCommon = [fileManager isReadableFileAtPath:commonFolder];
                        if (!isCommon){
                            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                            [_downloadUrlArray addObject:[prefs objectForKey:@"COMMON_DOWNLOAD"]];
                            [_menuTitles addObject:@"COMMON"];
                        }
                    }
                    
                    DownloadListViewController *vc = [[DownloadListViewController alloc]init];
                    
                    vc.downloadNoArray = [NSMutableArray arrayWithArray:@[nativeAppMenuNo]];
                    vc.downloadVerArray = [NSMutableArray arrayWithArray:@[currentAppVersion]];
                    
                    vc.downloadUrlArray = _downloadUrlArray;
                    vc.downloadMenuTitleList = _menuTitles;
                    vc.delegate = self;
                    //vc.view.frame = CGRectMake(0, 0, 320, 100);
                    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                    nvc.navigationBarHidden=NO;
                    int increaseRow = 0;
                    for (int i=1; i<[_downloadUrlArray count]; i++) {
                        increaseRow = increaseRow+DOWNLOAD_ROW_INCREASE_SIZE;
                    }
                    if (increaseRow > DOWNLOAD_HEIGHT) increaseRow = DOWNLOAD_HEIGHT;
                    
                    nvc.view.frame = CGRectMake(0, 0, DOWNLOAD_WIDTH, DOWNLOAD_ROW_SIZE+increaseRow);
                    [self presentPopupViewController:nvc animationType:MJPopupViewAnimationFade];
                    
                    //vc.downloadURL = naviteAppDownLoadUrl;
                    //vc.currentAppVersion = currentAppVersion;
                    //vc.nativeAppMenuNo = nativeAppMenuNo;
                    
                }else{
                    WebViewController *vc = [[WebViewController alloc] init];
                    vc.isDMS = _isDMS;
                    vc.isTabBar = _isTabBar;
                    if (!_isTabBar) {
                        vc.hidesBottomBarWhenPushed = YES;
                    }else{
                        vc.hidesBottomBarWhenPushed = NO;
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
            
        } else if ([menuType isEqualToString:@"A0"]||[menuType isEqualToString:@"A4"]){
            //Mobile web 메뉴일때
            NSString *page_url;
            if ([paramString isEqualToString:@""]) page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
            else page_url = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
            appDelegate.target_url = page_url;
            appDelegate.isMainWebView = NO;
            WebViewController *vc = [[WebViewController alloc] init];
            vc.isDMS = _isDMS;
            vc.isTabBar = _isTabBar;
            if (!_isTabBar) {
                vc.hidesBottomBarWhenPushed = YES;
            }else{
                vc.hidesBottomBarWhenPushed = NO;
            }
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if ([menuType isEqualToString:@"A3"]){
            NSString *page_url;
            appDelegate.isMainWebView = NO;
            
            if ([paramString isEqualToString:@""])
                page_url = [[NSString alloc] initWithFormat:@"%@",appDelegate.target_url];
            else
                page_url = [[NSString alloc] initWithFormat:@"%@?%@",appDelegate.target_url,paramString];
            
            appDelegate.target_url = page_url;
            WebViewController *vc = [[WebViewController alloc] init];
            vc.type = @"A3";
            vc.isDMS = _isDMS;
            vc.isTabBar = _isTabBar;
            if (!_isTabBar) {
                vc.hidesBottomBarWhenPushed = YES;
            }else{
                vc.hidesBottomBarWhenPushed = NO;
            }
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

-(void) addMenuHist:(NSString *)menu_no {
    if (!appDelegate.isOffLine) {
        if ([appDelegate.demo isEqualToString:@"DEMO"]) {
            [self menuHandler];
        }else{
            [SVProgressHUD show];
            NSString *menuHitURL;
            NSString *paramStr;
            if (appDelegate.isAES256) {
                menuHitURL = [[NSString alloc] initWithFormat:@"%@/addMenuHist",appDelegate.main_url];
                paramStr = [[NSString alloc]initWithFormat:@"cuser_no=%@&menu_no=%@&encType=AES256",appDelegate.user_no,menu_no];
            }else{
                menuHitURL = [[NSString alloc] initWithFormat:@"%@/addMenuHist",appDelegate.main_url];
                paramStr = [[NSString alloc]initWithFormat:@"cuser_no=%@&menu_no=%@",appDelegate.user_no,menu_no];
                
            }
            NSLog(@"menuHitURL : %@",menuHitURL);
            NSLog(@"menuHitParam : %@",paramStr);
            
            NSData *postData = [paramStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSURL *rankUrl = [NSURL URLWithString:menuHitURL];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:rankUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody: postData];
            
            NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (urlCon) {
                histData = [[NSMutableData alloc]init];
            }
            [urlCon start];
        }
    }else{
        [self menuHandler];
    }
}
-(void)rightBtnClick {
    NSLog(@"rightBTNCLick");
    
    if (_backMode) {
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",_backDefineFunc,_backUserSpecific];
        [self evaluateJavaScript:jsCommand];
    }else{
        if (IS_OS_8_OR_LATER) {
            if ([_webView canGoBack]) {
                [_webView goBack];
            }else{
                if (![self.webView isEqual:[self.webViews objectAtIndex:0]]) {
                    NSLog(@"before webview count : %lu",(unsigned long)[self.webViews count]);
                    WKWebView *webview = [self.webViews lastObject];
                    [webview removeFromSuperview];
                    [self.webViews removeLastObject];
                    NSLog(@"after webview count : %lu",(unsigned long)[self.webViews count]);
                    self.webView = [self.webViews lastObject];
                }
                
            }
        }else{
            if ([mywebView canGoBack]) {
                [mywebView goBack];
            }else{
                if(![mywebView isEqual:[self.webViews objectAtIndex:0]]){
                    [self closeActiveWebView];
                } else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }
    }
}

#pragma mark
#pragma mark Location Delegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status==2) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message201", @"위치 접근 허용") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"message52", @"취소") otherButtonTitles:NSLocalizedString(@"message51", @"확인"), nil];
        [alertView show];
        
    }
    NSLog(@"status : %d",status);
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"Location Updateing Failed! : %@",error);
} // 위치 정보 가져오는 것 실패 때


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation     // CLLocation *)newLocation 여기에 위도경도가 변수에 들어가 있다.
{
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
#pragma mark
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:NSLocalizedString(@"message91", @"")]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if([alertView.title isEqualToString:NSLocalizedString(@"message56", @"")]){
        [_webView reload];
        //[mywebView reload];
    }else if([alertView.title isEqualToString:NSLocalizedString(@"message201", @"")]){
        if (buttonIndex==1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
        }
        
    }
    
}
#pragma mark
#pragma mark WebViewController Utils
- (void)evaluateJavaScript:(NSString *)jsCommand{
    
    if (IS_OS_8_OR_LATER) {
        [_webView evaluateJavaScript:jsCommand completionHandler:nil];
    }else{
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    }
    
    NSLog(@"jsCommand : %@",jsCommand);
    //[mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
- (void) playbackDidFinish:(NSNotification *)noti {
    
    MPMoviePlayerController *player = [noti object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self dismissMoviePlayerViewControllerAnimated];
    
}

- (NSString *)makeDBFile{
    
    NSString *libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"Application Support"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"dbvalley"];
    libraryPath = [libraryPath stringByAppendingPathComponent:@"sqlite_db"];
    NSString *userPath = [libraryPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
    NSString *dbFilePath = [userPath stringByAppendingPathComponent:@"mFinity.db"];
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mFinity.sqlite" ofType:nil];
    NSError *error;
    
    if (![manager isReadableFileAtPath:userPath]) {
        [manager createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![manager isReadableFileAtPath:dbFilePath]) {
        [manager copyItemAtPath:filePath toPath:dbFilePath error:&error];
    }
    
    return libraryPath;
}
-(void)myLocation:(id)sender {
    if ([_type isEqualToString:@"A3"]) {
        [self.locationManager startUpdatingLocation];
        NSString *latitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
        NSString *jsCommand = [NSString stringWithFormat:@"defaultlocation('%@', '%@');",[latitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[longitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        //NSLog(@"jsCommand : %@",jsCommand);
        [self evaluateJavaScript:jsCommand];
        
    }
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
-(NSString *)getPhotoFilePath{
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *photoFolder = @"photo";
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/%@/",photoFolder];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    if (issue) {
        NSLog(@"directory success");
    }else{
        NSLog(@"directory failed");
        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:FALSE attributes:nil error:nil];
    }
    return saveFolder;
}
- (void)signSave:(NSString *)fileName :(NSString *)userSpecific :(NSString *)callbackFunc{
    NSLog(@"fileName : %@",fileName);
    NSString *filePath = [fileName stringByAppendingString:@"\n"];
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileName]) {
        NSLog(@"exist file");
    }else{
        NSLog(@"not exist file");
    }
    if (![fileManager fileExistsAtPath:txtPath]) {
        [filePath writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:txtPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[filePath dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"jsCommand : %@",jsCommand);

    [self evaluateJavaScript:jsCommand];
}
- (void)signSave:(NSString *)fileName{
    NSLog(@"fileName : %@",fileName);
    NSString *filePath = [fileName stringByAppendingString:@"\n"];
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:txtPath]) {
        [filePath writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:txtPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[filePath dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *jsCommand = [NSString stringWithFormat:@"CBSignPad('%@','%@');",[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[fileName lastPathComponent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
- (void)photoSave:(NSString *)fileName{
    _imgFileName = fileName;
    NSString *filePath = [fileName stringByAppendingString:@"\n"];
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:txtPath]) {
        [filePath writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:txtPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[filePath dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSString *jsCommand = [NSString stringWithFormat:@"photoSave('%@','%@');",[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[fileName lastPathComponent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
- (void)photoSave:(NSString *)fileName :(NSString *)userSpectific :(NSString *)callbackFunc{
    NSLog(@"photoSave");
    _imgFileName = fileName;
    NSString *filePath = [fileName stringByAppendingString:@"\n"];
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:txtPath]) {
        [filePath writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:txtPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[filePath dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
//    NSData *data = [NSData dataWithContentsOfFile:txtPath];
//    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"str : %@",str);
//    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpectific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSLog(@"PhotoSave jsCommand : %@",jsCommand);
//    [self evaluateJavaScript:jsCommand];
    
    if([callbackFunc isEqualToString:@"CBGallery"]){
        NSError *error;
        NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"TRUE",@"STATUS", fileName,@"PATH", nil];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString URLEncode];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific URLEncode], jsonString];
        [self evaluateJavaScript:jsCommand];
        
    } else {
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callbackFunc,[userSpectific URLEncode],[fileName URLEncode]];
        [self evaluateJavaScript:jsCommand];
    }
}
//이게 호출됨
-(void)dbConnection:(NSString *)page :(NSString *)crud :(NSString *)sql :(NSString *)dbName :(NSString *)cbName{
    
    sqlite3 *database;
    /*
     NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
     documentPath = [documentPath stringByAppendingPathComponent:@"app_oracle.sync"];
     documentPath = [documentPath stringByAppendingPathComponent:@"sqlite_db"];
     documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
     NSString *dbPath = [dbName stringByAppendingPathExtension:@"db"];
     documentPath = [documentPath stringByAppendingPathComponent:dbPath];
     */
    //NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    NSString *returnStr = @"{";
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) {
        
        // SQL명령을 실행한다.
        NSString *sql2 = [NSString urlDecodeString:sql];
        NSLog(@"sql2 : %@",sql2);
        const char *sqlStatement = [sql2 UTF8String];
        //const char *sqlStatement = "update aaa set bbb=0";
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            int rowCount = 0;
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                NSString *LKey = [NSString stringWithFormat:@"\"L%d\"",i];
                returnStr = [returnStr stringByAppendingFormat:@"%@:[",LKey];
                //NSMutableArray *innerArray = [[NSMutableArray alloc]init];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                        NSLog(@"value null");
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    returnStr = [returnStr stringByAppendingFormat:@"{\"%@\":\"%@\"},",keyString,valueString];
                    
                    
                }
                returnStr = [returnStr substringToIndex:returnStr.length-1];
                
                i++;
                returnStr = [returnStr stringByAppendingString:@"],"];
                
            }
            
            returnStr = [returnStr substringToIndex:returnStr.length-1];
            returnStr = [returnStr stringByAppendingString:@"}"];
            if (rowCount==0) {
                returnStr = @"null";
            }
            
            if (![crud isEqualToString:@"R"]) {
                returnStr = @"{\"L0\":[{\"RESULT\":\"SUCCEED\"}]}";
            }
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",cbName,page,returnStr];
            //NSLog(@"jsCommand : %@",jsCommand);
            [self evaluateJavaScript:jsCommand];
            
        }else {
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",cbName,page,returnStr];
            [self evaluateJavaScript:jsCommand];
        }
        NSLog(@"returnStr : %@",returnStr);
        // SQL 명령을 종료한다.
        sqlite3_finalize(compiledStatement);
        
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    // 데이터베이스를 닫는다.
    sqlite3_close(database);
}
-(void)oldDbConnection:(NSString *)gubn :(NSString *)crud :(NSString *)sql :(NSString *)dbName{
    
    //
    
    sqlite3 *database;
    NSLog(@"dbname : %@",dbName);
    NSLog(@"gubn : %@",gubn);
    NSLog(@"sql : %@",sql);
    NSLog(@"crud : %@",crud);
    //NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    NSString *returnStr = @"{";
    //NSLog(@"sqlite3_open([documentPath UTF8String], &database : %d",sqlite3_open([dbName UTF8String], &database));
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) {
        
        // SQL명령을 실행한다.
        NSString *sql2 = [NSString urlDecodeString:sql];
        //NSLog(@"sql2 : %@",sql2);
        const char *sqlStatement = [sql2 UTF8String];
        //const char *sqlStatement = "update aaa set bbb=0";
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            NSLog(@"SQLITE_OK");
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSString *LKey = [NSString stringWithFormat:@"\"L%d\"",i];
                returnStr = [returnStr stringByAppendingFormat:@"%@:[",LKey];
                //NSMutableArray *innerArray = [[NSMutableArray alloc]init];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    
                    NSString *valueString = nil;
                    //NSData *valueData = nil;
                    
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    returnStr = [returnStr stringByAppendingFormat:@"{\"%@\":\"%@\"},",keyString,valueString];
                    
                    //NSLog(@"valueData : %@",valueData);
                    
                    
                    
                }
                returnStr = [returnStr substringToIndex:returnStr.length-1];
                
                i++;
                returnStr = [returnStr stringByAppendingString:@"],"];
                
            }
            NSLog(@"returnStr : %@",returnStr);
            returnStr = [returnStr substringToIndex:returnStr.length-1];
            returnStr = [returnStr stringByAppendingString:@"}"];
            if (![crud isEqualToString:@"R"]) {
                returnStr = @"{\"L0\":[{\"RESULT\":\"SUCCEED\"}]}";
            }
            NSString *jsCommand = [NSString stringWithFormat:@"setMessageToJs('%@', '%@');",gubn,returnStr];
            //NSLog(@"jsCommand : %@",jsCommand);
            [self evaluateJavaScript:jsCommand];
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"setMessageToJs('%@', '%@');",gubn,returnStr];
            [self evaluateJavaScript:jsCommand];
        }
        
        // SQL 명령을 종료한다.
        sqlite3_finalize(compiledStatement);
        
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
        //NSLog(@"not db open");
    }
    
    // 데이터베이스를 닫는다.
    sqlite3_close(database);
    
}
-(void)dbConnection:(NSString *)gubn :(NSString *)crud :(NSString *)sql :(NSString *)dbName{
    
    //
    
    sqlite3 *database;
    NSLog(@"dbname : %@",dbName);
    NSLog(@"gubn : %@",gubn);
    NSLog(@"sql : %@",sql);
    NSLog(@"crud : %@",crud);
    //NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    NSString *returnStr = @"{";
    //NSLog(@"sqlite3_open([documentPath UTF8String], &database : %d",sqlite3_open([dbName UTF8String], &database));
    if (sqlite3_open([dbName UTF8String], &database) == SQLITE_OK) {
        
        // SQL명령을 실행한다.
        NSString *sql2 = [NSString urlDecodeString:sql];
        //NSLog(@"sql2 : %@",sql2);
        const char *sqlStatement = [sql2 UTF8String];
        //const char *sqlStatement = "update aaa set bbb=0";
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            NSLog(@"SQLITE_OK");
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSString *LKey = [NSString stringWithFormat:@"\"L%d\"",i];
                returnStr = [returnStr stringByAppendingFormat:@"%@:[",LKey];
                //NSMutableArray *innerArray = [[NSMutableArray alloc]init];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    returnStr = [returnStr stringByAppendingFormat:@"{\"%@\":\"%@\"},",keyString,valueString];
                    
                    //NSLog(@"valueData : %@",valueData);
                    
                    
                    
                }
                returnStr = [returnStr substringToIndex:returnStr.length-1];
                
                i++;
                returnStr = [returnStr stringByAppendingString:@"],"];
                
            }
            NSLog(@"returnStr : %@",returnStr);
            returnStr = [returnStr substringToIndex:returnStr.length-1];
            returnStr = [returnStr stringByAppendingString:@"}"];
            if (![crud isEqualToString:@"R"]) {
                returnStr = @"{\"L0\":[{\"RESULT\":\"SUCCEED\"}]}";
            }
            NSString *jsCommand = [NSString stringWithFormat:@"CBResultSql('%@', '%@');",gubn,returnStr];
            //NSLog(@"jsCommand : %@",jsCommand);
            [self evaluateJavaScript:jsCommand];
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
            returnStr = @"{\"L0\":[{\"RESULT\":\"FAILED\"}]}";
            NSString *jsCommand = [NSString stringWithFormat:@"CBResultSql('%@', '%@');",gubn,returnStr];
            [self evaluateJavaScript:jsCommand];
        }
        
        // SQL 명령을 종료한다.
        sqlite3_finalize(compiledStatement);
        
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
        //NSLog(@"not db open");
    }
    
    // 데이터베이스를 닫는다.
    sqlite3_close(database);
    
}
#pragma mark
#pragma mark Barcode Call
-(void)errorReadBarcode:(NSString *)errMessage{
    NSLog(@"error : %@",errMessage);
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[errMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
-(void)resultReadBarcode:(NSString *)result{
    NSLog(@"result : %@",result);
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self evaluateJavaScript:jsCommand];
}
-(void) barCodeReaderOpen{
    MFBarcodeScannerViewController *vc = [[MFBarcodeScannerViewController alloc]init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
    /*
    //등록한 외부라이브러리를 이용해 바코드리더 오픈 ---------------
    _reader = [ZBarReaderViewController new];
    _reader.readerDelegate = self;
    ZBarImageScanner *scanner = _reader.scanner;
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    //------------------------------------------------------
    
    //바코드리더뷰 열기
    [self presentViewController:_reader animated:YES completion:nil];
     */
}
#pragma mark - UIImagePickerControllerDelegate
- (void)photoAccessCheck :(NSString *)mediaType{
    //NSLog(@"%s", __func__);
    @try{
        int osVer = [[UIDevice currentDevice].systemVersion floatValue];
        PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
        
        if (photoStatus == PHAuthorizationStatusAuthorized) {
            
        } else if (photoStatus == PHAuthorizationStatusDenied) {
            NSLog(@"Access has been denied.");
            if(osVer >= 8){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 사진]에서 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 사진]에서 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else if (photoStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    NSLog(@"1 StatusNotDetermined Access has been granted.");
                    if([mediaType isEqualToString:@"PHOTO"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                        });
                    }
                    
                } else {
                    NSLog(@"2 StatusNotDetermined Access has been granted.");
                }
            }];
        } else if (photoStatus == PHAuthorizationStatusRestricted) {
            NSLog(@"Restricted access - normally won't happen.");
        }
        
        return;
        
    } @catch(NSException *exception){
        
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"취소 PhotoSave jsCommand : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    if (isCamera) {
        //카메라뷰일때
        UIImage *sendImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //동영상일때
        //NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        
        // 현재시간 알아오기
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        
        NSString *filename = appDelegate.user_no;
        filename = [filename stringByAppendingString:@"("];
        
        filename = [filename stringByAppendingString:currentTime];
        filename = [filename stringByAppendingString:@")"];
        if (sendImage!=nil) {
            [self savePicture:sendImage :filename];
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
        isCamera = NO;
        
    }else{
        //바코드뷰일때
        //        id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
        //        ZBarSymbol *symbol = nil;
        //
        //        for (symbol in results) {
        //            break;
        //        }
        //        NSString *serial = symbol.data;
        //        NSLog(@"serial : %@",symbol.data);
        //        [_reader dismissViewControllerAnimated:YES completion:nil];
        //        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[serial stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        //        [self evaluateJavaScript:jsCommand];
    }
    
    UIImage *sendImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"sendImage : %@",sendImage);
    
    if (sendImage!=nil) {
        [self savePicture:sendImage :[self createPhotoFileName]];
    } else {
        NSError *error;
        NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"FALSE",@"STATUS", nil];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific URLEncode], jsonString];
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
/*
- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    if (isCamera) {
        //카메라뷰일때
        UIImage *sendImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //동영상일때
        //NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        
        // 현재시간 알아오기
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        
        NSString *filename = appDelegate.user_no;
        filename = [filename stringByAppendingString:@"("];
        
        filename = [filename stringByAppendingString:currentTime];
        filename = [filename stringByAppendingString:@")"];
        if (sendImage!=nil) {
            [self savePicture:sendImage :filename];
        }
        [reader dismissViewControllerAnimated:YES completion:nil];
        isCamera = NO;
        
    }else{
        //바코드뷰일때
//        id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
//        ZBarSymbol *symbol = nil;
//        
//        for (symbol in results) {
//            break;
//        }
//        NSString *serial = symbol.data;
//        NSLog(@"serial : %@",symbol.data);
//        [_reader dismissViewControllerAnimated:YES completion:nil];
//        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[serial stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        [self evaluateJavaScript:jsCommand];
    }
    
    UIImage *sendImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"sendImage : %@",sendImage);
    
    if (sendImage!=nil) {
        [self savePicture:sendImage :[self createPhotoFileName]];
    } else {
        NSError *error;
        NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"FALSE",@"STATUS", nil];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc,[self.userSpecific URLEncode], jsonString];
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    }
    
    [reader dismissViewControllerAnimated:YES completion:nil];
}
 */
-(NSString *)createPhotoFileName{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    NSString *filename = @"";
    filename = [filename stringByAppendingString:@"("];
    
    filename = [filename stringByAppendingString:currentTime];
    filename = [filename stringByAppendingString:@")"];
    return filename;
}
-(void) savePicture:(UIImage *)sendImage :(NSString*)file{
    NSString *saveFolder = [self getPhotoFilePath];
    UIImage *image = sendImage;
    CGSize newSize;
    newSize.width = image.size.width/3;
    newSize.height = image.size.height/3;
    CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);
    [image drawInRect:rect];
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image,0.05)];
    //NSData *encryptImageData = [imageData AES256EncryptWithKey:appDelegate.AES256Key];
    NSString *filePath2 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:@".jpg"]];
    NSString *filePath3 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:@".thum"]];
    //NSLog(@"thum file path : %@",filePath3);
    [imageData writeToFile:filePath2 atomically:YES];
    UIImage *thumImage = [self resizedImage:image inRect:CGRectMake(0, 0, 60, 60)];
    NSData *thumData = [NSData dataWithData:UIImagePNGRepresentation(thumImage)];
    //NSData *encrytpThumData = [thumData AES256EncryptWithKey:appDelegate.AES256Key];
    [thumData writeToFile:filePath3 atomically:YES];
    
    if (_userSpecific ==nil) {
        [self photoSave:filePath2];
    }else{
        [self photoSave:filePath2 :_userSpecific :_callbackFunc];
    }
}
-(UIImage *) resizedImage:(UIImage *)img inRect:(CGRect)frameRect {
    UIGraphicsBeginImageContext(frameRect.size);
    [img drawInRect:frameRect];
    return UIGraphicsGetImageFromCurrentImageContext();
}
#pragma mark
#pragma mark MFNP
-(void) executeBackKeyEvent:(NSString *)callBackFunc :(NSString *)userSpecific{
    _backDefineFunc = callBackFunc;
    _backUserSpecific = userSpecific;
}
-(void)executeBarcode:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    [self barCodeReaderOpen];
}
-(void)executeCamera:(NSString *)callBackFunc :(NSString *)userSpecific{
    //MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    isCamera = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.delegate = self;
        self.picker.allowsEditing = YES;
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSLog(@"picker : %@",self.picker);
        
        [self presentViewController:self.picker animated:YES completion:NULL];
    }else{
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    /*
     CameraMenuViewController *vc = [[CameraMenuViewController alloc]init];
     appDelegate.mediaControl = @"camera";
     vc.isWebApp = YES;
     vc.callbackFunc = callBackFunc;
     vc.userSpecific = userSpecific;
     [self.navigationController pushViewController:vc animated:NO];
     */
}
-(void)executeDataGate:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)dbConfigKey :(NSString *)sprocName :(NSString *)args{
    _callBackDic = [[NSMutableDictionary alloc]init];
    [_callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [_callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    [_callBackDic setValue:[dbConfigKey urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"dbConfigKey"];
    [_callBackDic setValue:[sprocName urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"sprocName"];
    [_callBackDic setValue:[args urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"args"];
    
    NSString *_dbConfigKey =[FBEncryptorAES encryptBase64String:dbConfigKey
                                                      keyString:appDelegate.AES256Key
                                                  separateLines:NO];
    NSString *_sprocName =[FBEncryptorAES encryptBase64String:sprocName
                                                    keyString:appDelegate.AES256Key
                                                separateLines:NO];
    NSString *_args =[FBEncryptorAES encryptBase64String:args
                                               keyString:appDelegate.AES256Key
                                           separateLines:NO];
    NSString *_compNo =[FBEncryptorAES encryptBase64String:appDelegate.comp_no
                                                 keyString:appDelegate.AES256Key
                                             separateLines:NO];
    NSLog(@"dbConfigKey : %@",dbConfigKey);
    NSLog(@"sprocName : %@",sprocName);
    NSLog(@"args : %@",args);
    NSLog(@"appDelegate.comp_no : %@",appDelegate.comp_no);
    //NSString *mainString = [appDelegate.main_url stringByReplacingOccurrencesOfString:@"dataservice41" withString:@""];
    //NSString *mainString = @"http://192.168.0.54:1598/";
    NSString *urlString = [NSString stringWithFormat:@"%@/DataGate3",appDelegate.main_url];
    NSString *param = [[NSString alloc]initWithFormat:@"jsonPCallback=?&dbConfigKey=%@&sprocName=%@&args=%@&jsonPCallback?&compNo=%@&encType=AES256",[_dbConfigKey urlEncodeUsingEncoding:NSUTF8StringEncoding],[_sprocName urlEncodeUsingEncoding:NSUTF8StringEncoding],[_args urlEncodeUsingEncoding:NSUTF8StringEncoding],[_compNo urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"paramString : %@",param);
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:30.0];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if (urlConnection) {
        receiveData = [NSMutableData data];
        [urlConnection start];
    }
    
}
-(NSArray *)selectQuery:(NSString *)dbFilePath :(NSString *)selectStmt{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager isReadableFileAtPath:dbFilePath]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
        [self.navigationController popViewControllerAnimated:YES];
    }
    sqlite3 *database;
    if (sqlite3_open([dbFilePath UTF8String], &database) == SQLITE_OK) {
        NSString *sql2 = selectStmt;
        const char *sqlStatement = [sql2 UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                    }
                    [dic setObject:valueString forKey:keyString];
                }
                [resultArray addObject:dic];
            }
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
        }
        sqlite3_finalize(compiledStatement);
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    sqlite3_close(database);
    
    return resultArray;
}
-(void) executeExitWebBrowser{
    [self.navigationController popViewControllerAnimated:YES];
}
/*
 -(void)executeFileUpload:(NSString *)fileType :(NSDictionary *)fileList :(NSString *)upLoadPath{
 
 //@property (nonatomic, strong) NSMutableArray *uploadFilePathArray;
 //@property (nonatomic, strong) NSMutableArray *uploadUrlArray;
 NSMutableArray *uploadFilePathArray = [[NSMutableArray alloc]init];
 NSMutableArray *uploadUrlArray = [[NSMutableArray alloc]init];
 for (int i=0; i<[fileList count]; i++) {
 [uploadFilePathArray addObject:[fileList objectForKey:[NSString stringWithFormat:@"%d",i]]];
 [uploadUrlArray addObject:upLoadPath];
 }
 
 [self fileUploads:uploadFilePathArray :uploadUrlArray];
 }
 */
-(void)executeFileUpload:(NSString *)callBackFunc :(NSString *)userSpecific :(NSDictionary *)fileList :(NSString *)upLoadPath :(NSString *)flag{
    //    NSLog(@"callBackFunc : %@", callBackFunc);
    //    NSLog(@"userSpecific : %@", userSpecific);
    //    NSLog(@"fileList : %@", fileList);
    //    NSLog(@"upLoadPath : %@", upLoadPath);
    //    NSLog(@"flag : %@", flag);
    
    self.callbackFunc = callBackFunc;
    self.userSpecific = userSpecific;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ImageUploadReturn:) name:@"ImageUploadReturn" object:nil];
    
    NSMutableArray *uploadFilePathArray = [[NSMutableArray alloc]init];
    NSMutableArray *uploadUrlArray = [[NSMutableArray alloc]init];
    for (int i=0; i<[fileList count]; i++) {
        [uploadFilePathArray addObject:[fileList objectForKey:[NSString stringWithFormat:@"%d",i]]];
        [uploadUrlArray addObject:upLoadPath];
    }
    
    //NSLog(@"uploadFilePathArray : %@", uploadFilePathArray);
    //NSLog(@"uploadUrlArray : %@", uploadUrlArray);
    
    [self fileUploads:uploadFilePathArray :uploadUrlArray :flag];
}
-(void)fileUploads:(NSMutableArray *)uploadFilePathArray :(NSMutableArray *)uploadUrlArray :(NSString *)flag{
    //    UploadListViewController *vc = [[UploadListViewController alloc]init];
    //    vc.uploadFilePathArray = uploadFilePathArray;
    //    vc.uploadUrlArray = uploadUrlArray;
    //    vc.deleteFlag = flag;
    //    vc.delegate = self;
    //
    //    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    //    nvc.navigationBarHidden=NO;
    //    int increaseRow = 0;
    //    for (int i=1; i<[uploadFilePathArray count]; i++) {
    //        increaseRow = increaseRow+DOWNLOAD_ROW_INCREASE_SIZE;
    //    }
    //    if (increaseRow > DOWNLOAD_HEIGHT) increaseRow = DOWNLOAD_HEIGHT;
    //
    //    nvc.view.frame = CGRectMake(0, 0, DOWNLOAD_WIDTH, DOWNLOAD_ROW_SIZE+increaseRow);
    //    [self presentPopupViewController:nvc animationType:MJPopupViewAnimationFade];
    
    UploadProcessViewController *vc = [[UploadProcessViewController alloc] init];
    vc.uploadFilePathArray = uploadFilePathArray;
    vc.uploadUrlArray = uploadUrlArray;
    vc.deleteFlag = flag;
    vc.delegate = self;
    [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
}
- (void)ImageUploadReturn:(NSNotification *)notification {
    NSLog(@"ImageUploadReturn userinfo : %@", notification.userInfo);
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    NSArray *array = [notification.userInfo objectForKey:@"RETURN"];
    
    NSError *_error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&_error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString URLEncode];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc, self.userSpecific, jsonString];
    NSLog(@"jsCommand : %@", jsCommand);
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)UploadProcessViewReturn:(NSString *)result :(NSMutableArray *)returnArr{
    NSLog(@"%s",__func__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    NSLog(@"result : %@", result);
    NSLog(@"returnArr : %@", returnArr);
    
    if([result isEqualToString:@"SUCCEED"]){
        NSError *_error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnArr options:0 error:&_error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString URLEncode];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc, self.userSpecific, jsonString];
        NSLog(@"jsCommand : %@", jsCommand);
        
        [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    }
}
-(void)returnArray:(NSMutableArray *)array WithError:(NSString *)error{
    //executeFileUpload리턴
    NSLog(@"executeFileUpload리턴");
    NSError *_error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&_error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString URLEncode];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",self.callbackFunc, self.userSpecific, jsonString];
    NSLog(@"jsCommand : %@", jsCommand);
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)executeGallery:(NSDictionary *)dic{
    [self photoAccessCheck:@"PHOTO"];
    
    self.callbackFunc = [dic objectForKey:@"callbackFunc"];
    self.userSpecific = [dic objectForKey:@"userSpecific"];
    
    //UIImagePickerControllerSourceTypeCamera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.delegate = self;
        self.picker.navigationBar.backgroundColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:self.picker animated:YES completion:NULL];
    }
  
}
-(void)executeMenu:(NSString *)menuNo{
    [self getExecuteMenuInfo:menuNo];
}
-(void)executeNonQuery:(NSString *)dbName :(NSString *)selectStmt :(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *documentPath = [self makeDBFile];
    
    //self.dbDirectoryPath;
    
    documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
    NSLog(@"appDelegate.user_id : %@",appDelegate.user_id);
    NSString *dbPath = [dbName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    documentPath = [documentPath stringByAppendingPathComponent:dbPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"documentPath : %@",documentPath);
    
    if (![fileManager isReadableFileAtPath:documentPath]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    sqlite3 *database;
    
    NSString *returnStr = @"";
    if (sqlite3_open([documentPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql2 = [NSString urlDecodeString:selectStmt];
        //NSLog(@"sql2 : %@",sql2);
        const char *sqlStatement = [sql2 UTF8String];
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if(sqlite3_step(compiledStatement) != SQLITE_DONE){
                NSLog(@"Error updating table: %s", sqlite3_errmsg(database));
                
                NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
                returnStr = @"{\"RESULT\":\"FAILED\",\"MESSAGE\":\"";
                returnStr = [returnStr stringByAppendingString:NSLocalizedString(str, @"")];
                returnStr = [returnStr stringByAppendingString:@"\"}"];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
                
            }else{
                returnStr = @"{\"RESULT\":\"SUCCEED\"}";
            }
            
            if(sqlite3_finalize(compiledStatement) != SQLITE_OK){
                NSLog(@"SQL Error : %s",sqlite3_errmsg(database));
                NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
                returnStr = @"{\"RESULT\":\"FAILED\",\"MESSAGE\":\"";
                returnStr = [returnStr stringByAppendingString:NSLocalizedString(str, @"")];
                returnStr = [returnStr stringByAppendingString:@"\"}"];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            }
            
            
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            returnStr = @"{\"RESULT\":\"FAILED\",\"MESSAGE\":\"";
            returnStr = [returnStr stringByAppendingString:NSLocalizedString(str, @"")];
            returnStr = [returnStr stringByAppendingString:@"\"}"];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
        }
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    sqlite3_close(database);
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[returnStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"executeNonQuery : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)executeNotification:(NSString *)useVibrator :(NSString *)useBeep :(NSString *)timer{
    count=0;
    endCount=[timer intValue];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys:useVibrator,@"useVibrator",useBeep,@"useBeep", nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(handleTimer:)
                                   userInfo:userInfo
                                    repeats:YES];
    
}
-(void) handleTimer:(NSTimer *)timer {
    count++;
    
    if (count==endCount) {
        count=0;
        
        if ([[timer.userInfo objectForKey:@"useVibrator"] isEqualToString:@"true"]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
        if ([[timer.userInfo objectForKey:@"useBeep"] isEqualToString:@"true"]) {
            AudioServicesPlaySystemSound(1106);
            //AudioServicesPlayAlertSound(1057);
        }
        [timer invalidate];
    }
}
-(void)executeProgressDialogStart:(NSString *)title :(NSString *)msg :(NSString *)callbackFunc{
    [SVProgressHUD showWithStatus:msg];
    NSString *jsCommand = [NSString stringWithFormat:@"%@();",callbackFunc];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)executeProgressDialogStop{
    [SVProgressHUD dismiss];
}
-(void)executePush:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)userList :(NSString *)message{
    
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[userList dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    NSString *urlString = [NSString stringWithFormat:@"%@/sendPushService",appDelegate.main_url];
    //NSString *urlString = @"http://192.168.0.54:1598/dataservice41/sendPushService";
    NSLog(@"urlString : %@",urlString);
    NSLog(@"message : %@",message);
    NSLog(@"userList : %@",dic);
    
    NSString *_paramString = [NSString stringWithFormat:@"encType=AES256&mode=C&msg=%@&userList=%@",message,dic];
    
    NSData *paramData = [_paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    _callBackDic = [[NSMutableDictionary alloc]init];
    [_callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [_callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: paramData];
    [request setTimeoutInterval:30.0];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if (conn) {
        receiveData = [NSMutableData data];
    }
}
-(void) executeRecognizeSpeech:(NSString *)callBackFunc :(NSString *)userSpecific{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"executeRecognizeSpeech" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
}
-(void)executeRetrieve:(NSString *)dbName :(NSString *)selectStmt :(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *documentPath = [self makeDBFile];
    
    documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
    
    NSString *dbPath = [dbName stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    documentPath = [documentPath stringByAppendingPathComponent:dbPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager isReadableFileAtPath:documentPath]) {
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message160", @"DB파일을 찾을 수 없습니다.")];
        [self.navigationController popViewControllerAnimated:YES];
    }
    NSString *returnStr = @"";
    //NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    sqlite3 *database;
    if (sqlite3_open([documentPath UTF8String], &database) == SQLITE_OK) {
        NSString *sql2 = selectStmt;
        const char *sqlStatement = [sql2 UTF8String];
        sqlite3_stmt *compiledStatement;
        int i=0;
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            returnStr = @"{\"RESULT\":\"SUCCEED\",";
            
            //NSMutableDictionary *row = [[NSMutableDictionary alloc]init];
            
            int rowCount = 0;
            returnStr = [returnStr stringByAppendingFormat:@"\"DATASET\":{"];
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                rowCount = sqlite3_column_int(compiledStatement, 0);
                NSString *LKey = [NSString stringWithFormat:@"ROW%d",i++];
                
                returnStr = [returnStr stringByAppendingFormat:@"\"%@\":{",LKey];
                //NSMutableDictionary *dataSet = [[NSMutableDictionary alloc]init];
                for(int j=0; j<sqlite3_column_count(compiledStatement);j++){
                    NSString *keyString = [NSString stringWithUTF8String:(sqlite3_column_name(compiledStatement, j))];
                    NSString *valueString = nil;
                    if (sqlite3_column_text(compiledStatement, j)==NULL) {
                        valueString = @"null";
                    }else{
                        
                        valueString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, j)];
                        
                    }
                    returnStr = [returnStr stringByAppendingFormat:@"\"%@\":\"%@\",",keyString,valueString];
                }
                returnStr = [returnStr substringToIndex:returnStr.length-1];
                returnStr = [returnStr stringByAppendingFormat:@"},"];
            }
            returnStr = [returnStr substringToIndex:returnStr.length-1];
            if(rowCount==0){
                returnStr = [returnStr stringByAppendingFormat:@"\"\"}"];
            }else{
                returnStr = [returnStr stringByAppendingFormat:@"}}"];
            }
            
            
        }else {
            NSLog(@"not SQLITE_OK");
            NSString *str = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
            returnStr = @"{\"RESULT\":\"FAILED\",\"MESSAGE\":\"";
            returnStr = [returnStr stringByAppendingString:NSLocalizedString(str, @"")];
            returnStr = [returnStr stringByAppendingString:@"\"}"];
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(str, @"")];
            printf("could not prepare statement: %s\n", sqlite3_errmsg(database));
        }
        sqlite3_finalize(compiledStatement);
        
    }else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message162", @"Not db open")];
    }
    
    sqlite3_close(database);
    NSLog(@"returnStr : %@",returnStr);
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[returnStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"executeRetrive : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)executeSignpad:(NSString *)callBackFunc :(NSString *)userSpecific{
    SignPadViewController *vc = [[SignPadViewController alloc]init];
    vc.userSpecific = userSpecific;
    vc.callbackFunc = callBackFunc;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    //[self.navigationController pushViewController:vc animated:YES];
    [self presentViewController:nvc animated:YES completion:nil];
}
-(void) executeSms:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)msg :(NSString *)userList{
    _callBackDic = [[NSMutableDictionary alloc]init];
    [_callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [_callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    
    NSError *error;
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[userList dataUsingEncoding: NSUTF8StringEncoding] options:kNilOptions error:&error];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSString *user in [dataDic allValues]) {
        NSString *inValue = [user stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [array addObject:inValue];
    }
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = msg;
        controller.recipients = array;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        //[self presentModalViewController:controller animated:YES];
    }
}

-(void)executeLogout{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",appDelegate.main_url]]];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [conn start];
}
-(void) executeVideoPlayer:(NSString *)streamingUrl{
    NSLog(@"streamingUrl : %@",streamingUrl);
    NSURL *movieURL = [NSURL URLWithString:streamingUrl];
    MPMoviePlayerViewController *playView = [[MPMoviePlayerViewController alloc]initWithContentURL:movieURL];
    MPMoviePlayerController *moviePlayer = [playView moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:playView];
}

-(void)getAccelerometer:(NSString *)callBackFunc :(NSString *)userSpecific{
    // Create a CMMotionManager
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    _myDataLogger = [[DataLogger alloc] init];
    [_myDataLogger setLogUserAccelerationData:YES];
    [_myDataLogger startLoggingMotionData];
    [self performSelector:@selector(stopAccelerometer) withObject:self afterDelay:1.0];
}
-(void)stopAccelerometer{
    [_myDataLogger stopLoggingMotionDataAndSave];
    
    NSArray *accelorInfo = [_myDataLogger.userAccelerationString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:3] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void) getCheckSession:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callBackDic = [[NSMutableDictionary alloc]init];
    [_callBackDic setValue:[callBackFunc urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"callBackFunc"];
    [_callBackDic setValue:[userSpecific urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"userSpecific"];
    
    NSString *sessionURL = [NSString stringWithFormat:@"%@/CheckSession",appDelegate.main_url];
    NSURL *url = [NSURL URLWithString:sessionURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30.0];
    
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if (conn) {
        receiveData = [NSMutableData data];
    }
}
-(void)getConvertImageToBase64:(NSString *)callBackFunc :(NSString *)imagePath {
    /*
     Bitmap bitmap = BitmapFactory.decodeFile(imagePath);
     ByteArrayOutputStream outStream = new ByteArrayOutputStream();
     bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outStream);
     byte[] image = outStream.toByteArray();
     String fileImageBase64 = Base64.encodeToString(image, 0);
     
     JSONObject json = new JSONObject();
     File file = new File(imagePath);
     json.put("title",file.getName().toString());
     json.put("value", fileImageBase64);
     
     String result = "javascript:"+callbackFunc+"('"+json+"')";
     Message msg = mfnpHandler.obtainMessage();
     msg.what = 6;
     msg.obj = result;
     mfnpHandler.sendMessage(msg);
     */
    
    //NSString *_imagePath = [self getPhotoFilePath];
    //_imagePath = [_imagePath stringByAppendingFormat:@"/%@",];
    //_imagePath = [_imagePath stringByAppendingPathExtension:imagePath];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    NSString *base64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    [returnDic setObject:[imagePath lastPathComponent] forKey:@"title"];
    [returnDic setObject:base64 forKey:@"value"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@');",callBackFunc,[jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getDeviceSpec:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)specName{
    NSDictionary *deviceSpec = [self getDeviceSpec];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[deviceSpec objectForKey:specName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getDeviceSpec:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *spec = [self getJsonStringByDictionary:[self getDeviceSpec]];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[spec stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"deviceSpec command : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(NSDictionary *)getDeviceSpec{
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *osName = @"iOS";
    NSString *osVersion = myDevice.systemVersion;
    // 통신사
    //CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    //CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    // Get carrier name
    //NSString *carrierName = [carrier carrierName];
    
    NSString *production = @"Apple";
    //해상도
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    if ([self retinaDisplayCapable]) {
        screenHeight = screenHeight*2;
        screenWidth = screenWidth*2;
    }
    NSString *width = [NSString stringWithFormat:@"%f",screenWidth];
    width = [width stringByDeletingPathExtension];
    NSString *height = [NSString stringWithFormat:@"%f",screenHeight];
    height = [height stringByDeletingPathExtension];
    NSString *resolution = [width stringByAppendingString:@"*"];
    resolution = [resolution stringByAppendingString:height];
    
    //가속도 센서
    NSString *isAccelerometer = @"";
    if ([self accelerometerAvailable]) {
        isAccelerometer = @"YES";
    }else{
        isAccelerometer = @"NO";
    }
    //g센서
    
    NSString *isGyroscope = @"";
    if ([self gyroscopeAvailable]) {
        isGyroscope = @"YES";
    }else{
        isGyroscope = @"NO";
    }
    
    //자기장센서
    NSString *isMagnetometer = @"";
    if ([self compassAvailable]) {
        isMagnetometer = @"YES";
    }else{
        isMagnetometer = @"NO";
    }
    
    //방향센서
    NSString *isDirection = @"";
    if ([self accelerometerAvailable]) {
        isDirection = @"YES";
    }else{
        isDirection = @"NO";
    }
    
    //근접센서
    NSString *isProximity = @"";
    UIDevice *device = [UIDevice currentDevice];
    if(device.proximityMonitoringEnabled){
        isProximity = @"YES";
    }else{
        isProximity = @"NO";
    }
    
    //gps
    NSString *isGPS = @"";
    if ([self gpsAvailable]) {
        isGPS = @"YES";
    }else{
        isGPS = @"NO";
    }
    //camera
    //NSString *isCamera = [self isValue:@"still-camera"];
    NSString *_isCamera = @"";
    if ([self linearCameraAvailable]) {
        _isCamera = @"YES";
    }else{
        _isCamera = @"NO";
    }
    //front_camera
    //NSString *isFrontCamera = [self isValue:@"front-facing-camera"];
    NSString *isFrontCamera = @"";
    if ([self frontCameraAvailable]) {
        isFrontCamera = @"YES";
    }else{
        isFrontCamera = @"NO";
    }
    
    //cpu core
    NSString *coreCount = [NSString stringWithFormat:@"%d",[self countCores]];
    
    NSString *appType = @"Phone";
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSString *modelName = [[UIDevice currentDevice] modelName];
    
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    [returnDic setObject:modelName  forKey:@"modelName"];
    [returnDic setObject:coreCount  forKey:@"cpuCore"];
    [returnDic setObject:production forKey:@"manufacturer"];
    [returnDic setObject:resolution forKey:@"resolution"];
    
    [returnDic setObject:isAccelerometer forKey:@"accelerometer"];
    [returnDic setObject:isGyroscope forKey:@"gyroscope"];
    [returnDic setObject:isMagnetometer forKey:@"magnet"];
    [returnDic setObject:isDirection forKey:@"orientation"];
    [returnDic setObject:isGPS forKey:@"gps"];
    [returnDic setObject:_isCamera forKey:@"stillcam"];
    [returnDic setObject:isFrontCamera forKey:@"frontcam"];
    
    [returnDic setObject:osName forKey:@"osType"];
    [returnDic setObject:osVersion forKey:@"osVersion"];
    [returnDic setObject:appType forKey:@"appType"];
    [returnDic setObject:appVersion forKey:@"appVersion"];
    
    return returnDic;
}
-(NSString*)getJsonStringByDictionary:(NSDictionary*)dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(void)getFilePath:(NSString *)callBackFunc :(NSString *)userSpecific {
    NSString *photoPath = [self getPhotoFilePath];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[photoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[photoPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getGpsLocation:(NSString *)callBackFunc :(NSString *)userSpecific {
    // Location Manager 생성
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    /*
     if([CLLocationManager locationServicesEnabled]){
     
     NSLog(@"Location Services Enabled");
     }*/
    /*
     if (self.locationManager.location.coordinate.latitude==0 && self.locationManager.location.coordinate.longitude==0) {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
     }*/
    NSString *latitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude];
    NSString *jsCommand;
    if (userSpecific == nil) {
        jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[latitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[longitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else{
        jsCommand = [NSString stringWithFormat:@"%@('%@','%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[latitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[longitude stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    [self.locationManager stopUpdatingLocation];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getGyroscope:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    NSOperationQueue* queue = [[NSOperationQueue alloc]init];
    if( motionManager.gyroAvailable )
    {
        motionManager.gyroUpdateInterval = 1.0 / 10.0;
        [motionManager startGyroUpdatesToQueue:queue withHandler:
         ^(CMGyroData* gyroData, NSError* error )
         {
             if( error )
             {
                 [motionManager stopGyroUpdates];
                 NSLog(@"%@",[NSString stringWithFormat:@"Gyroscope encountered error: %@", error]);
             }
             else
             {
                 sensorString = [NSString stringWithFormat:
                                 @"%f,%f,%f",
                                 gyroData.rotationRate.x,
                                 gyroData.rotationRate.y,
                                 gyroData.rotationRate.z];
             }
             
         }];
        [self performSelector:@selector(stopGyroscope) withObject:self afterDelay:1.0];
        
    }
    else
    {
        NSLog(@"This device has no gyroscope");
    }
    
}
-(void)stopGyroscope{
    [motionManager stopGyroUpdates];
    NSArray *accelorInfo = [sensorString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    
}
-(void)getMagneticField:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    NSOperationQueue* queue = [[NSOperationQueue alloc]init];
    if(motionManager.gyroAvailable)
    {
        motionManager.gyroUpdateInterval = 1.0 / 10.0;
        [motionManager startMagnetometerUpdatesToQueue:queue withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
            CMMagneticField field = magnetometerData.magneticField;
            sensorString = [NSString stringWithFormat:
                            @"%f,%f,%f",
                            field.x,
                            field.y,
                            field.z];
            
        }];
        [self performSelector:@selector(stopMagneticField) withObject:self afterDelay:1.0];
        
    }
    else
    {
        NSLog(@"This device has no gyroscope");
    }
    
}
-(void)stopMagneticField{
    [motionManager stopMagnetometerUpdates];
    NSArray *sensorInfo = [sensorString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[sensorInfo objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[sensorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[sensorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
    
}
-(void)getNetworkStatus:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *result = [MFinityAppDelegate deviceNetworkingType];
    
    /*
    //NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    NSNumber *dataNetworkItemView = nil;
    NSArray *subviews = nil;
    id statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    
    if ([statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        subviews = [[[statusBar valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    } else {
        subviews = [[statusBar valueForKey:@"foregroundView"] subviews];
    }
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    switch ([[dataNetworkItemView valueForKey:@"dataNetworkType"]integerValue]) {
        case 0:
            NSLog(@"No wifi or cellular");
            break;
        case 1:
            NSLog(@"Cellular");
            result = @"Cellular";
            break;
        case 2:
            NSLog(@"Cellular");
            result = @"Cellular";
            break;
        case 3:
            NSLog(@"Cellular");
            result = @"Cellular";
            break;
        case 4:
            NSLog(@"Cellular");
            result = @"Cellular";
            break;
        case 5:
            NSLog(@"WIFI");
            result = @"WIFI";
            break;
        default:
            break;
    }
    */
    
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getOrientation:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    _myDataLogger = [[DataLogger alloc] init];
    [_myDataLogger setLogRotationRateData:YES];
    [_myDataLogger startLoggingMotionData];
    [self performSelector:@selector(stopRotationRate) withObject:self afterDelay:1.0];
}
-(void)stopRotationRate{
    [_myDataLogger stopLoggingMotionDataAndSave];
    NSArray *accelorInfo = [_myDataLogger.rotationRateString componentsSeparatedByString:@","];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@','%@','%@');",_callbackFunc,[_userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[accelorInfo objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)getProximity:(NSString *)callBackFunc :(NSString *)userSpecific{
    _callbackFunc = callBackFunc;
    _userSpecific = userSpecific;
    UIDevice *device = [UIDevice currentDevice];
    //device.proximityMonitoringEnabled = YES;
    NSLog(@"device.proximityMonitoringEnabled : %@",device.proximityMonitoringEnabled?@"YES":@"NO");
    if (device.proximityMonitoringEnabled == YES){
        NSLog(@"proximityMonitoringEnabled");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChanged:) name:@"UIDeviceProximityStateDidChangeNotification" object:device];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Proximity" message:NSLocalizedString(@"message143", @"지원하지 않는 기능입니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
        [alertView show];
    }
}
- (void) proximityChanged:(NSNotification *)notification {
    UIDevice *device = [notification object];
    NSLog(@"In proximity: %i", device.proximityState);
}
-(void)getUserInfo:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    [returnDic setObject:appDelegate.user_id forKey:@"UserId"];
    [returnDic setObject:appDelegate.passWord forKey:@"UserPwd"]; //191001 modify
    [returnDic setObject:@"NONE" forKey:@"PhoneNum"];
    [returnDic setObject:language forKey:@"DeviceLanguage"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnDic
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSString *jsCommand = [NSString stringWithFormat:@"callbackUserInfo2('%@');",jsonString];
    //NSString *jsCommand = @"callbackUserInfo2('jhpark');";
    NSLog(@"jsCommand : %@",jsCommand);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void) setBackKeyEvent:(NSString *)callBackFunc :(NSString *)userSpecific :(NSString *)backKeyMode{
    if ([backKeyMode isEqualToString:@"0"]) {
        _backMode = NO;
    }else if([backKeyMode isEqualToString:@"1"]){
        _backMode = YES;
    }
    NSString *tmp = @"true";
    tmp = [tmp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *jsCommand = [NSString stringWithFormat:@"%@('%@', '%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],tmp];
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}
-(void)setFileNames:(NSString *)fileList{
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
    NSFileHandle *readFile;
    readFile = [NSFileHandle fileHandleForReadingAtPath:txtPath];
    if (readFile!=nil) {
        
    }else{
        
    }
}
- (BOOL)isRoaming
{
    static NSString *carrierPListSymLinkPath = @"/var/mobile/Library/Preferences/com.apple.carrier.plist";
    static NSString *operatorPListSymLinkPath = @"/var/mobile/Library/Preferences/com.apple.operator.plist";
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSString *carrierPListPath = [fm destinationOfSymbolicLinkAtPath:carrierPListSymLinkPath error:&error];
    NSLog(@"carrierPListPath : %@",carrierPListPath);
    NSString *operatorPListPath = [fm destinationOfSymbolicLinkAtPath:operatorPListSymLinkPath error:&error];
    NSLog(@"operatorPListPath : %@",operatorPListPath);
    return (![operatorPListPath isEqualToString:carrierPListPath]);
}
- (void)isRoaming:(NSString *)callBackFunc :(NSString *)userSpecific{
    NSString *yesStr = @"YES";
    NSString *noStr = @"NO";
    
    NSString *jsCommand;
    
    if ([self isRoaming]) {
        jsCommand= [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[yesStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else{
        jsCommand= [NSString stringWithFormat:@"%@('%@','%@');",callBackFunc,[userSpecific stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[noStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [mywebView stringByEvaluatingJavaScriptFromString:jsCommand];
}

#pragma mark
#pragma mark URLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
    NSLog(@"error url : %@",connection.currentRequest.URL);
    NSLog(@"error : %@",error);
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
    [alert show];
    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    if (statusCode ==200) {
        [receiveData setLength:0];
    }else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [connection cancel];
        NSString *urlStr = connection.currentRequest.URL.absoluteString;
        NSArray *methodArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
        NSString *methodName = [methodArr objectAtIndex:0];
        if([methodName isEqualToString:@"upload"]){
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:@"FAILED" forKey:@"RESULT"];
            [dic setObject:[NSString stringWithFormat:@"Status Code : %ld",(long)statusCode] forKey:@"ERR_MSG"];
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                                   _callbackFunc,
                                   _userSpecific,
                                   [[NSString stringWithFormat:@"%@",dic] urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                   ];
            
            [self evaluateJavaScript:jsCommand];
            
        }
    }
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *methodArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [methodArr objectAtIndex:0];
    if ([methodName isEqualToString:@"addMenuHist"]) {
        [histData appendData:data];
    }else{
        [receiveData appendData:data];
    }
    
    
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *methodArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [methodArr objectAtIndex:0];
    NSLog(@"methodName : %@",methodName);
    if([methodName isEqualToString:@"upload"]){
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString = encString;
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        if ([dic objectForKey:@"ERR_MSG"]!=nil) {
            NSLog(@"upload result : %@",decString);
            NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                                   _callbackFunc,
                                   _userSpecific,
                                   [decString urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                   ];
            
            [self evaluateJavaScript:jsCommand];
        }else{
            
            NSArray *paths = [appDelegate.main_url pathComponents];
            
            if (appDelegate.uploadURL == nil || [appDelegate.uploadURL isEqualToString:@""]) {
                appDelegate.uploadURL = [NSString stringWithFormat:@"%@//%@/samples/PhotoSave",[paths objectAtIndex:0],[paths objectAtIndex:1]];
            }
            
            
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
            NSString *txtPath = [documentFolder stringByAppendingPathComponent:@"WebPhotoFiles.txt"];
            NSMutableArray *readArray;
            NSMutableArray *uploadArray = [[NSMutableArray alloc]init];
            NSFileHandle *readFile;
            readFile = [NSFileHandle fileHandleForReadingAtPath:txtPath];
            if (readFile==nil) {
                NSLog(@"not found filePhotoFiles.");
            }else{
                NSData *data = [readFile readDataToEndOfFile];
                NSString *readStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                readArray = [NSMutableArray arrayWithArray:[readStr componentsSeparatedByString:@"\n"]];
                [readArray removeLastObject];
            }
            for(int i=0; i<readArray.count; i++){
                [uploadArray addObject:appDelegate.uploadURL];
            }
            NSLog(@"uploadArray : %@",uploadArray);
            NSLog(@"readArray : %@",readArray);
            
            if(readArray!=nil){
                self.isSync = YES;
                [self fileUploads:readArray :uploadArray :@"false"];
            }else{
                NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                                       _callbackFunc,
                                       _userSpecific,
                                       [decString urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                       ];
                
                [self evaluateJavaScript:jsCommand];
            }
            
            
        }
        
    }else if ([methodName isEqualToString:@"DataGate3"]) {
        
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        if ([dic objectForKey:@"ERROR"]!=nil) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"DataGate Error" message:[dic objectForKey:@"ERROR"] delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
            [alertView show];
            
        }
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                               [self.callBackDic objectForKey:@"callBackFunc"],
                               [self.callBackDic objectForKey:@"userSpecific"],
                               decString];
        
        [self evaluateJavaScript:jsCommand];
        
    }else if([methodName isEqualToString:@"sendPushService"]){
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                               [self.callBackDic objectForKey:@"callBackFunc"],
                               [self.callBackDic objectForKey:@"userSpecific"],
                               [dic objectForKey:@"V1"]];
        
        NSLog(@"jsCommand : %@",jsCommand);
        [self evaluateJavaScript:jsCommand];
    }else if([methodName isEqualToString:@"CheckSession"]){
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        /*
         if (appDelegate.isAES256) {
         encString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
         }
         else{
         encString = encString;
         }*/
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[encString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        
        NSString *jsCommand = [NSString stringWithFormat:@"%@('%@','%@');",
                               [self.callBackDic objectForKey:@"callBackFunc"],
                               [self.callBackDic objectForKey:@"userSpecific"],
                               [dic objectForKey:@"V0"]];
        
        NSLog(@"jsCommand : %@",jsCommand);
        [self evaluateJavaScript:jsCommand];
        
    }else if([methodName isEqualToString:@"addMenuHist"]) {
        NSDictionary *dic;
        NSError *error;
        @try {
            // if AES256
            NSString *encString =[[NSString alloc]initWithData:histData encoding:NSUTF8StringEncoding];
            NSString *decString ;
            if (appDelegate.isAES256) {
                decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
            }
            else{
                decString = encString;
            }
            NSLog(@"WebViewController encString : %@",encString);
            NSLog(@"WebViewController decString : %@",decString);
            dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            NSLog(@"WebViewController addMenuHist dic : %@",dic);
            // if nomal
            //dic = [NSJSONSerialization JSONObjectWithData:receiveData options:kNilOptions error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }
        [SVProgressHUD dismiss];
        if ([[dic objectForKey:@"V0"]isEqualToString:@"True"]) {
            [self menuHandler];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alertView show];
        }
    } else if([methodName isEqualToString:@"GetExecuteMenuInfo"]){
        NSString *encString =[[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        NSLog(@"WebViewController GetExecuteMenuInfo dic : %@",dic);
        if ([[dic objectForKey:@"V0"] isEqualToString:@"True"]) {
            NSString *menu_no = [dic objectForKey:@"V3"];
            
            NSString *target_url = [dic objectForKey:@"V6"];
            
            NSString *param_String = [dic objectForKey:@"V6_1"];
            
            NSData *param_data = [param_String dataUsingEncoding:NSUTF8StringEncoding];
            menuKind = @"P";
            
            appDelegate.menu_title = [dic objectForKey:@"V9"];
            
            menuType = [dic objectForKey:@"V10"];
            
            NSString *versionFromServer = [dic objectForKey:@"V12"];
            
            nativeAppURL = [dic objectForKey:@"V13"];
            
            _isDMS = [[dic objectForKey:@"V16"] isEqualToString:@"Y"];
            _isTabBar = [[dic objectForKey:@"V17"] isEqualToString:@"Y"];
            
            paramString = @"";
            appDelegate.menu_no = menu_no;
            nativeAppMenuNo = menu_no;
            currentAppVersion = versionFromServer;
            appDelegate.target_url = target_url;
            
            NSDictionary *paramDic = [NSJSONSerialization JSONObjectWithData:param_data options:kNilOptions error:&error];
            @try {
                for(int i=1; i<=[paramDic count]; i++){
                    NSDictionary *subParamDic = [paramDic objectForKey:[NSString stringWithFormat:@"%d",i]];
                    paramString = [paramString stringByAppendingFormat:@"%@",[[subParamDic objectForKey:@"PARAM_KEY"] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
                    paramString = [paramString stringByAppendingFormat:@"="];
                    paramString = [paramString stringByAppendingFormat:@"%@",[[subParamDic objectForKey:@"PARAM_VAL"] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
                    paramString = [paramString stringByAppendingFormat:@"&"];
                }
                if ([[paramString substringFromIndex:paramString.length-1] isEqualToString:@"&"]) {
                    paramString = [paramString substringToIndex:paramString.length-1];
                }
                
            }
            @catch (NSException *exception) {
                //NSLog(@"exception : %@",[exception name]);
            }
            if (IS_OS_8_OR_LATER) {
                if (_isDMS) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"", @"") message:NSLocalizedString(@"message163", @"iOS8 버전 이상은 지원하지 않습니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
                    [alertView show];
                }else{
                    [self addMenuHist:appDelegate.menu_no];
                }
            }else{
                [self addMenuHist:appDelegate.menu_no];
            }
        }else{
            
        }
        
        [SVProgressHUD dismiss];
        
    } else if([methodName isEqualToString:@"MLogout"]){
        appDelegate.isLogout = YES;
        appDelegate.tabBarController = [[UITabBarController alloc] init];
        
        IntroViewController *loginView = [[IntroViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginView];
        navi.navigationBar.tintColor= [UIColor grayColor];

        [navi setNavigationBarHidden:TRUE];
        [self.navigationController pushViewController:loginView animated:YES];

    } else{
        
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:receiveData], nil, nil, nil);
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"사진이 앨범에 저장되었습니다." delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [alertView show];
        
        
    }
    receiveData = nil;
}
#pragma mark
#pragma mark Device Spec
- (int) countCores
{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info( mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount ) ;
    
    return hostInfo.max_cpus ;
}
- (BOOL) gpsAvailable{
    return [CLLocationManager locationServicesEnabled];
}

- (BOOL) accelerometerAvailable{
    //CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    BOOL accelerometer = motionManager.accelerometerAvailable;
    return accelerometer;
}

- (BOOL) gyroscopeAvailable
{
#ifdef __IPHONE_4_0
    //CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    BOOL gyroAvailable = motionManager.gyroAvailable;
    return gyroAvailable;
#else
    return NO;
#endif
    
}

- (BOOL) compassAvailable
{
    BOOL compassAvailable = NO;
    
#ifdef __IPHONE_3_0
    compassAvailable = [CLLocationManager headingAvailable];
#else
    CLLocationManager *cl = [[CLLocationManager alloc] init];
    compassAvailable = cl.headingAvailable;
    [cl release];
#endif
    
    return compassAvailable;
    
}

- (BOOL) retinaDisplayCapable
{
    int scale = 1.0;
    UIScreen *screen = [UIScreen mainScreen];
    if([screen respondsToSelector:@selector(scale)])
        scale = screen.scale;
    
    if(scale == 2.0f) return YES;
    else return NO;
}
- (BOOL) frontCameraAvailable
{
#ifdef __IPHONE_4_0
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
#else
    return NO;
#endif
    
    
}
- (BOOL) linearCameraAvailable
{
#ifdef __IPHONE_4_0
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
#else
    return NO;
#endif
    
    
}

- (BOOL) cameraFlashAvailable
{
#ifdef __IPHONE_4_0
    return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
#else
    return NO;
#endif
}
#pragma mark - Init Method
- (void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"pushNotification" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ExecutePush" object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"HideImageViewer" object: nil];
}
- (void)checkDownload{
    if (_isDownload) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        UIViewController *vc = [[self.navigationController viewControllers]objectAtIndex:[arr count]-2];
        [arr removeObject:vc];
        self.navigationController.viewControllers = arr;
        _isDownload = NO;
    }
}
- (void)initUI{
    
    //Back Button
    flag = NO;
    if (![appDelegate.demo isEqualToString:@"DEMO"]) {
        int badge = [appDelegate.badgeCount intValue];
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
        if (badge>0 && ![appDelegate.noticeTabBarNumber isEqualToString:@""] &&appDelegate.noticeTabBarNumber!=nil) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badge]];
        }
    }
    
    //네비게이션 바 색상 변환
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }
    
    /*
    UIImage *buttonImageRight = [UIImage imageNamed:@"navi_webback.png"];
    
    UIButton *rightButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [rightButton setImage:buttonImageRight forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, buttonImageRight.size.width-12,buttonImageRight.size.height-12);
    
    [rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItemRight = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = customBarItemRight;
    */
    UIImage *buttonImageLeft = [UIImage imageNamed:@"navi_webback.png"];
    
    UIButton *leftButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [leftButton setImage:buttonImageLeft forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, buttonImageLeft.size.width-12,buttonImageLeft.size.height-12);
    
    [leftButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customBarItemLeft = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = customBarItemLeft;
    
    
    NSData *data = [appDelegate.menu_title dataUsingEncoding:NSUTF8StringEncoding];
    
    if ([appDelegate.menu_title length] > 9 && [data length] > 18) {
        UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
        if (appDelegate.isMainWebView) {
            if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
                _label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
                _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
            }
            _label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        }else{
            if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
                _label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
                _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
            }
            _label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        }
        _label.text = appDelegate.menu_title;
        _label.font = [UIFont boldSystemFontOfSize:18.0];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = NSTextAlignmentCenter;
        
        self.navigationItem.titleView = _label;
        
    }else {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
        if (appDelegate.isMainWebView) {
            if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
                label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
            }
            label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        }else{
            if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
                label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
                label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
            }
            label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        }
        label.text = appDelegate.menu_title;
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        
    }
    
    NSArray *controllers = [self.navigationController viewControllers];
    
    UIViewController *controller = [controllers objectAtIndex:0];
    NSString *tempString = [NSString stringWithFormat:@"%@", controller.class];
    if ([tempString isEqualToString:@"Notice_PushViewController"]) {
        appDelegate.preURL = appDelegate.target_url;
        appDelegate.preTitleName = self.navigationItem.title;
    } else if([tempString isEqualToString:@"ThirdViewController"]){
        appDelegate.preThirdTitle = self.navigationItem.title;
    } else if([tempString isEqualToString:@"FirstViewController"]){
        appDelegate.preMainTitle = self.navigationItem.title;
    }
}
- (void)setMfnpMethod:(WKUserContentController *)userController{
    
    [userController addScriptMessageHandler:self name:@"executeBackKeyEvent"];
    [userController addScriptMessageHandler:self name:@"executeBarcode"];
    [userController addScriptMessageHandler:self name:@"executeCamera"];
    [userController addScriptMessageHandler:self name:@"executeDatagate"];
    [userController addScriptMessageHandler:self name:@"executeExitWebBrowser"];
    [userController addScriptMessageHandler:self name:@"executeFileUpload"];
    [userController addScriptMessageHandler:self name:@"executeGallery"];
    [userController addScriptMessageHandler:self name:@"executeMenu"];
    [userController addScriptMessageHandler:self name:@"executeNonQuery"];
    [userController addScriptMessageHandler:self name:@"executeNotification"];
    [userController addScriptMessageHandler:self name:@"executeRecognizeSpeech"];
    [userController addScriptMessageHandler:self name:@"executeRetrieve"];
    [userController addScriptMessageHandler:self name:@"executeProgressDialogStart"];
    [userController addScriptMessageHandler:self name:@"executeProgressDialogStop"];
    [userController addScriptMessageHandler:self name:@"executePush"];
    [userController addScriptMessageHandler:self name:@"executeSignpad"];
    [userController addScriptMessageHandler:self name:@"executeSms"];
    
    
    [userController addScriptMessageHandler:self name:@"getAccelerometer"];
    [userController addScriptMessageHandler:self name:@"getCheckSession"];
    [userController addScriptMessageHandler:self name:@"getConvertImageToBase64"];
    [userController addScriptMessageHandler:self name:@"getDeviceInfo"];
    [userController addScriptMessageHandler:self name:@"getDeviceSpec"];
    [userController addScriptMessageHandler:self name:@"getFilePath"];
    [userController addScriptMessageHandler:self name:@"getGpsLocation"];
    [userController addScriptMessageHandler:self name:@"getGyroscope"];
    [userController addScriptMessageHandler:self name:@"getMagneticField"];
    [userController addScriptMessageHandler:self name:@"getNetworkStatus"];
    [userController addScriptMessageHandler:self name:@"getProximity"];
    [userController addScriptMessageHandler:self name:@"getUserInfo"];
    
    [userController addScriptMessageHandler:self name:@"setBackKeyEvent"];
    [userController addScriptMessageHandler:self name:@"setFileNames"];
    
    [userController addScriptMessageHandler:self name:@"isRoaming"];
    [userController addScriptMessageHandler:self name:@"isWKWebView"];
    
}
- (void) closeActiveWebView
{
    // Grab and remove the top web view, remove its reference from the windows array,
    // and nil itself and its delegate. Then we re-set the activeWindow to the
    // now-top web view and refresh the toolbar.
    UIWebView *webView = [self.webViews lastObject];
    [webView removeFromSuperview];
    [self.webViews removeLastObject];
    webView.delegate = nil;
    webView = nil;
   
    mywebView = [self.webViews lastObject];
    
}
- (UIWebView *) newWebView
{
    // Create a web view that fills the entire window, minus the toolbar height
    IMTWebView *webView = [[IMTWebView alloc] initWithFrame:CGRectMake(0, 0, (float)self.view.bounds.size.width, (float)self.view.bounds.size.height - 44)];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Add to windows array and make active window
    [self.webViews addObject:webView];
    mywebView = webView;
    //[webView stringByEvaluatingJavaScriptFromString:@"window.open = function (open) { return function  (url, name, features) { window.location.href = url; return window; }; } (window.open);"];
    [webView stringByEvaluatingJavaScriptFromString:@"window.open = function (open) { return function  (url, name, features) { window.location.href = url; return window; }; } (window.open);"];
    NSString *close = @"window.close=function(){ open('mfinity://windowClose'); };";
    [webView stringByEvaluatingJavaScriptFromString:close];
    return webView;
}
- (void)initUIWebView{
    NSString *page_url = [NSString stringWithFormat:@"%@", appDelegate.target_url];
    mywebView.scalesPageToFit = YES;
    mywebView.mediaPlaybackRequiresUserAction = NO;
    mywebView.allowsInlineMediaPlayback = YES;
    mywebView.scrollView.bounces = NO;
    //user-agent
    //NSString *secretAgent = [mywebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    if ([[page_url substringToIndex:7] isEqualToString:@"http://"]||[[page_url substringToIndex:8] isEqualToString:@"https://"]) {
        
        if (appDelegate.isOffLine) {
            //[[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message109", @"")];
        }else{
            NSLog(@"appDelegate.target_method : %@",appDelegate.target_method);
            NSLog(@"appDelegate.target_param : %@",appDelegate.target_param);
            NSLog(@"appDelegate.target_url : %@",appDelegate.target_url);
            
            if(appDelegate.target_method==nil) appDelegate.target_method = @"POST";
           
            NSURL *nsurl=[NSURL URLWithString:page_url];
            NSMutableURLRequest *nsrequest = [NSMutableURLRequest requestWithURL:nsurl];
            [nsrequest setHTTPMethod:appDelegate.target_method];
            [nsrequest setHTTPBody:[appDelegate.target_param dataUsingEncoding:NSUTF8StringEncoding]];
            
            [mywebView loadRequest:nsrequest];
        }
        
    }else{
        NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSFileManager *filemgr;
        NSArray *filelist;
        int countT;
        int i;
        
        filemgr =[NSFileManager defaultManager];
        filelist = [filemgr contentsOfDirectoryAtPath:save error:NULL];
        countT = [filelist count];
        
        for(i = 0; i < countT; i++)
        {
            NSLog(@"item : %@", [filelist objectAtIndex: i]);
        }
        
        NSData *htmlData = [NSData dataWithContentsOfFile:appDelegate.target_url];
        
        if (htmlData == nil) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message91", @"") message:NSLocalizedString(@"message92", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alert show];
            
        }else{
            NSString *str = appDelegate.target_url;
            
            NSArray *arr = [NSArray arrayWithArray:[str pathComponents]];
            NSMutableString *tempString = [[NSMutableString alloc]initWithString:@""];
            for (int i=0; i<[arr count]-2; i++) {
                [tempString appendFormat:@"/"];
                [tempString appendFormat:@"%@",[arr objectAtIndex:i+1]];
            }
            [tempString appendFormat:@"/"];
            str = [str stringByAppendingFormat:@"?%@",appDelegate.paramString];
            str = [str stringByAppendingFormat:@"&devOs=I"];
            //str = [str stringByAppendingFormat:@"&uid=%@",appDelegate.user_id];
            [mywebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
            //[mywebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:tempString]];
        }
    }
    [self.webViews addObject:mywebView];
}
- (void)initWKWebView{
    NSString *page_url = [NSString stringWithFormat:@"%@", appDelegate.target_url];
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userController = [[WKUserContentController alloc]init];
    [self setMfnpMethod:userController];
    webViewConfig.userContentController = userController;
    
    if (_isTabBar) {
        NSLog(@"is TabBar");
        CGRect rect = CGRectMake(mywebView.frame.origin.x
                                 , mywebView.frame.origin.y
                                 , mywebView.frame.size.width
                                 , mywebView.frame.size.height-TAB_BAR_HEIGHT);
        _webView = [[WKWebView alloc] initWithFrame:rect configuration:webViewConfig];
    }else{
        NSLog(@"is not TabBar");
        CGRect rect = CGRectMake(mywebView.frame.origin.x
                                 , mywebView.frame.origin.y
                                 , mywebView.frame.size.width
                                 , mywebView.frame.size.height);
        _webView = [[WKWebView alloc] initWithFrame:rect configuration:webViewConfig];
    }
    
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.bounces = NO;
    
    if ([[page_url substringToIndex:7] isEqualToString:@"http://"]||[[page_url substringToIndex:8] isEqualToString:@"https://"]
        ||[page_url hasPrefix:@"hdwebview://"]) {
        if (appDelegate.isOffLine) {
            [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"message109", @"")];
        }else{
            NSLog(@"appDelegate.target_method : %@",appDelegate.target_method);
            NSLog(@"appDelegate.target_param : %@",appDelegate.target_param);
            NSURL *nsurl=[NSURL URLWithString:page_url];
            NSMutableURLRequest *nsrequest = [NSMutableURLRequest requestWithURL:nsurl];
            [nsrequest setHTTPMethod:appDelegate.target_method];
            [nsrequest setHTTPBody:[appDelegate.target_param dataUsingEncoding:NSUTF8StringEncoding]];
            //NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
            [_webView loadRequest:nsrequest];
        }
        
    }else{
        NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSData *htmlData = [NSData dataWithContentsOfFile:appDelegate.target_url];
        
        if (htmlData == nil) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message91", @"") message:NSLocalizedString(@"message92", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
            [alert show];
            
        }else{
            NSString *htmlFilePath = appDelegate.target_url;
            htmlFilePath = [htmlFilePath stringByAppendingFormat:@"?%@",appDelegate.paramString];
            htmlFilePath = [htmlFilePath stringByAppendingFormat:@"&devOs=I"];
            htmlFilePath = [NSString stringWithFormat:@"file://%@",htmlFilePath];
            
            NSURL *fileURL=[NSURL URLWithString:htmlFilePath];
            [_webView loadFileURL:fileURL allowingReadAccessToURL:[NSURL fileURLWithPath:documentsDir]];
        }
    }
    
    [self.webViews addObject:_webView];
    [self.view addSubview:_webView];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}


#pragma mark
#pragma mark SMS
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSString *resultString;
    switch (result) {
        case MessageComposeResultCancelled:
            resultString = NSLocalizedString(@"cancel", @"");
            break;
            
        case MessageComposeResultFailed:
        {
            resultString = NSLocalizedString(@"fail", @"");
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            resultString = NSLocalizedString(@"success", @"");
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Send SMS %@",resultString] message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }];
    
}
#pragma mark
#pragma mark WebView Download
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pt = [gestureRecognizer locationInView:mywebView];
        
        // convert point from view to HTML coordinate system
        // 뷰의 포인트 위치를 HTML 좌표계로 변경한다.
        CGSize viewSize = [mywebView frame].size;
        CGSize windowSize = [mywebView windowSize];
        CGFloat f = windowSize.width / viewSize.width;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
            pt.x = pt.x * f;
            pt.y = pt.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [mywebView scrollOffset];
            pt.x = pt.x * f + offset.x;
            pt.y = pt.y * f + offset.y;
        }
        
        [self openContextualMenuAt:pt];
    }
}
- (void)openContextualMenuAt:(CGPoint)pt{
    // Load the JavaScript code from the Resources and inject it into the web page
    NSBundle *bundle = [NSBundle mainBundle];
    //NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Anymate" ofType:@"bundle"]];
    
    NSString *path = [bundle pathForResource:@"JSTools" ofType:@"js"];
    //NSLog(@"js path : %@",path);
    
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"pt : %f, %f",pt.x,pt.y);
    //NSLog(@"jsCode : %@",jsCode);
    [mywebView stringByEvaluatingJavaScriptFromString:jsCode];
    
    // get the Tags at the touch location
    NSString *tags = [mywebView stringByEvaluatingJavaScriptFromString:
                      [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
    
    NSString *tagsHREF = [mywebView stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"MyAppGetLinkHREFAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
    
    NSString *tagsSRC = [mywebView stringByEvaluatingJavaScriptFromString:
                         [NSString stringWithFormat:@"MyAppGetLinkSRCAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
    
    //NSLog(@"tags : %@",tags);
    //NSLog(@"href : %@",tagsHREF);
    //NSLog(@"src : %@",tagsSRC);
    
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
            //_actionActionSheet.title = tagsSRC;
        }
        
        [_actionActionSheet addButtonWithTitle:@"Save Image"];
        //[_actionActionSheet addButtonWithTitle:@"Copy Image"];
    }
    // If a link is pressed add image buttons.
    if ([tags rangeOfString:@",A,"].location != NSNotFound){
        selectedLinkURL = tagsHREF;
        
        //_actionActionSheet.title = tagsHREF;
        [_actionActionSheet addButtonWithTitle:@"Open Link"];
        //[_actionActionSheet addButtonWithTitle:@"Copy Link"];
    }
    
    if (_actionActionSheet.numberOfButtons > 0) {
        [_actionActionSheet addButtonWithTitle:@"Cancel"];
        _actionActionSheet.cancelButtonIndex = (_actionActionSheet.numberOfButtons-1);
        
        
        [_actionActionSheet showInView:mywebView];
    }
    
}
#pragma mark
@end
@implementation UIWebView (WebUI)
/*
 -(void) webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame{
	UIAlertView *customAlert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
	[customAlert show];
 
 }
 */
@end
