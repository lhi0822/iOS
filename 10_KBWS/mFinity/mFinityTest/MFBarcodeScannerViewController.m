//
//  BarcodeScannerViewController.m
//  mFinity
//
//  Created by Jun HyungPark on 2016. 5. 26..
//  Copyright © 2016년 Jun hyeong Park. All rights reserved.
//

#import "MFBarcodeScannerViewController.h"

@interface MFBarcodeScannerViewController ()

@end

@implementation MFBarcodeScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[UIApplication sharedApplication].delegate;
    if (![appDelegate.demo isEqualToString:@"DEMO"]) {
        int badge = [appDelegate.badgeCount intValue];
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
        if (badge>0 && ![appDelegate.noticeTabBarNumber isEqualToString:@""] &&appDelegate.noticeTabBarNumber!=nil) {
            [[[[[self tabBarController] tabBar] items] objectAtIndex:[appDelegate.noticeTabBarNumber intValue]] setBadgeValue:[NSString stringWithFormat:@"%d",badge]];
        }
    }
    
    //네비게이션 바 색상 변환
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    if ([self.scanner isScanning]) {
        [self stopScanning];
    } else {
        [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
            if (success) {
                [self startScanning];
            } else {
                [self displayPermissionMissingAlert];
            }
        }];
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    if (appDelegate.isMainWebView) {
        if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
            label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
            label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        }
        label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    }else{
        if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
            label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
            label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        }
        label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    }
    label.text = appDelegate.menu_title;
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanner stopScanning];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)close{
    [self stopScanning];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)displayPermissionMissingAlert {
    NSString *message = nil;
    if ([MTBBarcodeScanner scanningIsProhibited]) {
        message = @"This app does not have permission to use the camera.";
    } else if (![MTBBarcodeScanner cameraIsPresent]) {
        message = @"This device does not have a camera.";
    } else {
        message = @"An unknown error occurred.";
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Scanning Unavailable"
                                message:message
                               delegate:self
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"Scanning Unavailable"]) {
        [self dismissViewControllerAnimated:YES completion:^(void){
            [self errorBarcode:@"Scanning Unavailable"];
        }];
    }else if ([alertView.title isEqualToString:@"Result"]) {
        NSString *code = [self.uniqueCodes objectAtIndex:0];
        [self dismissViewControllerAnimated:YES completion:^(void){
            [self resultBarcode:code];
        }];
    }
}
-(void)errorBarcode:(NSString *)msg{
    if (self.delegate && [self.delegate respondsToSelector:@selector(errorReadBarcode:)]) {
        [self.delegate errorReadBarcode:msg];
    }
}
-(void)resultBarcode:(NSString *)code{
    if (self.delegate && [self.delegate respondsToSelector:@selector(resultReadBarcode:)]) {
        [self.delegate resultReadBarcode:code];
    }
}
-(void)animationCompleted{
    
    NSString *code = [self.uniqueCodes objectAtIndex:0];
    NSLog(@"[barcode result] : %@",code);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"barcodeData" object:code];
}

#pragma mark - Scanner
- (MTBBarcodeScanner *)scanner {
    if (!_scanner) {
        _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_previewView];
    }
    return _scanner;
}

#pragma mark - Scanning
- (void)startScanning {
    self.uniqueCodes = [[NSMutableArray alloc] init];
    
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            if (code.stringValue && [self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                [self.uniqueCodes addObject:code.stringValue];
                
                NSLog(@"Found unique code: %@", code.stringValue);
                //NSString *accessCode = code.stringValue; //[code.stringValue substringFromIndex:[code.stringValue length]-8];
                //UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Result" message:accessCode delegate:self cancelButtonTitle:nil otherButtonTitles:@"confirm", nil];
                //[alertView show];
                
                NSString *code = [self.uniqueCodes objectAtIndex:0];
                [self dismissViewControllerAnimated:YES completion:^(void){
                    [self resultBarcode:code];
                }];
            }
        }
    }];
}

- (void)stopScanning {
    [self.scanner stopScanning];
}

@end
