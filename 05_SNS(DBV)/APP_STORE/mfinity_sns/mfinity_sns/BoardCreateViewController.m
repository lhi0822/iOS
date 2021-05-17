//
//  BoardCreateViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 2..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "BoardCreateViewController.h"
#import "BoardCreateViewCell.h"
#import "MyMessageViewController.h"

#import "MFDBHelper.h"
#import "UIViewController+MJPopupViewController.h"
#import "BoardTypeViewController.h"
#import "ChangeLeaderViewController.h"
#import "PHLibListViewController.h"

@interface BoardCreateViewController () {
    NSString *currCover;
    NSString *snsName;
    NSString *snsLeader;
    NSString *snsLeaderNo;
    NSString *snsKind;
    NSString *snsType;
    NSString *snsAllow;
    NSString *snsDesc;
    
    NSDictionary *snsKindDic;
    NSDictionary *snsTypeDic;
    NSDictionary *snsAllowDic;
    
    NSData *coverImgData;
    UIImage *coverImg;
    NSString *coverUrl;
    
    NSString *myUserNo;
    NSString *compNo;
    
    BOOL isChangeCover;
    
    NSMutableDictionary *editSnsInfo;
    AppDelegate *appDelegate;
}

@end

@implementation BoardCreateViewController

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"fromSegue : %@", self.fromSegue);
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"board_info_setting1", @"board_info_setting1")];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save", @"save")
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(rightSideMenuButtonPressed:)];
    } else {
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"board_create_title", @"board_create_title")];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"done", @"done")
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(rightSideMenuButtonPressed:)];
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClick)];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChangeSubInfo1:) name:@"noti_ChangeSubInfo1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChangeSubInfo2:) name:@"noti_ChangeSubInfo2" object:nil];
    
    self.snsNo = nil;
    editSnsInfo = [NSMutableDictionary dictionary];
    isChangeCover = NO;
    coverUrl = @"";
    
    self.imgView.image = [UIImage imageNamed:@"cover3-2.png"];
    self.imgView.alpha = 0.3;
    
    self.coverEditBtn.hidden=YES;
    
    self.iconView.hidden = NO;
    self.descLabel.hidden = NO;
    self.iconView.image = [MFUtil getScaledImage:[UIImage imageNamed:@"icon_plus.png"] scaledToMaxWidth:30.0f];
    self.descLabel.text = NSLocalizedString(@"board_create_img", @"board_create_img");
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnCoverImg:)];
    [self.imgView setUserInteractionEnabled:YES];
    [self.imgView addGestureRecognizer:tap];
    [self.view1 setUserInteractionEnabled:YES];
    [self.view1 addGestureRecognizer:tap];
    
    [self.coverEditBtn addTarget:self action:@selector(boardCoverEditClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view1.frame.size.height, self.view.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.view1 addSubview:lineView];
    
    self.keyArray = [NSArray array];
    
    snsKindDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"일반형",@"1", @"프로젝트형",@"2", nil];
    snsTypeDic = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"board_info_visible_type_public", @"board_info_visible_type_public"),@"3", /*@"이름공개",@"2",*/ NSLocalizedString(@"board_info_visible_type_secret", @"board_info_visible_type_secret"),@"1", nil];
    snsAllowDic = [[NSDictionary alloc] initWithObjectsAndKeys:NSLocalizedString(@"board_info_need_allow_no", @"board_info_need_allow_no"),@"0", NSLocalizedString(@"board_info_need_allow_yes", @"board_info_need_allow_yes"),@"1", nil];
    
    myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    [self drawContent];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)drawContent {
    @try{
        if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]){
            if(_currSnsKind==1){
                self.keyArray = @[NSLocalizedString(@"board_info_name", @"board_info_name"), NSLocalizedString(@"board_create_owner", @"board_create_owner"), NSLocalizedString(@"board_info_kind", @"board_info_kind"), NSLocalizedString(@"board_info_visible_type", @"board_info_visible_type"), NSLocalizedString(@"board_info_need_allow", @"board_info_need_allow"), NSLocalizedString(@"board_info_desc", @"board_info_desc")];
            } else if(_currSnsKind==2){
                self.keyArray = @[NSLocalizedString(@"board_info_name", @"board_info_name"), NSLocalizedString(@"board_create_owner", @"board_create_owner"), NSLocalizedString(@"board_info_kind", @"board_info_kind"), NSLocalizedString(@"board_info_desc", @"board_info_desc")];
            }
            
            self.snsNo = [self.snsInfoDic objectForKey:@"SNS_NO"];
            currCover = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"COVER_IMG"]];
            snsName = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"SNS_NM"]];
            snsLeader = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"CREATE_USER_NM"]];
            snsLeaderNo = [self.snsInfoDic objectForKey:@"CREATE_USER_NO"];
            snsKind = [self.snsInfoDic objectForKey:@"SNS_KIND"];
            snsType = [self.snsInfoDic objectForKey:@"SNS_TY"];
            snsAllow = [self.snsInfoDic objectForKey:@"NEED_ALLOW"];
            snsDesc = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"SNS_DESC"]];
            
            if([snsKind isEqualToString:@"Normal"]) snsKind = @"1";
            else if([snsKind isEqualToString:@"Project"]) snsKind = @"2";
            
            if([snsType isEqualToString:@"Public"]) snsType = @"3";
            //else if([snsType isEqualToString:@"Closed"]) snsType = @"2";
            else if([snsType isEqualToString:@"Secret"]) snsType = @"1";
            
            if([snsDesc isEqualToString:@"(null)"]) snsDesc = @"";
            
            if(![currCover isEqualToString:@""]&&![currCover isEqualToString:@"null"]&&currCover!=nil){
                UIImage *image = [MFUtil saveThumbImage:@"Cover" path:currCover num:nil];
                if(image!=nil){
                    UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.imgView.frame.size.width, self.imgView.frame.size.height) :image];
                    self.imgView.image = postCover;
                    
                    self.imgView.alpha = 1.0;
                    self.coverEditBtn.hidden = NO;
                    self.iconView.hidden = YES;
                    self.descLabel.hidden = YES;
                    
                } else {
                    UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.imgView.frame.size.width, self.imgView.frame.size.height) :[UIImage imageNamed:@"cover3-2.png"]];
                    self.imgView.image = postCover;
                    
                    self.imgView.alpha = 0.3;
                    self.coverEditBtn.hidden = YES;
                    self.iconView.hidden = NO;
                    self.descLabel.hidden = NO;
                }
                
            } else {
                UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.imgView.frame.size.width, self.imgView.frame.size.height) :[UIImage imageNamed:@"cover3-2.png"]];
                self.imgView.image = postCover;
                
                self.imgView.alpha = 0.3;
                self.coverEditBtn.hidden = YES;
                self.iconView.hidden = NO;
                self.descLabel.hidden = NO;
            }
                        //self.coverEditBtn.hidden = NO;
            
        } else {
            self.keyArray = @[NSLocalizedString(@"board_info_name", @"board_info_name"), NSLocalizedString(@"board_info_kind", @"board_info_kind"), NSLocalizedString(@"board_info_visible_type", @"board_info_visible_type"), NSLocalizedString(@"board_info_need_allow", @"board_info_need_allow"), NSLocalizedString(@"board_info_desc", @"board_info_desc")];
            
            snsKind = @"1";
            snsType = @"3";
            snsAllow = @"0";
        }
        
        [self.tableView reloadData];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)rightSideMenuButtonPressed:(id)sender{
    @try{
        snsName = [snsName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(snsName!=nil&&![snsName isEqualToString:@""]){
            if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]){
                if(isChangeCover) {
                    [self saveAttachedFile:coverImgData AndFileName:[self createFileName]];
                } else {
                    [self callWebService:@"createSNS"];
                }
                
            } else {
                [self callWebService:@"getSNSNo"];
            }
            
        } else {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"board_create_name_null", @"board_create_name_null") preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
            });
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
-(void)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapOnCoverImg:(UITapGestureRecognizer*)tap{
    [self boardCoverEditClick];
}

