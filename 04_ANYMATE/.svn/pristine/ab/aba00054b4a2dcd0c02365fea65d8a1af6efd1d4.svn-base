//
//  InfoViewController.m
//  Anymate
//
//  Created by Kyeong In Park on 13. 1. 4..
//  Copyright (c) 2013년 Kyeong In Park. All rights reserved.
//

#import "InfoViewController.h"
#import "AppDelegate.h"

@interface InfoViewController () {
    NSString *currVer;
    NSString *storeVer;
}

@end

@implementation InfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
//    currentVersion2Rect = currentVersion2.frame;
//    currentVersionRect = currentVersion.frame;
//    latestVersionRect = latestVersion.frame;
//    latestVersion2Rect = latestVersion2.frame;
//    upDateButtonRect = upDateButton.frame;
//    imageView2Center = imageView2.center;
//
//    upDateButton.backgroundColor = [appDelegate myRGBfromHex:@"2D4260"];
//    int offset;
//    int x_offset;
//    int x_offset2;
//    int y_offset;
//
//    if ([appDelegate.model_nm hasPrefix:@"iPhone 5"]) {
//        offset = 250;
//        x_offset = 0;
//        x_offset2 = 130;
//        y_offset = 150;
//    }else{
//        offset = 200;
//        x_offset = 35;
//        x_offset2 = 90;
//        y_offset = 130;
//    }
//    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        currentVersion2.frame = CGRectMake(currentVersion2.frame.origin.x-x_offset,
//                                           currentVersion2.frame.origin.y-50,
//                                           currentVersion2.frame.size.width,
//                                           currentVersion2.frame.size.height);
//        currentVersion.frame = CGRectMake(currentVersion.frame.origin.x-x_offset,
//                                          currentVersion.frame.origin.y-50,
//                                          currentVersion.frame.size.width,
//                                          currentVersion.frame.size.height);
//        latestVersion2.frame = CGRectMake(latestVersion2.frame.origin.x+offset,
//                                          currentVersion2.frame.origin.y,
//                                          latestVersion2.frame.size.width,
//                                          latestVersion2.frame.size.height);
//        latestVersion.frame = CGRectMake(latestVersion.frame.origin.x+offset,
//                                         currentVersion.frame.origin.y,
//                                         latestVersion.frame.size.width,
//                                         latestVersion.frame.size.height);
//        //upDateButton.center = imageView2Center;
//        upDateButton.frame = CGRectMake(upDateButton.frame.origin.x+x_offset2,
//                                        upDateButton.frame.origin.y-y_offset,
//                                        upDateButton.frame.size.width,
//                                        upDateButton.frame.size.height);
//        
//    }
    // Do any additional setup after loading the view from its nib.
    imageView.image = [UIImage imageNamed:@"bg_login.png"];
    
    [self storeVersionCheck];
    
    currentVersion.text = currVer;
    latestVersion.text = storeVer;
}
-(void)viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBar.topItem.title = @"버전 정보";
    if ([currentVersion.text isEqualToString:latestVersion.text]) {
        upDateButton.hidden = YES;
        upDateButton.enabled = NO;
        upDateButton.alpha = 0.5;
    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{

}
-(BOOL)shouldAutorotate{
    return YES;
}

-(void)storeVersionCheck{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* appID = infoDictionary[@"CFBundleIdentifier"];
    if([[appID lowercaseString] isEqualToString:@"com.dbvalley.anymate"]){
        appID = @"com.dbvalley.AnymateGW";
    }
    NSLog(@"appID : %@", appID);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/kr/lookup?bundleId=%@", appID]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    NSLog(@"lookup : %@", lookup);
    
    if ([lookup[@"resultCount"] integerValue] == 1){
        @try{
            NSString *appStoreVersion = lookup[@"results"][0][@"version"];
            NSString *currentVersion = infoDictionary[@"CFBundleShortVersionString"];
//            NSLog(@"appStoreVersion : %@", appStoreVersion);
//            NSLog(@"currentVersion : %@", currentVersion);
            
            currVer = currentVersion;
            storeVer = appStoreVersion;
            
//            appStoreVersion = [appStoreVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
//            currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
//
//            int storeVer = [appStoreVersion intValue];
//            int currentVer = [currentVersion intValue];
//
//            NSLog(@"store : %d, curr ; %d", storeVer, currentVer);
//
//            if(storeVer>currentVer){
//                NSLog(@"업데이트 O");
//
//            } else if(storeVer==currentVer){
//                NSLog(@"업데이트 X");
//
//
//            } else{
//                NSLog(@"다운그레이드");
//            }
            
        } @catch(NSException *e){
            
        }
    }
}

- (IBAction)upDate:(id)sender{
    NSString *downLoadLink = @"https://itunes.apple.com/kr/app/anymate/id610112050?mt=8&uo=4";
    NSURL *url = [NSURL URLWithString:downLoadLink];
    [[UIApplication sharedApplication] openURL:url];
}
-(void)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end


