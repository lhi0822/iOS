//
//  ShareViewController.h
//  ShareEx
//
//  Created by hilee on 24/10/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SDAVAssetExportSession.h"
#import "MFSingleton.h"

//@interface ShareViewController : SLComposeServiceViewController
@interface ShareViewController : UIViewController <SDAVAssetExportSessionDelegate>
@end
