//
//  BarcodeScannerViewController.h
//  mFinity
//
//  Created by Jun HyungPark on 2016. 5. 26..
//  Copyright © 2016년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTBBarcodeScanner.h"
#import "MFUtil.h"

@protocol MFBarcodeScannerDelegate;

@interface MFBarcodeScannerViewController : UIViewController<UIAlertViewDelegate>
@property (assign, nonatomic) id <MFBarcodeScannerDelegate>delegate;
@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) NSMutableArray *uniqueCodes;
@property (nonatomic, strong) NSString *naviBarColor;
@property (nonatomic, strong) NSString *naviFontColor;
@property (nonatomic, strong) NSString *naviIsShadow;
@property (nonatomic, strong) NSString *naviShadowColor;
@property (nonatomic, strong) NSString *naviShadowOffset;
@property (nonatomic, strong) NSString *backGroundImagePath;
@property (nonatomic, strong) NSString *fontColor;
@end
@protocol MFBarcodeScannerDelegate <NSObject>
@optional
- (void)errorReadBarcode:(NSString *)errMessage;
- (void)resultReadBarcode:(NSString *)result;
@end