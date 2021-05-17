//
//  DownloadViewController.h
//  mFinity
//
//  Created by Park on 2014. 6. 18..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YLProgressBar;
@interface DownloadViewController : UIViewController<NSURLConnectionDataDelegate>{
    IBOutlet UIImageView *_imageView;
    IBOutlet UILabel *_webAppLabel;
    IBOutlet UILabel *_commonLabel;
    NSMutableData *fileData;
    NSNumber *totalFileSize;
    NSString *progressName;
    BOOL isCommonDownload;
}

@property (nonatomic, strong) NSString *downloadURL;
@property (nonatomic, strong) NSString *nativeAppMenuNo;
@property (nonatomic, strong) NSString *currentAppVersion;
@property (nonatomic, strong) IBOutlet YLProgressBar      *webAppProgressBar;
@property (nonatomic, strong) IBOutlet YLProgressBar      *commonProgressBar;
@end
