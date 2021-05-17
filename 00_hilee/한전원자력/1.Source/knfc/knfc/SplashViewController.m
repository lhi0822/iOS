//
//  SplashViewController.m
//  iTennis
//
//  Created by Brandon Trebitowski on 3/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"

#define BOUNDARY @"---------------------------14737809831466499882746641449"


@implementation SplashViewController

@synthesize timer, splashImageView;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        NSLog(@"hi~~~");
////        [self loadView];
//
//        [self.view addSubview:self.splashImageView];
//        [self callVersion];
//    }
//    return self;
//}

- (void)viewWillAppear:(BOOL)animated {
	//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[super viewWillAppear:animated];
}

//-(void)callVersion{
//    NSString *currentVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    NSLog(@"crr22 ver : %@", currentVer);
//    NSString *urlStr = @"http://m.knfc.co.kr/deploy/getVersions";
//    NSString *paramStr = [NSString stringWithFormat:@"app_v=%@&dvc_os=iOS", currentVer];
//    [self URL:[NSURL URLWithString:urlStr] parameter:paramStr];
//}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    NSLog(@"%s", __FUNCTION__);
    
	//[self setWantsFullScreenLayout:YES]; 
	// Init the view
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *view = [[UIView alloc] initWithFrame:appFrame];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.view = view;
		
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
        splashImageView.frame = CGRectMake(0, -20, 320, 568);
        [self.view addSubview:splashImageView];
        
    } else {
        splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
        splashImageView.frame = CGRectMake(0, -20, 320, 460);
        
        [self.view addSubview:splashImageView];

    }

	[self.view addSubview:splashImageView];
    
//    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fadeScreen) userInfo:nil repeats:NO]; //커스텀적용시 주석처리
    
//    CUSTOM------------------------------------------------------
//    버전체크
    NSString *currentVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"crr ver : %@", currentVer);
    NSString *urlStr = @"http://m.knfc.co.kr/deploy/getVersions";
    NSString *paramStr = [NSString stringWithFormat:@"app_v=%@&dvc_os=iOS", currentVer];
    [self URL:[NSURL URLWithString:urlStr] parameter:paramStr];
}
 

-(void) onTimer{
	//NSLog(@"LOAD");
}

- (void)fadeScreen
{
    
	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:0.5];        // sets animation duration
	[UIView setAnimationDelegate:self];        // sets delegate for this block
	[UIView setAnimationDidStopSelector:@selector(finishedFading)];   // calls the finishedFading method when the animation is done (or done fading out)	
	self.view.alpha = 0.0;       // Fades the alpha channel of this view to "0.0" over the animationDuration of "0.75" seconds
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
    
}


- (void) finishedFading
{
	
	[UIView beginAnimations:nil context:nil]; // begins animation block
	[UIView setAnimationDuration:0.5];        // sets animation duration
	self.view.alpha = 1.0;   // fades the view to 1.0 alpha over 0.75 seconds
//	viewController.view.alpha = 1.0;
	[UIView commitAnimations];   // commits the animation block.  This Block is done.
	[splashImageView removeFromSuperview];
	[self.view removeFromSuperview];
    
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
	self.splashImageView = nil;
}


#pragma mark - Custom VersionCheck
- (void)URL:(NSURL *)url parameter:(NSString *)paramString {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    [request setHTTPMethod:@"POST"];

    @try {
        if (paramString != nil) {
            NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:paramData];
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        self.returnData = [[NSMutableData alloc] init];
        [task resume];
        
    }
    @catch (NSException *exception) {
        NSLog(@"error : %@",exception);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSInteger code = [(NSHTTPURLResponse *) response statusCode];
    if(code >= 200 && code < 300) {
        completionHandler (NSURLSessionResponseAllow);
    } else {
        NSLog(@"error code : %ld", (long)code);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.returnData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(!error){
        NSString *encReturnDataString = [[NSString alloc]initWithData:self.returnData encoding:NSUTF8StringEncoding];
//        NSLog(@"encReturnDataString : %@", encReturnDataString);

        NSError *dicError;
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
        
        [self versionCheckReturn:dataDic];
        
    } else {
        NSLog(@"error : %@",error);
    }
}

-(void)versionCheckReturn:(NSDictionary *)returnDic{
    @try{
        NSLog(@"returnDic : %@", returnDic);
        //{"DBV_OS":"iOS","RESULT":true,"IS_UPDATE":false,"TYPE":"APP"}
        BOOL result = [[returnDic objectForKey:@"RESULT"] boolValue];
        if(result){
            NSLog(@"result 1");
            BOOL isUpdate = [[returnDic objectForKey:@"IS_UPDATE"] boolValue];
            if(isUpdate){
                NSString *downUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", [returnDic objectForKey:@"URL"]];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"알림" message:@"새로운 버전이 업데이트되었습니다. 지금 업데이트 하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"예" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                        //다운로드 페이지 이동
                                                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downUrl] options:@{} completionHandler:nil];
                                                                 }];

                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"아니오" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                                        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fadeScreen) userInfo:nil repeats:NO];
                                                                     }];
                [alert addAction:cancelButton];
                [alert addAction:okButton];

                [self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];

            } else {
                NSLog(@"업데이트 없음");
                timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fadeScreen) userInfo:nil repeats:NO];
            }
            
        } else {
            NSString *errorMsg = [returnDic objectForKey:@"MSG"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"알림" message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fadeScreen) userInfo:nil repeats:NO];
                                                                 }];
            [alert addAction:okButton];
            [self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
        
    }@catch(NSException *exception){
        
    }
}


@end
