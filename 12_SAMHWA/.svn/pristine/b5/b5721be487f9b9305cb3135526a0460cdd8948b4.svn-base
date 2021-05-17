//
//  CameraMenuViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 21..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "CameraMenuViewController.h"
#import "WebViewController.h"
#import "LockInsertView.h"
@interface CameraMenuViewController ()

@end

@implementation CameraMenuViewController

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
    self.view.multipleTouchEnabled = NO;
     MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
     
     UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(goBackAdd:)];
     self.navigationItem.backBarButtonItem=left;
     
    
     //UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
     UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
     _label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
     _label.text =appDelegate.menu_title;
     _label.font = [UIFont boldSystemFontOfSize:20.0];
     _label.backgroundColor = [UIColor clearColor];
     _label.textAlignment = NSTextAlignmentCenter;
     if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
         _label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
         _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
     }
     self.navigationItem.titleView = _label;
     UIButton *pictureIcon = [[UIButton alloc] init];
     if ([appDelegate.mediaControl isEqualToString:@"camera"]) {
         //NSLog(@"camera");
         [pictureIcon setBackgroundImage:[UIImage imageNamed:@"camera_01"] forState:UIControlStateNormal];
         [pictureIcon setBackgroundImage:[UIImage imageNamed:@"camera_over_01"] forState:UIControlStateSelected];
     }else if([appDelegate.mediaControl isEqualToString:@"video"]){
         //NSLog(@"video");
         [pictureIcon setBackgroundImage:[UIImage imageNamed:@"camera_03"] forState:UIControlStateNormal];
         [pictureIcon setBackgroundImage:[UIImage imageNamed:@"camera_over_03"] forState:UIControlStateSelected];
     }
     UIButton *listIcon = [[UIButton alloc] init];
     [listIcon setBackgroundImage:[UIImage imageNamed:@"camera_02"] forState:UIControlStateNormal];
     [listIcon setBackgroundImage:[UIImage imageNamed:@"camera_over_02"] forState:UIControlStateSelected];
     listIcon.tag = 2;
     
     pictureIcon.tag = 1;
     [pictureIcon setFrame:CGRectMake(65, 30, 198*1.5, 131*1.5)];
     [pictureIcon addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
     [listIcon addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
     
     CGRect screen = [[UIScreen mainScreen]bounds];
     CGFloat screenWidth = screen.size.width;
     CGFloat screenHeight = screen.size.height;
     
     NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
     UIImage *bgImage = [UIImage imageWithData:decryptData];
     NSData *lDecryptData = [[NSData dataWithContentsOfFile:appDelegate.lSubBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
     UIImage *lBgImage = [UIImage imageWithData:lDecryptData];

     UIInterfaceOrientation toInterfaceOrientation = self.interfaceOrientation;
     if ((toInterfaceOrientation == UIInterfaceOrientationPortrait)||(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ) {
         if (bgImage==nil) {
             bgImage = [UIImage imageNamed:@"default2.png"];
         }
         imageView.image = bgImage;
         pictureIcon.center = CGPointMake(screenWidth/2, screenHeight/4);
     }else{
         if (lBgImage==nil) {
             lBgImage = [UIImage imageNamed:@"w_default2.png"];
         }
         imageView.image = lBgImage;
         pictureIcon.center = CGPointMake(screenHeight/2, screenWidth/4);
     }
     
     [listIcon setFrame:CGRectMake(pictureIcon.frame.origin.x, pictureIcon.frame.origin.y+pictureIcon.frame.size.height+50, 198*1.5, 131*1.5)];
     
     
     [self.view addSubview:pictureIcon];
     [self.view addSubview:listIcon];
     
     if (_isWebApp) {
         [self cameraOpen];
     }
}

-(void)viewDidAppear:(BOOL)animated{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    NSData *lDecryptData = [[NSData dataWithContentsOfFile:appDelegate.lSubBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *lBgImage = [UIImage imageWithData:lDecryptData];
    
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    
    UIButton *pictureIcon = (UIButton *)[self.view viewWithTag:1];
    UIButton *listIcon = (UIButton *)[self.view viewWithTag:2];
    pictureIcon.hidden=NO;
    listIcon.hidden=NO;
    UIInterfaceOrientation toInterfaceOrientation = self.interfaceOrientation;
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait)||(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ) {
        if (bgImage==nil) {
            bgImage = [UIImage imageNamed:@"default2.png"];
        }
        imageView.image = bgImage;
        pictureIcon.center = CGPointMake(screenWidth/2, screenHeight/4);
    }else{
        if (lBgImage==nil) {
            lBgImage = [UIImage imageNamed:@"w_default2.png"];
        }
        imageView.image = lBgImage;
        pictureIcon.center = CGPointMake(screenHeight/2, screenWidth/4);
    }
    [listIcon setFrame:CGRectMake(pictureIcon.frame.origin.x, pictureIcon.frame.origin.y+pictureIcon.frame.size.height+50, 198*1.5, 131*1.5)];
}
-(void)viewDidDisappear:(BOOL)animated{
    UIButton *pictureIcon = (UIButton *)[self.view viewWithTag:1];
    UIButton *listIcon = (UIButton *)[self.view viewWithTag:2];
    pictureIcon.hidden=YES;
    listIcon.hidden=YES;
}
- (void)applicationDidEnterBackground:(NSNotification *)notification{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    NSUserDefaults *pres = [NSUserDefaults standardUserDefaults];
    if ([[pres stringForKey:@"Lock"] isEqualToString:@"YES"] && appDelegate.isLogin) {
        
        LockInsertView *vc = [[LockInsertView alloc]init];
        [self presentViewController:vc animated:NO completion:nil];
    }
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    NSData *lDecryptData = [[NSData dataWithContentsOfFile:appDelegate.lSubBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *lBgImage = [UIImage imageWithData:lDecryptData];
    
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    UIButton *pictureIcon = (UIButton *)[self.view viewWithTag:1];
    UIButton *listIcon = (UIButton *)[self.view viewWithTag:2];
    if ((toInterfaceOrientation == UIInterfaceOrientationPortrait)||(toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ) {
        if (bgImage==nil) {
            bgImage = [UIImage imageNamed:@"default2.png"];
        }
        imageView.image = bgImage;
        pictureIcon.center = CGPointMake(screenWidth/2, screenHeight/4);
    }else{
        if (lBgImage==nil) {
            lBgImage = [UIImage imageNamed:@"w_default2.png"];
        }
        imageView.image = lBgImage;
        pictureIcon.center = CGPointMake(screenHeight/2, screenWidth/4);
    }
    [listIcon setFrame:CGRectMake(pictureIcon.frame.origin.x, pictureIcon.frame.origin.y+pictureIcon.frame.size.height+50, 198*1.5, 131*1.5)];
}

-(void) buttonTouched:(id)sender{
	if ([sender tag]==1) {
        NSLog(@"buttonTouched 1");
		[self cameraOpen];
	}else if ([sender tag]==2) {
		//NSString *str = [self getFilePath];
		////NSLog(@"%@",str);
		FileListViewController *vc = [[FileListViewController alloc] init];
		[self.navigationController pushViewController:vc animated:YES];
        
		//[self showAlertMessage:@"다음 업데이트를 기대하세요." Title:@"준비중" Btn:NSLocalizedString(@"message51", @"")];
		
	}
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)cameraOpen {
    NSLog(@"cameraOpen");
	/*
	//아이폰 내부 카메라 오픈
	picker = [[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    picker.videoQuality = UIImagePickerControllerQualityType640x480;
    //picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    picker.videoMaximumDuration = 20.0f;
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate.mediaControl isEqualToString:@"camera"]) {
        picker.mediaTypes = [NSArray arrayWithObjects:@"public.image",nil];
    }else{
        picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie",nil];
    }
    NSLog(@"picker.mediaTypes : %@",picker.mediaTypes);
	//카메라뷰 열기
    [self presentViewController:picker animated:YES completion:nil];
	*/
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSLog(@"picker : %@",picker);
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self presentViewController:picker animated:YES completion:NULL];
    }else{
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    
  

    
}
-(UIImage *) resizedImage:(UIImage *)img inRect:(CGRect)frameRect {
	UIGraphicsBeginImageContext(frameRect.size);
	[img drawInRect:frameRect];
	return UIGraphicsGetImageFromCurrentImageContext();
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_isWebApp) {
        NSLog(@"isWebApp");
        [self.navigationController popViewControllerAnimated:YES];
        _isWebApp = NO;
    }
}
- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    
	//카메라뷰일때
	sendImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //동영상일때
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    //NSLog(@"image : %@",sendImage);
    //NSLog(@"movie : %@",url);
    //NSLog(@"url path : %@",[url path]);
	MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
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
        fileName = [filename stringByAppendingString:@".jpg"];
        thumFileName = [filename stringByAppendingString:@".thum"];
        [self savePicture:filename];
    }else if(url !=nil) {
        NSString *saveFolder = [self getVideoFilePath];
        //동영상 썸네일 생성
        UIImage *photoImage = [self imageFromMovie:url atTime:0.0];
        
        UIImage *thumImage = [self resizedImage:photoImage inRect:CGRectMake(0, 0, 60, 60)];
        
        NSString *thumnailFileName = [filename stringByAppendingFormat:@".thum"];
        NSString *imageFileName = [filename stringByAppendingFormat:@".png"];
        NSString *saveImageFile = [saveFolder stringByAppendingPathComponent:imageFileName];
        NSString *saveThumFile = [saveFolder stringByAppendingPathComponent:thumnailFileName];
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(photoImage)];
        NSData *thumData = [NSData dataWithData:UIImagePNGRepresentation(thumImage)];
        //NSLog(@"save movie image : %@",imageFileName);
        
        [imageData writeToFile:saveImageFile atomically:YES];
        [thumData writeToFile:saveThumFile atomically:YES];
        
        //동영상 저장
        
        NSString *movFilename = [filename stringByAppendingFormat:@".mp4"];
        NSString *saveMovFile = [saveFolder stringByAppendingPathComponent:movFilename];
        //NSURL *dst = [NSURL URLWithString:saveMovFile];
        //UISaveVideoAtPathToSavedPhotosAlbum([url path], nil, nil, nil);
        NSError *error = nil;
        NSFileManager *manager = [[NSFileManager alloc] init];
        
        BOOL success =[manager copyItemAtPath:[url path] toPath:saveMovFile error:&error];
        
        if (NO == success || error) {
            //NSLog(@"Could not copy : %@", error);
        }
        NSData *data = [[NSData alloc]initWithContentsOfURL:url];
        //NSData *encryptData = [data AES256EncryptWithKey:appDelegate.AES256Key];
        [data writeToFile:saveMovFile atomically:YES];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_isWebApp) {
        NSLog(@"isWebApp");
        [self.navigationController popViewControllerAnimated:YES];
        _isWebApp = NO;
    }
    
}
- (UIImage *)imageFromMovie:(NSURL *)movieURL atTime:(NSTimeInterval)time{
    MPMoviePlayerController *mp = [[MPMoviePlayerController alloc]initWithContentURL:movieURL];
    mp.shouldAutoplay = NO;
    mp.initialPlaybackTime = time;
    mp.currentPlaybackTime = time;
    UIImage *thumnail = [mp thumbnailImageAtTime:time timeOption:MPMovieTimeOptionNearestKeyFrame];
    [mp stop];
    
    return thumnail;
}
-(void) savePicture:(NSString*)file{
    //	NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //	NSString *photoFolder = @"Photo";
    //    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/%@",photoFolder];
    //
    //	NSFileManager *fileManager = [[NSFileManager alloc]init];
    //    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    //    if (issue) {
    //        //NSLog(@"directory success");
    //    }else{
    //        //NSLog(@"directory failed");
    //        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:FALSE attributes:nil error:nil];
    //    }
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *saveFolder = [self getPhotoFilePath];
    UIImage *image = sendImage;
    CGSize newSize;
	newSize.width = image.size.width/3;
	newSize.height = image.size.height/3;
	CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);
	[image drawInRect:rect];
	NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image,0.05)];
    NSData *encryptImageData = [imageData AES256EncryptWithKey:appDelegate.AES256Key];
	NSString *filePath2 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:@".jpg"]];
	NSString *filePath3 = [saveFolder stringByAppendingPathComponent:[file stringByAppendingString:@".thum"]];
    //NSLog(@"thum file path : %@",filePath3);
	[imageData writeToFile:filePath2 atomically:YES];
	UIImage *thumImage = [self resizedImage:image inRect:CGRectMake(0, 0, 60, 60)];
	NSData *thumData = [NSData dataWithData:UIImagePNGRepresentation(thumImage)];
    NSData *encrytpThumData = [thumData AES256EncryptWithKey:appDelegate.AES256Key];
	[thumData writeToFile:filePath3 atomically:YES];
    if (_isWebApp) {
        NSArray *arr = [self.navigationController viewControllers];
        WebViewController *webView = [[self.navigationController viewControllers]objectAtIndex:[arr count]-2];
        if (_userSpecific ==nil) {
            [webView photoSave:filePath2];
        }else{
            [webView photoSave:filePath2 :_userSpecific :_callbackFunc];
        }
    }
	NSLog(@"photo success");
}
-(NSString *)getPhotoFilePath{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
	NSString *photoFolder = @"photo";
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/%@",photoFolder];

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
-(NSString *)getVideoFilePath{
	MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
	NSString *photoFolder = @"video";
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/%@",photoFolder];
    
	NSFileManager *fileManager = [[NSFileManager alloc]init];
    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    if (issue) {
        //NSLog(@"directory success");
    }else{
        //NSLog(@"directory failed");
        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:FALSE attributes:nil error:nil];
    }
    return saveFolder;
}
@end
