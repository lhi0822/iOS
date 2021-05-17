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
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSMutableArray *uploadFilePathArray;
@property (nonatomic, strong) NSMutableArray *uploadUrlArray;
@property (nonatomic, assign) BOOL isBackTouch;
@end

@protocol UploadListDelegate <NSObject>
@optional
- (void)cancelButtonClicked:(UploadListViewController *)secondDetailViewController;
@end