//
//  BarcodeScannerViewController.h
//  mFinity
//
//  Created by Jun HyungPark on 2016. 5. 26..
//  Copyright © 2016년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTBBarcodeScanner.h"
#import "MFinityAppDelegate.h"
@protocol MFBarcodeScannerDelegate;

@interface MFBarcodeScannerViewController : UIViewController<UIAlertViewDelegate>
@property (assign, nonatomic) id <MFBarcodeScannerDelegate>delegate;
@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) NSMutableArray *uniqueCodes;
@end
@protocol MFBarcodeScannerDelegate <NSObject>
@optional
- (void)errorReadBarcode:(NSString *)errMessage;
- (void)resultReadBarcode:(NSString *)result;
@end