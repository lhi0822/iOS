//
//  FirstViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 18..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"
#import <TapkuLibrary/TapkuLibrary.h>

#import "WebViewController.h"
#import "MFBarcodeScannerViewController.h"
#import "ZipArchive.h"
#import "DownloadListViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "SDiOSVersion.h"

@interface MainViewController : UIViewController<UIAlertViewDelegate, UINavigationControllerDelegate, NSURLConnectionDataDelegate,NSXMLParserDelegate, MFBarcodeScannerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate,TKCoverflowViewDelegate,TKCoverflowViewDataSource,UITableViewDelegate,UITableViewDataSource,DownloadListDelegate>{
    
    NSString *menuType;
    NSString *menuKind;

    
    MFinityAppDelegate *appDelegate;
    NSString *title_name;
 
    NSMutableData *fileData;
	NSNumber *totalFileSize;
    NSString *currentAppNo;
    NSString *currentAppVersion;
    NSMutableData			*receiveData;
    NSString                *param;
    NSArray					*views;
    int pageNumber;
	BOOL pageControlUsed;
    BOOL isDrawMenu;
    NSString *nativeAppMenuNo;
    NSString *nativeAppURL;
    NSString *nativeAppVersion;
    BOOL isCommonDownload;
    
    NSMutableArray *menuArray;
    NSString *paramString;
    NSString *kind;
    NSMutableArray *covers;
    TKCoverflowView *coverflow;
    
    BOOL isTabBar;
    BOOL isDMS;
    
    IBOutlet UIScrollView *mainScrollView;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UITableView *myTableView;
    IBOutlet UIImageView	*imageView;
    IBOutlet UILabel        *menuName;
    IBOutlet UILabel        *powerName;
    
    NSString *_methodName;
    
    int colCount;
    int rowCount;
}

@property (nonatomic, assign)BOOL isLogin;
-(void)coverFlowSetting;
-(void) menuSetting;
-(void) buttonTouched:(id)sender;
-(void) barCodeReaderOpen;
-(void) parserJsonData:(NSData *)data;
//- (void)setUILabel:(UILabel *)myLabel withMaxFrame:(CGRect)maxFrame withText:(NSString *)theText usingVerticalAlign:(int)vertAlign;
@end
