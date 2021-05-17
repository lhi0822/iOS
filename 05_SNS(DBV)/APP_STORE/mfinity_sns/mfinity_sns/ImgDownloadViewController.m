//
//  ImgDownloadViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 20..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ImgDownloadViewController.h"
#import "JTSImageViewController.h"
#import "PostDetailViewController.h"
#import "NotiChatViewController.h"

#define BASEHEIGHT    300.0f
#define NPAGES        3

@interface ImgDownloadViewController () {
    CGFloat lastScale;
    AppDelegate *appDelegate;
    UIActivityIndicatorView *indicator;
}

@end

@implementation ImgDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    NSLog(@"fromSegue : %@", self.fromSegue);

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                            style:UIBarButtonItemStylePlain target:self action:@selector(leftSideMenuButtonPressed:)];
    
    //현중 저장 X
    if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"NONE"]){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save", @"save")
                                                                                 style:UIBarButtonItemStylePlain target:self action:@selector(rightSideMenuButtonPressed:)];
    } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save", @"save")
                                                                                 style:UIBarButtonItemStylePlain target:self action:@selector(rightSideMenuButtonPressed:)];
    } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"저장", @"저장")
//                                                                                 style:UIBarButtonItemStylePlain target:self action:@selector(rightSideMenuButtonPressed:)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(self.view.center.x, self.view.center.y-(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height));
    [indicator startAnimating];
    [self.view addSubview:indicator];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:self.writer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *originImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
        
        UIImageView *imageView = [[UIImageView alloc]initWithImage:originImage];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, _scrollView.frame.size.width, _scrollView.frame.size.height-(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height));
        
        [_scrollView setScrollEnabled:YES];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        
        _scrollView.contentSize = imageView.frame.size;
        [_scrollView addSubview:imageView];
        _imageView = imageView;
        
        [_scrollView setMaximumZoomScale:3.0f];
        [_scrollView setMinimumZoomScale:1.0f];
        
        [indicator stopAnimating];
    });
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)noti_NewPostPush:(NSNotification *)notification {
    if(notification.userInfo!=nil){
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
        
        NSString *message = [notification.userInfo objectForKey:@"MESSAGE"];
        NSDictionary *dict = [NSDictionary dictionary];
        if(message!=nil){
            NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        } else {
            dict = notification.userInfo;
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PostDetailViewController *vc = (PostDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        
        vc.fromSegue = @"NOTI_POST_DETAIL";
        vc.notiPostDic = dict;
        [self presentViewController:nav animated:YES completion:nil];
    }
    appDelegate.inactivePostPushInfo=nil;
}

- (void)noti_NewChatPush:(NSNotification *)notification {
    NSLog();
    appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
    
    if(notification.userInfo!=nil){
        NSString *message = [notification.userInfo objectForKey:@"MESSAGE"];
        NSString *noti = [notification.userInfo objectForKey:@"NOTI"];
        NSDictionary *dict = [NSDictionary dictionary];
        if(noti==nil){
            NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        } else {
            dict = notification.userInfo;
        }
        
        NSArray *dataSet = [dict objectForKey:@"DATASET"];
        NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
        
        NSString *sqlString = [appDelegate.dbHelper getRoomInfo:roomNo];
        NSMutableArray *roomChatArr = [appDelegate.dbHelper selectMutableArray:sqlString];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
        CGRect screen = [[UIScreen mainScreen]bounds];
        CGFloat screenWidth = screen.size.width;
        CGFloat screenHeight = screen.size.height;
        rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
        
        if(roomChatArr.count>0){
            NSString *roomNoti = [[roomChatArr objectAtIndex:0]objectForKey:@"ROOM_NOTI"];
            NSString *roomName = [NSString urlDecodeString:[[roomChatArr objectAtIndex:0]objectForKey:@"ROOM_NM"]];
            NSString *roomType = [[roomChatArr objectAtIndex:0]objectForKey:@"ROOM_TYPE"];
            
            if([roomType isEqualToString:@"0"]){
                NotiChatViewController *vc = (NotiChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
                
                vc.roomNo = roomNo;
                vc.roomNoti = roomNoti;
                vc.roomName = roomName;
                rightViewController.roomNo = roomNo;
                rightViewController.roomNoti = roomNoti;
                rightViewController.roomName = roomName;
                rightViewController.roomType = roomType;
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:vc leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:vc.roomName]];
                
                self.navigationController.navigationBar.topItem.title = @"";
                
                NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:roomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
                
                NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
                NSString *chatDetailClass = NSStringFromClass([vc class]);
                
                vc.fromSegue = @"NOTI_CHAT_DETAIL";
                
                if([currentClass isEqualToString:chatDetailClass]){
                    //send notification to postdetail and if noti postno equal current postno, not open modal
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatDetailView" object:nil userInfo:dict];
                    
                } else {
                    NSString *strClass = NSStringFromClass([self class]);
                    if([currentClass isEqualToString:strClass]){
                        CATransition* transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.type = kCATransitionMoveIn;
                        transition.subtype = kCATransitionFromTop;
                        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
                        [self.navigationController pushViewController:container animated:NO];
                    }
                }
                
            } else {
                ChatViewController *vc = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                vc.roomNo = roomNo;
                vc.roomNoti = roomNoti;
                vc.roomName = roomName;
                rightViewController.roomNo = roomNo;
                rightViewController.roomNoti = roomNoti;
                rightViewController.roomName = roomName;
                rightViewController.roomType = roomType;
                
                LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:vc leftViewController:nil rightViewController:rightViewController];
                [container setNavigationItemTitle:[NSString urlDecodeString:vc.roomName]];
                
                self.navigationController.navigationBar.topItem.title = @"";
                
                NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:roomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
                
                NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
                NSString *chatDetailClass = NSStringFromClass([vc class]);
                
                vc.fromSegue = @"NOTI_CHAT_DETAIL";
                vc.notiChatDic = dict;
                
                if([currentClass isEqualToString:chatDetailClass]){
                    //send notification to postdetail and if noti postno equal current postno, not open modal
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChatDetailView" object:nil userInfo:dict];
                } else {
                    NSString *strClass = NSStringFromClass([self class]);
                    if([currentClass isEqualToString:strClass]){
                        CATransition* transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.type = kCATransitionMoveIn;
                        transition.subtype = kCATransitionFromTop;
                        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
                        [self.navigationController pushViewController:container animated:NO];
                    }
                }
            }
        }
    }
    
    appDelegate.inactiveChatPushInfo=nil;
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    //NSLog(@"저장");
    UIImage *originImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.imgPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]]];
    UIImageWriteToSavedPhotosAlbum(originImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"save_failed", @"save_failed") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"save_succeed", @"save_succeed") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
