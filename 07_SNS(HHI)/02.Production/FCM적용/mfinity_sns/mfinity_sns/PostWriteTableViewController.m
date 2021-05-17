//  PostWriteTableViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 10. 25..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "PostWriteTableViewController.h"
#import "PHLibListViewController.h"
#import "TeamListViewController.h"
#import "PostDetailViewController.h"
#import "SDImageCache.h"
#import "TextTableViewCell.h"
#import "ImageTableViewCell.h"
#import "VideoTableViewCell.h"
#import "FileTableViewCell.h"
#import "PostOrderModifyViewController.h"

@interface PostWriteTableViewController () {
    AppDelegate *appDelegate;
    
    NSMutableArray *dataArr;
    NSMutableArray *firstArr;
    
    float cursor;
    NSRange textRange;
    UITextView *currTextView;
    NSString *firstText;
    NSString *secondText;
    
    BOOL isSplit;
    BOOL isFirst;
    BOOL isSetScroll;
    
    int fileNameCnt;
    NSString *mediaType;
    NSMutableArray *contentFileArr;
    NSString *videoThumbName;
    
    NSMutableArray *convertFileArr;
    int setCount;
    NSMutableArray *resultArr;
    
    UIImage *thumbImage;
    SDImageCache *imgCache;
    
    NSTimeInterval duration;
    float progress;
    
    BOOL isKeyboardShow;
}

@property (strong, nonatomic) TextTableViewCell *textCell;
@property (strong, nonatomic) VideoTableViewCell *videoCell;

@end

