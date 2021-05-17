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

    //네비게이션 바 색상 변환

    [self.navigationController.navigationBar setTintColor:[MFUtil myRGBfromHex:self.naviBarColor]];
    
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
    
    if ([self.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowOffset = CGSizeMake([self.naviShadowOffset floatValue], [self.naviShadowOffset floatValue]);
        label.shadowColor = [MFUtil myRGBfromHex:self.naviShadowColor];
    }
    label.textColor = [MFUtil myRGBfromHex:self.fontColor];

    label.text = @"Barcode Scanner";
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
    //code = [code substringFromIndex:[code length]-8];
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
                //NSString *accessCode = [code.stringValue substringFromIndex:[code.stringValue length]-8];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Result" message:code.stringValue delegate:self cancelButtonTitle:nil otherButtonTitles:@"confirm", nil];
                [alertView show];
            }
        }
    }];
    
}

- (void)stopScanning {
    [self.scanner stopScanning];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end