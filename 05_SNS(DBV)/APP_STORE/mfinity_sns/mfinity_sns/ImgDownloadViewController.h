//
//  ImgDownloadViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 20..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "MFUtil.h"
#import "JTSImageViewController.h"

@interface ImgDownloadViewController : UIViewController <UIAlertViewDelegate, UIScrollViewDelegate> {
    UIImageView *_imageView;
    IBOutlet UIScrollView *_scrollView;
}

@property (strong, nonatomic) NSString *imgPath;
@property (strong, nonatomic) NSString *writer;
@property (strong, nonatomic) NSString *writeDate;
@property (strong, nonatomic) NSString *fromSegue;
@property (strong, nonatomic) NSString *imgName;


@end