@implementation PostWriteTableViewController
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSLog(@"fromSegue : %@", self.fromSegue);
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:self.snsName];
    
    if (self.navigationController.childViewControllers.count==1) {
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(leftSideMenuButtonPressed:)];
    }
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"done", @"done")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(rightSideMenuButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(leftBackButtonPressed:)];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    
    isSetScroll = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TeamExit:) name:@"noti_TeamExit" object:nil];
    
    UIButton *right1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [right1 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"menu_camera.png"] scaledToMaxWidth:35] forState:UIControlStateNormal];
    [right1 addTarget:self action:@selector(photo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc]initWithCustomView:right1];
    
    UIButton *right2 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [right2 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"menu_movie.png"] scaledToMaxWidth:35] forState:UIControlStateNormal];
    [right2 addTarget:self action:@selector(video:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn2 = [[UIBarButtonItem alloc]initWithCustomView:right2];
    
    UIButton *right3 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [right3 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"menu_file.png"] scaledToMaxWidth:35] forState:UIControlStateNormal];
    [right3 addTarget:self action:@selector(file:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn3 = [[UIBarButtonItem alloc]initWithCustomView:right3];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barButtonArr = [[NSArray alloc] initWithObjects:rightBtn1, flexibleSpace, rightBtn2, flexibleSpace, rightBtn3, flexibleSpace, flexibleSpace, flexibleSpace, flexibleSpace, flexibleSpace, flexibleSpace, flexibleSpace, flexibleSpace, flexibleSpace, flexibleSpace, nil];
    
    self.toolBar.items = barButtonArr;
    
    self.contentImageArray = [NSMutableArray array];
    self.filePathArray = [NSMutableArray array];
    self.fileNameArray = [NSMutableArray array];
    contentFileArr = [NSMutableArray array];
    convertFileArr = [NSMutableArray array];
    
    uploadCount = 0;
    cursor = 0;
    fileNameCnt = 0;
    
    isKeyboardShow = NO;
    isFirst = YES;
    mediaType = @"";
    
    imgCache = [SDImageCache sharedImageCache];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    [imgCache makeDiskCachePath:cachePath];
    
    @try{
        if([self.fromSegue isEqualToString:@"SHARE_POST_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]){
            NSUserDefaults *shareDefaults;
            NSArray *shareArr = [NSArray array];
            
            if([self.fromSegue isEqualToString:@"SHARE_POST_MODAL"]){
                //앨범->게시판 공유
                shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[MFSingleton sharedInstance] shareExtScheme]];
                shareArr = [shareDefaults objectForKey:@"SHARE_ITEM"];
                NSLog(@"defaults shared value1 : %@", [shareDefaults objectForKey:@"SHARE_ITEM"]);
                
            } else if([self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]){
                //채팅->게시판 공유
                shareArr = [appDelegate.appPrefs objectForKey:@"SHARE_ITEM_FROM_CHAT"];
                NSLog(@"defaults shared value2 : %@", [appDelegate.appPrefs objectForKey:@"SHARE_ITEM_FROM_CHAT"]);
            
            } else if([self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]){
                //게시판->게시판 공유
                shareArr = [appDelegate.appPrefs objectForKey:@"SHARE_ITEM_FROM_POST"];
                NSLog(@"defaults shared value3 : %@", [appDelegate.appPrefs objectForKey:@"SHARE_ITEM_FROM_POST"]);
            }
            
            dataArr = [NSMutableArray array];
            
            for(int i=0; i<shareArr.count; i++){
                NSString *type = [[shareArr objectAtIndex:i] objectForKey:@"TYPE"];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                if([type isEqualToString:@"TEXT"]){
                    [dict setObject:@"TEXT" forKey:@"TYPE"];
                    [dict setObject:[[shareArr objectAtIndex:i] objectForKey:@"VALUE"] forKey:@"VALUE"];
                    
                    if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                        [dict setObject:@"true" forKey:@"IS_SHARE"];
                    }
                    
                } else if([type isEqualToString:@"IMG"]){
                    NSData *value = [[shareArr objectAtIndex:i] objectForKey:@"VALUE"];
                    UIImage *image = [UIImage imageWithData:value];
                    UIImage *thumbImg = [MFUtil getScaledImage:image scaledToMaxWidth:self.view.frame.size.width-20];
                 
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    [dict setObject:thumbImg forKey:@"VALUE"];
                    [dict setObject:image forKey:@"ORIGIN"];
                    
                    if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                        [dict setObject:@"true" forKey:@"IS_SHARE"];
                        [dict setObject:[[shareArr objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
                    }
                    
                } else if([type isEqualToString:@"VIDEO"]){
                    NSData *videoData = [[shareArr objectAtIndex:i] objectForKey:@"VIDEO_DATA"];
                    NSData *data = [[shareArr objectAtIndex:i] objectForKey:@"VIDEO_THUMB"];
                    UIImage *image = [UIImage imageWithData:data];
                    UIImage *thumbImage = [MFUtil getScaledImage:image scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    [dict setObject:@"VIDEO" forKey:@"TYPE"];
                    [dict setObject:thumbImage forKey:@"VIDEO_THUMB"];
                    [dict setObject:videoData forKey:@"VIDEO_DATA"];
                    [dict setObject:image forKey:@"ORIGIN"];
                    
                    if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                        [dict setObject:@"true" forKey:@"IS_SHARE"];
                        [dict setObject:[[shareArr objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
                    }
                    
                } else if([type isEqualToString:@"FILE"]){
                    NSString *value = [[shareArr objectAtIndex:i] objectForKey:@"VALUE"];
                    value = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:value]];

                    [dict setObject:@"FILE" forKey:@"TYPE"];
                    [dict setObject:value forKey:@"VALUE"];
                    [dict setObject:data forKey:@"FILE_DATA"];
                    [dict setObject:[value lastPathComponent] forKey:@"FILE_NM"];
                    
                    if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                        [dict setObject:@"true" forKey:@"IS_SHARE"];
                        //[dict setObject:[[shareArr objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
                    }
                }
                
                [dataArr insertObject:dict atIndex:i];
            }
            
            if(![[[dataArr lastObject] objectForKey:@"TYPE"] isEqualToString:@"TEXT"]){
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"TEXT" forKey:@"TYPE"];
                [dict setObject:@"" forKey:@"VALUE"];
                [dataArr addObject:dict];
            }
            
            
            [self.tableView reloadData];
            
        } else {
            dataArr = [NSMutableArray array];
//            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//            [dict setObject:@"TEXT" forKey:@"TYPE"];
//            [dict setObject:@"" forKey:@"VALUE"];
//            [dataArr addObject:dict];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHandler:)];
    [self.tableView addGestureRecognizer:tap];
}

- (void)keyboardWillAnimate:(NSNotification *)notification{
    @try{
        CGRect keyboardBounds;
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
        NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        
        keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        NSDictionary* info = [notification userInfo];
        //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        if (@available(iOS 11.0, *)) {
            kbSize.height = kbSize.height - self.view.safeAreaInsets.bottom;
        } else {
            kbSize.height = kbSize.height;
        }
        
        if ([notification name]==UIKeyboardWillShowNotification) {
            NSLog(@"UIKeyboardWillShowNotification");
            isKeyboardShow = YES;
            self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"done", @"done")
                                                                                    style:UIBarButtonItemStylePlain
                                                                                   target:self
                                                                                   action:@selector(rightSideMenuButtonPressed:)];
            self.keyboardHeight.constant = kbSize.height;
            [self.view layoutIfNeeded];
            
        }else if([notification name]==UIKeyboardWillHideNotification){
            NSLog(@"UIKeyboardWillHideNotification");
            isKeyboardShow = NO;
            
            self.keyboardHeight.constant = 0;
            [self.view layoutIfNeeded];
            
        }
        [UIView commitAnimations];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UINavigationBar Button Action
- (void)leftSideMenuButtonPressed:(id)sender {
    NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[MFSingleton sharedInstance] shareExtScheme]];
    [shareDefaults removeObjectForKey:@"SHARE_ITEM"];
    [shareDefaults synchronize];
    
    [appDelegate.appPrefs removeObjectForKey:@"SHARE_ITEM_FROM_CHAT"];
    [appDelegate.appPrefs removeObjectForKey:@"SHARE_ITEM_FROM_POST"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftBackButtonPressed:(id)sender {
    @try{
        NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[MFSingleton sharedInstance] shareExtScheme]];
        [shareDefaults removeObjectForKey:@"SHARE_ITEM"];
        [shareDefaults synchronize];
        
        [appDelegate.appPrefs removeObjectForKey:@"SHARE_ITEM_FROM_CHAT"];
        [appDelegate.appPrefs removeObjectForKey:@"SHARE_ITEM_FROM_POST"];
        
        if(dataArr.count==1){
            NSString *type = [[dataArr objectAtIndex:0] objectForKey:@"TYPE"];
            NSString *value = [[dataArr objectAtIndex:0] objectForKey:@"VALUE"];
            
            if([type isEqualToString:@"TEXT"]&&[value isEqualToString:@""]){
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"post_save_cancel3", @"post_save_cancel3") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     
                                                                 }];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     if([self.fromSegue isEqualToString:@"POST_WRITE_PUSH"]||[self.fromSegue isEqualToString:@"BOARD_POST_WRITE_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_POST_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]){
                                                                         [self dismissViewControllerAnimated:YES completion:^{
                                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ShareViewClose" object:nil];
                                                                         }];
                                                                     } else{
                                                                         [self.navigationController popViewControllerAnimated:YES];
                                                                     }
                                                                 }];
                [alert addAction:cancelButton];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"post_save_cancel3", @"post_save_cancel3") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     
                                                                 }];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 
                                                                 if([self.fromSegue isEqualToString:@"POST_WRITE_PUSH"] || [self.fromSegue isEqualToString:@"BOARD_POST_WRITE_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_POST_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]){
                                                                     [self dismissViewControllerAnimated:YES completion:^{
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ShareViewClose" object:nil];
                                                                     }];
                                                                     
                                                                 } else{
                                                                     [self.navigationController popViewControllerAnimated:YES];
                                                                 }
                                                             }];
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)rightSideMenuButtonPressed:(id)sender {
    @try{
        [self.view endEditing:YES];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        NSLog(@"글쓰기 dataArr : %@", dataArr);
        
        int firstTxtCnt = 0;
        int firstImgCnt = 0;
        int firstFileCnt = 0;
        firstArr = [NSMutableArray array];
        
        int count = (int)dataArr.count;
        for(int i=0; i<count; i++){
            NSString *type = [[dataArr objectAtIndex:i] objectForKey:@"TYPE"];
            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
            
            if([type isEqualToString:@"TEXT"]){
                NSString *value = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
//                value = [MFUtil replaceEncodeToChar:value];
//                value = [value urlEncodeUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"value :%@", value);
                
                [dataDic setObject:@"TEXT" forKey:@"TYPE"];
                [dataDic setObject:value forKey:@"VALUE"];
                
                if([[dataArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                    [dataDic setObject:@"true" forKey:@"IS_SHARE"];
                }
                
                [dataArr replaceObjectAtIndex:i withObject:dataDic];
            
            } else if([type isEqualToString:@"IMG"]){
                UIImage *value = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
                
                [dataDic setObject:@"IMG" forKey:@"TYPE"];
                [dataDic setObject:value forKey:@"VALUE"];
                [dataDic setObject:[[dataArr objectAtIndex:i] objectForKey:@"ORIGIN"] forKey:@"ORIGIN"];
                
                if([[dataArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                    [dataDic setObject:@"true" forKey:@"IS_SHARE"];
                    [dataDic setObject:[[dataArr objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
                }
                
                [contentFileArr addObject:dataDic];
                
            } else if([type isEqualToString:@"VIDEO"]){
                if([[dataArr objectAtIndex:i] objectForKey:@"VIDEO_ASSET"]!=nil){
                    //앨범에서 가져온 비디오
                    PHAsset *value = [[dataArr objectAtIndex:i] objectForKey:@"VIDEO_ASSET"];
                    [dataDic setObject:@"VIDEO" forKey:@"TYPE"];
                    [dataDic setObject:value forKey:@"VIDEO_VALUE"];
                    [dataDic setObject:[[dataArr objectAtIndex:i] objectForKey:@"ORIGIN"] forKey:@"ORIGIN"];
                    [contentFileArr addObject:dataDic];
                    
                } else if([[dataArr objectAtIndex:i] objectForKey:@"RECORD_ASSET"]!=nil){
                    //촬영한 비디오
                    AVURLAsset *value = [[dataArr objectAtIndex:i] objectForKey:@"RECORD_ASSET"];
                                  
                    [dataDic setObject:@"VIDEO" forKey:@"TYPE"];
                    [dataDic setObject:value forKey:@"RECORD_VALUE"];
                    [dataDic setObject:[[dataArr objectAtIndex:i] objectForKey:@"ORIGIN"] forKey:@"ORIGIN"];
                    [contentFileArr addObject:dataDic];
                    
                } else if([[dataArr objectAtIndex:i] objectForKey:@"VIDEO_DATA"]!=nil){
                    NSData *value = [[dataArr objectAtIndex:i] objectForKey:@"VIDEO_DATA"];
                    UIImage *thumbImg = [[dataArr objectAtIndex:i] objectForKey:@"VIDEO_THUMB"];
                    
                    [dataDic setObject:@"VIDEO" forKey:@"TYPE"];
                    [dataDic setObject:value forKey:@"VIDEO_DATA"];
                    [dataDic setObject:thumbImg forKey:@"VIDEO_THUMB"];
                    [dataDic setObject:[[dataArr objectAtIndex:i] objectForKey:@"ORIGIN"] forKey:@"ORIGIN"];
                    
                    if([[dataArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                        [dataDic setObject:@"true" forKey:@"IS_SHARE"];
                        [dataDic setObject:[[dataArr objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
                    }
                    
                    [contentFileArr addObject:dataDic];
                }
            
            } else if([type isEqualToString:@"FILE"]){
                NSString *value = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
                NSData *data = [[dataArr objectAtIndex:i] objectForKey:@"FILE_DATA"];
                
                [dataDic setObject:@"FILE" forKey:@"TYPE"];
                [dataDic setObject:value forKey:@"VALUE"];
                [dataDic setObject:data forKey:@"FILE_DATA"];
                [dataDic setObject:[[dataArr objectAtIndex:i] objectForKey:@"FILE_NM"] forKey:@"FILE_NM"];
                
                if([[dataArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                    [dataDic setObject:@"true" forKey:@"IS_SHARE"];
                }
                
                [contentFileArr addObject:dataDic];
            }
            
            NSLog(@"dataArr : %@", dataArr);
            if([type isEqualToString:@"TEXT"]&&firstTxtCnt==0){
                NSString *prevStr = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
                
//                바이트자르기
//                NSUInteger textByte = [prevStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//                NSLog(@"textbyte : %lu", textByte);
//                if(textByte > 200) {
//                    NSData *contentData = [prevStr dataUsingEncoding:NSUTF8StringEncoding];
//                    contentData = [contentData subdataWithRange:NSMakeRange(0, 200)];
//                    prevStr = [[NSString alloc] initWithBytes:[contentData bytes] length:[contentData length] encoding:NSUTF8StringEncoding];
//                }
                
                if(prevStr.length > 200) {
                    prevStr = [prevStr substringWithRange:NSMakeRange(0, 200)];
                }
                
                NSDictionary *textDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"TEXT", @"TYPE", prevStr, @"VALUE", nil];
                [firstArr addObject:textDict];
                firstTxtCnt++;
                
            } else if(([type isEqualToString:@"IMG"]||[type isEqualToString:@"VIDEO"])&&firstImgCnt==0){
                [firstArr addObject:[dataArr objectAtIndex:i]];
                firstImgCnt++;
                
            } else if([type isEqualToString:@"FILE"]&&firstFileCnt==0){
                [firstArr addObject:[dataArr objectAtIndex:i]];
                firstFileCnt++;
            }
        }
        
        if(count==1){
            NSString *type = [[dataArr objectAtIndex:0] objectForKey:@"TYPE"];
            NSString *value = [[dataArr objectAtIndex:0] objectForKey:@"VALUE"];

            if([type isEqualToString:@"TEXT"]&&[value isEqualToString:@""]){
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"post_save_content_null", @"post_save_content_null") message:nil preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alert animated:YES completion:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
            } else {
//                self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save", @"save")
//                                                                                        style:UIBarButtonItemStylePlain
//                                                                                       target:self
//                                                                                       action:@selector(saveButtonPressed:)];
                [self saveButtonPressed:nil];
            }
        } else {
//            self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save", @"save")
//                                                                                 style:UIBarButtonItemStylePlain
//                                                                                target:self
//                                                                                action:@selector(saveButtonPressed:)];
            [self saveButtonPressed:nil];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)saveButtonPressed:(id)sender {
    @try{
//        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
//        [SVProgressHUD show];
        
        if(contentFileArr.count>0){
            [self convertDataSet:contentFileArr];
        } else {
            [self callWebService:@"getPostNo" WithParameter:nil];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - Post write
- (void)tapHandler:(UITapGestureRecognizer *)recognizer {
    NSLog();
    //텍스트 뷰 추가하기 위한 로직
    NSIndexPath *tapPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
    isSplit = NO;
    int count = (int)dataArr.count;
    
    @try {
        if(isKeyboardShow){
            NSLog(@"키보드 올라와있음");
            [self.view endEditing:YES];
            
            NSLog(@"show dataArr[cnt : %lu / tap : %ld] : %@", (unsigned long)dataArr.count, (long)tapPath.row, dataArr);
            
            if(count > 0){
                isFirst = NO;
                NSString *currDataType = [[dataArr objectAtIndex:tapPath.row] objectForKey:@"TYPE"];
                NSLog(@"currDataType : %@", currDataType);
                
                if(tapPath.row==0&&([currDataType isEqualToString:@"IMG"]||[currDataType isEqualToString:@"VIDEO"]||[currDataType isEqualToString:@"FILE"])){
                    NSLog(@"이미지 위에 텍스트 추가");
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"TEXT" forKey:@"TYPE"];
                    [dict setObject:@"" forKey:@"VALUE"];
                    [dataArr insertObject:dict atIndex:tapPath.row];
                    
                    [UIView performWithoutAnimation:^{
                        [self.tableView reloadData];
                    }];
                    
                } else {
                    //텍스트뷰 추가는 탭한 곳이 이미지고(이미지가 있는 로우의 하단 1/4정도라면), 다음 로우도 이미지 일때 (탭한 곳 밑에 추가)
                    //탭한 곳이 이미지고(이미지가 있는 로우의 상단단 1/4정도라면), 이전 로우도 이미지 일때 (탭한 곳 위에 추가)
                    //-> 이렇게 하지말고, 기준은 항상 뷰의 아래! 무조건 아래에 추가하는 걸로.
                    
                    NSLog(@"여기로 와야하는데");
                    if(count > 1 && count > tapPath.row+1){
                        NSString *nextDataType = [[dataArr objectAtIndex:tapPath.row+1] objectForKey:@"TYPE"];
                        NSLog(@"nextDataType : %@", nextDataType);
                        if(([currDataType isEqualToString:@"IMG"]&&[nextDataType isEqualToString:@"IMG"])
                           ||([currDataType isEqualToString:@"IMG"]&&[nextDataType isEqualToString:@"VIDEO"])
                           ||([currDataType isEqualToString:@"IMG"]&&[nextDataType isEqualToString:@"FILE"])
                           ||([currDataType isEqualToString:@"VIDEO"]&&[nextDataType isEqualToString:@"IMG"])
                           ||([currDataType isEqualToString:@"VIDEO"]&&[nextDataType isEqualToString:@"VIDEO"])
                           ||([currDataType isEqualToString:@"VIDEO"]&&[nextDataType isEqualToString:@"FILE"])
                           ||([currDataType isEqualToString:@"FILE"]&&[nextDataType isEqualToString:@"FILE"])
                           ||([currDataType isEqualToString:@"FILE"]&&[nextDataType isEqualToString:@"IMG"])
                           ||([currDataType isEqualToString:@"FILE"]&&[nextDataType isEqualToString:@"VIDEO"])){
                            
                            //                NSLog(@"1/4 : %f", [self.tableView rectForRowAtIndexPath:tapPath].size.height/4);
                            //                NSLog(@"y : %f", [self.tableView rectForRowAtIndexPath:tapPath].origin.y);
                            //                NSLog(@"recognize : %f", [recognizer locationInView:self.tableView].y);
                            
                            int rowY = [self.tableView rectForRowAtIndexPath:tapPath].origin.y;
                            int rowHeight = [self.tableView rectForRowAtIndexPath:tapPath].size.height;
                            int rowQuater = [self.tableView rectForRowAtIndexPath:tapPath].size.height/4;
                            int myPosition = [recognizer locationInView:self.tableView].y;
                            
                            int startLoc = rowY + rowHeight - rowQuater ;
                            int endLoc = startLoc + rowQuater;
                            
                            if(startLoc<=myPosition && myPosition<=endLoc){
                                NSLog(@"아래에 추가");
                                
                                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                [dict setObject:@"TEXT" forKey:@"TYPE"];
                                [dict setObject:@"" forKey:@"VALUE"];
                                [dataArr insertObject:dict atIndex:tapPath.row+1];
                                
                                isSetScroll = NO;
                                
                                [UIView performWithoutAnimation:^{
                                    [self.tableView reloadData];
                                }];
                                
                                //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                //                        //텍스트 추가한 곳에 스크롤을 두기 위해.
                                //                        NSIndexPath *lastCell = [NSIndexPath indexPathForItem:tapPath.row inSection:0];
                                //                        [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                                //                    });
                                
                            } else {
                                NSLog(@"가만히있으면 됨");
                                //근데 잘 안눌려서..
                            }
                        }
                        
                    } else {
                        NSLog(@"갯수가 한개까진 되는데..");
                        //윽 이 문제가 아닌가봐 그래도 죽네
                    }
                }
                
            } else {
                
            }
            
        } else {
            NSLog(@"키보드 내려가있음");
            NSLog(@"hide dataArr[cnt : %lu / tap : %ld] : %@", (unsigned long)dataArr.count, (long)tapPath.row, dataArr);
            if(count > 0){
                isFirst = NO;
                
                NSString *currDataType = [[dataArr objectAtIndex:tapPath.row] objectForKey:@"TYPE"];
                NSLog(@"currDataType : %@", currDataType);
                if([currDataType isEqualToString:@"TEXT"]){
                    UITextView *txtView = _textCell.textView;
                    [txtView becomeFirstResponder];
                }
                
                if(tapPath.row==0&&([currDataType isEqualToString:@"IMG"]||[currDataType isEqualToString:@"VIDEO"]||[currDataType isEqualToString:@"FILE"])){
                    NSLog(@"이미지 위에 텍스트 추가");
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"TEXT" forKey:@"TYPE"];
                    [dict setObject:@"" forKey:@"VALUE"];
                    [dataArr insertObject:dict atIndex:tapPath.row];
                    
                    [UIView performWithoutAnimation:^{
                        [self.tableView reloadData];
                    }];
                    
                } else {
                    //텍스트뷰 추가는 탭한 곳이 이미지고(이미지가 있는 로우의 하단 1/4정도라면), 다음 로우도 이미지 일때 (탭한 곳 밑에 추가)
                    //탭한 곳이 이미지고(이미지가 있는 로우의 상단단 1/4정도라면), 이전 로우도 이미지 일때 (탭한 곳 위에 추가)
                    //-> 이렇게 하지말고, 기준은 항상 뷰의 아래! 무조건 아래에 추가하는 걸로.
                    
                    if(count > 1){
                        NSString *nextDataType = [[dataArr objectAtIndex:tapPath.row+1] objectForKey:@"TYPE"];
                        if(([currDataType isEqualToString:@"IMG"]&&[nextDataType isEqualToString:@"IMG"])
                           ||([currDataType isEqualToString:@"IMG"]&&[nextDataType isEqualToString:@"VIDEO"])
                           ||([currDataType isEqualToString:@"IMG"]&&[nextDataType isEqualToString:@"FILE"])
                           ||([currDataType isEqualToString:@"VIDEO"]&&[nextDataType isEqualToString:@"IMG"])
                           ||([currDataType isEqualToString:@"VIDEO"]&&[nextDataType isEqualToString:@"VIDEO"])
                           ||([currDataType isEqualToString:@"VIDEO"]&&[nextDataType isEqualToString:@"FILE"])
                           ||([currDataType isEqualToString:@"FILE"]&&[nextDataType isEqualToString:@"FILE"])
                           ||([currDataType isEqualToString:@"FILE"]&&[nextDataType isEqualToString:@"IMG"])
                           ||([currDataType isEqualToString:@"FILE"]&&[nextDataType isEqualToString:@"VIDEO"])){
                            
                            //                NSLog(@"1/4 : %f", [self.tableView rectForRowAtIndexPath:tapPath].size.height/4);
                            //                NSLog(@"y : %f", [self.tableView rectForRowAtIndexPath:tapPath].origin.y);
                            //                NSLog(@"recognize : %f", [recognizer locationInView:self.tableView].y);
                            
                            int rowY = [self.tableView rectForRowAtIndexPath:tapPath].origin.y;
                            int rowHeight = [self.tableView rectForRowAtIndexPath:tapPath].size.height;
                            int rowQuater = [self.tableView rectForRowAtIndexPath:tapPath].size.height/4;
                            int myPosition = [recognizer locationInView:self.tableView].y;
                            
                            int startLoc = rowY + rowHeight - rowQuater ;
                            int endLoc = startLoc + rowQuater;
                            
                            if(startLoc<=myPosition && myPosition<=endLoc){
                                NSLog(@"아래에 추가");
                                
                                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                [dict setObject:@"TEXT" forKey:@"TYPE"];
                                [dict setObject:@"" forKey:@"VALUE"];
                                [dataArr insertObject:dict atIndex:tapPath.row+1];
                                
                                isSetScroll = NO;
                                
                                [UIView performWithoutAnimation:^{
                                    [self.tableView reloadData];
                                }];
                                
                                //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                //                        //텍스트 추가한 곳에 스크롤을 두기 위해.
                                //                        NSIndexPath *lastCell = [NSIndexPath indexPathForItem:tapPath.row inSection:0];
                                //                        [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                                //                    });
                                
                            } else {
                                NSLog(@"가만히있으면 됨");
                                //근데 잘 안눌려서..
                            }
                        }
                    }
                }
                
            
            } else {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"TEXT" forKey:@"TYPE"];
                [dict setObject:@"" forKey:@"VALUE"];
                [dataArr insertObject:dict atIndex:tapPath.row];
                
                isFirst = YES;
                
                [UIView performWithoutAnimation:^{
                    [self.tableView reloadData];
                }];
                
            }
        }
        
        /*
        if(dataArr.count > 0){
            NSString *currDataType = [[dataArr objectAtIndex:tapPath.row] objectForKey:@"TYPE"];
            
            if(tapPath.row==0&&([currDataType isEqualToString:@"IMG"]||[currDataType isEqualToString:@"VIDEO"]||[currDataType isEqualToString:@"FILE"])){
                NSLog(@"이미지 위에 텍스트 추가");
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"TEXT" forKey:@"TYPE"];
                [dict setObject:@"" forKey:@"VALUE"];
                [dataArr insertObject:dict atIndex:tapPath.row];
                
                isFirst = NO;
                
                [UIView performWithoutAnimation:^{
                    [self.tableView reloadData];
                }];
                
            } else {
                //텍스트뷰 추가는 탭한 곳이 이미지고(이미지가 있는 로우의 하단 1/4정도라면), 다음 로우도 이미지 일때 (탭한 곳 밑에 추가)
                //탭한 곳이 이미지고(이미지가 있는 로우의 상단단 1/4정도라면), 이전 로우도 이미지 일때 (탭한 곳 위에 추가)
                //-> 이렇게 하지말고, 기준은 항상 뷰의 아래! 무조건 아래에 추가하는 걸로.
                
                NSString *nextDataType = [[dataArr objectAtIndex:tapPath.row+1] objectForKey:@"TYPE"];
                if(([currDataType isEqualToString:@"IMG"]&&[nextDataType isEqualToString:@"IMG"])
                   ||([currDataType isEqualToString:@"IMG"]&&[nextDataType isEqualToString:@"VIDEO"])
                   ||([currDataType isEqualToString:@"IMG"]&&[nextDataType isEqualToString:@"FILE"])
                   ||([currDataType isEqualToString:@"VIDEO"]&&[nextDataType isEqualToString:@"IMG"])
                   ||([currDataType isEqualToString:@"VIDEO"]&&[nextDataType isEqualToString:@"VIDEO"])
                   ||([currDataType isEqualToString:@"VIDEO"]&&[nextDataType isEqualToString:@"FILE"])
                   ||([currDataType isEqualToString:@"FILE"]&&[nextDataType isEqualToString:@"FILE"])
                   ||([currDataType isEqualToString:@"FILE"]&&[nextDataType isEqualToString:@"IMG"])
                   ||([currDataType isEqualToString:@"FILE"]&&[nextDataType isEqualToString:@"VIDEO"])){
                    
                    //                NSLog(@"1/4 : %f", [self.tableView rectForRowAtIndexPath:tapPath].size.height/4);
                    //                NSLog(@"y : %f", [self.tableView rectForRowAtIndexPath:tapPath].origin.y);
                    //                NSLog(@"recognize : %f", [recognizer locationInView:self.tableView].y);
                    
                    int rowY = [self.tableView rectForRowAtIndexPath:tapPath].origin.y;
                    int rowHeight = [self.tableView rectForRowAtIndexPath:tapPath].size.height;
                    int rowQuater = [self.tableView rectForRowAtIndexPath:tapPath].size.height/4;
                    int myPosition = [recognizer locationInView:self.tableView].y;
                    
                    int startLoc = rowY + rowHeight - rowQuater ;
                    int endLoc = startLoc + rowQuater;
                    
                    if(startLoc<=myPosition && myPosition<=endLoc){
                        NSLog(@"아래에 추가");
                        
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [dict setObject:@"TEXT" forKey:@"TYPE"];
                        [dict setObject:@"" forKey:@"VALUE"];
                        [dataArr insertObject:dict atIndex:tapPath.row+1];
                        
                        isSetScroll = NO;
                        
                        [UIView performWithoutAnimation:^{
                            [self.tableView reloadData];
                        }];
                        
                        //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        //                        //텍스트 추가한 곳에 스크롤을 두기 위해.
                        //                        NSIndexPath *lastCell = [NSIndexPath indexPathForItem:tapPath.row inSection:0];
                        //                        [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        //                    });
                        
                    } else {
                        NSLog(@"가만히있으면 됨");
                        //근데 잘 안눌려서..
                    }
                }
            }
        } else {
//            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//            [dict setObject:@"TEXT" forKey:@"TYPE"];
//            [dict setObject:@"" forKey:@"VALUE"];
//            [dataArr insertObject:dict atIndex:tapPath.row];
//
//            isFirst = YES;
//
//            [UIView performWithoutAnimation:^{
//                [self.tableView reloadData];
//            }];
        }
        */
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)setImageFromNoti:(NSArray *)imgArr isAlbum:(BOOL)isAlbum {
    //이미지 추가하면 커서가 없어져서 어떤 텍스트뷰인지 모른다. isText값 불필요.
    //isText불필요하긴한데, 커서없을때 이미지 추가하면 마지막으로 텍스트 쓴 뷰 밑에 추가됨.(위에 텍스트뷰 있어도 삭제안됨)
    //사진 추가 하고 밑에 붙는 텍스트뷰에 자동으로 커서를 둬야할 것 같은데.. 어떻게 해야되지ㅠㅠ
    @try {
        isFirst = NO;
        
        if(currTextView==nil){
            NSLog(@"텍스트뷰 널! : %@", dataArr);
            [self addImageView:imgArr selectIndex:dataArr.count isSplit:NO isAlbum:isAlbum];
            
        } else {
            UITextRange *range = currTextView.selectedTextRange;
            UITextPosition *beginning = currTextView.beginningOfDocument;
            NSInteger location = [currTextView offsetFromPosition:beginning toPosition:range.start];
            NSInteger length = [currTextView offsetFromPosition:range.start toPosition:range.end];
            textRange = NSMakeRange(location, length);
            
            firstText = [currTextView.text substringToIndex:textRange.location];
            secondText = [currTextView.text substringFromIndex:textRange.location];
            
            NSLog(@"firstText : %@, secondText : %@", firstText, secondText);
            NSLog(@"location : %ld", (long)location);
            
            //firstText : , secondText : ㅇ ㄹㄹㄹㄹㄹ -> 텍스트 제일앞에 커서두고 이미지 추가했을때
            //그리고 로케이션은 0
            //텍스트를 쓰고 중간에 나눴을 때 second가 있고 안나눴을땐 없음
            
            if(location==0&&[secondText isEqualToString:@""]){
                //텍스트 아예 없을때, 텍스트 뷰 지우고 이미지뷰 추가
                NSLog(@"텍스트 아예 없을때 dataArr : %@", dataArr);
                NSLog(@"currTextView.tag : %ld", (long)currTextView.tag);

                [dataArr removeObjectAtIndex:currTextView.tag];
                [self addImageView:imgArr selectIndex:currTextView.tag isSplit:NO isAlbum:isAlbum];

                NSLog(@"지우고 난 후 dataArr : %@", dataArr);
                
                //문제점 : 로우 업데이트가 안됨. reload는 됨. 근데 reload하면 텍스트 써놓은게 없어짐. 위에 데이터를 공백으로 넣어서 그럼.
                //->완료
            } else if(location==0&&![secondText isEqualToString:@""]){
                NSLog(@"텍스트있고, 제일 앞에 커서 두고 이미지 등록했을 때 (텍스트뷰 위에 등록되어야함)");
                [self addImageView:imgArr selectIndex:currTextView.tag isAlbum:isAlbum];
                
            } else if(location!=0&&[secondText isEqualToString:@""]){
                NSLog(@"일반적으로 텍스트 썼을 때 currTextView.tag : %ld", (long)currTextView.tag);
                [self addImageView:imgArr selectIndex:currTextView.tag+1 isSplit:NO isAlbum:isAlbum];
                
            } else if(location!=0&&![secondText isEqualToString:@""]){
                //텍스트 중간에 커서 두고 이미지 눌렀을 때(텍스트 분리)
                NSLog(@"텍스트 중간에 커서 두고 이미지 눌렀을 때(텍스트 분리) currTextView.tag : %ld", (long)currTextView.tag);
                currTextView.text = firstText;
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"TEXT" forKey:@"TYPE"];
                [dict setObject:firstText forKey:@"VALUE"];
                [dataArr replaceObjectAtIndex:currTextView.tag withObject:dict];
                
                [self addImageView:imgArr selectIndex:currTextView.tag+1 isSplit:YES isAlbum:isAlbum];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
        
//        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"입력할 위치를 클릭하세요." preferredStyle:UIAlertControllerStyleAlert];
//        [self presentViewController:alert animated:YES completion:nil];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [alert dismissViewControllerAnimated:YES completion:nil];
//        });
    }
}

- (void)addImageView:(NSArray *)imgArr selectIndex:(NSInteger)index isAlbum:(BOOL)isAlbum {
    @try {
        NSLog(@"텍스트뷰 앞에 커서 두고 이미지 추가");
        
        int lastIdx = 0;
        if([mediaType isEqualToString:@"IMG"]){
            if(isAlbum){
                NSArray *imgList = [[imgArr objectAtIndex:0] objectForKey:@"IMG_LIST"];
                for(int i=0; i<imgList.count; i++){
                    UIImage *image = [MFUtil getScaledImage:[imgList objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    [dict setObject:image forKey:@"VALUE"];
                    [dict setObject:[imgList objectAtIndex:i] forKey:@"ORIGIN"];
                    
                    [dataArr insertObject:dict atIndex:index+i];
                    lastIdx = (int)index+i;
                }
            } else {
                for(int i=0; i<imgArr.count; i++){
                    UIImage *image = [MFUtil getScaledImage:[imgArr objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    [dict setObject:image forKey:@"VALUE"];
                    [dict setObject:[imgArr objectAtIndex:i] forKey:@"ORIGIN"];
                    
                    [dataArr insertObject:dict atIndex:index+i];
                    lastIdx = (int)index+i;
                }
            }
            
        } else if([mediaType isEqualToString:@"VIDEO"]){
            if(isAlbum){
                NSArray *assetList = [[imgArr objectAtIndex:0] objectForKey:@"ASSET_LIST"];
                NSArray *imgList = [[imgArr objectAtIndex:0] objectForKey:@"IMG_LIST"];
                
                for(int i=0; i<imgList.count; i++){
                    UIImage *image = [MFUtil getScaledImage:[imgList objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"VIDEO" forKey:@"TYPE"];
                    [dict setObject:image forKey:@"VALUE"];
                    [dict setObject:[imgList objectAtIndex:i] forKey:@"ORIGIN"];
                    [dict setObject:[assetList objectAtIndex:i] forKey:@"VIDEO_ASSET"];

                    [dataArr insertObject:dict atIndex:index+i];
                    lastIdx = (int)index+i;
                }
            } else {
                NSString *videoPath = [imgArr objectAtIndex:0];
                
                // 비디오 파일로 애셋 URL 만들기
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath] options:nil];
                
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                imageGenerator.appliesPreferredTrackTransform = YES;
                CMTime time = CMTimeMake(1, 1);
                CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                UIImage *originThumbnail = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                
                UIImage *thumbnail = [MFUtil getScaledImage:originThumbnail scaledToMaxWidth:self.tableView.frame.size.width-20];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"VIDEO" forKey:@"TYPE"];
                [dict setObject:thumbnail forKey:@"VALUE"];
                [dict setObject:originThumbnail forKey:@"ORIGIN"];
                [dict setObject:asset forKey:@"RECORD_ASSET"];
                
                [dataArr insertObject:dict atIndex:index];
                lastIdx = (int)index;
            }
            
        } else if([mediaType isEqualToString:@"FILE"]){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"FILE" forKey:@"TYPE"];
            [dict setObject:[[imgArr objectAtIndex:0] objectForKey:@"FILE_DATA"] forKey:@"FILE_DATA"];
            [dict setObject:[[imgArr objectAtIndex:0] objectForKey:@"VALUE"] forKey:@"VALUE"];
            [dict setObject:[[imgArr objectAtIndex:0] objectForKey:@"FILE_NM"] forKey:@"FILE_NM"];

            NSLog(@"인덱스 : %ld", (long)index);
            [dataArr insertObject:dict atIndex:index];
            lastIdx = (int)index;
        }
        
        [UIView performWithoutAnimation:^{
            [self.tableView reloadData];
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //이미지 추가한 곳에 스크롤을 두기 위해.
            if(index>0){
                NSIndexPath *lastCell = [NSIndexPath indexPathForItem:index inSection:0];
                [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        });
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)addImageView:(NSArray *)imgArr selectIndex:(NSInteger)index isSplit:(BOOL)isSplit isAlbum:(BOOL)isAlbum{
    @try {
        //텍스트뷰 앞에 커서두고 이미지 추가하면 텍스트 뷰 없어야 되는데.
        int lastIdx = 0;
        
        if([mediaType isEqualToString:@"IMG"]){
            if(isAlbum){
                NSArray *imgList = [[imgArr objectAtIndex:0] objectForKey:@"IMG_LIST"];
                for(int i=0; i<imgList.count; i++){
                    UIImage *image = [MFUtil getScaledImage:[imgList objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    [dict setObject:image forKey:@"VALUE"];
                    [dict setObject:[imgList objectAtIndex:i] forKey:@"ORIGIN"];
                    [dataArr insertObject:dict atIndex:index+i];
                    lastIdx = (int)index+i;
                }
            } else {
                for(int i=0; i<imgArr.count; i++){
                    UIImage *image = [MFUtil getScaledImage:[imgArr objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    [dict setObject:image forKey:@"VALUE"];
                    [dict setObject:[imgArr objectAtIndex:i] forKey:@"ORIGIN"];
                    [dataArr insertObject:dict atIndex:index+i];
                    lastIdx = (int)index+i;
                }
            }
            NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
            [dict2 setObject:@"TEXT" forKey:@"TYPE"];
            
            if(isSplit){
                [dict2 setObject:secondText forKey:@"VALUE"];
            } else {
                [dict2 setObject:@"" forKey:@"VALUE"];
            }
            [dataArr insertObject:dict2 atIndex:lastIdx+1];
            
        } else if([mediaType isEqualToString:@"VIDEO"]){
            if(isAlbum){
                NSArray *assetList = [[imgArr objectAtIndex:0] objectForKey:@"ASSET_LIST"];
                NSArray *imgList = [[imgArr objectAtIndex:0] objectForKey:@"IMG_LIST"];
                
                for(int i=0; i<imgList.count; i++){
                    UIImage *image = [MFUtil getScaledImage:[imgList objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"VIDEO" forKey:@"TYPE"];
                    [dict setObject:image forKey:@"VALUE"];
                    [dict setObject:[imgList objectAtIndex:i] forKey:@"ORIGIN"];
                    [dict setObject:[assetList objectAtIndex:i] forKey:@"VIDEO_ASSET"];
                    
                    [dataArr insertObject:dict atIndex:index+i];
                    lastIdx = (int)index+i;
                }
                NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                [dict2 setObject:@"TEXT" forKey:@"TYPE"];
                
                if(isSplit){
                    [dict2 setObject:secondText forKey:@"VALUE"];
                } else {
                    [dict2 setObject:@"" forKey:@"VALUE"];
                }
                [dataArr insertObject:dict2 atIndex:lastIdx+1];
                
            } else {
                NSString *videoPath = [imgArr objectAtIndex:0];
                
                // 비디오 파일로 애셋 URL 만들기
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath] options:nil];
                
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                imageGenerator.appliesPreferredTrackTransform = YES;
                CMTime time = CMTimeMake(1, 1);
                CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                UIImage *originThumbnail = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
                
                UIImage *thumbnail = [MFUtil getScaledImage:originThumbnail scaledToMaxWidth:self.tableView.frame.size.width-20];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"VIDEO" forKey:@"TYPE"];
                [dict setObject:thumbnail forKey:@"VALUE"];
                [dict setObject:originThumbnail forKey:@"ORIGIN"];
                [dict setObject:asset forKey:@"RECORD_ASSET"];
                
                [dataArr insertObject:dict atIndex:index];
                lastIdx = (int)index;
                
                NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                [dict2 setObject:@"TEXT" forKey:@"TYPE"];
                
                if(isSplit){
                    [dict2 setObject:secondText forKey:@"VALUE"];
                } else {
                    [dict2 setObject:@"" forKey:@"VALUE"];
                }
                [dataArr insertObject:dict2 atIndex:lastIdx+1];
            }
            
        } else if([mediaType isEqualToString:@"FILE"]){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"FILE" forKey:@"TYPE"];
            [dict setObject:[[imgArr objectAtIndex:0] objectForKey:@"FILE_DATA"] forKey:@"FILE_DATA"];
            [dict setObject:[[imgArr objectAtIndex:0] objectForKey:@"VALUE"] forKey:@"VALUE"];
            [dict setObject:[[imgArr objectAtIndex:0] objectForKey:@"FILE_NM"] forKey:@"FILE_NM"];
            
            [dataArr insertObject:dict atIndex:index];
            lastIdx = (int)index;
            
            NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
            [dict2 setObject:@"TEXT" forKey:@"TYPE"];
            
            if(isSplit){
                [dict2 setObject:secondText forKey:@"VALUE"];
            } else {
                [dict2 setObject:@"" forKey:@"VALUE"];
            }
            [dataArr insertObject:dict2 atIndex:lastIdx+1];
        }
        [UIView performWithoutAnimation:^{
            [self.tableView reloadData];
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //이미지 추가 후 생긴 텍스트에 스크롤을 두기 위해.
            //if(lastIdx>0){
                NSIndexPath *lastCell = [NSIndexPath indexPathForItem:lastIdx+1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            //}
        });
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)imgTapHandler:(UITapGestureRecognizer *)recognizer {
    @try {
        NSInteger index = recognizer.view.tag;
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *orderAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"post_content_order_title", @"post_content_order_title")
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action){
                                                                    [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                    
                                                                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                    PostOrderModifyViewController *vc = (PostOrderModifyViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostOrderModifyViewController"];
                                                                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                                                
                                                                    @try{
                                                                        vc.isEdit = NO;
                                                                        vc.contentArr = dataArr;
                                                                        
                                                                        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                                        [self presentViewController:nav animated:YES completion:^{
                                                                            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_PostOrderModify:) name:@"noti_PostOrderModify" object:nil];
                                                                        }];
                                                                    } @catch(NSException *exception){
                                                                        NSLog(@"Exception : %@", exception);
                                                                    }
                                                                    
                                                                }];
            [actionSheet addAction:orderAction];
        
        
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action){
                                                                 [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                 [self deleteImageClick:index];
                                                             }];
        [actionSheet addAction:deleteAction];
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action){
                                                                     [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            [actionSheet addAction:cancelAction];
            
            [actionSheet.popoverPresentationController setPermittedArrowDirections:0];
            CGRect rect = self.view.frame;
            rect.origin.x = (self.view.frame.size.width/2)-(actionSheet.view.frame.size.width/2);
            rect.origin.y = (self.view.frame.size.height/2)-(actionSheet.view.frame.size.height/2);
            actionSheet.popoverPresentationController.sourceView = self.view;
            actionSheet.popoverPresentationController.sourceRect = rect;
            
        } else {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action){
                                                                     [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            [actionSheet addAction:cancelAction];
        }
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)deleteImageClick:(NSInteger)index{
    NSLog(@"이미지 삭제 인덱스 : %ld", (long)index);
    
    @try {
        if(index!=0){
            NSLog(@"삭제 전 dataArr : %@", dataArr);
            NSString *prevType = [[dataArr objectAtIndex:index-1] objectForKey:@"TYPE"];
            NSString *nextType = [[dataArr objectAtIndex:index+1] objectForKey: @"TYPE"];
            
            if([prevType isEqualToString:@"TEXT"] && [nextType isEqualToString:@"TEXT"]){
                NSString *prevVal = [[dataArr objectAtIndex:index-1] objectForKey:@"VALUE"];
                NSString *nextVal = [[dataArr objectAtIndex:index+1] objectForKey:@"VALUE"];

                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"TEXT" forKey:@"TYPE"];

                if([nextVal isEqualToString:@""]){
                    [dict setObject:[NSString stringWithFormat:@"%@",prevVal] forKey:@"VALUE"];
                } else {
                    [dict setObject:[NSString stringWithFormat:@"%@\n%@",prevVal,nextVal] forKey:@"VALUE"];
                }

                [dataArr replaceObjectAtIndex:index-1 withObject:dict];
                [dataArr removeObjectAtIndex:index+1];
            }
        }
        
        NSLog(@"[dataArr index] : %@", [dataArr objectAtIndex:index]);
        [dataArr removeObjectAtIndex:index];
        NSLog(@"이미지지우고 dataArr : %@", dataArr);
        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
//        [self.tableView beginUpdates];
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        [self.tableView endUpdates];
        
        [UIView performWithoutAnimation:^{ //이걸 없애도 죽음ㅠ
            [self.tableView reloadData];
        }];
        
//        UIKeyboardWillHideNotification호출에서 isKeyboardShow 이거때문에 삭제 시 계속 에러남.. 아닌가
//        일단 저거 없고, 키보드 올라와있는 상태에서 삭제 시 안죽음
//        저거 없고, 키보드 내려간 상태에서 삭제 시 앱죽음
//        아니 왜 또 안죽어..
//        아니..또 안죽는다고ㅠㅠ -> 키보드 올라와있을때 삭제 시 죽는가..? -> 죽을때도있고 안죽을때도 있네..(안죽어ㅠㅠ 뭘까 왤까 왜 죽었던걸까)
//        키보드 내려간 상태에서 첫번째 이미지를 지우니까 죽음 -> 오 이렇게 하니까 또 죽음
//        [PostWriteTableViewController tapHandler:](L:572) currDataType : TEXT
//        [PostWriteTableViewController tapHandler:](L:591) 여기로 와야하는데
//        [PostWriteTableViewController tapHandler:](L:835) Exception : *** -[__NSArrayM objectAtIndex:]: index 5 beyond bounds [0 .. 4] -> 일단 여기에 대한 에러 처리는 했음
//        아 이 에러가 발생하면 앱이 죽는것같음 -> 어떻게 재현해야하지ㅠㅠ -> 오잉 에러발생안했는데도 죽어따;;

        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            //이미지 삭제한 곳에 스크롤을 두기 위해.
//            if(index>0){
//                NSIndexPath *lastCell = [NSIndexPath indexPathForItem:index-1 inSection:0];
//                [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//            }
//        });
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    @try{
//        TextTableViewCell *textCell = (TextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell"];
        _textCell = (TextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell"];
        ImageTableViewCell *imgCell = (ImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ImageTableViewCell"];
        _videoCell = (VideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"VideoTableViewCell"];
        FileTableViewCell *fileCell = (FileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FileTableViewCell"];
        
        if (_textCell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"TextTableViewCell" owner:self options:nil];
            
            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[TextTableViewCell class]]) {
                    _textCell = (TextTableViewCell *) currentObject;
                    [_textCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
        }
        
        if (imgCell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ImageTableViewCell" owner:self options:nil];
            
            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[ImageTableViewCell class]]) {
                    imgCell = (ImageTableViewCell *) currentObject;
                    [imgCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
        }
        
        if (_videoCell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"VideoTableViewCell" owner:self options:nil];
            
            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[VideoTableViewCell class]]) {
                    _videoCell = (VideoTableViewCell *) currentObject;
                    [_videoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
        }
        
        if (fileCell == nil) {
            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"FileTableViewCell" owner:self options:nil];
            
            for (id currentObject in topLevelObject) {
                if ([currentObject isKindOfClass:[FileTableViewCell class]]) {
                    fileCell = (FileTableViewCell *) currentObject;
                    [fileCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
            }
        }
        
        
        NSString *type = [[dataArr objectAtIndex:indexPath.row] objectForKey:@"TYPE"];
        if([type isEqualToString:@"TEXT"]){
//            _textCell.backgroundColor = [UIColor yellowColor];
            
            _textCell.textView.text = nil;
            [self setTextView:_textCell.textView];
            
            NSString *textValue = [[dataArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
            _textCell.textView.delegate = self;
            _textCell.textView.tag = indexPath.row;
            _textCell.textView.text = textValue;
            
            if(isFirst==YES && [textValue isEqualToString:@""]){
                NSLog(@"첫입장임 키보드 띄우기");
                [_textCell.textView becomeFirstResponder];
////                isKeyboardShow = YES;
            }
            
            /*
            textCell.textView.text = nil;
            
            [self setTextView:textCell.textView];
            
            NSString *textValue = [[dataArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
//            NSLog(@"TEXT VAL : %@", textValue);
            
            textCell.textView.delegate = self;
            textCell.textView.tag = indexPath.row;
            textCell.textView.text = textValue;
            
//            NSMutableDictionary *dict = [dataArr objectAtIndex:indexPath.row];
//            [dataArr replaceObjectAtIndex:indexPath.row withObject:dict];
            
            
            if(indexPath.row==0){
                if(isFirst){
//                    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(textCell.textView.frame.origin.x, textCell.textView.frame.origin.y, textCell.textView.frame.size.width, textCell.textView.frame.size.height)];
//                    NSMutableAttributedString *placeholderAttributedString = [[NSMutableAttributedString alloc] initWithString:@"글을 입력하세요."];
//                    [placeholderAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [placeholderAttributedString length])];
//                    textField.attributedPlaceholder = placeholderAttributedString;
//                    [textCell addSubview:textField];
                    
                    //textCell.textView.placeholder = @"글을 입력하세요.";
                    [textCell.textView becomeFirstResponder];
                    isFirst = NO;
                }
            } else {
                //textCell.textView.placeholder = nil;
            }
             */
             
            return _textCell;
            
            //사진등록하고 아래쪽 탭 하면 텍스트뷰에 커서 및 키보드 올라오게 할 수 없을까!
            //사진 사이에 텍스트 뷰 누르면 텍스트 추가되고 키보드 올라오게!!!
            //->방법이 없네ㅠ
            
        } else if([type isEqualToString:@"IMG"]){
            imgCell.imgView.image = nil;
            
            UIImage *imgValue = [[dataArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
            [imgCell.imgView setUserInteractionEnabled:YES];
            imgCell.imgView.image = imgValue;
            imgCell.imgView.tag = indexPath.row;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapHandler:)];
            [imgCell.imgView addGestureRecognizer:tap];
            
            return imgCell;
            
        } else if([type isEqualToString:@"VIDEO"]){
            _videoCell.compressView.hidden = YES;
            _videoCell.videoView.image = nil;
            
            UIImage *imgValue;
            if([[dataArr objectAtIndex:indexPath.row] objectForKey:@"VIDEO_DATA"]!=nil){
                imgValue = [[dataArr objectAtIndex:indexPath.row] objectForKey:@"VIDEO_THUMB"];
            } else {
                imgValue = [[dataArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
            }
            
            [_videoCell.videoTmpView setUserInteractionEnabled:YES];
            _videoCell.videoView.image = imgValue;
            _videoCell.videoTmpView.tag = indexPath.row;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapHandler:)];
            [_videoCell.videoTmpView addGestureRecognizer:tap];
            
            return _videoCell;
        
        } else if([type isEqualToString:@"FILE"]){
            fileCell.fileButton.gestureRecognizers = nil;
            fileCell.fileButton.tag = indexPath.row;
            
            NSLog(@"DATAARR : %@", dataArr);
            
            NSString *value = [NSString urlDecodeString:[[dataArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"]];
            
            NSString *fileName = @"";
            @try{
                fileName = [value lastPathComponent];
                
            } @catch (NSException *exception) {
                fileName = value;
                NSLog(@"Exception : %@", exception);
            }
            [fileCell.fileButton setTitle:fileName forState:UIControlStateNormal];
            
            NSRange range = [value rangeOfString:@"." options:NSBackwardsSearch];
            NSString *fileExt = [[value substringFromIndex:range.location+1] lowercaseString];
            
            if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_img.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_movie.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_music.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"psd"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_psd.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"ai"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_ai.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_word.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_ppt.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_excel.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"pdf"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_pdf.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"txt"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_txt.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"hwp"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_hwp.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_zip.png"] forState:UIControlStateNormal];
                
            } else {
                [fileCell.fileButton setImage:[UIImage imageNamed:@"file_document.png"] forState:UIControlStateNormal];
            }
            
            fileCell.fileButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [fileCell.fileButton setImageEdgeInsets:UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0)];
            [fileCell.fileButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -5.0, 0.0, 0.0)];
            
            return fileCell;
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    return nil;
}

-(void)setTextView:(UITextView *)textView {
    @try {
        //NSLog(@"setTextView tag : %ld", (long)textView.tag);
        CGFloat fixedWidth = textView.frame.size.width;
        CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = textView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        textView.frame = newFrame;
        textView.scrollEnabled = NO;
        
//        if(isSetScroll){
//            int height = self.tableView.contentSize.height-_keyboardHeight.constant-self.tableView.contentOffset.y;
//            if(height<50 && height>-50){
//
//            int height1 = self.tableView.contentSize.height-_keyboardHeight.constant-self.tableView.contentOffset.y;
//            int height2 = self.tableView.frame.size.height-_keyboardHeight.constant;
//
//            if((height1-height2)>-10&&(height1-height2)<20){
//                NSLog(@"스크롤이 하단에 있다");
                //스크롤이 하단에 있을 때만. 텍스트뷰에 맞춰서 스크롤을 내려주기 위해.
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    NSIndexPath *lastCell = [NSIndexPath indexPathForItem:(dataArr.count-1) inSection:0];
//                    [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//                });
//            }
//        }
        
        [UIView performWithoutAnimation:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - TextView Delegate
-(void)textViewDidChange:(UITextView *)textView{
    @try {
        currTextView = textView;
        
        //텍스트 뷰 커서에 따라 스크롤 위치 변경해주기 위해.
        NSIndexPath *currentCell = [NSIndexPath indexPathForItem:textView.tag inSection:0];
        CGPoint cursorPosition2 = [textView caretRectForPosition:textView.selectedTextRange.start].origin;
        //NSLog(@"결론 스크롤 위치 : %f", cursorPosition2.y+[self.tableView rectForRowAtIndexPath:currentCell].origin.y);
        float scrollPosition = cursorPosition2.y+[self.tableView rectForRowAtIndexPath:currentCell].origin.y+35;
        [self.tableView scrollRectToVisible:CGRectMake(0, scrollPosition, 1, 1) animated:NO];
        
        //텍스트를 입력할때마다 데이터 변경.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"TEXT" forKey:@"TYPE"];
        [dict setObject:textView.text forKey:@"VALUE"];
        [dataArr replaceObjectAtIndex:textView.tag withObject:dict];
        
        [self setTextView:textView];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    currTextView = textView;
    isSetScroll = YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    int isBackSpace = strcmp(_char, "\b");
    
    if(isBackSpace == -8){//백스페이스
        if(dataArr.count>2){
            if([textView.text isEqualToString:@""]){
                //텍스트 없으면 텍스트뷰를 지우는데
                //이미지와 이미지 사이에 있는 텍스트 일 때 만 지운다.
                NSLog(@"텍스트 없음! 그리고 텍스트 뷰 태그는 : %ld", (long)textView.tag);
                
                @try{
                    NSString *type = [[dataArr objectAtIndex:textView.tag] objectForKey:@"TYPE"];
                    NSString *type2 = [[dataArr objectAtIndex:textView.tag-1] objectForKey:@"TYPE"];
                    NSString *type3 = [[dataArr objectAtIndex:textView.tag+1] objectForKey:@"TYPE"];
                    //NSLog(@"type : %@, type2 : %@, type3 : %@", type, type2, type3);
                    
                    if((textView.tag==0&&[type isEqualToString:@"TEXT"])
                       ||([type2 isEqualToString:@"IMG"]&&[type3 isEqualToString:@"IMG"])
                       ||([type2 isEqualToString:@"IMG"]&&[type3 isEqualToString:@"VIDEO"])
                       ||([type2 isEqualToString:@"IMG"]&&[type3 isEqualToString:@"FILE"])
                       ||([type2 isEqualToString:@"VIDEO"]&&[type3 isEqualToString:@"IMG"])
                       ||([type2 isEqualToString:@"VIDEO"]&&[type3 isEqualToString:@"VIDEO"])
                       ||([type2 isEqualToString:@"VIDEO"]&&[type3 isEqualToString:@"FILE"])
                       ||([type2 isEqualToString:@"FILE"]&&[type3 isEqualToString:@"FILE"])
                       ||([type2 isEqualToString:@"FILE"]&&[type3 isEqualToString:@"IMG"])
                       ||([type2 isEqualToString:@"FILE"]&&[type3 isEqualToString:@"VIDEO"])){
                        
                        NSLog(@"위아래 이미지/동영상 일 때 텍스트 지워야지");
                        
                        [dataArr removeObjectAtIndex:textView.tag];
                        
                        [UIView performWithoutAnimation:^{
                            [self.tableView reloadData];
                        }];
                        
                        if(self.tableView.contentSize.height > self.tableView.frame.size.height){
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                //텍스트 삭제한 곳에 스크롤을 두기 위해.
                                NSIndexPath *lastCell = [NSIndexPath indexPathForItem:textView.tag inSection:0];
                                [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                            });
                        }
                    }
                } @catch(NSException* exception){
                    NSLog(@"Exception : %@", exception);
                    
                    NSString *type = [[dataArr objectAtIndex:textView.tag] objectForKey:@"TYPE"];
                    if(textView.tag==0&&[type isEqualToString:@"TEXT"]){
                        [dataArr removeObjectAtIndex:textView.tag];
                        NSLog(@"22텍스트지우고 dataArr : %@", dataArr);
                        [UIView performWithoutAnimation:^{
                            [self.tableView reloadData];
                        }];
                    }
                }
            }
        }
    }
    return YES;
}

#pragma mark - ScrollView
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //스크롤 시 여기로 들어옴
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //키보드 내려간 상태에서 텍스트 뷰(마지막에 있는 텍스트뷰) 클릭하면 여기로 들어옴(키보드 올라온것만큼 뷰 올리기 위해)
}

#pragma mark - UIToolbar Button Action
- (IBAction)photo:(id)sender{
    @try {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"popup_camera1", @"popup_camera1")
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action){
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
                if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                        [alert dismissViewControllerAnimated:YES completion:nil];
                        
                        [AccessAuthCheck cameraAccessCheckNotAuth:^(BOOL status) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(status==YES){
                                    self.picker = [[UIImagePickerController alloc] init];
                                    self.picker.delegate = self;
                                    
                                    self.picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
                                    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                    self.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
                                    self.picker.videoMaximumDuration = 60.0f; //최대촬영시간설정
                                    
                                    self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                                    [self presentViewController:self.picker animated:YES completion:nil];
                                }
                            });
                        }];
                        
                    }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                } else {
                    [AccessAuthCheck cameraAccessCheckNotAuth:^(BOOL status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(status==YES){
                                self.picker = [[UIImagePickerController alloc] init];
                                self.picker.delegate = self;
                                
                                self.picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
                                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                self.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
                                self.picker.videoMaximumDuration = 60.0f; //최대촬영시간설정
                                
                                self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                                [[MFUtil topViewController] presentViewController:self.picker animated:YES completion:nil];
                            }
                        });
                    }];
                }
                
//                if([AccessAuthCheck cameraAccessCheck]){
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        //UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
//                        self.picker = [[UIImagePickerController alloc] init];
//                        self.picker.delegate = self;
//
//                        self.picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
//                        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//                        self.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
//                        self.picker.videoMaximumDuration = 60.0f; //최대촬영시간설정
//
//                        self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
//                        //[top presentViewController:self.picker animated:YES completion:nil];
//                        [[MFUtil topViewController] presentViewController:self.picker animated:YES completion:nil];
//                    });
//                }
                
            } else {
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
        UIAlertAction *selectPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"popup_camera2", @"popup_camera2")
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action){
            mediaType = @"IMG";
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
            if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    
                    [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(status==YES) [self performSegueWithIdentifier:@"POST_PHLIB_MODAL" sender:@"PHOTO"];
                        });
                    }];
                    
                }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES) [self performSegueWithIdentifier:@"POST_PHLIB_MODAL" sender:@"PHOTO"];
                    });
                }];
            }
            
//            if([AccessAuthCheck photoAccessCheck]){
//                [self performSegueWithIdentifier:@"POST_PHLIB_MODAL" sender:@"PHOTO"];
//            }
            
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        [actionSheet addAction:takePictureAction];
        [actionSheet addAction:selectPhotoAction];
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action){
                mediaType = @"";
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
            }];
            [actionSheet addAction:cancelAction];
            
            [actionSheet.popoverPresentationController setPermittedArrowDirections:0];
            CGRect rect = self.view.frame;
            rect.origin.x = (self.view.frame.size.width/2)-(actionSheet.view.frame.size.width/2);
            rect.origin.y = (self.view.frame.size.height/2)-(actionSheet.view.frame.size.height/2);
            actionSheet.popoverPresentationController.sourceView = self.view;
            actionSheet.popoverPresentationController.sourceRect = rect;
        } else {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action){
                mediaType = @"";
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
            }];
            [actionSheet addAction:cancelAction];
        }
        
        [self presentViewController:actionSheet animated:YES completion:nil];
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (IBAction)video:(id)sender{
    @try {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"동영상 촬영", @"동영상 촬영")
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action){
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
                if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                        [alert dismissViewControllerAnimated:YES completion:nil];
                        
                        [AccessAuthCheck cameraAccessCheckNotAuth:^(BOOL status) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(status==YES){
                                    self.picker = [[UIImagePickerController alloc] init];
                                    self.picker.delegate = self;
                                    
                                    self.picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
                                    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                    self.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
                                    self.picker.videoMaximumDuration = 60.0f; //최대촬영시간설정
                                    
                                    self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                                    [self presentViewController:self.picker animated:YES completion:nil];
                                }
                            });
                        }];
                        
                    }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                } else {
                    [AccessAuthCheck cameraAccessCheckNotAuth:^(BOOL status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(status==YES){
                                self.picker = [[UIImagePickerController alloc] init];
                                self.picker.delegate = self;
                                
                                self.picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
                                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                self.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
                                self.picker.videoMaximumDuration = 60.0f; //최대촬영시간설정
                                
                                self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                                [[MFUtil topViewController] presentViewController:self.picker animated:YES completion:nil];
                            }
                        });
                    }];
                }
                
//                if([AccessAuthCheck cameraAccessCheck]){
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
//                        self.picker = [[UIImagePickerController alloc] init];
//                        self.picker.delegate = self;
//
//                        self.picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
//                        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//                        self.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
//                        self.picker.videoMaximumDuration = 60.0f; //최대촬영시간설정
//
//                        self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
//                        [top presentViewController:self.picker animated:YES completion:nil];
//                    });
//                }
                
            }else{
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        UIAlertAction *selectPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"동영상 선택", @"동영상 선택")
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action){
            mediaType = @"VIDEO";
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
            if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    
                    [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(status==YES) [self performSegueWithIdentifier:@"POST_PHLIB_MODAL" sender:@"VIDEO"];
                        });
                    }];
                }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES) [self performSegueWithIdentifier:@"POST_PHLIB_MODAL" sender:@"VIDEO"];
                    });
                }];
            }
            
