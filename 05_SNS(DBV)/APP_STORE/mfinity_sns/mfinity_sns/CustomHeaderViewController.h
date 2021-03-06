//
//  CustomHeaderViewController.h
//  ARSegmentPager
//
//  Created by August on 15/5/20.
//  Copyright (c) 2015年 August. All rights reserved.
//

#import "ARSegmentPageController.h"

#import "JTSImageViewController.h"
#import "MFURLSession.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "RightSideViewController.h"
#import "ChatListViewController.h"
#import "PostDetailViewController.h"
#import "MFDBHelper.h"

@class ARSegmentView;
@interface CustomHeaderViewController : ARSegmentPageController<MFURLSessionDelegate, UIScrollViewDelegate, MFMessageComposeViewControllerDelegate>

@property (strong,nonatomic) NSString *imageFileName;
@property (strong,nonatomic) NSString *bgImageFileName;
@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *phoneNo;
@property (strong,nonatomic) NSString *userID;
@property (strong,nonatomic) NSString *userNo;
@property (strong,nonatomic) NSString *statusMsg;
@property (strong,nonatomic) NSString *userType;

@property (strong,nonatomic) NSString *levelName;
@property (strong,nonatomic) NSString *deptName;
@property (strong,nonatomic) NSString *exCompName;


@property (strong,nonatomic) NSString *fromSegue;
@property (strong,nonatomic) NSString *chatRoomTy;

- (instancetype)initwithUserNo:(NSString *)userNo userType:(NSString *)userType;

@end