- (void)boardCoverEditClick {
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
                                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                
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
                            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                            
                            self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                            [[MFUtil topViewController] presentViewController:self.picker animated:YES completion:nil];
                        }
                    });
                }];
            }
            
//            if([AccessAuthCheck cameraAccessCheckNotAuth]){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
//                    self.picker = [[UIImagePickerController alloc] init];
//                    self.picker.delegate = self;
//                    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//
//                    self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
//                    [top presentViewController:self.picker animated:YES completion:nil];
//                });
//            }
            
        }else{
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];
    
    UIAlertAction *selectPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"popup_camera2", @"popup_camera2")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
        if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                
                [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES) [self performSegueWithIdentifier:@"BOARD_PHLIB_MODAL" sender:@"PHOTO"];
                    });
                }];
                
            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(status==YES) [self performSegueWithIdentifier:@"BOARD_PHLIB_MODAL" sender:@"PHOTO"];
                });
                
            }];
        }
        
//        if([AccessAuthCheck photoAccessCheck]){
//            [self performSegueWithIdentifier:@"BOARD_PHLIB_MODAL" sender:@"PHOTO"];
//        }
        
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    
    if(coverImg!=nil){
        UIAlertAction *defaultImageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"myinfo_image_null", @"기본이미지로 myinfo_image_null")
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"myinfo_image_null_msg", @"myinfo_image_null_msg") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                
                coverImg = nil;
                self.imgView.image = nil;
                
                self.imgView.image = [UIImage imageNamed:@"cover3-2.png"];
                self.imgView.alpha = 0.3;
                
                self.iconView.hidden = NO;
                self.descLabel.hidden = NO;
                
                self.coverEditBtn.hidden = YES;
                [self.tableView reloadData];
            }];
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [actionSheet addAction:defaultImageAction];
    }
    
    [actionSheet addAction:takePictureAction];
    [actionSheet addAction:selectPhotoAction];
    
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
}

