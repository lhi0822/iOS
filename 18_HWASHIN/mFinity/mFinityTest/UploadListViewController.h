//
//  UploadListViewController.h
//  mFinity
//
//  Created by Park on 2014. 10. 8..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UploadListDelegate;

@interface UploadListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate>
@property (assign, nonatomic) id <UploadListDelegate>delegate;

@property (nonatomic, strong) NSMutableArray *uploadFilePathArray;
@property (nonatomic, strong) NSMutableArray *uploadUrlArray;
@property (nonatomic, assign) BOOL isBackTouch;

@property (nonatomic, assign) BOOL deleteFlag; //executeFileUpload 삭제 플래그

@end

@protocol UploadListDelegate <NSObject>
@optional
- (void)cancelButtonClicked2:(UploadListViewController *)secondDetailViewController;
- (void)errorButtonClicked2:(UploadListViewController *)secondDetailViewController;
- (void)leftButtonClicked2:(UploadListViewController *)secondDetailViewController :(NSMutableArray *)returnArr;
@end

