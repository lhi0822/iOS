//
//  ViewController.h
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 1..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFSwipeToHide.h"
#import "TOCropViewController.h"


#define EXAFE_SERVER_CERT @"30820122300d06092a864886f70d01010105000382010f003082010a0282010100b3c9302e6bc4ecaab7936759fcb1dd2388a1493ca82dc88344bdf32f308f51d0c0182a4148e4c9a9ebed30ead51b14778af3ccf4d44391d15d05f026cfa661a88f7d52891615b6821f7870ed2209337a210dd27682b34cb4f2a6dcf4d093bb4aad3a41e38b17c40734d062992ef0663055cd607f542a89e924209dcdfee61b6f5fbf478f6b0f24dc7e9be1b8fae085f79dca7cfec9bb63031c16e98520fcd6add4a38339fabdbada567b07e88b6aeb04d15d8bd9c4ab83719aed5d8a0baf7cb7f2bda18e9d0c87bbc02276797362c131b549f0dc6b06844428f7d4f0fec980f41ca30d9860d41387b73f891aac733b210330fbba347c2c6245a631f2c345e5c10203010001"
/*
#define EXAFE_GOODS_LICENSE_CODE @"MThjNzRmYWMyZjExMWNhYzJjNGZjNmVlMTQ3YTVlYmE0NTM2OTdjYksoMykrRSgxKTIwMTYtMDctMjd+MjAxNy0wNy0yNw=="
#define EXAFE_GOODS_LICENSE_CODE @"ZmUxOGE0M2VlMTg4MmQ5NGNmNDY2NjhjNjkwNzg1OGMwMTkyYmFkY0soMykrRSgxKTIwMTYtMDgtMTJ+MjAxNi0xMC0xMg=="
#define EXAFE_GOODS_LICENSE_CODE @"MzhlMzc3MGEyOWIwOTJiNzRkY2YxOTkxMjA3N2U2NzA4ODFmNjAyMksoMykrRSgxKTIwMTYtMDgtMjR+MjAzNi0wOC0yNA=="
*/
#define EXAFE_GOODS_LICENSE_CODE @"NTBhNDY2MTgxNWE5MmY1M2I4YzRmYTA2ODQwOTkyNDExODc4MGE1N0soMykrRSgxKTIwMTYtMTAtMTd+MjAzNi0xMC0xNw=="


#import "MFWebViewController.h"
@interface WebViewController : MFWebViewController<UIToolbarDelegate,UIScrollViewDelegate,TOCropViewControllerDelegate>{

    
}

@property (nonatomic,strong)NSString *startURL;
@property (nonatomic, strong) NSMutableArray *urlHistoryArray;
@property (strong, nonatomic) AFSwipeToHide *swipeToHide;

@property (nonatomic, assign) TOCropViewCroppingStyle croppingStyle;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGRect croppedFrame;
@property (nonatomic, assign) NSInteger angle;

@end

