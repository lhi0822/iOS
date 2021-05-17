//
//  ImageDrawViewController.h
//  mFinity
//
//  Created by hilee on 07/01/2019.
//  Copyright © 2019 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import "MainDrawView.h"
//#import "TOCropViewController.h"

@protocol ImageDrawDelegate;

@interface ImageDrawViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate/*, TOCropViewControllerDelegate*/>

@property (assign, nonatomic) id <ImageDrawDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet MainDrawView *canvasView;
@property (strong, nonatomic) IBOutlet UIImageView *imgCanvas;

@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *penItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *eraserItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *clearItem;

//@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIImage *getBgImg;
@property (strong, nonatomic) NSString *bgImgPath;

//@property (nonatomic, assign) TOCropViewCroppingStyle croppingStyle;
//@property (nonatomic, strong) UIImage *image;
//@property (nonatomic, assign) CGRect croppedFrame;
//@property (nonatomic, assign) NSInteger angle;


- (IBAction)penClick:(id)sender;
- (IBAction)eraserClick:(id)sender;
- (IBAction)clearClick:(id)sender;

@end

@protocol ImageDrawDelegate <NSObject>
@optional
- (void)returnEditImage :(NSString *)imgPath;
@end
