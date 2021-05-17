
#import "SplashViewController.h"
#import "AppDelegate.h"

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

- (void)viewWillAppear:(BOOL)animated {
	//[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[super viewWillAppear:animated];
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
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
	
    //버전체크
    NSString *currentVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    NSLog(@"crr ver : %@", currentVer);
    
//    http://~~~/deploy/getVersions/app_v={APP_Version}&dvc_os=iOS
    NSString *urlStr = @"";
    NSString *paramStr = [NSString stringWithFormat:@"app_v=%@&dvc_os=iOS", currentVer];
    VersionCheck *vc = [[VersionCheck alloc] init];
    vc.delegate = self;
    [vc currentVersionCheck:urlStr param:paramStr];
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

#pragma mark - VersionCheck Delegate
- (void)returnDataWithObject:(VersionCheck *)session error:(NSString *)error{
    
//    - {"TYPE":"APP", "DVC_OS":"iOS", "RESULT": true, "IS_UPDATE": false}
//    - {"TYPE":"APP", "DVC_OS":"iOS", "RESULT":true, "IS_UPDATE":true, "URL":"http:~~~~test.plist", "VERSION":"1.0.0"}
//    - {"TYPE":"APP", "DVC_OS":"iOS", "RESULT": false, "MSG": "에러메시지"}
//    * 팝업메시지 출력
//    - 타이틀 : 알림
//    - 메시지 : 새로운 버전이 업데이트되었습니다. 지금 업데이트 하시겠습니까?
//    - 버튼 : 예 / 아니오
//     
//    예하면 업그레이드 진행 아니오하면 우선 그냥 로그인화면으로 진행하도록
    
    NSString *isUpdate = [session.returnDictionary objectForKey:@"IS_UPDATE"];
    if([isUpdate isEqualToString:@"true"]){
        NSString *downUrl = [session.returnDictionary objectForKey:@"URL"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"알림" message:@"새로운 버전이 업데이트되었습니다. 지금 업데이트 하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"예" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    //다운로드 페이지 이동
                                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downUrl]];
                                                                 
                                                             }];
            
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"아니오" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fadeScreen) userInfo:nil repeats:NO];
                                                                 }];
            
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        //리턴 false
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fadeScreen) userInfo:nil repeats:NO];
    }
}


@end
