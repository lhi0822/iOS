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
#import "URLInsertViewController.h"
#import "Notice_PushViewController.h"

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
    self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSData *decryptData = [[NSData dataWithContentsOfFile:[prefs stringForKey:@"IntroImagePath"]] AES256DecryptWithKey:appDelegate.AES256Key];
	UIImage *bgImage = [UIImage imageWithData:decryptData];
    
	if (bgImage == nil) {
		bgImage = [UIImage imageNamed:@"2021_intro_port.jpeg"];
	}
    imageView.image = bgImage;
	count = 0;
	myIndicator.hidesWhenStopped = NO;
	[myIndicator startAnimating];
	endCount=0;
	endCount = [[prefs stringForKey:@"IntroCount"] intValue];
    
    NSString *mainURL = @"https://mdesk.samhwa.com/dataservice41";
    [prefs setObject:mainURL forKey:@"URL_ADDRESS"];
    [prefs synchronize];
    
//    NSString *mainURL = @"http://192.168.0.178:8080/dataservice41";
//    [prefs setObject:mainURL forKey:@"URL_ADDRESS"];
//    [prefs synchronize];
    
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
		[myIndicator stopAnimating];
		myIndicator.hidesWhenStopped =YES;
		[myIndicator removeFromSuperview];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
        appDelegate.main_url = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"URL_ADDRESS"]];
        
        LoginViewController *vc = [[LoginViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        
        /*
        if ([prefs objectForKey:@"URL_ADDRESS"]!=nil) {
            appDelegate.main_url = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"URL_ADDRESS"]];
            LoginViewController *vc = [[LoginViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            URLInsertViewController *vc = [[URLInsertViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
         */
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
