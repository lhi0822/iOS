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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MDMIntroNotification:) name:@"MDMIntroNotification" object:nil];
    

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    ////NSLog(@"intro image : %@",[prefs stringForKey:@"IntroImagePath"]);
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSData *decryptData = [[NSData dataWithContentsOfFile:[prefs stringForKey:@"IntroImagePath"]] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    
    if (bgImage == nil) {
        //2018.06 UI개선
        bgImage = [UIImage imageNamed:@"intro_default.png"];
    }
    imageView.image = bgImage;
    count = 0;
    myIndicator.hidesWhenStopped = NO;
    [myIndicator startAnimating];
    endCount=0;
    endCount = [[prefs stringForKey:@"IntroCount"] intValue];
    
    // 35 -> 41 수정
//    NSString *urlAdderess =[prefs stringForKey:@"URL_ADDRESS"];
//    urlAdderess = [urlAdderess stringByReplacingOccurrencesOfString:@"35" withString:@"41"];
//    [prefs setObject:urlAdderess forKey:@"URL_ADDRESS"];
//    [prefs synchronize];
    
    //URL접속정보 저장
    [prefs setObject:@"https://dev.hhi.co.kr:44175/dataservice41" forKey:@"URL_ADDRESS"];
    [prefs synchronize];
    
    if (endCount == 0) {
        endCount = 3;
    }
    
    
    [self startTimer];

    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //MDM 배포페이지
    //https://mdm.hhi.co.kr/mdm_admin_server/download
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
    
    /*
    NSURL *url = [NSURL URLWithString:@"com.gaia.mobikit.apple://"];

    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL *url = [NSURL URLWithString:@"https://mdm.hhi.co.kr/mdm_admin_server/download"];
        [[UIApplication sharedApplication] openURL:url];
        exit(0);
    }else{
    
        if (count==endCount) {
            [myIndicator stopAnimating];
            myIndicator.hidesWhenStopped =YES;
            [myIndicator removeFromSuperview];

            //[self nextStep];

            //MDM 실행 루틴
#ifdef DEBUG
            [self nextStep];
#else
            if ([self getMDMExageInfo:@"queries_getStatus_getRichStatus"]) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
                if ([prefs objectForKey:@"URL_ADDRESS"]!=nil) {
                    appDelegate.main_url = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"URL_ADDRESS"]];
                    LoginViewController *vc = [[LoginViewController alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    URLInsertViewController *vc = [[URLInsertViewController alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else{
                //MDM이 실행되지 않아 앱을 종료합니다.
                exit(0);
            }
#endif
        }
    }
    */
    
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.isMDM){
        NSURL *url = [NSURL URLWithString:@"com.gaia.mobikit.apple://"];

        if (![[UIApplication sharedApplication] canOpenURL:url]) {
            NSURL *url = [NSURL URLWithString:@"https://mdm.hhi.co.kr/mdm_admin_server/download"];
            [[UIApplication sharedApplication] openURL:url];
            exit(0);
        }else{

            if (count==endCount) {
                [myIndicator stopAnimating];
                myIndicator.hidesWhenStopped =YES;
                [myIndicator removeFromSuperview];

                if ([self getMDMExageInfo:@"queries_getStatus_getRichStatus"]) {
                    
                }else{
                    //MDM이 실행되지 않아 앱을 종료합니다.
                    exit(0);
                }
            }
        }
        
    } else {
        //테스트 시 MDM 제거
        if (count==endCount) {
            [myIndicator stopAnimating];
            myIndicator.hidesWhenStopped =YES;
            [myIndicator removeFromSuperview];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
            if ([prefs objectForKey:@"URL_ADDRESS"]!=nil) {
                appDelegate.main_url = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"URL_ADDRESS"]];
                LoginViewController *vc = [[LoginViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                URLInsertViewController *vc = [[URLInsertViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}
- (void)nextStep{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    if ([prefs objectForKey:@"URL_ADDRESS"]!=nil) {
        appDelegate.main_url = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"URL_ADDRESS"]];
        LoginViewController *vc = [[LoginViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        URLInsertViewController *vc = [[URLInsertViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)MDMIntroNotification:(NSNotification *)notification{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
        if ([prefs objectForKey:@"URL_ADDRESS"]!=nil) {
            appDelegate.main_url = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"URL_ADDRESS"]];
            
            LoginViewController *vc = [[LoginViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else{
            URLInsertViewController *vc = [[URLInsertViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    });
}

-(BOOL)getMDMExageInfo:(NSString*)command{
    NSString * stringURLScheme = nil;
    BOOL isBe;
    NSArray * URLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (URLTypes && [URLTypes count]) {
        NSDictionary * dict = [URLTypes objectAtIndex:0];
        NSArray * CFBundleURLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
        if (CFBundleURLSchemes && [CFBundleURLSchemes count]) {
            stringURLScheme = [CFBundleURLSchemes objectAtIndex:0];
        }
    }
    
    if (stringURLScheme) {
        NSMutableString * urlString = [NSMutableString stringWithFormat:@"com.gaia.mobikit.apple://?command=%@",command];
        
        [urlString appendFormat:@"&caller=%@", stringURLScheme];
        NSLog(@"urlString : %@",urlString);
        isBe = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
       return isBe;
    }
    else{
        NSLog(@"현재 앱에 URL Scheme 이 지정되어 있지 않아 호출할 수 없습니다. URL Scheme 지정해야 결과를 응답받을 수 있습니다.");
        UIAlertView * alert = [[UIAlertView alloc]
                               initWithTitle: nil
                               message: @"현재 앱에 URL Scheme 이 지정되어 있지 않아 호출할 수 없습니다. URL Scheme 지정해야 결과를 응답받을 수 있습니다."
                               delegate:nil
                               cancelButtonTitle:@"확인"
                               otherButtonTitles:nil, nil];
        alert.tag = 2000;
        alert.delegate = self;
        [alert show];
        
        return NO;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
