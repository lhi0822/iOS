//
//  WebViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 15..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "WebViewController.h"
#import "PostDetailViewController.h"
#import "AppDelegate.h"


@interface WebViewController (){
    AppDelegate *appDelegate;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
    
    [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:[self.fileUrl lastPathComponent]];

    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(rightSideMenuButtonPressed:)];
    
    [self fileExtensionCheck];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VideoEnterFullScreen:) name:UIWindowDidBecomeVisibleNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VideoExitFullScreen:) name:UIWindowDidBecomeHiddenNotification object:self.view.window];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)fileExtensionCheck{
    NSString *ext = [self.fileUrl pathExtension];
    NSLog(@"ext : %@", ext);
    
    if([ext isEqualToString:@"jpg"]||[ext isEqualToString:@"jpeg"]||[ext isEqualToString:@"gif"]||[ext isEqualToString:@"png"]||[ext isEqualToString:@"tiff"]||[ext isEqualToString:@"bmp"]||[ext isEqualToString:@"heic"]||[ext isEqualToString:@"docx"]||[ext isEqualToString:@"doc"]||[ext isEqualToString:@"pptx"]||[ext isEqualToString:@"ppt"]||[ext isEqualToString:@"xls"]||[ext isEqualToString:@"xlsx"]||[ext isEqualToString:@"pdf"]||[ext isEqualToString:@"txt"]||[ext isEqualToString:@"html"]){
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.fileUrl]];
        [self.webView loadRequest:request];
        
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSLog(@"fileUrl : %@", self.fileUrl);
        
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:appName message:NSLocalizedString(@"file_not_support", @"file_not_support") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleCancel
        handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];

            NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *filePath = [documentPath stringByAppendingFormat:@"/%@", appName];
            filePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@", [self.fileUrl lastPathComponent]]];
            
            NSURL *url = [NSURL fileURLWithPath:filePath];
            UIDocumentInteractionController *doic = [UIDocumentInteractionController interactionControllerWithURL:url];
            doic.delegate = self;

            // Action Sheet 호출
            if([doic presentOptionsMenuFromRect:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) inView:self.view animated:YES]){
                [SVProgressHUD showWithStatus:NSLocalizedString(@"file_changing", @"file_changing")];
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.fileUrl]];
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
                    [SVProgressHUD dismiss];
                }];
                [task resume];
            } else {
                NSLog(@"There is no app for this file");
            }
            
        }];
        
        [alert addAction:cancelButton];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
       
    }
}

-(void)VideoEnterFullScreen:(NSNotification *)myNotification{
    
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(void)VideoExitFullScreen:(NSNotification *)myNotification{
    //[self prefersStatusBarHidden];
    //[self setNeedsStatusBarAppearanceUpdate];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    //id rootViewController = appDelegate.window.rootViewController;
    //appDelegate.window.rootViewController = nil;
    //appDelegate.window.rootViewController = rootViewController;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.webView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)noti_NewPostPush:(NSNotification *)notification {
    if(notification.userInfo!=nil){
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
        
        NSString *message = [notification.userInfo objectForKey:@"MESSAGE"];
        NSDictionary *dict = [NSDictionary dictionary];
        if(message!=nil){
            NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        } else {
            dict = notification.userInfo;
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PostDetailViewController *vc = (PostDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        
        vc.fromSegue = @"NOTI_POST_DETAIL";
        vc.notiPostDic = dict;
        [self presentViewController:nav animated:YES completion:nil];
    }
    appDelegate.inactivePostPushInfo=nil;
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