//            if([AccessAuthCheck photoAccessCheck]){
//                [self performSegueWithIdentifier:@"POST_PHLIB_MODAL" sender:@"VIDEO"];
//            }
            
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        [actionSheet addAction:takePictureAction];
        [actionSheet addAction:selectPhotoAction];
        
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action){
                mediaType = @"";
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
            }];
            [actionSheet addAction:cancelAction];
            
            [actionSheet.popoverPresentationController setPermittedArrowDirections:0];
            CGRect rect = self.view.frame;
            rect.origin.x = (self.view.frame.size.width/2)-(actionSheet.view.frame.size.width/2);
            rect.origin.y = (self.view.frame.size.height/2)-(actionSheet.view.frame.size.height/2);
            actionSheet.popoverPresentationController.sourceView = self.view;
            actionSheet.popoverPresentationController.sourceRect = rect;
        } else {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action){
                mediaType = @"";
                [actionSheet dismissViewControllerAnimated:YES completion:nil];
            }];
            [actionSheet addAction:cancelAction];
        }
        
        [self presentViewController:actionSheet animated:YES completion:nil];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)file:(id)sender{
    NSArray *types = [[NSArray alloc] initWithObjects:@"public.data", nil];
    self.docPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
    self.docPicker.delegate = self;
    if (@available(iOS 11.0, *)) {
      self.docPicker.allowsMultipleSelection = NO;
    } else {
      // Fallback on earlier versions
    }

    self.docPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.docPicker animated:YES completion:nil];
}

