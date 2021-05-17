//
//  ImageSetViewController.h
//  mFinity
//
//  Created by hilee on 28/11/2018.
//  Copyright © 2018 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "UploadProcessViewController.h"

@interface ImageSetViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UploadProcessViewDelegate> {
    UIImagePickerController *picker;
}

@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet UIButton *cameraBtn;
@property (strong, nonatomic) IBOutlet UIButton *albumBtn;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) BOOL isTabBar;
@property (strong, nonatomic) NSString *uploadUrl;
@property (strong, nonatomic) NSString *count;
@property (strong, nonatomic) NSString *maxSize;
@property (nonatomic, assign) BOOL deleteFlag; //executeFileUpload 삭제 플래그

@end


