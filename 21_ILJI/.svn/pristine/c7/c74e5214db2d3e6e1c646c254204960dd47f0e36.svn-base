//
//  VideoViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 27..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "VideoViewController.h"
#import "MFinityAppDelegate.h"
@interface VideoViewController ()

@end

@implementation VideoViewController
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    _isWebApp = NO;
    // Do any additional setup after loading the view from its nib.
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    _label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    _label.text = NSLocalizedString(@"message79", @"");
    _label.font = [UIFont boldSystemFontOfSize:20.0];
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        _label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    }
    self.navigationItem.titleView = _label;
    
    //[self.navigationItem setTitle:NSLocalizedString(@"message79", @"")];
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
	imageView.image = bgImage;
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:_thumNailPath]];
	thumImageView.image = image;
    if (!appDelegate.isOffLine) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClick)];
    }
    CGRect screen = [[UIScreen mainScreen]bounds];
	CGFloat screenHeight = screen.size.height;
    //NSLog(@"screenheight : %f",screenHeight);
    //NSLog(@"view size : %f",self.view.frame.size.height);
    float btnY = (screenHeight/2)-44;
    btnPlay.center = CGPointMake(btnPlay.center.x, btnY);
    //NSLog(@"button y : %f",btnPlay.center.y);
}
-(IBAction)PlayMovie
{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
	
    NSArray *components = [_videoPath pathComponents];
    saveDecryptFilePath = @"/";
    for (int i=1; i<[components count]-1; i++) {
        saveDecryptFilePath = [saveDecryptFilePath stringByAppendingString:[components objectAtIndex:i]];
        saveDecryptFilePath = [saveDecryptFilePath stringByAppendingString:@"/"];
    }
    
    NSString *decrypt = [_videoPath lastPathComponent];
    NSString *decryptFile = [[decrypt componentsSeparatedByString:@"."]objectAtIndex:0];
    decryptFile = [decryptFile stringByAppendingString:@"_tmp"];
    NSString *fileType = [[decrypt componentsSeparatedByString:@"."]objectAtIndex:1];
    decryptFile = [decryptFile stringByAppendingFormat:@".%@",fileType];
    saveDecryptFilePath = [saveDecryptFilePath stringByAppendingString:decryptFile];
    
    NSData * decryptData = [NSData dataWithContentsOfFile:_videoPath];
    [decryptData writeToFile:saveDecryptFilePath atomically:YES];
    
    NSURL *movieURL = [NSURL fileURLWithPath:saveDecryptFilePath];
    MPMoviePlayerViewController *playView = [[MPMoviePlayerViewController alloc]initWithContentURL:movieURL];
    MPMoviePlayerController *moviePlayer = [playView moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:playView];
    
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
    //HTTP POST 파일전송 =======================
	NSString *filename = [_videoPath lastPathComponent];
    
    NSData *movieData = [[NSData alloc]initWithContentsOfFile:_videoPath];
	////NSLog(@"_videoPath : %@",_videoPath);
    ////NSLog(@"movieData : %@",movieData);
    //IDC .net upload------------------------------------
    //NSString *temp_urlString = [NSString stringWithFormat:@"http://211.220.195.51:8084/mSales/UploadFromAndroid.ashx?comp_no=%@&fileName=%@",appDelegate.comp_no, filename];
    
    //jsp upload-----------------------------------------
    //NSString *temp_urlString = @"http://192.168.0.130:8080/FileUpload/upload.jsp";
    NSString *urlString = [appDelegate.uploadURL stringByAppendingString:@"returnTy=file&target=webkit"];
    
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	NSURL *url = [NSURL URLWithString:urlString];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filename\"; filename=\"%@\"\r\n",filename] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:movieData];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody:body];
	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
    progressAlertView = [[UIAlertView alloc]initWithTitle:@"Uploading..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(30, 80, 225, 90)];
    [progressView setProgressViewStyle:UIProgressViewStyleBar];
    
	myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    myIndicator.center = CGPointMake(140, 60);
    myIndicator.hidesWhenStopped = NO;
    [progressAlertView addSubview:progressView];
    [progressAlertView addSubview:myIndicator];
    [myIndicator startAnimating];
    [progressAlertView show];
    //[NSThread detachNewThreadSelector:@selector(startBackgroundThread) toTarget:self withObject:nil];
	
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
    NSData *login_data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:login_data options:kNilOptions error:&error];
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
    //NSLog(@"error : %@",[error domain]);
    [progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message82", @"")
                                                    message:NSLocalizedString(@"message83", @"")
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"")
                                          otherButtonTitles:nil];
    
    [alert show];
    
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
                //                WebPageView *webView = [[WebPageView alloc]init];
                //                [self.navigationController pushViewController:webView animated:YES];
                //                [webView release];
                MPMoviePlayerViewController *playView = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:appDelegate.target_url]];
                MPMoviePlayerController *moviePlayer = [playView moviePlayer];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
                [self presentMoviePlayerViewControllerAnimated:playView];
                
            }
            
        }
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
}

- (void) playbackDidFinish:(NSNotification *)noti {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    [manager removeItemAtPath:saveDecryptFilePath error:&error];
    MPMoviePlayerController *player = [noti object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self dismissMoviePlayerViewControllerAnimated];
	
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