- (void)getImageNotification:(NSNotification *)notification {
    @try {
        NSArray *imageArray = [[NSArray alloc] initWithObjects:notification.userInfo, nil];
        
        NSArray *imgList = [[imageArray objectAtIndex:0] objectForKey:@"IMG_LIST"];
        if(imgList.count==1&&[mediaType isEqualToString:@"IMG"]){
            self.croppingStyle = TOCropViewCroppingStyleDefault;
            TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:[imgList objectAtIndex:0]];
            cropController.delegate = self;
            self.image = [imgList objectAtIndex:0];
            [self presentViewController:cropController animated:YES completion:nil];
            
        } else {
            [self setImageFromNoti:imageArray isAlbum:YES];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getImageNotification" object:nil];
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}


#pragma mark - UIImagePickerController Delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
        NSURL *mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"NONE"]){
            UISaveVideoAtPathToSavedPhotosAlbum([mediaUrl path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
            UISaveVideoAtPathToSavedPhotosAlbum([mediaUrl path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
            [self video:mediaUrl.absoluteString didFinishSavingWithError:nil contextInfo:nil];
        }
        
    } else{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        //현중 촬영이미지 저장 X
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"NONE"]){
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
            [self image:image didFinishSavingWithError:nil contextInfo:nil];
        }
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        @try{
            mediaType = @"VIDEO";
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];
            
            NSArray *assetArr = [[NSArray alloc] initWithObjects:asset, nil];
            NSArray *imgArr = [[NSArray alloc] initWithObjects:@"NONE", nil];
            
            NSMutableDictionary *assetDict = [NSMutableDictionary dictionary];
            [assetDict setObject:assetArr forKey:@"ASSET_LIST"];
            [assetDict setObject:imgArr forKey:@"IMG_LIST"];
            
            NSArray *videoArray = [[NSArray alloc] initWithObjects:videoPath, nil];
            [self setImageFromNoti:videoArray isAlbum:NO];
            
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        mediaType = @"IMG";
        
        self.croppingStyle = TOCropViewCroppingStyleDefault;
        TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:image];
        cropController.delegate = self;
        self.image = image;
        [self presentViewController:cropController animated:YES completion:nil];
    }
}

