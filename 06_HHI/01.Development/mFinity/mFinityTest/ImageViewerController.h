//
//  ImageViewerController.h
//  mFinity_HHI
//
//  Created by hilee on 21/08/2019.
//  Copyright © 2019 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageViewerController : UIViewController<UIAlertViewDelegate, UIScrollViewDelegate> {
    UIImageView *_imageView;
    IBOutlet UIScrollView *_scrollView;
}

@property (strong, nonatomic) NSString *imgPath;
@property (strong, nonatomic) NSString *imgName;

@end

NS_ASSUME_NONNULL_END
