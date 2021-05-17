//
//  DownloadListViewController.h
//  downloadTest
//
//  Created by Park on 2014. 6. 25..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadListDelegate;

@interface DownloadListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate>
@property (assign, nonatomic) id <DownloadListDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSMutableArray *downloadMenuTitleList;
@property (nonatomic, strong) NSMutableArray *downloadVerArray;
@property (nonatomic, strong) NSMutableArray *downloadUrlArray;
@property (nonatomic, strong) NSMutableArray *downloadNoArray;
@property (nonatomic, assign) BOOL isBackTouch;
@end

@protocol DownloadListDelegate <NSObject>
@optional
- (void)cancelButtonClicked:(DownloadListViewController *)secondDetailViewController;
@end