#pragma mark - UIDocumentPickerController Delegate
-(void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url{
    mediaType = @"FILE";

    NSData *data = [NSData dataWithContentsOfURL:url];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"FILE" forKey:@"TYPE"];
    [dict setObject:[NSString urlDecodeString:url.absoluteString] forKey:@"VALUE"];
    [dict setObject:data forKey:@"FILE_DATA"];
    [dict setObject:[NSString urlDecodeString:[url.absoluteString lastPathComponent]] forKey:@"FILE_NM"];
    [dict setObject:@"false" forKey:@"IS_SHARE"];

    NSArray *fileArray = [[NSArray alloc] initWithObjects:dict, nil];
    [self setImageFromNoti:fileArray isAlbum:NO];
}
-(void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
   NSLog();
}

#pragma mark - Cropper Delegate
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.croppedFrame = cropRect;
    self.angle = angle;
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToCircularImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.croppedFrame = cropRect;
    self.angle = angle;
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}

- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController
{
    if (image!=nil) {
        if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {
            [cropViewController dismissAnimatedFromParentViewController:self
                                                       withCroppedImage:image
                                                                 toView:nil
                                                                toFrame:CGRectZero
                                                                  setup:^{}
                                                             completion:^{
                                                                 NSArray *imageArray = [[NSArray alloc] initWithObjects:image, nil];
                                                                 [self setImageFromNoti:imageArray isAlbum:NO];
                                                             }];
        }
        
    }
}


