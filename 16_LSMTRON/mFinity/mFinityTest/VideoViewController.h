//
//  VideoViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 27..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface VideoViewController : UIViewController<NSURLConnectionDelegate, NSURLConnectionDataDelegate,UIAlertViewDelegate>{
    IBOutlet UIButton *btnPlay;
    IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *thumImageView;
    UIActivityIndicatorView *myIndicator;
    UIAlertView *progressAlertView;
    UIProgressView *progressView;
    NSString *mode;
    NSString *saveDecryptFilePath;
    BOOL _isWebApp;
}
@property (nonatomic, assign)BOOL isWebApp;
@property (nonatomic, strong)NSString *thumNailPath;
@property (nonatomic, strong)NSString *videoPath;
-(IBAction)PlayMovie;
@end
