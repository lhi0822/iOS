//
//  WebViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 15..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFUtil.h"

@interface WebViewController : UIViewController <UIDocumentInteractionControllerDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *fileUrl;

- (BOOL)shouldAutorotate;
- (BOOL)prefersStatusBarHidden;

@end