#pragma mark - Notification
- (void)noti_NewPostPush:(NSNotification *)notification {
    @try{
        if(notification.userInfo!=nil){
            appDelegate.toolBarBtnTitle = @"등록";
            
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
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    appDelegate.inactivePostPushInfo=nil;
}

- (void)noti_TeamExit:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamSelectExit" object:nil];
    }];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_TeamExit" object:nil];
}

- (void)noti_PostOrderModify:(NSNotification *)notification {
    NSLog();
    
    NSArray *dataSetArr = [notification.userInfo objectForKey:@"DATASET"];
//    NSLog(@"PostOrderModify dataArr : %@", dataSetArr);
    
    self.filePathArray = [NSMutableArray array];
    self.contentImageArray = [NSMutableArray array];
    dataArr = [NSMutableArray array];
    uploadCount = 0;

    [dataArr setArray:dataSetArr];
    
    NSLog(@"dataArr : %@", dataArr);
    
    [SVProgressHUD show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

//    [UIView performWithoutAnimation:^{
//        [self.tableView reloadData];
//    }];
    
    NSIndexPath *lastCell = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_PostOrderModify" object:nil];
    
    [SVProgressHUD dismiss];
}

#pragma mark - Web Service
- (void)callWebService:(NSString *)serviceName WithParameter:(NSString *)paramString{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
}
- (NSString *)createFileName :(NSString *)filetype{
    @try{
        NSString *fileExt = @"";
        if([filetype isEqualToString:@"IMG"]) fileExt = @"png";
        else if([filetype isEqualToString:@"VIDEO"]) fileExt = @"mp4";
        
        NSString *fileName = nil;
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd-HHmmssSSS"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        fileName = [NSString stringWithFormat:@"%@.%@",currentTime,fileExt];
        return fileName;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)sessionFileUpload :(NSString *)urlString :(NSMutableDictionary *)sendFileParam :(NSData *)data :(NSString *)fileName{
    MFURLSessionUpload *sessionUpload = [[MFURLSessionUpload alloc]initWithURL:[NSURL URLWithString:urlString] option:sendFileParam WithData:data AndFileName:fileName];
    sessionUpload.delegate = self;
    if ([sessionUpload start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

#pragma mark
#pragma mark - 파일압축
-(void)videoCompessToPercent:(float)progress{
    @try{
        dispatch_async(dispatch_get_main_queue(), ^{
            _videoCell.compressView.hidden = NO;

//            [_videoCell.compressView setPrimaryColor:[MFUtil myRGBfromHex:@"0093D5"]];
            [_videoCell.compressView setPrimaryColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
            [_videoCell.compressView setProgress:progress animated: YES];
       });

    } @catch (NSException *exception) {
       NSLog(@"Exception : %@", exception);
    }
}

-(void)convertDataSet:(NSMutableArray *)array{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD show];
    
    @try{
        setCount = 0;
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
        
        NSUInteger count = array.count;
        
        for(int i=0; i<(int)count; i++){
            NSMutableDictionary *obj = [NSMutableDictionary dictionary];
            
            NSString *type = [[array objectAtIndex:i] objectForKey:@"TYPE"];
            if([type isEqualToString:@"IMG"]){
                [obj setObject:@"IMG" forKey:@"TYPE"];
                [obj setObject:[[array objectAtIndex:i] objectForKey:@"ORIGIN"] forKey:@"VALUE"];
                
                if([[array objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                    [obj setObject:@"true" forKey:@"IS_SHARE"];
                    [obj setObject:[[array objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
                }
                
                [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
                
                setCount++;
                if(setCount==count) [self dataConvertFinished:tmpDict];
                
            } else if([type isEqualToString:@"VIDEO"]){
                if([[array objectAtIndex:i] objectForKey:@"VIDEO_VALUE"]!=nil){
                //앨범에서 가져온 비디오
                   PHAsset *value = [[array objectAtIndex:i] objectForKey:@"VIDEO_VALUE"];
                   
                   PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                   options.version = PHVideoRequestOptionsVersionOriginal;
                   options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                   options.networkAccessAllowed = YES;
                   
                   //동영상 변환
                   [[PHImageManager defaultManager] requestAVAssetForVideo:value options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                         NSURL *URL = [(AVURLAsset *)avAsset URL];
                          [MFFileCompress compressVideoWithInputVideoUrl:URL asset:avAsset num:i mode:nil fileName:nil paramNo:nil completion:^(NSData *data) {
                               NSLog(@"변환된 데이터 : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);
  
                                UIImage *thumbnail = [[array objectAtIndex:i] objectForKey:@"ORIGIN"];
  
                                [obj setObject:@"VIDEO" forKey:@"TYPE"];
                                [obj setObject:data forKey:@"VALUE"];
                                if(thumbnail!=nil) [obj setObject:thumbnail forKey:@"THUMB"];
                                [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
  
                                setCount++;
                                if(setCount==count) [self dataConvertFinished:tmpDict];
                            }];
                          
//                          [self compressVideoWithInputVideoUrl:URL asset:avAsset num:i completion:^(NSData *data) {
//                             NSLog(@"변환된 데이터 : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);
//
//                              UIImage *thumbnail = [[array objectAtIndex:i] objectForKey:@"ORIGIN"];
//
//                              [obj setObject:@"VIDEO" forKey:@"TYPE"];
//                              [obj setObject:data forKey:@"VALUE"];
//                              if(thumbnail!=nil) [obj setObject:thumbnail forKey:@"THUMB"];
//                              [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
//
//                              setCount++;
//                              if(setCount==count) [self dataConvertFinished:tmpDict];
//                          }];
                      });
                   }];

                    
                } else if([[array objectAtIndex:i] objectForKey:@"RECORD_VALUE"]!=nil){
                    //촬영한 비디오
                    AVURLAsset *avAsset = [[array objectAtIndex:i] objectForKey:@"RECORD_VALUE"];
                    
                    [MFFileCompress compressVideoWithInputVideoUrl:avAsset.URL asset:avAsset num:i mode:nil fileName:nil paramNo:nil completion:^(NSData *data) {
                        NSLog(@"변환된 데이터 : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);

                        UIImage *thumbnail = [[array objectAtIndex:i] objectForKey:@"ORIGIN"];
                        
                        [obj setObject:@"VIDEO" forKey:@"TYPE"];
                        [obj setObject:data forKey:@"VALUE"];
                        if(thumbnail!=nil) [obj setObject:thumbnail forKey:@"THUMB"];
                        [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];

                        setCount++;
                        if(setCount==count) [self dataConvertFinished:tmpDict];
                    }];
                    
//                    [self compressVideoWithInputVideoUrl:avAsset.URL asset:avAsset num:i completion:^(NSData *data) {
//                        NSLog(@"변환된 데이터 : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);
//
//                        UIImage *thumbnail = [[array objectAtIndex:i] objectForKey:@"ORIGIN"];
//
//                        [obj setObject:@"VIDEO" forKey:@"TYPE"];
//                        [obj setObject:data forKey:@"VALUE"];
//                        if(thumbnail!=nil) [obj setObject:thumbnail forKey:@"THUMB"];
//                        [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
//
//                        setCount++;
//                        if(setCount==count) [self dataConvertFinished:tmpDict];
//                    }];
                    
                } else if([[array objectAtIndex:i] objectForKey:@"VIDEO_DATA"]!=nil){
                    NSData *data = [[array objectAtIndex:i] objectForKey:@"VIDEO_DATA"];
                    //UIImage *thumbImg = [[array objectAtIndex:i] objectForKey:@"VIDEO_THUMB"];
                    UIImage *thumbImg = [[array objectAtIndex:i] objectForKey:@"ORIGIN"];
                    
                    [obj setObject:@"VIDEO" forKey:@"TYPE"];
                    [obj setObject:data forKey:@"VALUE"];
                    [obj setObject:thumbImg forKey:@"THUMB"];
                    
                    if([[array objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                        [obj setObject:@"true" forKey:@"IS_SHARE"];
                        [obj setObject:[[array objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
                    }
                    
                    [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
                    
                    setCount++;
                    if(setCount==count) [self dataConvertFinished:tmpDict];
                }
            
            } else if([type isEqualToString:@"FILE"]){
                NSString *value = [[array objectAtIndex:i] objectForKey:@"VALUE"];
                NSData *data = [[array objectAtIndex:i] objectForKey:@"FILE_DATA"];
                
                [obj setObject:@"FILE" forKey:@"TYPE"];
                [obj setObject:value forKey:@"VALUE"];
                [obj setObject:data forKey:@"FILE_DATA"];
                [obj setObject:[[array objectAtIndex:i] objectForKey:@"FILE_NM"] forKey:@"FILE_NM"];
                
                if([[array objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                    [obj setObject:@"true" forKey:@"IS_SHARE"];
                }
                
                [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
                
                setCount++;
                if(setCount==count) [self dataConvertFinished:tmpDict];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)dataConvertFinished:(NSMutableDictionary *)dict{
    NSLog(@"dict : %@", dict);
    
    resultArr = [NSMutableArray array];
    
    @try{
        for(int i=0; i<dict.count; i++){
            NSMutableDictionary *reDict = [NSMutableDictionary dictionary];
            
            NSDictionary *dataDict = [dict objectForKey:[NSString stringWithFormat:@"%d",i]];
            NSString *type = [dataDict objectForKey:@"TYPE"];
            if([type isEqualToString:@"IMG"]){
                [reDict setObject:@"IMG" forKey:@"TYPE"];
                [reDict setObject:[dataDict objectForKey:@"VALUE"] forKey:@"VALUE"]; //UIImage
                
                UIImage *img = [dataDict objectForKey:@"VALUE"];
                int height = img.size.height;
                [reDict setObject:[NSString stringWithFormat:@"%d", height] forKey:@"HEIGHT"];
                
                if([dataDict objectForKey:@"IS_SHARE"]!=nil){
                    [reDict setObject:@"true" forKey:@"IS_SHARE"];
                    [reDict setObject:[dataDict objectForKey:@"URL"] forKey:@"URL"];
                }
                
                [resultArr addObject:reDict];
                
            } else if([type isEqualToString:@"VIDEO"]){
                NSMutableDictionary *thumbDict = [NSMutableDictionary dictionary];
                if([dataDict objectForKey:@"THUMB"]!=nil){
                    [thumbDict setObject:@"VIDEO_THUMB" forKey:@"TYPE"];
                    [thumbDict setObject:[dataDict objectForKey:@"THUMB"] forKey:@"VALUE"]; //UIImage
                    [resultArr addObject:thumbDict];
                }
                
                [reDict setObject:@"VIDEO" forKey:@"TYPE"];
                [reDict setObject:[dataDict objectForKey:@"VALUE"] forKey:@"VALUE"]; //NSData
                
                if([dataDict objectForKey:@"IS_SHARE"]!=nil){
                    [reDict setObject:@"true" forKey:@"IS_SHARE"];
                    [reDict setObject:[dataDict objectForKey:@"URL"] forKey:@"URL"];
                }
                
                [resultArr addObject:reDict];
            
            } else if([type isEqualToString:@"FILE"]){
                [reDict setObject:@"FILE" forKey:@"TYPE"];
                [reDict setObject:[dataDict objectForKey:@"VALUE"] forKey:@"VALUE"];
                [reDict setObject:[dataDict objectForKey:@"FILE_DATA"] forKey:@"FILE_DATA"]; //NSData
                [reDict setObject:[dataDict objectForKey:@"FILE_NM"] forKey:@"FILE_NM"];
                
                if([dataDict objectForKey:@"IS_SHARE"]!=nil){
                    [reDict setObject:@"true" forKey:@"IS_SHARE"];
                }
                
                [resultArr addObject:reDict];
            }
        }
        
        [self callWebService:@"getPostNo" WithParameter:nil];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
-(void)dataConvertFailed{
    [SVProgressHUD dismiss];
    uploadCount = 0;
    fileNameCnt = 0;
    self.filePathArray = [NSMutableArray array];
    
    @try{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"동영상 변환 실패" message:@"재시도 하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             [self saveButtonPressed:nil];
                                                         }];
        
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        
        [alert addAction:okButton];
        [alert addAction:cancelButton];
        [self presentViewController:alert animated:YES completion:nil];
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)videoSizeCheck{
    uploadCount = 0;
    fileNameCnt = 0;
    self.filePathArray = [NSMutableArray array];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"upload_fail_title", @"upload_fail_title") message:NSLocalizedString(@"upload_fail_size_limit", @"upload_fail_size_limit") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)saveMediaFiles{
    @try{
        NSString *type = [[resultArr objectAtIndex:0] objectForKey:@"TYPE"];
        
        if([type isEqualToString:@"IMG"]){
            if([[resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]!=nil&&[[[resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
                [self shareMediaFiles:nil mediaType:type isFile:nil isShared:@"true" srcFileUrl:[[resultArr objectAtIndex:0] objectForKey:@"URL"]];
                
            } else {
                UIImage *value = [[resultArr objectAtIndex:0] objectForKey:@"VALUE"];
                value = [MFUtil getResizeImageRatio:value];
                NSData *data = UIImageJPEGRepresentation(value, 0.7);
//                NSLog(@"img size : %f*%f", value.size.width, value.size.height);
//                NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
                [self saveMediaFiles:data mediaType:type];
            }
            
        } else if([type isEqualToString:@"VIDEO"]){
            if([[resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]!=nil&&[[[resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
                [self shareMediaFiles:nil mediaType:type isFile:nil isShared:@"true" srcFileUrl:[[resultArr objectAtIndex:0] objectForKey:@"URL"]];
            } else {
                NSData *data = [[resultArr objectAtIndex:0] objectForKey:@"VALUE"];
//                NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
                
                if((float)data.length/1024.0f/1024.0f>20){
                    [self videoSizeCheck];
                } else {
                    [self saveMediaFiles:data mediaType:type];
                }
            }
            
        } else if([type isEqualToString:@"VIDEO_THUMB"]){
            UIImage *value = [[resultArr objectAtIndex:0] objectForKey:@"VALUE"];
            value = [MFUtil getResizeImageRatio:value];
            NSData *data = UIImageJPEGRepresentation(value, 0.7);
//            NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
            [self saveMediaFiles:data mediaType:type];
        
        } else if([type isEqualToString:@"FILE"]){
//            fileTypeName = [[resultArr objectAtIndex:0] objectForKey:@"FILE_NM"];
            if([[resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]!=nil&&[[[resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
                [self shareMediaFiles:nil mediaType:type isFile:[[resultArr objectAtIndex:0] objectForKey:@"FILE_NM"] isShared:@"true" srcFileUrl:[[resultArr objectAtIndex:0] objectForKey:@"VALUE"]];
            } else {
                NSData *data = [[resultArr objectAtIndex:0] objectForKey:@"FILE_DATA"];
                NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
                [self saveMediaFiles:data mediaType:type];
            }
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)shareMediaFiles:(NSData *)data mediaType:(NSString *)type isFile:(NSString *)fileNm isShared:(NSString *)isShare srcFileUrl:(NSString *)fileUrl{
    @try{
        if (self.postNo==nil) {
            
        }else{
            NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
            urlString = [urlString stringByAppendingPathComponent:@"saveAttachedFile"];
            
//            fileUrl = [fileUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

            NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
            [aditDic setObject:@"1" forKey:@"TMP_NO"];
            [aditDic setObject:@"" forKey:@"LOCAL_CONTENT"];
            
            NSData* aditData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:nil];
            NSString* aditJsonData = [[NSString alloc] initWithData:aditData encoding:NSUTF8StringEncoding];
            
            NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
            
            NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
            [sendFileParam setObject:self.snsNo forKey:@"snsNo"];
            [sendFileParam setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
            [sendFileParam setObject:myUserNo forKey:@"usrNo"];
            [sendFileParam setObject:@"1" forKey:@"refTy"];
            [sendFileParam setObject:self.postNo forKey:@"refNo"];
            [sendFileParam setObject:aditJsonData forKey:@"aditInfo"];
            [sendFileParam setObject:isShare forKey:@"isShared"];
            [sendFileParam setObject:fileUrl forKey:@"srcFileUrl"];
            
            if([type isEqualToString:@"IMG"]) {
                [sendFileParam setObject:@"false" forKey:@"isThumb"];
            }
            else if([type isEqualToString:@"VIDEO"]) {
                [sendFileParam setObject:@"false" forKey:@"isThumb"];
                [sendFileParam setObject:videoThumbName forKey:@"thumbName"];
            }
//            else if([type isEqualToString:@"VIDEO_THUMB"]){
//                [sendFileParam setObject:@"true" forKey:@"isThumb"];
//                fileName = [self createFileName:@"IMG"];
//
//                thumbImage = [[UIImage alloc] initWithData:data];
//            }
            else if([type isEqualToString:@"FILE"]) {
                [sendFileParam setObject:@"false" forKey:@"isThumb"];
            }
            
            [self sessionFileUpload:urlString :sendFileParam :nil :nil];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)saveMediaFiles:(NSData *)data mediaType:(NSString *)type{
    @try{
        if (self.postNo==nil) {
            
        }else{
            NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
            urlString = [urlString stringByAppendingPathComponent:@"saveAttachedFile"];
            
            NSString *fileName;
            
            NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
            [aditDic setObject:@"1" forKey:@"TMP_NO"];
            //[aditDic setObject:@"THIS IS TEST!" forKey:@"LOCAL_CONTENT"];
            
            NSData* aditData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:nil];
            NSString* aditJsonData = [[NSString alloc] initWithData:aditData encoding:NSUTF8StringEncoding];
            
            NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
            
            NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
            [sendFileParam setObject:self.snsNo forKey:@"snsNo"];
            [sendFileParam setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
            [sendFileParam setObject:myUserNo forKey:@"usrNo"];
            [sendFileParam setObject:@"1" forKey:@"refTy"];
            [sendFileParam setObject:self.postNo forKey:@"refNo"];
            [sendFileParam setObject:aditJsonData forKey:@"aditInfo"];
            [sendFileParam setObject:@"false" forKey:@"isShared"];
            [sendFileParam setObject:@"" forKey:@"srcFileUrl"];
            
            if([type isEqualToString:@"IMG"]) {
                [sendFileParam setObject:@"false" forKey:@"isThumb"];
                fileName = [self createFileName:@"IMG"];
            }
            else if([type isEqualToString:@"VIDEO"]) {
                [sendFileParam setObject:@"false" forKey:@"isThumb"];
                [sendFileParam setObject:videoThumbName forKey:@"thumbName"];
                
                NSRange range = [videoThumbName rangeOfString:@"." options:NSBackwardsSearch];
                NSString *videoName = [NSString stringWithFormat:@"%@.mp4",[videoThumbName substringToIndex:range.location]];
                fileName = videoName;
            }
            else if([type isEqualToString:@"VIDEO_THUMB"]){
                [sendFileParam setObject:@"true" forKey:@"isThumb"];
                fileName = [self createFileName:@"IMG"];
                
                thumbImage = [[UIImage alloc] initWithData:data];
            }
            else if([type isEqualToString:@"FILE"]) {
                [sendFileParam setObject:@"false" forKey:@"isThumb"];
                fileName = [[resultArr objectAtIndex:uploadCount] objectForKey:@"FILE_NM"];
                NSLog(@"fileTypeName : %@", fileName);
            }
            
            [self sessionFileUpload:urlString :sendFileParam :data :fileName];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSession Delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    if (error != nil) {
        [SVProgressHUD dismiss];
        
        
    }else{
        NSString *wsName = [[session.url absoluteString] lastPathComponent];
        NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
        //NSLog(@"wsName : %@",wsName);
        if ([result isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"getPostNo"]) {
                @try {
                    self.postNo = [[[session.returnDictionary objectForKey:@"DATASET"] objectAtIndex:0] objectForKey:@"SEQ"];
                    /*if(contentFileArr.count>0 ){
                        [self saveAttachedFile];
                    }*/
                    if(resultArr.count>0 ){
                        [self saveMediaFiles];
                    } else {
                        NSError *error;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArr options:0 error:&error];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        jsonString = [jsonString urlEncodeUsingEncoding:NSUTF8StringEncoding];
                        
                        NSData *prevData = [NSJSONSerialization dataWithJSONObject:firstArr options:0 error:&error];
                        NSString *prevString = [[NSString alloc] initWithData:prevData encoding:NSUTF8StringEncoding];
                        prevString = [prevString urlEncodeUsingEncoding:NSUTF8StringEncoding];
//                        NSLog(@"prevString : %@", prevString);
                        
                        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
                        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@&feed_content=%@",myUserNo, self.snsNo, self.postNo, jsonString, prevString];
                        NSLog(@"savePost param : %@", paramString);
                        
                        [self callWebService:@"savePost" WithParameter:paramString];
                    }
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
                
            }else if ([wsName isEqualToString:@"savePost"]) {
                [SVProgressHUD dismiss];
                self.navigationItem.rightBarButtonItem.enabled = YES;
                
                @try {
                    NSString *affected = [session.returnDictionary objectForKey:@"AFFECTED"];
                    if ([affected intValue]>0) {
                        if([self.fromSegue isEqualToString:@"SHARE_POST_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]){
                            NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[MFSingleton sharedInstance] shareExtScheme]];
                            [shareDefaults removeObjectForKey:@"SHARE_ITEM"];
                            [shareDefaults synchronize];
                            
                            [appDelegate.appPrefs removeObjectForKey:@"SHARE_ITEM_FROM_CHAT"];
                            [appDelegate.appPrefs removeObjectForKey:@"SHARE_ITEM_FROM_POST"];
                            
                            [self dismissViewControllerAnimated:YES completion:^(void){
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ShareViewClose" object:nil];
//                                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SavePost" object:nil userInfo:@{@"RESULT":@"SUCCESS"}];
//                                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_PostModify" object:nil];
                            }];
                            
                        } else {
                            [self dismissViewControllerAnimated:YES completion:^(void){
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SavePost" object:nil userInfo:@{@"RESULT":@"SUCCESS"}];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_PostModify" object:nil];
                            }];
                        }
                    }
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
            }
        }else{
            [SVProgressHUD dismiss];
            
            NSString *errorMsg = [NSString stringWithFormat:@"%@\n%@",session.url,error];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)returnError:(MFURLSession *)session error:(NSError *)error{
    [SVProgressHUD dismiss];
    NSLog(@"error : %@", error);
    
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
    }
}

-(void)imageToUrlString{
    int changeCnt = 0;
    @try {
        NSLog(@"dataArr ; %@", dataArr);
        
        int firstTxtCnt = 0;
        int firstImgCnt = 0;
        int firstFileCnt = 0;
        firstArr = [NSMutableArray array];
        
        for(int i=0; i<dataArr.count; i++){
            NSString *type = [[dataArr objectAtIndex:i] objectForKey:@"TYPE"];
            
            if([type isEqualToString:@"IMG"]){
                NSString *imagePath = [self.filePathArray objectAtIndex:changeCnt];
                if(changeCnt<=fileNameCnt){
                    [[dataArr objectAtIndex:i] setObject:imagePath  forKey:@"VALUE"];
                    [[dataArr objectAtIndex:i] removeObjectForKey:@"ORIGIN"];
                    [[dataArr objectAtIndex:i] removeObjectForKey:@"IS_SHARE"];
                    [[dataArr objectAtIndex:i] removeObjectForKey:@"URL"];
                }
                changeCnt++;
                
                
            } else if([type isEqualToString:@"VIDEO"]){
                NSString *imagePath = [self.filePathArray objectAtIndex:changeCnt];
                if(changeCnt<=fileNameCnt){
                    if([[dataArr objectAtIndex:i] objectForKey:@"VIDEO_DATA"]!=nil){
                        [[dataArr objectAtIndex:i] setObject:imagePath forKey:@"VALUE"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"VIDEO_DATA"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"VIDEO_THUMB"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"ORIGIN"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"IS_SHARE"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"URL"];
                    } else {
                        [[dataArr objectAtIndex:i] setObject:imagePath forKey:@"VALUE"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"VIDEO_ASSET"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"RECORD_ASSET"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"ORIGIN"];
                    }
                }
                changeCnt++;
                
            } else if([type isEqualToString:@"FILE"]){
                NSString *filePath = [self.filePathArray objectAtIndex:changeCnt];
                if(changeCnt<=fileNameCnt){
                    [[dataArr objectAtIndex:i] setObject:filePath forKey:@"VALUE"];
                    [[dataArr objectAtIndex:i] removeObjectForKey:@"FILE_DATA"];
                    [[dataArr objectAtIndex:i] removeObjectForKey:@"FILE_NM"];
                    [[dataArr objectAtIndex:i] removeObjectForKey:@"IS_SHARE"];
                    [[dataArr objectAtIndex:i] removeObjectForKey:@"URL"];
                }
                changeCnt++;
            }
            
            if([type isEqualToString:@"TEXT"]&&firstTxtCnt==0){
                NSString *prevStr = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
                if(prevStr.length > 200) {
                    prevStr = [prevStr substringWithRange:NSMakeRange(0, 200)];
                }
                
                NSDictionary *textDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"TEXT", @"TYPE", prevStr, @"VALUE", nil];
                [firstArr addObject:textDict];
                firstTxtCnt++;
                
            } else if(([type isEqualToString:@"IMG"]||[type isEqualToString:@"VIDEO"])&&firstImgCnt==0){
                [firstArr addObject:[dataArr objectAtIndex:i]];
                firstImgCnt++;
                
            } else if([type isEqualToString:@"FILE"]&&firstFileCnt==0){
                [firstArr addObject:[dataArr objectAtIndex:i]];
                firstFileCnt++;
            }
//            NSLog(@"333 firstArr : %@", firstArr);
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSession Upload Delegate
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error{
    @try{
        uploadCount++;
        if (error != nil) {
            
        }else{
            NSString *result = [dictionary objectForKey:@"RESULT"];
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([dictionary objectForKey:@"FILE_URL"]==nil) {
                    [SVProgressHUD dismiss];
                    
                }else{
                    videoThumbName = @"";
                    NSLog(@"dictionary : %@", dictionary);
                    
                    @try{
                        NSString *ttype = [[resultArr objectAtIndex:uploadCount-1] objectForKey:@"TYPE"];
                        if([ttype isEqualToString:@"IMG"]){
                            [self.filePathArray addObject:[dictionary objectForKey:@"FILE_URL"]];
                            fileNameCnt++;
                            
                        }else if([ttype isEqualToString:@"VIDEO"]){
                            [self.filePathArray addObject:[dictionary objectForKey:@"FILE_URL"]];
                            fileNameCnt++;
                            
                            NSString *thumbValue = [dictionary objectForKey:@"FILE_URL_THUMB"];
                            UIImage *thumbnail = [MFUtil getScaledImage:thumbImage scaledToMaxWidth:self.tableView.frame.size.width-20];
                            [imgCache storeImage:thumbnail forKey:thumbValue toDisk:YES];
                            
                        } else if([ttype isEqualToString:@"VIDEO_THUMB"]){
                            videoThumbName = [[dictionary objectForKey:@"FILE_URL"] lastPathComponent];
                        
                        } else if([ttype isEqualToString:@"FILE"]){
                            [self.filePathArray addObject:[dictionary objectForKey:@"FILE_URL"]];
                            fileNameCnt++;
                        }
                        
                        if(uploadCount<resultArr.count){
                            NSString *type = [[resultArr objectAtIndex:uploadCount] objectForKey:@"TYPE"];
                            
                            if([type isEqualToString:@"IMG"]){
                                if([[resultArr objectAtIndex:uploadCount] objectForKey:@"IS_SHARE"]!=nil&&[[[resultArr objectAtIndex:uploadCount] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
                                    [self shareMediaFiles:nil mediaType:type isFile:nil isShared:@"true" srcFileUrl:[[resultArr objectAtIndex:uploadCount] objectForKey:@"URL"]];
                                    
                                } else {
                                    UIImage *value = [[resultArr objectAtIndex:uploadCount] objectForKey:@"VALUE"];
                                    value = [MFUtil getResizeImageRatio:value];
                                    NSData *data = UIImageJPEGRepresentation(value, 0.7);
                                    //NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
                                    [self saveMediaFiles:data mediaType:type];
                                }
                                
                            } else if([type isEqualToString:@"VIDEO"]){
                                if([[resultArr objectAtIndex:uploadCount] objectForKey:@"IS_SHARE"]!=nil&&[[[resultArr objectAtIndex:uploadCount] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
                                    [self shareMediaFiles:nil mediaType:type isFile:nil isShared:@"true" srcFileUrl:[[resultArr objectAtIndex:uploadCount] objectForKey:@"URL"]];
                                    
                                } else {
                                    NSData *data = [[resultArr objectAtIndex:uploadCount] objectForKey:@"VALUE"];
                                    if((float)data.length/1024.0f/1024.0f>20){
                                        [self videoSizeCheck];
                                    } else {
                                        [self saveMediaFiles:data mediaType:type];
                                    }
                                }
                                
                                
                            } else if([type isEqualToString:@"VIDEO_THUMB"]){
                                //videoThumbName = @"";
                                UIImage *value = [[resultArr objectAtIndex:uploadCount] objectForKey:@"VALUE"];
                                value = [MFUtil getResizeImageRatio:value];
                                NSData * data = UIImageJPEGRepresentation(value, 0.7);
                                [self saveMediaFiles:data mediaType:type];
                            
                            } else if([type isEqualToString:@"FILE"]){
                                if([[resultArr objectAtIndex:uploadCount] objectForKey:@"IS_SHARE"]!=nil&&[[[resultArr objectAtIndex:uploadCount] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
                                    [self shareMediaFiles:nil mediaType:type isFile:[[resultArr objectAtIndex:uploadCount] objectForKey:@"FILE_NM"] isShared:@"true" srcFileUrl:[[resultArr objectAtIndex:uploadCount] objectForKey:@"VALUE"]];
                                    
                                } else {
                                    NSData *data = [[resultArr objectAtIndex:uploadCount] objectForKey:@"FILE_DATA"];
                                    [self saveMediaFiles:data mediaType:type];
                                }
                            }
                            
                        } else if(uploadCount==resultArr.count){
                            [self imageToUrlString];
                            
                            NSError *error;
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArr options:0 error:&error];
                            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            jsonString = [jsonString urlEncodeUsingEncoding:NSUTF8StringEncoding];
                            
                            
                            NSData *prevData = [NSJSONSerialization dataWithJSONObject:firstArr options:0 error:&error];
                            NSString *prevString = [[NSString alloc] initWithData:prevData encoding:NSUTF8StringEncoding];
                            prevString = [prevString urlEncodeUsingEncoding:NSUTF8StringEncoding];
//                            NSLog(@"prevString22 : %@", prevString);
                            
                            NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
                            
                            NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@&feed_content=%@", myUserNo, self.snsNo, self.postNo, jsonString, prevString];
                            NSLog(@"img savepost paramStr : %@", paramString);
                            [self callWebService:@"savePost" WithParameter:paramString];
                        }
                    } @catch (NSException *exception) {
                        NSLog(@"Exception : %@", exception);
                    }
                }
                
            } else {
                [SVProgressHUD dismiss];
                
                uploadCount = 0;
                fileNameCnt = 0;
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"업로드실패" message:@"재시도 하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     [self saveButtonPressed:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error{
    [SVProgressHUD dismiss];
    NSLog(@"%@", error);

    uploadCount = 0;
    fileNameCnt = 0;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getImageNotification:)
                                                 name:@"getImageNotification"
                                               object:nil];
    
    if ([[segue identifier] isEqualToString:@"POST_PHLIB_MODAL"]) {
        UINavigationController *destination = segue.destinationViewController;
        PHLibListViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.fromSegue = segue.identifier;
        vc.listType = sender;
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
}

@end
