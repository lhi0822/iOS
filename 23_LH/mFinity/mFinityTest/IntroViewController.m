//
//  IntroViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 19..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "IntroViewController.h"
#import "LoginViewController.h"
#import "MFinityAppDelegate.h"

@interface IntroViewController (){
    int endCount;
}

@end

@implementation IntroViewController

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
    NSLog(@"%s",__FUNCTION__);
    self.navigationController.navigationBarHidden = YES;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	count = 0;
	_myIndicator.hidesWhenStopped = NO;
	[_myIndicator startAnimating];
	endCount=0;
	endCount = [[prefs stringForKey:@"IntroCount"] intValue];

//    NSString *mainURL = @"http://192.168.0.141:8080/mservice";
//    NSString *mainURL = @"https://roms.dbvalley.com/mservice";
//    NSString *mainURL = @"https://roms.dbvalley.com/dataservice41";
    NSString *mainURL = @"http://192.168.17.51/mservice";
    [prefs setObject:mainURL forKey:@"URL_ADDRESS"];
    [prefs synchronize];
    
    imageView.backgroundColor = [UIColor whiteColor];
    _logoView.image = [UIImage imageNamed:@"logo.png"];
    
	if (endCount == 0) {
		endCount = 3;
	}
    
	[self startTimer];
}

-(NSString *) startTimer{
	[NSTimer scheduledTimerWithTimeInterval:1.0
									 target:self
								   selector:@selector(handleTimer:)
								   userInfo:nil
									repeats:YES];
	return @"YES";
}
-(void) handleTimer:(NSTimer *)timer {
	count++;
	if (count==endCount) {
        ixShieldSystemCheck *is = [[ixShieldSystemCheck alloc] init];
        
		[_myIndicator stopAnimating];
		_myIndicator.hidesWhenStopped =YES;
		[_myIndicator removeFromSuperview];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
        appDelegate.main_url = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"URL_ADDRESS"]];
        LoginViewController *vc = [[LoginViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
