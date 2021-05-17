//
//  PhotoViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 27..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "PhotoViewController.h"
#import "WebViewController.h"
#import "MFinityAppDelegate.h"
#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define RSTRING(X) NSStringFromCGRect(X)

#define BASEHEIGHT	300.0f
#define NPAGES		3
@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize isWebApp = _isWebApp;
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
    _isWebApp = NO;
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    _label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    _label.text = NSLocalizedString(@"message78", @"");
    _label.font = [UIFont boldSystemFontOfSize:20.0];
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        _label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    }
    self.navigationItem.titleView = _label;
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBackAdd:)];
    self.navigationItem.backBarButtonItem = left;
    
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320.0f, BASEHEIGHT)];
	sv.contentSize = CGSizeMake(NPAGES * 320.0f, sv.frame.size.height);
	sv.pagingEnabled = YES;
	sv.delegate = self;
    
    if (!appDelegate.isOffLine) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBtnClick)];
    }
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:_imagePath]];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    //imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.frame = _scrollView.frame;
    [_scrollView setScrollEnabled:YES];
    [_scrollView setContentSize:[image size]];
    [_scrollView addSubview:imageView];
    _imageView = imageView;
    [_scrollView setMaximumZoomScale:1.0f];
    [_scrollView setMinimumZoomScale:0.4f];
    
    
    //NSString *str = @"width=\"100%\" height=\"100%\"cellpadding=0 cellspacing=0 boarder=1 >";
    ////NSLog(@"str : %@",str);
	//UIImage *image = [UIImage imageWithContentsOfFile:appDelegate.imagePath];
    //NSString * html = [NSString stringWithFormat:@"<img src=\"file://%@\"%@" ,_imagePath,str];
    //[webView loadHTMLString:html baseURL:nil];
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}
-(void)rightBtnClick {
	MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	//======= LOAD ========
	/*
	 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	 NSString *documentsDirectory = [paths objectAtIndex:0];
	 NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:name];
	 NSString *pngFilePath = [NSString stringWithFormat:@"%@/ezSmart/test.jpg",documentsDirectory];
	 UIImage *res = [UIImage imageWithContentsOfFile:pngFilePath];
	 */
	//=====================
    
    //=======================
    //EzSmartAppDelegate *appDelegate = (EzSmartAppDelegate *)[[UIApplication sharedApplication] delegate];
    //HTTP POST 파일전송 =======================
    //NSLog(@"전송 시작 ~ !");
	NSString *filename = [_imagePath lastPathComponent];
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:_imagePath]];
	//UIImage *sendImage = [UIImage imageWithContentsOfFile: _imagePath];
	NSData *imageData = UIImageJPEGRepresentation(image,90);
	
	//NSString *temp_urlString = [NSString stringWithFormat:@"svr001.ezsmart.co.kr:8084/icon/Upload.ashx?fileName=%@", filename];
	//IDC .net Upload---------------------------
    //NSString *temp_urlString = [NSString stringWithFormat:@"http://211.220.195.51:8084/mSales/UploadFromAndroid.ashx?comp_no=%@&fileName=%@",appDelegate.comp_no, filename];
    //jsp Upload--------------------------------
    //NSString *temp_urlString = @"http://192.168.0.130:8080/FileUpload/savePhoto";
	//NSString *temp_urlString = [NSString stringWithFormat:@"http://203.241.249.45:801/UploadFromAndroid.ashx?fileName=%@", filename];
	//NSString *temp_urlString = [NSString stringWithFormat:@"http://203.241.249.51/WebSite/UploadFromAndroid.ashx?filename=%@",filename];
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    NSArray *paths = [appDelegate.main_url pathComponents];
    
	if (appDelegate.uploadURL == nil) {
        appDelegate.uploadURL = [NSString stringWithFormat:@"%@//%@/samples/PhotoSave",[paths objectAtIndex:0],[paths objectAtIndex:1]];
        //appDelegate.uploadURL = @"http://svr001.ezsmart.co.kr:1598/samples/PhotoSave";
    }else if([appDelegate.uploadURL isEqualToString:@""]){
        appDelegate.uploadURL = [NSString stringWithFormat:@"%@//%@/samples/PhotoSave",[paths objectAtIndex:0],[paths objectAtIndex:1]];
        //appDelegate.uploadURL = @"http://svr001.ezsmart.co.kr:1598/samples/PhotoSave";
    }
    NSLog(@"upload url : %@",appDelegate.uploadURL);
	NSURL *url = [NSURL URLWithString:appDelegate.uploadURL];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n",filename] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
    
	//NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    //NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	//NSLog(@"request2 : %@",request);
	//============================================
	
	////NSLog(@"응답 : %@",returnString);
    //================================================
    progressAlertView = [[UIAlertView alloc]initWithTitle:@"Uploading..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(30, 80, 225, 90)];
    [progressView setProgressViewStyle:UIProgressViewStyleBar];
    
	myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    myIndicator.center = CGPointMake(140, 55);
    myIndicator.hidesWhenStopped = NO;
    [progressAlertView addSubview:progressView];
    [progressAlertView addSubview:myIndicator];
    [myIndicator startAnimating];
    [progressAlertView show];
    //[NSThread detachNewThreadSelector:@selector(startBackgroundThread) toTarget:self withObject:nil];
	
	
}
- (void)startBackgroundThread{
    //HTTP POST 파일전송 =======================
    @autoreleasepool {
        //NSLog(@"전송 시작 ~ !");
        MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
        NSString *filename = [_imagePath lastPathComponent];
        
        UIImage *sendImage = [UIImage imageWithContentsOfFile: _imagePath];
        NSData *imageData = UIImageJPEGRepresentation(sendImage,90);
        
        //NSString *temp_urlString = [NSString stringWithFormat:@"svr001.ezsmart.co.kr:8084/icon/Upload.ashx?fileName=%@", filename];
        NSString *temp_urlString = [NSString stringWithFormat:@"http://211.220.195.51:8084/mSales/UploadFromAndroid.ashx?comp_no=%@&fileName=%@",appDelegate.comp_no, filename];
        //NSString *temp_urlString = [NSString stringWithFormat:@"http://203.241.249.45:801/UploadFromAndroid.ashx?fileName=%@", filename];
        //NSString *temp_urlString = [NSString stringWithFormat:@"http://203.241.249.51/WebSite/UploadFromAndroid.ashx?filename=%@",filename];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        
        NSURL *url = [NSURL URLWithString:temp_urlString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n",filename] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        
        //NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];
        
        //NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        ////NSLog(@"%@",request);
        //============================================
        
        ////NSLog(@"응답 : %@",returnString);
        [self performSelectorOnMainThread:@selector(upLoadFinish) withObject:nil waitUntilDone:NO];
    }
}
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    ////NSLog(@"uploading %d    %d    %d",bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    float num = totalBytesWritten;
    float total = totalBytesExpectedToWrite;
    float percent = num/total;
    progressView.progress = percent;
}
//파일 업로드 완료 되었을 때
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",returnString);  // 리턴값이 있다면 확인해 볼 수 있다.
    NSError *error=nil;
    NSData *returnData = [returnString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&error];
    if (error==nil) {
        NSString *temp = [dic objectForKey:@"URL"];
        mode = [dic objectForKey:@"MODE"];
        //NSLog(@"didReceiveData == %@", temp);
        MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.target_url = temp;
        if (!_isWebApp) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message80", @"") message:NSLocalizedString(@"message81", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""),nil];
            [alert show];
        }
        
    }else{
        NSLog(@"error : %@",error);
    }
    
}


