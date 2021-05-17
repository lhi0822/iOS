//
//  UploadProcessViewController.h
//  mFinity
//
//  Created by hilee on 30/11/2018.
//  Copyright © 2018 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UploadProcessViewDelegate;

@interface UploadProcessViewController : UIViewController <NSURLConnectionDataDelegate,UIAlertViewDelegate>

@property (assign, nonatomic) id <UploadProcessViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel;

@property (strong, nonatomic) NSMutableArray *dataArr;
@property (nonatomic, assign) BOOL deleteFlag; //executeFileUpload 삭제 플래그
@property (nonatomic, assign) NSString *uploadUrl;

@end

@protocol UploadProcessViewDelegate <NSObject>
@required
-(void)UploadProcessViewReturn :(NSString *)result :(NSMutableArray *)returnArr;
@optional

@end