- (void)saveAttachedFile:(UIImage *)image{
    self.coverEditBtn.hidden = NO;
    coverImg = nil;
    
    @try{
        NSData * data = UIImageJPEGRepresentation(image, 0.3);
        coverImgData = data;
        
        if(image!=nil){
            coverImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(self.imgView.frame.size.width, self.imgView.frame.size.height):image];
            
            self.imgView.alpha = 1.0;
            self.coverEditBtn.hidden = NO;
            self.iconView.hidden = YES;
            self.descLabel.hidden = YES;
            
        } else {
            coverImg = [UIImage imageNamed:@"cover3-2.png"];
            self.imgView.alpha = 0.3;
            self.coverEditBtn.hidden=YES;
            self.iconView.hidden = NO;
            self.descLabel.hidden = NO;
        }
        
        self.imgView.image = coverImg;
        [self.tableView reloadData];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)saveAttachedFile:(NSData *)data AndFileName:(NSString *)fileName{
    @try{
        NSString *dvcID =  [appDelegate.appPrefs objectForKey:@"DVC_ID"];//[MFUtil getUUID];
        NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
        [aditDic setObject:@1 forKey:@"TMP_NO"];
        [aditDic setObject:dvcID forKey:@"DEVICE_ID"];
        
        NSData* aditData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:nil];
        NSString* aditJsonData = [[NSString alloc] initWithData:aditData encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
        [sendFileParam setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
        [sendFileParam setObject:self.snsNo forKey:@"snsNo"];
        [sendFileParam setObject:@"0" forKey:@"refTy"];
        [sendFileParam setObject:myUserNo forKey:@"refNo"];
        [sendFileParam setObject:aditJsonData forKey:@"aditInfo"];
        [sendFileParam setObject:myUserNo forKey:@"refNo"];
        [sendFileParam setObject:@"false" forKey:@"isShared"];
        [sendFileParam setObject:@"" forKey:@"srcFileUrl"];
        
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
        urlString = [urlString stringByAppendingPathComponent:@"saveAttachedFile"];
        
        MFURLSessionUpload *sessionUpload = [[MFURLSessionUpload alloc]initWithURL:[NSURL URLWithString:urlString] option:sendFileParam WithData:data AndFileName:fileName];
        sessionUpload.delegate = self;
        if ([sessionUpload start]) {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (NSString *)createFileName{
    @try{
        NSString *fileName = nil;
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd-HHmmssSSS"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        fileName = [NSString stringWithFormat:@"%@.png",currentTime];
        return fileName;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)callWebService:(NSString *)serviceName{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    NSString *paramString = nil;
    
    @try{
        if([serviceName isEqualToString:@"getSNSNo"]){
            paramString = [NSString stringWithFormat:@"usrNo=%@&compNo=%@&snsKind=%@&dvcId=%@", myUserNo, compNo, snsKind, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            
        } else if([serviceName isEqualToString:@"createSNS"]){
            //targetUserNo : 리더위임시 위임된 유저번호, 위임이 아닐경우 usrNo와 같은값
            //isCreateSNS("true":생성 or "false":수정)
            //NSLog(@"snsKind : %@", snsKind);
            
            //if([snsKind isEqualToString:@"1"]) snsKind = @"Normal";
            //else snsKind = @"Project";
            
            if(!isChangeCover) {
                coverUrl = currCover;
            }
            else{
                isChangeCover = NO;
            }
            
            if(coverUrl==nil||[coverUrl isEqualToString:@"(null)"]||[coverUrl isEqualToString:@"null"]||[coverUrl isEqualToString:@""]) coverUrl = @"";
            if(snsDesc==nil) snsDesc = @"";
            
            NSString *isCreateSns = nil;
            if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]) {
                isCreateSns = @"false";
                
                [editSnsInfo setValue:[self.snsInfoDic objectForKey:@"COMP_NO"] forKey:@"COMP_NO"];
                [editSnsInfo setValue:[self.snsInfoDic objectForKey:@"CREATE_DATE"] forKey:@"CREATE_DATE"];
                [editSnsInfo setValue:snsLeaderNo forKey:@"CREATE_USER_NO"];
                [editSnsInfo setValue:snsLeader forKey:@"CREATE_USER_NM"];
                [editSnsInfo setValue:[self.snsInfoDic objectForKey:@"ITEM_TYPE"] forKey:@"ITEM_TYPE"];
                [editSnsInfo setValue:[self.snsInfoDic objectForKey:@"SNS_NO"]  forKey:@"SNS_NO"];
                [editSnsInfo setValue:[self.snsInfoDic objectForKey:@"SORT_NO"] forKey:@"SORT_NO"];
                [editSnsInfo setValue:[self.snsInfoDic objectForKey:@"USER_COUNT"] forKey:@"USER_COUNT"];
                [editSnsInfo setValue:[self.snsInfoDic objectForKey:@"USER_LIST"] forKey:@"USER_LIST"];
                [editSnsInfo setValue:[self.snsInfoDic objectForKey:@"WAITING_USER_COUNT"] forKey:@"WAITING_USER_COUNT"];
                [editSnsInfo setValue:coverUrl forKey:@"COVER_IMG"];
                [editSnsInfo setValue:snsName forKey:@"SNS_NM"];
                [editSnsInfo setValue:snsType forKey:@"SNS_TY"];
                [editSnsInfo setValue:snsAllow forKey:@"NEED_ALLOW"];
                [editSnsInfo setValue:snsDesc forKey:@"SNS_DESC"];
                [editSnsInfo setValue:[self.snsInfoDic objectForKey:@"SNS_KIND"] forKey:@"SNS_KIND"];
                
            } else {
                isCreateSns = @"true";
            }
            NSString *mfpsId = [NSString stringWithFormat:@"USER.SNS.%@.%@.%@.%@.%@", [[MFSingleton sharedInstance] appType],[[MFSingleton sharedInstance] dvcType],[appDelegate.appPrefs objectForKey:@"COMP_NO"], [appDelegate.appPrefs objectForKey:@"USERID"], [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
            paramString = [NSString stringWithFormat:@"usrNo=%@&targetUserNo=%@&snsNo=%@&snsNm=%@&snsTy=%@&snsNeedAllow=%@&snsDesc=%@&snsCoverImg=%@&compNo=%@&isCreateSNS=%@&mfpsId=%@&snsKind=%@&dvcId=%@", myUserNo, snsLeaderNo, self.snsNo, snsName, snsType, snsAllow, snsDesc, coverUrl, compNo, isCreateSns, mfpsId, snsKind, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
        }
        
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        if ([session start]) {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSession Delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    
    @try{
        NSString *wsName = [[session.url absoluteString] lastPathComponent];
        
        if (error!=nil || ![error isEqualToString:@"(null)"]) {
            NSDictionary *dic = session.returnDictionary;
            
            if ([[dic objectForKey:@"RESULT"]isEqualToString:@"SUCCESS"]) {
                if ([wsName isEqualToString:@"getSNSNo"]) {
                    NSArray *dataSet = [dic objectForKey:@"DATASET"];
                    self.snsNo = [[dataSet objectAtIndex:0] objectForKey:@"SEQ"];
                    if(coverImg!=nil) {
                        [self saveAttachedFile:coverImgData AndFileName:[self createFileName]];
                    } else {
                        [self callWebService:@"createSNS"];
                    }
                    
                } else if([wsName isEqualToString:@"createSNS"]){
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
                    NSString *createUserNm = [NSString urlDecodeString:[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]]];
                    
                    NSString *sqlString = [appDelegate.dbHelper insertOrUpdateSns:self.snsNo snsName:snsName snsType:snsType needAllow:snsAllow snsDesc:snsDesc coverImg:coverUrl createUserNo:snsLeaderNo createUserNm:createUserNm createDate:today compNo:compNo snsKind:snsKind];
                    [appDelegate.dbHelper crudStatement:sqlString];
                    
                    if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]){
                        //                    [self dismissViewControllerAnimated:YES completion:^(void){
                        //                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ModifyBoard" object:nil userInfo:editSnsInfo];
                        //                    }];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ModifyBoard" object:nil userInfo:editSnsInfo];
                        
                        //[self dismissViewControllerAnimated:YES completion:nil];
                        [self dismissViewControllerAnimated:YES completion:^(void){
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamSelect"
                                                                                object:nil
                                                                              userInfo:editSnsInfo];
                        }];
                        
                    } else {
                        [self dismissViewControllerAnimated:YES completion:^(void){
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SaveBoard"
                                                                                object:nil
                                                                              userInfo:@{@"RESULT":@"SUCCESS", @"SNS_KIND":snsKind}];
                        }];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_DismissTeamList" object:nil userInfo:nil];
                }
                
            } else {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"exception_msg_unknownhostexception", @"exception_msg_unknownhostexception") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSessionUpload Delegate
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error{
    coverUrl = @"";
    [SVProgressHUD dismiss];
    
    if (error != nil) {
        
    }else{
        if(dictionary != nil){
            [self.imageFileNameArray addObject:[dictionary objectForKey:@"FILE_URL"]];
            
            if ([dictionary objectForKey:@"FILE_URL"]==nil) {
                
            } else{
                coverUrl = [dictionary objectForKey:@"FILE_URL"];
                [self callWebService:@"createSNS"];
            }
        } else {
            //데이터,와이파이 둘 다 꺼져있을경우
            NSLog(@"인터넷 연결이 오프라인으로 나타납니다.");
        }
        
    }
}

- (void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error{
    NSLog(@"%@", error);
}


#pragma mark - UITableView Delegate & Datasrouce
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.keyArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BoardCreateViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BoardCreateViewCell"];
    if(cell == nil){
        cell = [[BoardCreateViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"BoardCreateViewCell"];
    }
    
    @try{
        cell.keyLabel.text = [self.keyArray objectAtIndex:indexPath.row];
        
        cell.editButton.imageView.image=nil;
        [cell.editButton setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
        
        if(indexPath.row == 0){
            cell.valueLabel.text = [NSString urlDecodeString:snsName];
            [cell.editButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_edit.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
            [cell.editButton setTitle:nil forState:UIControlStateNormal];
            
        }
        
        if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]){
            if(indexPath.row == 1){
                cell.valueLabel.text = snsLeader;
                [cell.editButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_tree_close.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
                [cell.editButton setTitle:nil forState:UIControlStateNormal];
                
            } else if(indexPath.row == 2){
                cell.valueLabel.text = [snsKindDic objectForKey:snsKind];
                [cell.editButton setImage:nil forState:UIControlStateNormal];
                [cell.editButton setTitle:@"변경" forState:UIControlStateNormal];
                cell.editButton.hidden = YES;
                
            }
            
            if(_currSnsKind==1){
                if(indexPath.row == 3){
                    cell.valueLabel.text = [snsTypeDic objectForKey:snsType];
                    [cell.editButton setImage:nil forState:UIControlStateNormal];
                    [cell.editButton setTitle:@"변경" forState:UIControlStateNormal];
                    
                } else if(indexPath.row == 4){
                    cell.valueLabel.text = [snsAllowDic objectForKey:snsAllow];
                    [cell.editButton setImage:nil forState:UIControlStateNormal];
                    [cell.editButton setTitle:@"변경" forState:UIControlStateNormal];
                    
                } else if(indexPath.row == 5){
                    cell.valueLabel.text = snsDesc;
                    [cell.editButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_edit.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
                    [cell.editButton setTitle:nil forState:UIControlStateNormal];
                }
            } else if(_currSnsKind==2){
                if(indexPath.row == 3){
                    cell.valueLabel.text = snsDesc;
                    [cell.editButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_edit.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
                    [cell.editButton setTitle:nil forState:UIControlStateNormal];
                }
            }
        } else {
            if(indexPath.row == 1){
                cell.valueLabel.text = [snsKindDic objectForKey:snsKind];
                [cell.editButton setImage:nil forState:UIControlStateNormal];
                [cell.editButton setTitle:@"변경" forState:UIControlStateNormal];
                cell.editButton.hidden = NO;
                
                if([[MFSingleton sharedInstance] useTask]) {
                    cell.editButton.hidden = NO;
                }
                else {
                    cell.editButton.hidden = YES;
                    cell.editBtnConstraint.constant = 0;
                    cell.editBtnSpaceConstraint.constant = 0;
                }
                
            } else if(indexPath.row == 2){
                cell.valueLabel.text = [snsTypeDic objectForKey:snsType];
                [cell.editButton setImage:nil forState:UIControlStateNormal];
                [cell.editButton setTitle:@"변경" forState:UIControlStateNormal];
                
                if([snsKind intValue]==1) {
                    cell.editButton.hidden = NO;
                } else if([snsKind intValue]==2){
                    cell.editButton.hidden = YES;
                }
                
            } else if(indexPath.row == 3){
                cell.valueLabel.text = [snsAllowDic objectForKey:snsAllow];
                [cell.editButton setImage:nil forState:UIControlStateNormal];
                [cell.editButton setTitle:@"변경" forState:UIControlStateNormal];
                
                if([snsKind intValue]==1) {
                    cell.editButton.hidden = NO;
                } else if([snsKind intValue]==2){
                    cell.editButton.hidden = YES;
                }
                
            } else if(indexPath.row == 4){
                cell.valueLabel.text = [NSString urlDecodeString:snsDesc];
                [cell.editButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_edit.png"] scaledToMaxWidth:20.0f] forState:UIControlStateNormal];
                [cell.editButton setTitle:nil forState:UIControlStateNormal];
            }
        }
        
        return cell;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    @try{
        if(indexPath.row == 0){
            [self performSegueWithIdentifier:@"BOARD_TO_MY_MSG_PUSH" sender:indexPath];
            
        }
        
        if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]){
            if(indexPath.row == 1){
                [self performSegueWithIdentifier:@"BOARD_CHANGE_LEADER_PUSH" sender:nil];
                
            }
            
            if(_currSnsKind==1){
                if(indexPath.row == 3){
                    BoardTypeViewController *vc = [[BoardTypeViewController alloc] init];
                    vc.fromSegue = @"SELECT_SNS_TYPE";
                    if([snsType integerValue]==3) vc.codeNo=@"0";
                    //else if([snsType integerValue]==2) vc.codeNo=@"1";
                    else if([snsType integerValue]==1) vc.codeNo=@"1";//vc.codeNo=@"2";
                    [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
                    
                } else if(indexPath.row == 4){
                    BoardTypeViewController *vc = [[BoardTypeViewController alloc] init];
                    vc.fromSegue = @"SELECT_SNS_ALLOW";
                    vc.codeNo = snsAllow;
                    [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
                    
                } else if(indexPath.row == 5){
                    [self performSegueWithIdentifier:@"BOARD_TO_MY_MSG_PUSH" sender:indexPath];
                    
                }
                
            } else if(_currSnsKind==2){
                if(indexPath.row == 3){
                    [self performSegueWithIdentifier:@"BOARD_TO_MY_MSG_PUSH" sender:indexPath];
                }
                
            } else {
                
            }
            
        } else {
            if(indexPath.row == 1){
                BoardTypeViewController *vc = [[BoardTypeViewController alloc] init];
                vc.fromSegue = @"SELECT_SNS_KIND";
                if([snsKind integerValue]==1) vc.codeNo=@"0";
                else if([snsKind integerValue]==2) vc.codeNo=@"1";
                
                if([[MFSingleton sharedInstance] useTask]) [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
                
            }
            else if(indexPath.row == 2){
                if([snsKind intValue]==1) {
                    BoardTypeViewController *vc = [[BoardTypeViewController alloc] init];
                    vc.fromSegue = @"SELECT_SNS_TYPE";
                    if([snsType integerValue]==3) vc.codeNo=@"0";
                    //else if([snsType integerValue]==2) vc.codeNo=@"1";
                    else if([snsType integerValue]==1) vc.codeNo=@"1";//vc.codeNo=@"2";
                    [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
                }
                
                
            } else if(indexPath.row == 3){
                if([snsKind intValue]==1) {
                    BoardTypeViewController *vc = [[BoardTypeViewController alloc] init];
                    vc.fromSegue = @"SELECT_SNS_ALLOW";
                    vc.codeNo = snsAllow;
                    [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
                }
                
            } else if(indexPath.row == 4){
                [self performSegueWithIdentifier:@"BOARD_TO_MY_MSG_PUSH" sender:indexPath];
                
            } else {
                
            }
        }
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getImageNotification:) name:@"getImageNotification" object:nil];
    
    @try{
        if([segue.identifier isEqualToString:@"BOARD_TO_MY_MSG_PUSH"]){
            NSIndexPath *indexPath = sender;
            MyMessageViewController *destination = segue.destinationViewController;
            if(indexPath.row==0){
                destination.fromSegue = @"BOARD_MSG_NAME";
                destination.statusMsg = [NSString urlDecodeString:snsName];
            } else {
                destination.fromSegue = @"BOARD_MSG_DESC";
                destination.statusMsg = snsDesc;
            }
        } else if ([segue.identifier isEqualToString:@"BOARD_CHANGE_LEADER_PUSH"]){
            ChangeLeaderViewController *destination = segue.destinationViewController;
            destination.snsNo = self.snsNo;
            destination.leaderNo = snsLeaderNo;
            self.navigationController.navigationBar.topItem.title = @"";
            
        } else if([segue.identifier isEqualToString:@"BOARD_PHLIB_MODAL"]){
            UINavigationController *destination = segue.destinationViewController;
            PHLibListViewController *vc = [[destination childViewControllers] objectAtIndex:0];
            vc.fromSegue = segue.identifier;
            vc.listType = sender;
            destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - Notification
- (void)noti_ChangeSubInfo1:(NSNotification *)notification{
    NSString *type = [notification.userInfo objectForKey:@"TYPE"];
    NSIndexPath *indexPath=nil;
    
    @try{
        if([type isEqualToString:@"NAME"]){
            snsName = [notification.userInfo objectForKey:@"SNS_NAME"];
            indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            
        } else if([type isEqualToString:@"DESC"]){
            snsDesc = [notification.userInfo objectForKey:@"SNS_DESC"];
            
            if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]){
                if(_currSnsKind==1){
                    indexPath = [NSIndexPath indexPathForItem:5 inSection:0];
                } else if(_currSnsKind==2){
                    indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
                }
                
            } else {
                indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
            }
        }
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}
- (void)noti_ChangeSubInfo2:(NSNotification *)notification{
    NSLog(@"userInfo : %@", notification.userInfo);
    
    NSIndexPath *indexPath=nil;
    NSString *type = [notification.userInfo objectForKey:@"TYPE"];
    
    @try{
        if([type isEqualToString:@"KIND"]){
            [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
            
            snsKind = [notification.userInfo objectForKey:@"SNS_KIND"];
            if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]){
                //indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
                if(_currSnsKind==1){
                    indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
                } else if(_currSnsKind==2){
                    
                }
                
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
                
            } else {
                //indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
                [self.tableView reloadData];
            }
            //            [self.tableView beginUpdates];
            //            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //            [self.tableView endUpdates];
            
        } else if([type isEqualToString:@"TYPE"]){
            [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
            
            snsType = [notification.userInfo objectForKey:@"SNS_TYPE"];
            if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]){
                //indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
                if(_currSnsKind==1){
                    indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
                } else if(_currSnsKind==2){
                    
                }
            } else {
                indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
            }
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
        } else if([type isEqualToString:@"ALLOW"]){
            [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
            
            snsAllow = [notification.userInfo objectForKey:@"SNS_ALLOW"];
            if([self.fromSegue isEqualToString:@"BOARD_MODIFY_PUSH"]){
                //indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
                if(_currSnsKind==1){
                    indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
                } else if(_currSnsKind==2){
                    
                }
            } else {
                indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
            }
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
        } else if([type isEqualToString:@"LEADER"]){
            snsLeader = [notification.userInfo objectForKey:@"CREATE_USER_NM"];
            snsLeaderNo = [notification.userInfo objectForKey:@"CREATE_USER_NO"];
            
            [self callWebService:@"createSNS"];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)getImageNotification:(NSNotification *)notification {
    isChangeCover = YES;
    self.imageArray = [notification.userInfo objectForKey:@"IMG_LIST"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getImageNotification" object:nil];
    //[self saveAttachedFile:notification.userInfo];
    
    self.croppingStyle = TOCropViewCroppingStyleDefault;
    TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:[self.imageArray objectAtIndex:0]];
    cropController.delegate = self;
    self.image = [self.imageArray objectAtIndex:0];
    [self presentViewController:cropController animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
    }else{
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        isChangeCover = YES;
        
        UIImage *rotateImg = nil;
        if(image.size.width>image.size.height){
            rotateImg = [MFUtil rotateImage:image byOrientationFlag:image.imageOrientation];
        } else {
            rotateImg = [MFUtil rotateImage90:image];
        }
        
        self.croppingStyle = TOCropViewCroppingStyleDefault;
        TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:rotateImg];
        cropController.delegate = self;
        self.image = rotateImg;
        [self presentViewController:cropController animated:YES completion:nil];
    }
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
                                                                 [self saveAttachedFile:image];
                                                             }];
        }
        
    }
}

@end
