//
//  MFWebViewController.h
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 8..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreMotion/CoreMotion.h>
#import <MessageUI/MessageUI.h>
#import <WebKit/WebKit.h>
#import <dlfcn.h>
#import <mach/port.h>
#import <mach/kern_return.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <ContactsUI/ContactsUI.h>


#import "UploadListViewController.h"

#import "MFDownloadViewController.h"
#import "MFNewWebViewController.h"
#import "MFBarcodeScannerViewController.h"
#import "MFURLSession.h"
#import "MFSignPadViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "SCLAlertView.h"
#import "FBEncryptorAES.h"
#import "SVProgressHUD.h"
#import "UIDevice-Hardware.h"
#import "DataLogger.h"

#import "AppDelegate.h"



@interface MFWebViewController : UIViewController<UIScrollViewDelegate,UIApplicationDelegate,UIActionSheetDelegate,NSURLConnectionDataDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MFDownloadDelegate,MFBarcodeScannerDelegate,MFURLSessionDelegate,MFSignPadViewDelegate,CNContactViewControllerDelegate, CNContactPickerDelegate, ABPeoplePickerNavigationControllerDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UploadListDelegate>{
    BOOL isCamera;
    CMMotionManager *motionManager;
    DataLogger *_myDataLogger;
    NSString *sensorString;
    IBOutlet UIView *webViewFrame;
    BOOL flag;
}
-(IBAction)backButton:(id)sender;
- (void)setMfnpMethod:(WKUserContentController *)userController;
-(NSDictionary *)getParameters:(NSString *)query;
- (void)evaluateJavaScript:(NSString *)jsCommand;
@property (nonatomic, strong)NSMutableDictionary *callBackDic;
@property (nonatomic, strong)NSString *pageURL;
@property (nonatomic, strong)NSString *webServiceURL;
@property (nonatomic, strong)NSString *callbackFunc;
@property (nonatomic, strong)NSString *userSpecific;
@property (nonatomic, strong)UIImagePickerController *picker;
@property (nonatomic, strong)NSMutableArray *webViews;
@property (nonatomic, strong)IBOutlet UIProgressView *progressView;
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic, strong)NSString *latitude;
@property (nonatomic, strong)NSString *longitude;
@property (nonatomic, strong)NSMutableArray *createdWKWebViews;
@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, strong)UIView *topBarView;
@end
