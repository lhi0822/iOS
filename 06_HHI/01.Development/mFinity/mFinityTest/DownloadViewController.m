//
//  DownloadViewController.m
//  mFinity
//
//  Created by Park on 2014. 6. 18..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import "DownloadViewController.h"
#import "MFinityAppDelegate.h"
#import "YLProgressBar.h"
#import "ZipArchive.h"
#import "WebViewController.h"
//#import "WKWebViewController.h"

@interface DownloadViewController (){
    int count;
}

// Manage progress bars
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end

@implementation DownloadViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    [self initWebAppProgressBar];
    [self initCommonProgressBar];
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBackAdd:)];
    
    self.navigationItem.backBarButtonItem = left;
    
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.bgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    _imageView.image = bgImage;
    _webAppLabel.font = [UIFont systemFontOfSize:24];
    _webAppLabel.textColor = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
    _webAppLabel.text = appDelegate.menu_title;
}
- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = @"Download";
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
    }
    self.navigationItem.titleView = label;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *compFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    NSString *commonFolder = [compFolder stringByAppendingPathComponent:@"webapp"];
    commonFolder = [commonFolder stringByAppendingPathComponent:@"common"];

    if ([prefs objectForKey:@"COMMON_DOWNLOAD"]!=nil) {
        BOOL isCommon = [fileManager isReadableFileAtPath:commonFolder];
        if (!isCommon){
            _commonLabel.hidden = NO;
            _commonProgressBar.hidden = NO;
            isCommonDownload = YES;
            progressName = @"commonProgressBar";
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[prefs objectForKey:@"COMMON_DOWNLOAD"]]];
            [urlRequest setHTTPMethod:@"POST"];
            NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (urlCon) {
                fileData =[[NSMutableData alloc] init];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
            
            
        }else{
            isCommonDownload = NO;
            progressName = @"webAppProgressBar";
            [self setProgress:0.0f animated:YES];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_downloadURL]];
            [urlRequest setHTTPMethod:@"POST"];
            NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (urlCon) {
                fileData =[[NSMutableData alloc] init];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
        }
        
    }else{
        BOOL isCommon = [fileManager isReadableFileAtPath:commonFolder];
        if (!isCommon){
            _commonLabel.hidden = NO;
            _commonProgressBar.hidden = NO;
            isCommonDownload = YES;
            progressName = @"commonProgressBar";
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[prefs objectForKey:@"COMMON_DOWNLOAD"]]];
            [urlRequest setHTTPMethod:@"POST"];
            NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (urlCon) {
                fileData =[[NSMutableData alloc] init];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
            
            
        }
        
        
    }

    
}
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
    [alertView show];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    
    if(statusCode == 404 || statusCode == 500){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [connection cancel];

        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
        [alertView show];
        
        
    }else{
        NSString *urlStr = connection.currentRequest.URL.absoluteString;
        NSArray *tempArr = [urlStr componentsSeparatedByString:@"."];
        if ([[tempArr lastObject]isEqualToString:@"zip"]) {
            [fileData setLength:0];
            totalFileSize = [NSNumber numberWithLongLong:[response expectedContentLength]];
            
        }else{
            
        }
        
        
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [urlStr componentsSeparatedByString:@"."];
    if ([[tempArr lastObject]isEqualToString:@"zip"]) {
        [fileData appendData:data];
        NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[fileData length]];
        NSNumber *progress = [NSNumber numberWithFloat:([resourceLength floatValue] / [totalFileSize floatValue] )];
        if (isCommonDownload) {
            progressName = @"commonProgressBar";
        }else{
            progressName = @"webAppProgressBar";
        }
        [self setProgress:[progress floatValue] animated:YES];

        
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (isCommonDownload) {
        NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        save = [save stringByAppendingFormat:@"/%@/webapp/common",appDelegate.comp_no];
        save = [save stringByAppendingString:@".zip"];
        [fileData writeToFile:save atomically:YES];
        ZipArchive *zip = [[ZipArchive alloc]init];
        NSError *error;
        NSString *unZipFolder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingFormat:@"/%@/webapp/common",appDelegate.comp_no];
        if ([zip UnzipOpenFile:save]) {
            [zip UnzipFileTo:unZipFolder overWrite:YES];
        }
        [zip UnzipCloseFile];
        NSFileManager *manager =[NSFileManager defaultManager];
        [manager removeItemAtPath:save error:&error];
        
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[prefs objectForKey:@"RES_VER"],@"RES_VER",nil];
        
        [dic writeToFile:filePath atomically:YES];
        
        isCommonDownload = NO;
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_downloadURL]];
        [urlRequest setHTTPMethod:@"POST"];
        NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        if (urlCon) {
            fileData =[[NSMutableData alloc]init];
            //[self createProgressionAlertWithMessage:[col6 objectAtIndex:_indexBtn]];
        }
    }else{
        NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        save = [save stringByAppendingFormat:@"/%@/webapp/%@",appDelegate.comp_no,_nativeAppMenuNo];
        save = [save stringByAppendingString:@".zip"];
        [fileData writeToFile:save atomically:YES];
        ZipArchive *zip = [[ZipArchive alloc]init];
        NSError *error;
        NSString *unZipFolder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingFormat:@"/%@/webapp/%@",appDelegate.comp_no,[[save lastPathComponent] stringByDeletingPathExtension]];
        if ([zip UnzipOpenFile:save]) {
            [zip UnzipFileTo:unZipFolder overWrite:YES];
        }
        [zip UnzipCloseFile];
        NSFileManager *manager =[NSFileManager defaultManager];
        [manager removeItemAtPath:save error:&error];
        
        NSPropertyListFormat format;
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
        NSMutableDictionary *dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
        [dic setObject:_currentAppVersion forKey:_nativeAppMenuNo];
        [dic writeToFile:filePath atomically:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        count = 0;
        [self startTimer];
    }
    
}
-(NSString *) startTimer{
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(handleTimer:)
                                   userInfo:nil
                                    repeats:YES];
    return @"YES";
}
-(void) handleTimer:(NSTimer *)timer {
    count++;
    
    if (count==1) {
        WebViewController *vc = [[WebViewController alloc] init];
//        WKWebViewController *vc = [[WKWebViewController alloc] init];
        vc.isDownload = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}
#pragma mark
#pragma mark Progress Delegate
-(void)setProgress:(CGFloat)progress animated:(BOOL)animated{
    if ([progressName isEqualToString:@"webAppProgressBar"]) {
        [_webAppProgressBar setProgress:progress animated:animated];
    }else{
        [_commonProgressBar setProgress:progress animated:animated];
    }
    
}

#pragma mark
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)initWebAppProgressBar
{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    _webAppProgressBar.progressTintColor  = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
    _webAppProgressBar.stripesOrientation       = YLProgressBarStripesOrientationLeft;
    _webAppProgressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    _webAppProgressBar.indicatorTextLabel.font  = [UIFont fontWithName:@"Arial-BoldMT" size:20];
}
- (void)initCommonProgressBar
{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    _commonProgressBar.progressTintColor  = [appDelegate myRGBfromHex:appDelegate.mainFontColor];
    _commonProgressBar.stripesOrientation       = YLProgressBarStripesOrientationLeft;
    _commonProgressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    _commonProgressBar.indicatorTextLabel.font  = [UIFont fontWithName:@"Arial-BoldMT" size:20];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
