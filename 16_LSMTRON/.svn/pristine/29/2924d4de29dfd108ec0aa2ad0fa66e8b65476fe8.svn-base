//
//  CameraMenuViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 21..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MFinityAppDelegate.h"
#import "FileListViewController.h"
@interface CameraMenuViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate>{
    IBOutlet UIImageView *imageView;
	UIImage	*sendImage;
	NSString *thumFileName;
	NSString *fileName;
	UIImagePickerController *picker;
	UIActivityIndicatorView *myIndicator;

}
@property (nonatomic, strong)NSString *callbackFunc;
@property (nonatomic, strong)NSString *userSpecific;
@property (nonatomic,assign)BOOL isWebApp;
-(NSString *)getPhotoFilePath;
-(NSString *)getVideoFilePath;
-(void)cameraOpen;
-(void) buttonTouched:(id)sender;
-(void) savePicture:(NSString *)file;
- (UIImage *)imageFromMovie:(NSURL *)movieURL atTime:(NSTimeInterval)time;
@end