//끝나면 프로그레스바가 있는 Alert을 닫아준다.
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //NSLog(@"upload end");
    [progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

//파일 업로드 중 실패하였을 경우
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    //NSLog(@"upload fail");
    //NSLog(@"error : %@",error);
    [progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message82", @"")
                                                    message:NSLocalizedString(@"message83", @"")
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"")
                                          otherButtonTitles:nil];
    
    [alert show];
    
}

- (void)upLoadFinish {
    //    [myIndicator stopAnimating];
    //	myIndicator.hidesWhenStopped =YES;
    //    [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    //    [self.alertView release];
    //
    //    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"업로드 성공" message:@"확인해보시겠습니까?" delegate:self cancelButtonTitle:@"확인" otherButtonTitles:@"취소",nil];
    //	[alert show];
    //	[alert release];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        if ([alertView.title isEqualToString:NSLocalizedString(@"message80", @"")]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            MFinityAppDelegate *appDelegate =  (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
            //appDelegate._target_url = [NSString stringWithFormat:@"http://211.220.195.51:8084/mSales/camera.aspx?cuser_no=%@&menu_no=%@&file=%@",appDelegate._user_no,appDelegate._menu_no,[appDelegate.imagePath lastPathComponent]];
            if ([mode isEqualToString:@"browser"]) {
                NSURL *browser = [NSURL URLWithString:appDelegate.target_url];
                [[UIApplication sharedApplication] openURL:browser];
            }else if([mode isEqualToString:@"webkit"]){
                appDelegate.menu_title = NSLocalizedString(@"message78", @"");
                WebViewController *webViewController = [[WebViewController alloc]init];
                [self.navigationController pushViewController:webViewController animated:YES];
                
            }
            
        }
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
