//
//  PostModifyTableViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 11. 8..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "PostModifyTableViewController.h"
#import "SDImageCache.h"
#import "TextTableViewCell.h"
#import "ImageTableViewCell.h"
#import "VideoTableViewCell.h"
#import "MFDBHelper.h"
#import "PHLibListViewController.h"
#import "PostOrderModifyViewController.h"
#import "FileTableViewCell.h"

@interface PostModifyTableViewController () {
    AppDelegate *appDelegate;
    UIImage *thumbImage;
    SDImageCache *imgCache;
    NSMutableArray *dataArr;
    
    NSRange textRange;
    UITextView *currTextView;
    NSString *firstText;
    NSString *secondText;
    
    BOOL isSplit;
    int fileNameCnt;
    
    NSString *mediaType;
    NSMutableArray *contentFileArr;
    NSString *videoThumbName;
    
    NSMutableArray *convertFileArr;
    int setCount;
    NSMutableArray *resultArr;
    
    NSMutableArray *resultCommArr;
    NSInteger prevLoc;
    NSInteger prevLen;
    NSMutableAttributedString *commAttrStr;
    
    NSString *textVal;
    int attrCount;
    BOOL isTagSpace;
    
    BOOL isAddImg; //이미지 추가했는지 안했는지. 수정화면에서 이미지 추가 후 순서편집 시 에러
    NSMutableArray *firstArr;
    
    BOOL isKeyboardShow;
}

@property (strong, nonatomic) TextTableViewCell *textCell;

@end

@implementation PostModifyTableViewController

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    
    isAddImg = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TeamExit:) name:@"noti_TeamExit" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"done", @"done")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(rightSideMenuButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(leftBackButtonPressed:)];
    
    self.contentImageArray = [NSMutableArray array];
    self.filePathArray = [NSMutableArray array];
    self.fileThumbPathArray = [NSMutableArray array];
    self.fileNameArray = [NSMutableArray array];
    contentFileArr = [NSMutableArray array];
    dataArr = [NSMutableArray array];
    convertFileArr = [NSMutableArray array];
    
    resultCommArr = [NSMutableArray array];
    
    uploadCount = 0;
    mediaType = @"";
    
    prevLoc = 0;
    prevLen = 0;
    
    isKeyboardShow = NO;
    
    imgCache = [SDImageCache sharedImageCache];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    [imgCache makeDiskCachePath:cachePath];
    
    @try {
        if([self.isEdit isEqualToString:@"COMMENT"]){
            self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"popup_comment_edit", @"popup_comment_edit")];
            
            NSString *comment = [self.commDic objectForKey:@"CONTENT"];
            NSError *jsonError;
            NSData *commData = [[NSString urlDecodeString:comment] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
            
            self.toolBar.items = nil;

            dataArr = [[NSMutableArray alloc] initWithArray:jsonArr];
            [self commentSetTableData:dataArr];
            
        } else if([self.isEdit isEqualToString:@"POST"]){
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
            
            self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"post_edit", @"post_edit")];
            dataArr = [[NSMutableArray alloc] initWithArray:[self.postDic objectForKey:@"CONTENT"]];
            
            //이미지 캐시 저장
            int dataArrCnt = (int)dataArr.count;
            for(int i=0; i<dataArrCnt; i++){
                if([[[dataArr objectAtIndex:i] objectForKey:@"TYPE"] isEqualToString:@"IMG"]){
                    NSString *originImg = [[[dataArr objectAtIndex:i] objectForKey:@"VALUE"] objectForKey:@"ORIGIN"];
                    UIImage *img = [MFUtil saveThumbImage:@"Cache" path:[NSString urlDecodeString:originImg] num:nil];
                    if(img!=nil){
                        [imgCache storeImage:[MFUtil getScaledImage:img scaledToMaxWidth:self.view.frame.size.width-10] forKey:[NSString urlDecodeString:originImg] toDisk:YES];
                    }
                }
            }
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHandler:)];
            [self.tableView addGestureRecognizer:tap];
        }
        
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)keyboardWillAnimate:(NSNotification *)notification{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    NSDictionary* info = [notification userInfo];

    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if (@available(iOS 11.0, *)) {
        kbSize.height = kbSize.height - self.view.safeAreaInsets.bottom;
    } else {
        kbSize.height = kbSize.height;
    }
    
    if ([notification name]==UIKeyboardWillShowNotification) {
        isKeyboardShow = YES;
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"done", @"done")
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(rightSideMenuButtonPressed:)];
        self.keyboardHeight.constant = kbSize.height;
        [self.view layoutIfNeeded];
        
    }else if([notification name]==UIKeyboardWillHideNotification){
        isKeyboardShow = NO;
        self.keyboardHeight.constant = 0;
        [self.view layoutIfNeeded];
    }
    [UIView commitAnimations];
}

#pragma mark - UINavigationBar Button Action
- (void)leftSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftBackButtonPressed:(id)sender {
    NSString *msg;
    if([self.isEdit isEqualToString:@"COMMENT"]){
        msg = NSLocalizedString(@"post_comment_edit_cancel", @"post_comment_edit_cancel");
    } else if([self.isEdit isEqualToString:@"POST"]){
        msg = NSLocalizedString(@"post_edit_save_cancel1", @"post_edit_save_cancel1");
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [alert addAction:okButton];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)rightSideMenuButtonPressed:(id)sender {
    @try{
        [self.view endEditing:YES];
        
        NSLog(@"dataarrrr : %@", dataArr);

//        if([self.isEdit isEqualToString:@"COMMENT"]){
//            NSString *comm = [[dataArr objectAtIndex:0] objectForKey:@"TEXT"];
//            if([comm length]>0){
//                self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save", @"save")
//                                                                                        style:UIBarButtonItemStylePlain
//                                                                                       target:self
//                                                                                       action:@selector(saveButtonPressed:)];
//            } else {
//                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"post_save_content_null", @"post_save_content_null") preferredStyle:UIAlertControllerStyleAlert];
//                [self presentViewController:alert animated:YES completion:nil];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [alert dismissViewControllerAnimated:YES completion:nil];
//                });
//            }
//
//
//        } else {
            int count = (int)dataArr.count;
            
            int firstTxtCnt = 0;
            int firstImgCnt = 0;
            int firstFileCnt = 0;
            firstArr = [NSMutableArray array];
            
            for(int i=0; i<count; i++){
                NSString *type = [[dataArr objectAtIndex:i] objectForKey:@"TYPE"];
                NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
                
                if([type isEqualToString:@"IMG"]){
                    NSDictionary *valueDic = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    
                    if([valueDic objectForKey:@"TMP_IMG"]){
                        UIImage *imgValue = [valueDic objectForKey:@"TMP_IMG"];
                        UIImage *orgValue = [valueDic objectForKey:@"TMP_IMG"];
                        
                        [dataDic setObject:@"IMG" forKey:@"TYPE"];
                        [dataDic setObject:imgValue forKey:@"VALUE"];
//                        [dataDic setObject:[NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]] forKey:@"ORIGIN"];
                        [dataDic setObject:orgValue forKey:@"ORIGIN"];
                        [contentFileArr addObject:dataDic];
                        
                        //[dict setObject:[NSString stringWithFormat:@"%@",imgValue] forKey:@"VALUE"];
                        NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                        [dict2 setObject:imgValue forKey:@"TMP_IMG"];
                        [dict setObject:dict2 forKey:@"VALUE"];
                        
                    } else if([valueDic objectForKey:@"ORIGIN"]){
                        //[dict setObject:[valueDic objectForKey:@"ORIGIN"] forKey:@"VALUE"];
                        NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                        [dict2 setObject:[NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]] forKey:@"ORIGIN"];
                        [dict2 setObject:[NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]] forKey:@"THUMB"];
                        [dict setObject:dict2 forKey:@"VALUE"];
                    }
                    
                    [dataArr replaceObjectAtIndex:i withObject:dict];
                    
                } else if([type isEqualToString:@"VIDEO"]){
                    NSDictionary *valueDic = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];

                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"VIDEO" forKey:@"TYPE"];
                    
                    if([valueDic objectForKey:@"VIDEO_ASSET"]){
                        //앨범에서 가져온 비디오
                        PHAsset *value = [valueDic objectForKey:@"VIDEO_ASSET"];
                        
                        [dataDic setObject:@"VIDEO" forKey:@"TYPE"];
                        [dataDic setObject:value forKey:@"VIDEO_VALUE"];
                        [dataDic setObject:[NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]] forKey:@"ORIGIN"];
                        [contentFileArr addObject:dataDic];
                        
                        if([valueDic objectForKey:@"TMP_IMG"]){
                            UIImage *imgValue = [valueDic objectForKey:@"TMP_IMG"];
                            
                            NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                            [dict2 setObject:imgValue forKey:@"TMP_IMG"];
                            [dict setObject:dict2 forKey:@"VALUE"];
                        }
                        
                    } else if([valueDic objectForKey:@"RECORD_ASSET"]){
                        //촬영한 비디오
                        AVURLAsset *value = [valueDic objectForKey:@"RECORD_ASSET"];
                        
                        [dataDic setObject:@"VIDEO" forKey:@"TYPE"];
                        [dataDic setObject:value forKey:@"RECORD_VALUE"];
                        [dataDic setObject:[NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]] forKey:@"ORIGIN"];
                        [contentFileArr addObject:dataDic];
                        
                        if([valueDic objectForKey:@"TMP_IMG"]){
                            UIImage *imgValue = [valueDic objectForKey:@"TMP_IMG"];
                            
                            NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                            [dict2 setObject:imgValue forKey:@"TMP_IMG"];
                            [dict setObject:dict2 forKey:@"VALUE"];
                        }
                        
                    } else if([valueDic objectForKey:@"ORIGIN"]){
                        NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                        [dict2 setObject:[NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]] forKey:@"ORIGIN"];
                        [dict2 setObject:[NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]] forKey:@"THUMB"];
                        [dict setObject:dict2 forKey:@"VALUE"];
                    }
                    
                    [dataArr replaceObjectAtIndex:i withObject:dict];
                
                } else if([type isEqualToString:@"FILE"]){
//                    NSString *value = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
//                    NSData *data = [[dataArr objectAtIndex:i] objectForKey:@"FILE_DATA"];
//                    [dataDic setObject:@"FILE" forKey:@"TYPE"];
//                    [dataDic setObject:value forKey:@"VALUE"];
//                    [dataDic setObject:data forKey:@"FILE_DATA"];
//                    [dataDic setObject:[[dataArr objectAtIndex:i] objectForKey:@"FILE_NM"] forKey:@"FILE_NM"];
//
//                    [contentFileArr addObject:dataDic];
                    
                    if([[dataArr objectAtIndex:i] objectForKey:@"FILE_DATA"]!=nil){
                        
                        //새로 추가한 파일
                        NSData *data = [[dataArr objectAtIndex:i] objectForKey:@"FILE_DATA"];
                        NSString *value = [NSString urlDecodeString:[[dataArr objectAtIndex:i] objectForKey:@"VALUE"]];
                        NSString *fileName = [[dataArr objectAtIndex:i] objectForKey:@"FILE_NM"];
                        
                        [dataDic setObject:@"FILE" forKey:@"TYPE"];
                        [dataDic setObject:value forKey:@"VALUE"];
                        [dataDic setObject:data forKey:@"FILE_DATA"];
                        [dataDic setObject:fileName forKey:@"FILE_NM"];
                        [contentFileArr addObject:dataDic];
                        
                    } else {
                        NSString *value = [NSString urlDecodeString:[[dataArr objectAtIndex:i] objectForKey:@"VALUE"]];
                        
                        [dataDic setObject:@"FILE" forKey:@"TYPE"];
                        [dataDic setObject:value forKey:@"VALUE"];
                        
                        [dataArr replaceObjectAtIndex:i withObject:dataDic];
                    }
                    
                } else if([type isEqualToString:@"TEXT"]){
                    NSString *value;
                    if([self.isEdit isEqualToString:@"COMMENT"]){
                        value = [NSString urlDecodeString:[[dataArr objectAtIndex:i] objectForKey:@"TEXT"]];
                    } else {
                        value = [NSString urlDecodeString:[[dataArr objectAtIndex:i] objectForKey:@"VALUE"]];
                    }
                    
                    [dataDic setObject:@"TEXT" forKey:@"TYPE"];
                    [dataDic setObject:value forKey:@"VALUE"];
                    
                    [dataArr replaceObjectAtIndex:i withObject:dataDic];
                }
                
                if([type isEqualToString:@"TEXT"]&&firstTxtCnt==0){
                    NSString *prevStr = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
//                    NSUInteger textByte = [prevStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//                    if(textByte > 200) {
//                        NSData *contentData = [prevStr dataUsingEncoding:NSUTF8StringEncoding];
//                        contentData = [contentData subdataWithRange:NSMakeRange(0, 200)];
//                        prevStr = [[NSString alloc] initWithBytes:[contentData bytes] length:[contentData length] encoding:NSUTF8StringEncoding];
//                    }
                    
                    if([self.isEdit isEqualToString:@"COMMENT"]){
                        if(prevStr.length > 500) {
                            prevStr = [prevStr substringWithRange:NSMakeRange(0, 500)];
                        }
                    } else {
                        if(prevStr.length > 200) {
                            prevStr = [prevStr substringWithRange:NSMakeRange(0, 200)];
                        }
                    }
                    
                    NSLog(@"modi prev : %@", prevStr);
                    
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
//                    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save", @"save")
//                                                                                            style:UIBarButtonItemStylePlain
//                                                                                           target:self
//                                                                                           action:@selector(saveButtonPressed:)];
                    [self saveButtonPressed:nil];
                }
            } else {
//                self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"save", @"save")
//                                                                                        style:UIBarButtonItemStylePlain
//                                                                                       target:self
//                                                                                       action:@selector(saveButtonPressed:)];
                [self saveButtonPressed:nil];
            }
            
//        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)saveButtonPressed:(id)sender {
    @try{
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
        if([self.isEdit isEqualToString:@"COMMENT"]){
            if([self.fromSegue isEqualToString:@"MODIFY_TASK_COMMENT"]){
                NSString *commentNo = [self.commDic objectForKey:@"DATA_NO"];
                
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArr options:0 error:&error];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                jsonString = [jsonString stringByReplacingOccurrencesOfString:@"%0A" withString:@"%5Cn"];
                
                NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&taskNo=%@&commentNo=%@&content=%@&isNewComment=false", myUserNo, self.snsNo, self.taskNo, commentNo, jsonString];
                [self callWebService:@"saveTaskComment" WithParameter:paramString];

            } else {
                [self setCommentMsg];
                
            }
            
        } else if([self.isEdit isEqualToString:@"POST"]){
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
            
            if (contentFileArr.count>0) {
                [self convertDataSet:contentFileArr];
                
            }else{
                for(int i=0; i<dataArr.count; i++){
                    NSString *type = [[dataArr objectAtIndex:i] objectForKey:@"TYPE"];
                    if([type isEqualToString:@"TEXT"]){
                        
                    } else if([type isEqualToString:@"IMG"]){
                        NSDictionary *valueDict = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
                        NSString *imagePath = [valueDict objectForKey:@"ORIGIN"];
                        [[dataArr objectAtIndex:i] setObject:imagePath forKey:@"VALUE"];
                        
                    } else if([type isEqualToString:@"VIDEO"]){
                        NSDictionary *valueDict = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
                        NSString *imagePath = [valueDict objectForKey:@"ORIGIN"];
                        [[dataArr objectAtIndex:i] setObject:imagePath forKey:@"VALUE"];
                    
                    } else if([type isEqualToString:@"FILE"]){
                        //NSString *filePath = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
                        //[[dataArr objectAtIndex:i] setObject:filePath forKey:@"VALUE"];
                    }
                }
                
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArr options:0 error:&error];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                jsonString = [jsonString urlEncodeUsingEncoding:NSUTF8StringEncoding];
//                jsonString = [jsonString stringByReplacingOccurrencesOfString:@"%0A" withString:@"%5Cn"];
                
                NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
                
                NSData *prevData = [NSJSONSerialization dataWithJSONObject:firstArr options:0 error:&error];
                NSString *prevString = [[NSString alloc] initWithData:prevData encoding:NSUTF8StringEncoding];
                prevString = [prevString urlEncodeUsingEncoding:NSUTF8StringEncoding];
//                prevString = [prevString stringByReplacingOccurrencesOfString:@"%0A" withString:@"%5Cn"];
                
                NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@&feed_content=%@", myUserNo, self.snsNo, self.postNo, jsonString, prevString];
                NSLog(@"post modi param : %@", paramString);
//                NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@",myUserNo, self.snsNo, self.postNo, jsonString];
                [self callWebService:@"savePost" WithParameter:paramString];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)setCommentMsg{
    NSMutableArray *testArr = [NSMutableArray array];
    textVal = @"";
    attrCount = 0;
    isTagSpace = NO;
    
    @try{
        [commAttrStr enumerateAttributesInRange:NSMakeRange(0, commAttrStr.length)
                                        options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                     usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop){
            NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
            
            UIFont *currentFont = [mutableAttributes objectForKey:NSFontAttributeName];
            NSString *currFontName = [currentFont.fontName lowercaseString];
            
            NSMutableDictionary *testDic = [NSMutableDictionary dictionary];
            
            if([currFontName rangeOfString:@"bold"].location!=NSNotFound){
                if(![[commAttrStr attributedSubstringFromRange:range].string isEqualToString:@" "]){
                    NSString *userInfo = [mutableAttributes objectForKey:NSLinkAttributeName];
                    NSRange infoRange = [userInfo rangeOfString:@"&" options:0];
                    NSString *userNo = [userInfo substringToIndex:infoRange.location];
                    NSString *userId = [userInfo substringFromIndex:infoRange.location+1];
                    
                    [testDic setObject:[commAttrStr attributedSubstringFromRange:range].string forKey:@"TARGET_NM"];
                    [testDic setObject:userNo forKey:@"TARGET_NO"];
                    [testDic setObject:userId forKey:@"TARGET_ID"];
                    [testArr addObject:testDic];
                    
                    attrCount++;
                }
            } else {
                //if(![[commAttrStr attributedSubstringFromRange:range].string isEqualToString:@" "]){
                NSString *str = [commAttrStr attributedSubstringFromRange:range].string;
                
                if(isTagSpace){
                    if([[str substringToIndex:1] isEqualToString:@" "]) str = [str substringFromIndex:1];
                    isTagSpace = NO;
                }
                
                if(testArr.count>0){
                    if([[testArr objectAtIndex:attrCount-1] objectForKey:@"TEXT"]!=nil){
                        textVal = [textVal stringByAppendingString:str];
                        [testDic setObject:textVal forKey:@"TEXT"];
                        [testArr replaceObjectAtIndex:attrCount-1 withObject:testDic];
                        
                    } else {
                        textVal = str;
                        [testDic setObject:textVal forKey:@"TEXT"];
                        [testArr addObject:testDic];
                        
                        attrCount++;
                    }
                } else {
                    textVal = str;
                    [testDic setObject:textVal forKey:@"TEXT"];
                    [testArr addObject:testDic];
                    
                    attrCount++;
                }
                //}
            }
        }];
        
        NSMutableArray *commDataArr = [NSMutableArray array];
        NSMutableArray *targetArr = [NSMutableArray array];
        
        for(int i=0; i<testArr.count; i++){
            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
            NSMutableDictionary *targetDic = [NSMutableDictionary dictionary];
            
            if([[testArr objectAtIndex:i] objectForKey:@"TEXT"]!=nil){
                if(i==0){
                    //                NSLog(@"첫번째데이터가 텍스트일 경우");
                    NSMutableArray *emptyTargetArr = [NSMutableArray array];
                    [dataDic setObject:@"TEXT" forKey:@"TYPE"];
                    [dataDic setObject:emptyTargetArr forKey:@"TARGET"];
                    [dataDic setObject:[[testArr objectAtIndex:i] objectForKey:@"TEXT"] forKey:@"TEXT"];
                    
                    [commDataArr addObject:dataDic];
                    
                } else{
                    if([[testArr objectAtIndex:i-1] objectForKey:@"VALUE"]==nil){
                        [dataDic setObject:@"TEXT" forKey:@"TYPE"];
                        [dataDic setObject:targetArr forKey:@"TARGET"];
                        [dataDic setObject:[[testArr objectAtIndex:i] objectForKey:@"TEXT"] forKey:@"TEXT"];
                        
                        targetArr = [NSMutableArray array];
                        
                        [commDataArr addObject:dataDic];
                        
                    } else if([[testArr objectAtIndex:i-1] objectForKey:@"VALUE"]!=nil){
                        [dataDic setObject:@"TEXT" forKey:@"TYPE"];
                        [dataDic setObject:[[commDataArr objectAtIndex:i-1] objectForKey:@"TARGET"] forKey:@"TARGET"];
                        
                        NSString *value = [[[testArr objectAtIndex:i-1] objectForKey:@"TEXT"] stringByAppendingString:[[testArr objectAtIndex:i] objectForKey:@"TEXT"]];
                        [dataDic setObject:value forKey:@"TEXT"];
                        
                        [commDataArr replaceObjectAtIndex:i-1 withObject:dataDic];
                        
                    }
                }
                
            } else if([[testArr objectAtIndex:i] objectForKey:@"TARGET_NO"]!=nil){
                [targetDic setObject:[[testArr objectAtIndex:i] objectForKey:@"TARGET_NO"] forKey:@"USER_NO"];
                [targetDic setObject:[[testArr objectAtIndex:i] objectForKey:@"TARGET_NM"] forKey:@"USER_NM"];
                [targetDic setObject:[[testArr objectAtIndex:i] objectForKey:@"TARGET_ID"] forKey:@"USER_ID"];
                
                [targetArr addObject:targetDic];
                
                if (i==testArr.count-1){
                    //마지막데이터가 태그일 경우
                    [dataDic setObject:@"TEXT" forKey:@"TYPE"];
                    [dataDic setObject:targetArr forKey:@"TARGET"];
                    [dataDic setObject:@"" forKey:@"TEXT"];
                    
                    [commDataArr addObject:dataDic];
                }
            }
        }
        
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSString *commentNo = [self.commDic objectForKey:@"COMMENT_NO"];
        NSString *postUsrNo = [self.postDic objectForKey:@"CUSER_NO"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commDataArr options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString urlEncodeUsingEncoding:NSUTF8StringEncoding];
        
        NSData *prevData = [NSJSONSerialization dataWithJSONObject:firstArr options:0 error:&error];
        NSString *prevString = [[NSString alloc] initWithData:prevData encoding:NSUTF8StringEncoding];
        prevString = [prevString urlEncodeUsingEncoding:NSUTF8StringEncoding];
        
        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&commentNo=%@&content=%@&isNewComment=false&postUsrNo=%@&feed_content=%@", myUserNo, self.snsNo, self.postNo, commentNo, jsonString, postUsrNo, prevString];
        NSLog(@"comm modify param : %@", jsonString);
        [self callWebService:@"savePostComment" WithParameter:paramString];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - Post write
- (void)tapHandler:(UITapGestureRecognizer *)recognizer {
    //텍스트 뷰 추가하기 위한 로직
    NSIndexPath *tapPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
    isSplit = NO;
    int count = (int)dataArr.count;

    @try {
        //텍스트뷰 추가는 탭한 곳이 이미지고(이미지가 있는 로우의 하단 1/4정도라면), 다음 로우도 이미지 일때 (탭한 곳 밑에 추가)
        //탭한 곳이 이미지고(이미지가 있는 로우의 상단단 1/4정도라면), 이전 로우도 이미지 일때 (탭한 곳 위에 추가)
        //-> 이렇게 하지말고, 기준은 항상 뷰의 아래! 무조건 아래에 추가하는 걸로.
        
        if(isKeyboardShow){
            NSLog(@"키보드 올라와있음");
            [self.view endEditing:YES];
            
            NSLog(@"show dataArr[cnt : %lu / tap : %ld] : %@", (unsigned long)dataArr.count, (long)tapPath.row, dataArr);
            if([self.isEdit isEqualToString:@"COMMENT"]){
                
            } else {
                if(count > 0){
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
                        if(count > 1 && count > tapPath.row+1){
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
                                    
                                    [UIView performWithoutAnimation:^{
                                        [self.tableView reloadData];
                                    }];
                                    
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
                
            }
            
        } else {
            NSLog(@"키보드 내려가있음");
            NSLog(@"hide dataArr[cnt : %lu / tap : %ld] : %@", (unsigned long)dataArr.count, (long)tapPath.row, dataArr);
            
            if([self.isEdit isEqualToString:@"COMMENT"]){
                
            } else {
                if(count > 0){
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
                                    
                                    [UIView performWithoutAnimation:^{
                                        [self.tableView reloadData];
                                    }];
                                    
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
                    
                    [UIView performWithoutAnimation:^{
                        [self.tableView reloadData];
                    }];
                }
            }
        }
        
        
        /*
        NSString *currDataType = [[dataArr objectAtIndex:tapPath.row] objectForKey:@"TYPE"];
        
        if([self.isEdit isEqualToString:@"COMMENT"]){
//            if(dataArr.count>0){
//                NSString *comment = [NSString urlDecodeString:[dataArr objectAtIndex:0]];
//                NSError *jsonError;
//                NSData *commData = [comment dataUsingEncoding:NSUTF8StringEncoding];
//                NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
//                NSString *value = [[jsonArr objectAtIndex:0] objectForKey:@"VALUE"];
//                NSString *type = [[jsonArr objectAtIndex:0] objectForKey:@"TYPE"];
//
//                if([type isEqualToString:@"TEXT"]){
//
//                } else if([type isEqualToString:@"IMG"]){
//                    NSLog(@"사진을 삭제하고 텍스트를 추가하시겠습니까?");
//
//                } else if([type isEqualToString:@"VIDEO"]){
//                    NSLog(@"동영상을 삭제하고 텍스트를 추가하시겠습니까?");
//
//                } else if([type isEqualToString:@"FILE"]){
//                    NSLog(@"파일을 삭제하고 텍스트를 추가하시겠습니까?");
//
//                } else {
//
//                }
//
//            } else {
//                //데이터 아무것도 없을 때 텍스트추가.
//                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//                [dict setObject:@"TEXT" forKey:@"TYPE"];
//                [dict setObject:@"" forKey:@"VALUE"];
//                [dict setObject:@"ALL" forKey:@"TARGET"];
//                [dataArr addObject:dict];
//
//                [UIView performWithoutAnimation:^{
//                    [self.tableView reloadData];
//                }];
//            }
        } else {
            if(tapPath.row==0&&([currDataType isEqualToString:@"IMG"]||[currDataType isEqualToString:@"VIDEO"])){
                NSLog(@"이미지 위에 텍스트 추가");
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"TEXT" forKey:@"TYPE"];
                [dict setObject:@"" forKey:@"VALUE"];
                [dataArr insertObject:dict atIndex:tapPath.row];
                
                [UIView performWithoutAnimation:^{
                    [self.tableView reloadData];
                }];
            } else {
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
//                    NSLog(@"1/4 : %f", [self.tableView rectForRowAtIndexPath:tapPath].size.height/4);
//                    NSLog(@"y : %f", [self.tableView rectForRowAtIndexPath:tapPath].origin.y);
//                    NSLog(@"recognize : %f", [recognizer locationInView:self.tableView].y);
                    
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
                        
                        [UIView performWithoutAnimation:^{
                            [self.tableView reloadData];
                        }];
                    } else {
                        NSLog(@"가만히있으면 됨");
                        //근데 잘 안눌려서..
                        
                    }
                }
            }
        }
         */
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)setImageFromNoti:(NSArray *)imgArr isAlbum:(BOOL)isAlbum {
    isAddImg = YES;
    
    //이미지 추가하면 커서가 없어져서 어떤 텍스트뷰인지 모른다. isText값 불필요.
    //isText불필요하긴한데, 커서없을때 이미지 추가하면 마지막으로 텍스트 쓴 뷰 밑에 추가됨.(위에 텍스트뷰 있어도 삭제안됨)
    //사진 추가 하고 밑에 붙는 텍스트뷰에 자동으로 커서를 둬야할 것 같은데.. 어떻게 해야되지ㅠㅠ
    
    
    @try {
        NSLog(@"currTextViw : %@", currTextView);
        NSLog(@"dataarr cnt : %lu", dataArr.count);
        if(currTextView==nil){
            NSLog(@"텍스트뷰 널!");
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
            //firstText : , secondText : ㅇ ㄹㄹㄹㄹㄹ -> 텍스트 제일앞에 커서두고 이미지 추가했을때 그리고 로케이션은 0
            //텍스트를 쓰고 중간에 나눴을 때 second가 있고 안나눴을땐 없음
            
            if(location==0&&[secondText isEqualToString:@""]){
                //텍스트 아예 없을때
                //텍스트 뷰 지우고 이미지뷰 추가
                NSLog(@"텍스트 아예 없을때 dataArr : %@", dataArr);
                
                [dataArr removeObjectAtIndex:currTextView.tag];
    //            NSLog(@"지우고 난 후  dataArr : %@", dataArr);

                [self addImageView:imgArr selectIndex:currTextView.tag isSplit:NO isAlbum:isAlbum];

            } else if(location==0&&![secondText isEqualToString:@""]){
                //텍스트있고, 제일 앞에 커서 두고 이미지 등록했을 때. (텍스트뷰 위에 등록되어야함)
                NSLog(@"텍스트있고, 제일 앞에 커서 두고 이미지 등록했을 때");
                
                [self addImageView:imgArr selectIndex:currTextView.tag isAlbum:isAlbum];
                
                
            } else if(location!=0&&[secondText isEqualToString:@""]){
                //일반적으로 텍스트 썼을 때
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
    NSLog(@"텍스트뷰 앞에 커서 두고 이미지 추가");
    
    int lastIdx = 0;
    
    @try {
        if([mediaType isEqualToString:@"IMG"]){
            if(isAlbum){
                NSArray *imgList = [[imgArr objectAtIndex:0] objectForKey:@"IMG_LIST"];
                for(int i=0; i<imgList.count; i++){
                    UIImage *image = [MFUtil getScaledImage:[imgList objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    
                    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                    [dict2 setObject:image forKey:@"TMP_IMG"];
                    [dict2 setObject:[imgList objectAtIndex:i] forKey:@"ORIGIN"];
                    
                    [dict setObject:dict2 forKey:@"VALUE"];
                    
                    [dataArr insertObject:dict atIndex:index+i];
                    lastIdx = (int)index+i;
                }
            } else {
                for(int i=0; i<imgArr.count; i++){
                    UIImage *image = [MFUtil getScaledImage:[imgArr objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    
                    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                    [dict2 setObject:image forKey:@"TMP_IMG"];
                    [dict2 setObject:[imgArr objectAtIndex:i] forKey:@"ORIGIN"];
                    
                    [dict setObject:dict2 forKey:@"VALUE"];
                    
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
                    
                    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                    [dict2 setObject:image forKey:@"TMP_IMG"];
                    [dict2 setObject:[imgList objectAtIndex:i] forKey:@"ORIGIN"];
                    [dict2 setObject:[assetList objectAtIndex:i] forKey:@"VIDEO_ASSET"];
                    [dict setObject:dict2 forKey:@"VALUE"];
                    
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
                
                NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                [dict2 setObject:thumbnail forKey:@"TMP_IMG"];
                [dict2 setObject:originThumbnail forKey:@"ORIGIN"];
                [dict2 setObject:asset forKey:@"RECORD_ASSET"];
                [dict setObject:dict2 forKey:@"VALUE"];
                
                [dataArr insertObject:dict atIndex:index];
                lastIdx = (int)index;
            }
            
        } else if([mediaType isEqualToString:@"FILE"]){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"FILE" forKey:@"TYPE"];
            [dict setObject:[[imgArr objectAtIndex:0] objectForKey:@"FILE_DATA"] forKey:@"FILE_DATA"];
            [dict setObject:[[imgArr objectAtIndex:0] objectForKey:@"VALUE"] forKey:@"VALUE"];
            [dict setObject:[[imgArr objectAtIndex:0] objectForKey:@"FILE_NM"] forKey:@"FILE_NM"];
            
            [dataArr insertObject:dict atIndex:index];
            lastIdx = (int)index;
            
        }
        
        [UIView performWithoutAnimation:^{
            [self.tableView reloadData];
        }];
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)addImageView:(NSArray *)imgArr selectIndex:(NSInteger)index isSplit:(BOOL)isSplit isAlbum:(BOOL)isAlbum{
    int lastIdx = 0;
    
    @try{
        if([mediaType isEqualToString:@"IMG"]){
            if(isAlbum){
                NSArray *imgList = [[imgArr objectAtIndex:0] objectForKey:@"IMG_LIST"];
                for(int i=0; i<imgList.count; i++){
                    UIImage *image = [MFUtil getScaledImage:[imgList objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    
                    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                    [dict2 setObject:image forKey:@"TMP_IMG"];
                    [dict2 setObject:[imgList objectAtIndex:i] forKey:@"ORIGIN"];
                    
                    [dict setObject:dict2 forKey:@"VALUE"];
                    
                    [dataArr insertObject:dict atIndex:index+i];
                    lastIdx = (int)index+i;
                }
            } else {
                for(int i=0; i<imgArr.count; i++){
                    UIImage *image = [MFUtil getScaledImage:[imgArr objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-20];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    
                    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                    [dict2 setObject:image forKey:@"TMP_IMG"];
                    [dict2 setObject:[imgArr objectAtIndex:i] forKey:@"ORIGIN"];
                    
                    [dict setObject:dict2 forKey:@"VALUE"];
                    
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
                    
                    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                    [dict2 setObject:image forKey:@"TMP_IMG"];
                    [dict2 setObject:[imgList objectAtIndex:i] forKey:@"ORIGIN"];
                    [dict2 setObject:[assetList objectAtIndex:i] forKey:@"VIDEO_ASSET"];
                    [dict setObject:dict2 forKey:@"VALUE"];
                    
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
                
                NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                [dict2 setObject:thumbnail forKey:@"TMP_IMG"];
                [dict2 setObject:originThumbnail forKey:@"ORIGIN"];
                [dict2 setObject:asset forKey:@"RECORD_ASSET"];
                [dict setObject:dict2 forKey:@"VALUE"];
                
                [dataArr insertObject:dict atIndex:index];
                lastIdx = (int)index;
                
                NSMutableDictionary *dict3 = [NSMutableDictionary dictionary];
                [dict3 setObject:@"TEXT" forKey:@"TYPE"];
                if(isSplit){
                    [dict3 setObject:secondText forKey:@"VALUE"];
                } else {
                    [dict3 setObject:@"" forKey:@"VALUE"];
                }
                [dataArr insertObject:dict3 atIndex:lastIdx+1];
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
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSIndexPath *lastCell = [NSIndexPath indexPathForItem:lastIdx inSection:0];
                [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            });
        }];
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)imgTapHandler:(UITapGestureRecognizer *)recognizer {
    NSInteger index = recognizer.view.tag;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if(![self.isEdit isEqualToString:@"COMMENT"] && !isAddImg){
        UIAlertAction *orderAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"post_content_order_title", @"post_content_order_title")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action){
                                                                [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                
                                                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                PostOrderModifyViewController *vc = (PostOrderModifyViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostOrderModifyViewController"];
                                                                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                                            
                                                                @try{
                                                                    vc.isEdit = YES;
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
    }
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action){
                                                             [self deleteImageClick:index];
                                                             [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                             
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
}

- (void)deleteImageClick:(NSInteger)index{
    NSLog(@"이미지 삭제 인덱스 : %ld", (long)index);
    
    @try {
        if(index!=0){
            NSString *prevType = [[dataArr objectAtIndex:index-1] objectForKey:@"TYPE"];
            NSString *nextType = [[dataArr objectAtIndex:index+1] objectForKey: @"TYPE"];
            
            if([prevType isEqualToString:@"TEXT"] && [nextType isEqualToString:@"TEXT"]){
                NSLog(@"이전/다음 모두 TEXT");
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
        NSLog(@"인덱스의 데이터 삭제");
        [dataArr removeObjectAtIndex:index];
        NSLog(@"삭제 후 dataArr : %@", dataArr);
        
//        NSIndexPath *lastCell = [NSIndexPath indexPathForItem:index inSection:0];
        [UIView performWithoutAnimation:^{
            [self.tableView reloadData];
//            [self.tableView beginUpdates];
//            [self.tableView deleteRowsAtIndexPaths:@[lastCell] withRowAnimation:UITableViewRowAnimationNone];
//            [self.tableView endUpdates];
        }];
        
        
//        if(self.tableView.contentSize.height > self.tableView.frame.size.height){
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                //이미지 삭제한 곳에 스크롤을 두기 위해.
//                if(index>0){
//                    NSIndexPath *lastCell = [NSIndexPath indexPathForItem:index inSection:0];
//                    [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//                    }
//            });
//        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([self.isEdit isEqualToString:@"COMMENT"]){
        return resultCommArr.count;
    } else if([self.isEdit isEqualToString:@"POST"]){
        return dataArr.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
//    TextTableViewCell *textCell = (TextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell"];
    _textCell = (TextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell"];
    ImageTableViewCell *imgCell = (ImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ImageTableViewCell"];
    VideoTableViewCell *videoCell = (VideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"VideoTableViewCell"];
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
    if (videoCell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"VideoTableViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[VideoTableViewCell class]]) {
                videoCell = (VideoTableViewCell *) currentObject;
                [videoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
    
    if([self.isEdit isEqualToString:@"COMMENT"]){
        @try{
            _textCell.textView.text = nil;
            [self setTextView:_textCell.textView];
            
            NSString *type = [[resultCommArr objectAtIndex:0] objectForKey:@"TYPE"];
            if([type isEqualToString:@"TEXT"]){
                _textCell.textView.delegate = self;
                _textCell.textView.tag = indexPath.row;
                //textCell.textView.text = value;
                
                _textCell.textView.selectable = YES;
                
                NSMutableAttributedString *attrStr = [[resultCommArr objectAtIndex:0] objectForKey:@"TEXT"];
                
                _textCell.textView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
                _textCell.textView.attributedText = attrStr;
                
                return _textCell;

            } else if([type isEqualToString:@"IMG"]){

            } else if([type isEqualToString:@"VIDEO"]){

            } else if([type isEqualToString:@"FILE"]){

            } else {
                
            }
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
        
    } else {
        NSString *type = [[dataArr objectAtIndex:indexPath.row] objectForKey:@"TYPE"];
        
        if([type isEqualToString:@"TEXT"]){
            _textCell.textView.text = nil;
            [self setTextView:_textCell.textView];
            
            @try{
                NSString *value = @"";
                NSString *textValue = @"";
                if(![[[dataArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"] isEqualToString:@""]){
                    value = [[[dataArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"] stringByReplacingOccurrencesOfString:@"%5Cn" withString:@"%0A"];
                    textValue = [NSString urlDecodeString:value];
                }
                
                _textCell.textView.delegate = self;
                _textCell.textView.tag = indexPath.row;
                _textCell.textView.text = textValue;
                
//                NSMutableDictionary *dict = [dataArr objectAtIndex:indexPath.row];
//                [dataArr replaceObjectAtIndex:indexPath.row withObject:dict];
                
                //사진등록하고 아래쪽 탭 하면 텍스트뷰에 커서 및 키보드 올라오게 할 수 없을까
                return _textCell;
                
            } @catch(NSException *exception){
                return nil;
            }
            
            
        } else if([type isEqualToString:@"IMG"]){
            @try{
                imgCell.imgView.image = nil;
                NSDictionary *valueDic = [[dataArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
                
                if([valueDic objectForKey:@"TMP_IMG"]){
                    UIImage *imgValue = [valueDic objectForKey:@"TMP_IMG"];
                    imgCell.imgView.image = imgValue;
                    
                } else{
                    NSString *originImg = [valueDic objectForKey:@"ORIGIN"];
                    [imgCache queryDiskCacheForKey:[NSString urlDecodeString:originImg] done:^(UIImage *image, SDImageCacheType cacheType) {
                        if(image!=nil){
                            imgCell.imgView.image = image;
                        }
                    }];
                }
                
                [imgCell.imgView setUserInteractionEnabled:YES];
                imgCell.imgView.tag = indexPath.row;
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapHandler:)];
                [imgCell.imgView addGestureRecognizer:tap];
                
            } @catch (NSException *exception) {
                NSLog(@"Exception : %@", exception);
            }
            return imgCell;
            
        } else if([type isEqualToString:@"VIDEO"]){
            @try{
                videoCell.compressView.hidden = YES;
                videoCell.videoView.image = nil;
                NSDictionary *valueDic = [[dataArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
                
                if([valueDic objectForKey:@"TMP_IMG"]){
                    UIImage *imgValue = [valueDic objectForKey:@"TMP_IMG"];
                    videoCell.videoView.image = imgValue;
                    
                } else {
                    //서버 리턴 썸네일 있을 때
                    NSString *thumb = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                    [videoCell.videoView sd_setImageWithURL:[NSURL URLWithString:thumb]
                                           placeholderImage:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                        if (image) {
                                                            if(image.size.width>self.tableView.frame.size.width){
                                                                image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                                                videoCell.videoView.image = image;
                                                            }
                                                        }
                                                  }];
                }
                
                [videoCell.videoTmpView setUserInteractionEnabled:YES];
                videoCell.videoTmpView.tag = indexPath.row;
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapHandler:)];
                [videoCell.videoTmpView addGestureRecognizer:tap];
                
            } @catch (NSException *exception) {
                NSLog(@"Exception : %@", exception);
            }
            return videoCell;
        
        } else if([type isEqualToString:@"FILE"]){
            @try{
                fileCell.fileButton.gestureRecognizers = nil;
                fileCell.fileButton.tag = indexPath.row;
                
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
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapHandler:)];
                [fileCell.fileButton addGestureRecognizer:tap];
                
            } @catch (NSException *exception) {
                NSLog(@"Exception : %@", exception);
            }
            return fileCell;
        }
    }
    
    return nil;
}

-(void)setTextView:(UITextView *)textView {
    @try {
        CGFloat fixedWidth = textView.frame.size.width;
        CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = textView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        textView.frame = newFrame;
        textView.scrollEnabled = NO;
        
//        int height = self.tableView.contentSize.height-_keyboardHeight.constant-self.tableView.contentOffset.y;
//        if(height<50 && height>-50){
//            NSLog(@"스크롤이 하단에 있다");
//            //스크롤이 하단에 있을 때만. 텍스트뷰에 맞춰서 스크롤을 내려주기 위해.
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                NSIndexPath *lastCell = [NSIndexPath indexPathForItem:(dataArr.count-1) inSection:0];
//                [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//            });
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
        
//        if (textView.selectedTextRange.empty) {
//            NSLog(@"비었는지");
//        }
        
        NSLog(@"결론 스크롤 위치 : %f", cursorPosition2.y+[self.tableView rectForRowAtIndexPath:currentCell].origin.y);
        float scrollPosition = cursorPosition2.y+[self.tableView rectForRowAtIndexPath:currentCell].origin.y+35;
//        NSLog(@"scrollPosition2 : %f", scrollPosition);
        
        [self.tableView scrollRectToVisible:CGRectMake(0, scrollPosition, 1, 1) animated:NO];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if([self.isEdit isEqualToString:@"COMMENT"]){
            //텍스트를 입력할때마다 데이터 변경.
            [dict setObject:@"TEXT" forKey:@"TYPE"];
            [dict setObject:[textView.text urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"TEXT"];
            
            commAttrStr = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
            
        } else {
            //텍스트를 입력할때마다 데이터 변경.
            [dict setObject:@"TEXT" forKey:@"TYPE"];
            [dict setObject:[textView.text urlEncodeUsingEncoding:NSUTF8StringEncoding] forKey:@"VALUE"];
        }
        
        [dataArr replaceObjectAtIndex:textView.tag withObject:dict];
        
        [self setTextView:textView];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    currTextView = textView;
}

- (void)textViewDidChangeSelection:(MFTextView *)textView {
    NSRange textRange = textView.selectedRange;
    
    if(prevLen==textView.text.length){
        if(prevLoc<textRange.location){
            //NSLog(@"뒤로가기 ->");
            if(textRange.location>0){
                NSRange ran;
                UIFont *dic = [textView.attributedText attribute:NSFontAttributeName atIndex:textRange.location-1 effectiveRange:&ran];
                NSString *fontName = [dic.fontName lowercaseString];
                
                if([fontName rangeOfString:@"bold"].location!=NSNotFound){
                    [textView.attributedText enumerateAttributesInRange:NSMakeRange(0, textRange.location)
                                                                options:NSAttributedStringEnumerationReverse
                                                             usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop){
                                                                 NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
                                                                 UIFont *currentFont = [mutableAttributes objectForKey:NSFontAttributeName];
                                                                 NSString *currFontName = [currentFont.fontName lowercaseString];
                                                                 
                                                                 if([currFontName rangeOfString:@"bold"].location!=NSNotFound){
                                                                     [textView setSelectedRange:NSMakeRange(NSNotFound, 0)];
                                                                 }
                                                             }];
                }
            }
        } else {
            if(textRange.location>0){
                //NSLog(@"앞으로가기 <-");
                NSRange ran;
                UIFont *dic = [textView.attributedText attribute:NSFontAttributeName atIndex:textRange.location-1 effectiveRange:&ran];
                NSString *fontName = [dic.fontName lowercaseString];
                
                if([fontName rangeOfString:@"bold"].location!=NSNotFound){
                    [textView.attributedText enumerateAttributesInRange:NSMakeRange(0, textRange.location)
                                                                options:NSAttributedStringEnumerationReverse
                                                             usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop){
                                                                 NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
                                                                 UIFont *currentFont = [mutableAttributes objectForKey:NSFontAttributeName];
                                                                 NSString *currFontName = [currentFont.fontName lowercaseString];
                                                                 
                                                                 if([currFontName rangeOfString:@"bold"].location!=NSNotFound){
                                                                     [textView setSelectedRange:NSMakeRange(NSNotFound, 0)];
                                                                 }
                                                             }];
                }
            }
        }
    }
    
    prevLoc = textRange.location;
    prevLen = textView.text.length;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    int isBackSpace = strcmp(_char, "\b");
    
    if(isBackSpace == -8){//백스페이스
        //NSLog(@"backspace");
        @try{
            NSRange textRange = range;
            UIFont *dic = [textView.attributedText attribute:NSFontAttributeName atIndex:textRange.location-1 effectiveRange:&range];
            NSString *fontName = [dic.fontName lowercaseString];
            if([fontName rangeOfString:@"bold"].location!=NSNotFound){
                [textView.attributedText enumerateAttributesInRange:NSMakeRange(0, textRange.location)
                                                            options:NSAttributedStringEnumerationReverse
                                                         usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop){
                                                             NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
                                                             UIFont *currentFont = [mutableAttributes objectForKey:NSFontAttributeName];
                                                             NSString *currFontName = [currentFont.fontName lowercaseString];
                                                             //NSLog(@"currFontName : %@", currFontName);
                                                             if([currFontName rangeOfString:@"bold"].location!=NSNotFound){
                                                                 //NSLog(@"태그위치 : %lu, 태그길이 : %lu, 현재위치 : %lu, 현재길이 : %lu", textRange.location, range.length, range.location, textRange.length);
                                                                 [textView.textStorage deleteCharactersInRange:NSMakeRange(textRange.location-range.length, range.length)];
                                                                 
                                                                 //NSRange delRange = textView.selectedRange;
                                                                 
                                                                 //NSAttributedString *emptyStr = [[NSAttributedString alloc] initWithString:@" "];
                                                                 //[textView.textStorage insertAttributedString:emptyStr atIndex:delRange.location];
                                                                 
                                                                 //[textView setSelectedRange:NSMakeRange(delRange.location+1, 0)];
                                                                 [textView setSelectedRange:NSMakeRange(range.location+1, 0)];
                                                             }
                                                             *stop = YES;
                                                         }];
            }
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
        
        
        if(dataArr.count>2){
            if([textView.text isEqualToString:@""]){
                //텍스트 없으면 텍스트뷰를 지우는데
                //이미지와 이미지 사이에 있는 텍스트 일 때 만 지운다.
                NSLog(@"텍스트 없음! 그리고 텍스트 뷰 태그는 : %ld", (long)textView.tag);
                
                @try{
                    NSString *type = [[dataArr objectAtIndex:textView.tag] objectForKey:@"TYPE"];
                    NSString *type3 = [[dataArr objectAtIndex:textView.tag+1] objectForKey:@"TYPE"];
                    
                    if(textView.tag==0){
                        if([type isEqualToString:@"TEXT"]&&([type3 isEqualToString:@"IMG"]||[type3 isEqualToString:@"VIDEO"])){
                            NSLog(@"뒤에 이미지나 동영상 있고 처음 텍스트 뷰 삭제");
                            [dataArr removeObjectAtIndex:textView.tag];
//                            NSLog(@"텍스트지우고 dataArr : %@", dataArr);
                            
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
                    } else {
                        NSString *type2 = [[dataArr objectAtIndex:textView.tag-1] objectForKey:@"TYPE"];
                        
                        if([type isEqualToString:@"TEXT"]&&
                            (([type2 isEqualToString:@"IMG"]&&[type3 isEqualToString:@"IMG"])
                            ||([type2 isEqualToString:@"IMG"]&&[type3 isEqualToString:@"VIDEO"])
                            ||([type2 isEqualToString:@"IMG"]&&[type3 isEqualToString:@"FILE"])
                            ||([type2 isEqualToString:@"VIDEO"]&&[type3 isEqualToString:@"IMG"])
                            ||([type2 isEqualToString:@"VIDEO"]&&[type3 isEqualToString:@"VIDEO"])
                            ||([type2 isEqualToString:@"VIDEO"]&&[type3 isEqualToString:@"FILE"])
                            ||([type2 isEqualToString:@"FILE"]&&[type3 isEqualToString:@"IMG"])
                            ||([type2 isEqualToString:@"FILE"]&&[type3 isEqualToString:@"VIDEO"])
                            ||([type2 isEqualToString:@"FILE"]&&[type3 isEqualToString:@"FILE"]))){

                            NSLog(@"위아래 이미지/동영상 일 때 텍스트 뷰 삭제");
                            
                            [dataArr removeObjectAtIndex:textView.tag];
//                            NSLog(@"텍스트지우고 dataArr : %@", dataArr);
                            
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
                    }
                    
                } @catch(NSException* exception){
                    NSLog(@"Exception : %@", exception);
                    
                    NSString *type = [[dataArr objectAtIndex:textView.tag] objectForKey:@"TYPE"];
                    if(textView.tag==0&&[type isEqualToString:@"TEXT"]){
                        [dataArr removeObjectAtIndex:textView.tag];
//                        NSLog(@"22텍스트지우고 dataArr : %@", dataArr);
                        
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
                            if(status==YES) [self performSegueWithIdentifier:@"POST_MODIFY_PHLIB_MODAL" sender:@"PHOTO"];
                        });
                    }];
                    
                }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES) [self performSegueWithIdentifier:@"POST_MODIFY_PHLIB_MODAL" sender:@"PHOTO"];
                    });
                }];
            }
            
//            if([AccessAuthCheck photoAccessCheck]){
//                [self performSegueWithIdentifier:@"POST_MODIFY_PHLIB_MODAL" sender:@"PHOTO"];
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
                            if(status==YES) [self performSegueWithIdentifier:@"POST_MODIFY_PHLIB_MODAL" sender:@"VIDEO"];
                        });
                    }];
                }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES) [self performSegueWithIdentifier:@"POST_MODIFY_PHLIB_MODAL" sender:@"VIDEO"];
                    });
                }];
            }
            
//            if([AccessAuthCheck photoAccessCheck]){
//                [self performSegueWithIdentifier:@"POST_MODIFY_PHLIB_MODAL" sender:@"VIDEO"];
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
        @try {
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];
            
            NSArray *assetArr = [[NSArray alloc] initWithObjects:asset, nil];
            NSArray *imgArr = [[NSArray alloc] initWithObjects:@"NONE", nil];
            
            NSMutableDictionary *assetDict = [NSMutableDictionary dictionary];
            [assetDict setObject:assetArr forKey:@"ASSET_LIST"];
            [assetDict setObject:imgArr forKey:@"IMG_LIST"];
            
            NSArray *videoArray = [[NSArray alloc] initWithObjects:videoPath, nil];
            mediaType = @"VIDEO";
            
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
        @try {
            mediaType = @"IMG";
            
            self.croppingStyle = TOCropViewCroppingStyleDefault;
            TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:image];
            cropController.delegate = self;
            self.image = image;
            [self presentViewController:cropController animated:YES completion:nil];
            
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
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

#pragma mark - Web Service
- (void)callWebService:(NSString *)serviceName WithParameter:(NSString *)paramString{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
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

-(void)convertDataSet:(NSMutableArray *)array{
    NSLog(@"array : %@", array);
    
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
                [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
                
                setCount++;
                if(setCount==count) [self dataConvertFinished:tmpDict];
                
            } else if([type isEqualToString:@"VIDEO"]){
                if([[array objectAtIndex:i] objectForKey:@"VIDEO_VALUE"]!=nil){
//                    NSLog(@"이건 앨범에서 가져온 비디오 i=%d", i);
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
                            
                            // 비디오 파일로 애셋 URL 만들기
//                            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
                            [MFFileCompress compressVideoWithInputVideoUrl:URL asset:avAsset num:i mode:nil fileName:nil paramNo:nil completion:^(NSData *data) {
                                NSLog(@"변환된 데이터(Alb) : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);

                                UIImage *thumbnail = [[array objectAtIndex:i] objectForKey:@"ORIGIN"];
                                [obj setObject:@"VIDEO" forKey:@"TYPE"];
                                [obj setObject:data forKey:@"VALUE"];
                                if(thumbnail!=nil) [obj setObject:thumbnail forKey:@"THUMB"];
                                [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];

                                setCount++;
                                if(setCount==count) [self dataConvertFinished:tmpDict];
                            }];
                        });
                    }];
                    
                } else {
                    NSLog(@"촬영한 비디오 i=%d", i);
                    //촬영한 비디오
                    AVURLAsset *avAsset = [[array objectAtIndex:i] objectForKey:@"RECORD_VALUE"];
                    
                    [MFFileCompress compressVideoWithInputVideoUrl:avAsset.URL asset:avAsset num:i mode:nil fileName:nil paramNo:nil completion:^(NSData *data) {
                        NSLog(@"변환된 데이터(Rec) : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);

                        UIImage *thumbnail = [[array objectAtIndex:i] objectForKey:@"ORIGIN"];
                        
                        [obj setObject:@"VIDEO" forKey:@"TYPE"];
                        [obj setObject:data forKey:@"VALUE"];
                        if(thumbnail!=nil) [obj setObject:thumbnail forKey:@"THUMB"];
                        [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];

                        setCount++;
                        if(setCount==count) [self dataConvertFinished:tmpDict];
                    }];
                }
                
            } else if([type isEqualToString:@"FILE"]){
                NSString *value = [[array objectAtIndex:i] objectForKey:@"VALUE"];
                NSData *data = [[array objectAtIndex:i] objectForKey:@"FILE_DATA"];
                
                [obj setObject:@"FILE" forKey:@"TYPE"];
                [obj setObject:value forKey:@"VALUE"];
                [obj setObject:data forKey:@"FILE_DATA"];
                [obj setObject:[[array objectAtIndex:i] objectForKey:@"FILE_NM"] forKey:@"FILE_NM"];
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
    @try{
        resultArr = [NSMutableArray array];
        
        for(int i=0; i<dict.count; i++){
            NSMutableDictionary *reDict = [NSMutableDictionary dictionary];
            
            NSDictionary *dataDict = [dict objectForKey:[NSString stringWithFormat:@"%d",i]];
            NSString *type = [dataDict objectForKey:@"TYPE"];
            if([type isEqualToString:@"IMG"]){
                [reDict setObject:@"IMG" forKey:@"TYPE"];
                [reDict setObject:[dataDict objectForKey:@"VALUE"] forKey:@"VALUE"]; //UIImage
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
                [resultArr addObject:reDict];
            
            } else if([type isEqualToString:@"FILE"]){
                [reDict setObject:@"FILE" forKey:@"TYPE"];
                [reDict setObject:[dataDict objectForKey:@"VALUE"] forKey:@"VALUE"];
                [reDict setObject:[dataDict objectForKey:@"FILE_DATA"] forKey:@"FILE_DATA"]; //NSData
                [reDict setObject:[dataDict objectForKey:@"FILE_NM"] forKey:@"FILE_NM"];
                
                [resultArr addObject:reDict];
            }
        }
        
        [self saveMediaFiles];
        
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
-(void)saveMediaFiles{
    @try{
//        NSLog(@"saveMediaFiles : %@", resultArr);
        NSString *type = [[resultArr objectAtIndex:0] objectForKey:@"TYPE"];
        if([type isEqualToString:@"IMG"]){
            UIImage *value = [[resultArr objectAtIndex:0] objectForKey:@"VALUE"];
            value = [MFUtil getResizeImageRatio:value];
            NSData *data = UIImageJPEGRepresentation(value, 0.7);
//            NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
            [self saveMediaFiles:data mediaType:type isFile:nil];
            
        } else if([type isEqualToString:@"VIDEO"]){
            NSData *data = [[resultArr objectAtIndex:0] objectForKey:@"VALUE"];
            [self saveMediaFiles:data mediaType:type isFile:nil];
            
        } else if([type isEqualToString:@"VIDEO_THUMB"]){
            UIImage *value = [[resultArr objectAtIndex:0] objectForKey:@"VALUE"];
            value = [MFUtil getResizeImageRatio:value];
            NSData *data = UIImageJPEGRepresentation(value, 0.7);
//            NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
            [self saveMediaFiles:data mediaType:type isFile:nil];
        
        } else if([type isEqualToString:@"FILE"]){
            NSData *data = [[resultArr objectAtIndex:0] objectForKey:@"FILE_DATA"];
//            NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
            [self saveMediaFiles:data mediaType:type isFile:[[resultArr objectAtIndex:0] objectForKey:@"FILE_NM"]];
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
}
-(void)saveMediaFiles:(NSData *)data mediaType:(NSString *)type isFile:(NSString *)fileNm{
    @try{
        if (self.postNo==nil) {
            
        }else{
            NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
            urlString = [urlString stringByAppendingPathComponent:@"saveAttachedFile"];
            
            NSString *fileName;
            
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
            [sendFileParam setObject:@"false" forKey:@"isShared"];
            [sendFileParam setObject:@"" forKey:@"srcFileUrl"];
            
            if([type isEqualToString:@"IMG"]) {
                [sendFileParam setObject:@"false" forKey:@"isThumb"];
                fileName = [self createFileName:@"IMG"];
            }
            else if([type isEqualToString:@"VIDEO"]) {
                [sendFileParam setObject:@"false" forKey:@"isThumb"];
                [sendFileParam setObject:videoThumbName forKey:@"thumbName"];
                fileName = [self createFileName:@"VIDEO"];
            }
            else if([type isEqualToString:@"VIDEO_THUMB"]){
                [sendFileParam setObject:@"true" forKey:@"isThumb"];
                fileName = [self createFileName:@"IMG"];
                
                thumbImage = [[UIImage alloc] initWithData:data];
            }
            else if([type isEqualToString:@"FILE"]) {
                [sendFileParam setObject:@"false" forKey:@"isThumb"];
                fileName = fileNm;
            }
            
            [self sessionFileUpload:urlString :sendFileParam :data :fileName];
        }
        
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


#pragma mark - MFURLSession Delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    if (error != nil) {
        [SVProgressHUD dismiss];
        
        
    }else{
        
        NSString *wsName = [[session.url absoluteString] lastPathComponent];
        NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
        
        if ([result isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"savePost"]) {
                [SVProgressHUD dismiss];
                
                @try {
                    NSString *affected = [session.returnDictionary objectForKey:@"AFFECTED"];
                    if ([affected intValue]>0) {
                        [self dismissViewControllerAnimated:YES completion:^(void){
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SavePost" object:nil userInfo:@{@"RESULT":@"SUCCESS"}];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_PostModify" object:nil];
                            
                        }];
                        
                    }
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
                
            } else {
                @try {
                    NSString *affected = [session.returnDictionary objectForKey:@"AFFECTED"];
                    if ([affected intValue]>0) {
                        [self dismissViewControllerAnimated:YES completion:^(void){
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SavePost" object:nil userInfo:@{@"RESULT":@"SUCCESS"}];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_PostModify" object:nil userInfo:@{@"TYPE":@"COMMENT"}];
                        }];
                        
                    }
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
                
            }
        }else{
            [SVProgressHUD dismiss];
            
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
        int firstTxtCnt = 0;
        int firstImgCnt = 0;
        int firstFileCnt = 0;
        firstArr = [NSMutableArray array];
        
        for(int i=0; i<dataArr.count; i++){
            NSString *type = [[dataArr objectAtIndex:i] objectForKey:@"TYPE"];
            
            if([type isEqualToString:@"IMG"]){
                NSDictionary *valueDict = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
                if([valueDict objectForKey:@"TMP_IMG"]!=nil){
                    if(changeCnt<fileNameCnt){
//                        NSString *imagePath = [[self.filePathArray objectAtIndex:changeCnt] urlEncodeUsingEncoding:NSUTF8StringEncoding];
                        NSString *imagePath = [self.filePathArray objectAtIndex:changeCnt];
                        [[dataArr objectAtIndex:i] setObject:imagePath forKey:@"VALUE"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"ORIGIN"];
                    }
                    changeCnt++;
                    
                } else {
                    NSString *imagePath = [valueDict objectForKey:@"ORIGIN"];
                    [[dataArr objectAtIndex:i] setObject:imagePath forKey:@"VALUE"];
                }
                
            } else if([type isEqualToString:@"VIDEO"]){
                NSDictionary *valueDict = [[dataArr objectAtIndex:i] objectForKey:@"VALUE"];
                if([valueDict objectForKey:@"TMP_IMG"]!=nil){
//                    NSString *imagePath = [[self.filePathArray objectAtIndex:changeCnt] urlEncodeUsingEncoding:NSUTF8StringEncoding];
                    NSString *imagePath = [self.filePathArray objectAtIndex:changeCnt];
                    if(changeCnt<fileNameCnt){
                        [[dataArr objectAtIndex:i] setObject:imagePath forKey:@"VALUE"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"ORIGIN"];
                    }
                    changeCnt++;
                
                } else {
                    NSString *imagePath = [valueDict objectForKey:@"ORIGIN"];
                    [[dataArr objectAtIndex:i] setObject:imagePath forKey:@"VALUE"];
                }
                
            } else if([type isEqualToString:@"FILE"]){
                if([[dataArr objectAtIndex:i] objectForKey:@"FILE_DATA"]!=nil){
//                    NSString *path = [[self.filePathArray objectAtIndex:changeCnt] urlEncodeUsingEncoding:NSUTF8StringEncoding];
                    NSString *path = [self.filePathArray objectAtIndex:changeCnt];
                    if(changeCnt<fileNameCnt){
                        [[dataArr objectAtIndex:i] setObject:path forKey:@"VALUE"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"FILE_DATA"];
                        [[dataArr objectAtIndex:i] removeObjectForKey:@"FILE_NM"];
                    }
                    changeCnt++;
                }
            }
            
            if([type isEqualToString:@"TEXT"]&&firstTxtCnt==0){
                NSString *prevStr = [NSString urlDecodeString:[[dataArr objectAtIndex:i] objectForKey:@"VALUE"]];
//                NSUInteger textByte = [prevStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
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
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)commentSetTableData:(NSMutableArray *)array{
    @try{
        resultCommArr = [NSMutableArray array];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc] initWithString:@""];
        
        for(int k=0; k<array.count; k++){
            NSString *commType = [[array objectAtIndex:k] objectForKey:@"TYPE"];
            NSArray *commTarget = [[array objectAtIndex:k] objectForKey:@"TARGET"];
            
            if([commType isEqualToString:@"TEXT"]){
                NSString *commValue = [[array objectAtIndex:k] objectForKey:@"TEXT"];
                NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                
                if(commTarget.count>0){
                    for(int j=0; j<commTarget.count; j++){
                        NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                        NSString *usrNo = [[commTarget objectAtIndex:j] objectForKey:@"USER_NO"];
                        NSString *usrId = [[commTarget objectAtIndex:j] objectForKey:@"USER_ID"];
                        
                        NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]], NSLinkAttributeName:[NSString stringWithFormat:@"%@&%@", usrNo, usrId]}];
                        NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];
                        [commStr appendAttributedString:attrName];
                        [commStr appendAttributedString:attrSpace];
                    }
                }
                
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:commValue attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];
                [commStr appendAttributedString:attrStr];
                
                [resultStr appendAttributedString:commStr];
                
                [dict setObject:commType forKey:@"TYPE"];
                [dict setObject:resultStr forKey:@"TEXT"];
                
            } else if([commType isEqualToString:@"IMG"]){
                NSString *commValue = [[array objectAtIndex:k] objectForKey:@"VALUE"];
                NSString *origin = [[array objectAtIndex:k] objectForKey:@"FILE"];
                
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:origin]];
                if(data) {
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    image = [MFUtil getScaledImage:image scaledToMaxWidth:150];
                    [imgCache storeImage:image forKey:origin toDisk:YES];
                }
                
                if(commValue!=nil&&![commValue isEqualToString:@""]) {
                    NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                    
                    if(commTarget.count>0){
                        for(int j=0; j<commTarget.count; j++){
                            NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                            NSString *usrNo = [[commTarget objectAtIndex:j] objectForKey:@"USER_NO"];
                            NSString *usrId = [[commTarget objectAtIndex:j] objectForKey:@"USER_ID"];
                            
                            NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]], NSLinkAttributeName:[NSString stringWithFormat:@"%@&%@", usrNo, usrId]}];
                            NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];
                            [commStr appendAttributedString:attrName];
                            [commStr appendAttributedString:attrSpace];
                        }
                    }
                    
                    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:commValue attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];
                    [commStr appendAttributedString:attrStr];
                }
                
                [dict setObject:commType forKey:@"TYPE"];
                [dict setObject:origin forKey:@"FILE"];
                
            } else if([commType isEqualToString:@"VIDEO"]){
                NSString *commValue = [[array objectAtIndex:k] objectForKey:@"VALUE"];
                NSString *origin = [[array objectAtIndex:k] objectForKey:@"FILE"];
                NSString *thumb = [[array objectAtIndex:k] objectForKey:@"THUMB"];
                
                //서버 리턴 썸네일 있을 때
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumb]];
                if(data) {
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    image = [MFUtil getScaledImage:image scaledToMaxWidth:150];
                    [imgCache storeImage:image forKey:thumb toDisk:YES];
                } else {
                    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:origin]];
                    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                    imageGenerator.appliesPreferredTrackTransform = YES;
                    CMTime time = CMTimeMake(1, 1);
                    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    thumbnail = [MFUtil getScaledImage:thumbnail scaledToMaxWidth:150];
                    [imgCache storeImage:thumbnail forKey:thumb toDisk:YES];
                }
                
                if(commValue!=nil&&![commValue isEqualToString:@""]) {
                    NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                    
                    if(commTarget.count>0){
                        for(int j=0; j<commTarget.count; j++){
                            NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                            NSString *usrNo = [[commTarget objectAtIndex:j] objectForKey:@"USER_NO"];
                            NSString *usrId = [[commTarget objectAtIndex:j] objectForKey:@"USER_ID"];
                            
                            NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]], NSLinkAttributeName:[NSString stringWithFormat:@"%@&%@", usrNo, usrId]}];
                            NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];
                            [commStr appendAttributedString:attrName];
                            [commStr appendAttributedString:attrSpace];
                        }
                    }
                    
                    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:commValue attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];
                    [commStr appendAttributedString:attrStr];
                }
                
                [dict setObject:commType forKey:@"TYPE"];
                [dict setObject:origin forKey:@"FILE"];
                [dict setObject:thumb forKey:@"THUMB"];
                
            } else if([commType isEqualToString:@"FILE"]){
                NSString *commValue = [[array objectAtIndex:k] objectForKey:@"VALUE"];
                NSString *origin = [[array objectAtIndex:k] objectForKey:@"FILE"];
                
                if(commValue!=nil&&![commValue isEqualToString:@""]) {
                    NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                    
                    if(commTarget.count>0){
                        for(int j=0; j<commTarget.count; j++){
                            NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                            NSString *usrNo = [[commTarget objectAtIndex:j] objectForKey:@"USER_NO"];
                            NSString *usrId = [[commTarget objectAtIndex:j] objectForKey:@"USER_ID"];
                            
                            NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]], NSLinkAttributeName:[NSString stringWithFormat:@"%@&%@", usrNo, usrId]}];
                            NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];
                            [commStr appendAttributedString:attrName];
                            [commStr appendAttributedString:attrSpace];
                        }
                    }
                    
                    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:commValue attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];
                    [commStr appendAttributedString:attrStr];
                }
                
                [dict setObject:commType forKey:@"TYPE"];
                [dict setObject:origin forKey:@"FILE"];
            }
        }
        
        [resultCommArr addObject:dict];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
        
    }
}

#pragma mark - MFURLSession Upload Delegate
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error{
    @try{
        uploadCount++;
        if (error != nil) {
            
        }else{
            NSLog(@"dictionary : %@", dictionary);
            
            NSString *result = [dictionary objectForKey:@"RESULT"];
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([dictionary objectForKey:@"FILE_URL"]==nil) {
                    [SVProgressHUD dismiss];
                    
                }else{
                    videoThumbName = @"";
                    
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
                            UIImage *value = [[resultArr objectAtIndex:uploadCount] objectForKey:@"VALUE"];
                            value = [MFUtil getResizeImageRatio:value];
                            NSData *data = UIImageJPEGRepresentation(value, 0.7);
                            [self saveMediaFiles:data mediaType:type isFile:nil];
                            
                        } else if([type isEqualToString:@"VIDEO"]){
                            NSData *data = [[resultArr objectAtIndex:uploadCount] objectForKey:@"VALUE"];
                            [self saveMediaFiles:data mediaType:type isFile:nil];
                            
                        } else if([type isEqualToString:@"VIDEO_THUMB"]){
                            UIImage *value = [[resultArr objectAtIndex:uploadCount] objectForKey:@"VALUE"];
                            value = [MFUtil getResizeImageRatio:value];
                            NSData * data = UIImageJPEGRepresentation(value, 0.7);
                            [self saveMediaFiles:data mediaType:type isFile:nil];
                            
                        } else if([type isEqualToString:@"FILE"]){
                            NSData *data = [[resultArr objectAtIndex:uploadCount] objectForKey:@"FILE_DATA"];
                            [self saveMediaFiles:data mediaType:type isFile:[[resultArr objectAtIndex:uploadCount] objectForKey:@"FILE_NM"]];
                        }
                        
                    } else if(uploadCount==resultArr.count){
                        [self imageToUrlString];
                        
                        NSError *error;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArr options:0 error:&error];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"%0A" withString:@"%5Cn"];
                        jsonString = [jsonString urlEncodeUsingEncoding:NSUTF8StringEncoding];
                        
                        NSData *prevData = [NSJSONSerialization dataWithJSONObject:firstArr options:0 error:&error];
                        NSString *prevString = [[NSString alloc] initWithData:prevData encoding:NSUTF8StringEncoding];
//                        prevString = [prevString stringByReplacingOccurrencesOfString:@"%0A" withString:@"%5Cn"];
                        prevString = [prevString urlEncodeUsingEncoding:NSUTF8StringEncoding];
                        
                        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
                        
                        [SVProgressHUD dismiss];
                        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@&feed_content=%@", myUserNo, self.snsNo, self.postNo, jsonString, prevString];
                        NSLog(@"modi img savepost param : %@", paramString);
                        [self callWebService:@"savePost" WithParameter:paramString];
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
}

#pragma mark - Notification
- (void)noti_PostOrderModify:(NSNotification *)notification {
    NSArray *dataSetArr = [notification.userInfo objectForKey:@"DATASET"];
    self.filePathArray = [NSMutableArray array];
    self.contentImageArray = [NSMutableArray array];
    dataArr = [NSMutableArray array];
    uploadCount = 0;

    [dataArr setArray:dataSetArr];

//    [UIView performWithoutAnimation:^{
//        [self.tableView reloadData];
//    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
        
        NSIndexPath *lastCell = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_PostOrderModify" object:nil];
}

- (void)noti_TeamExit:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamSelectExit" object:nil];
    }];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getImageNotification:)
                                                 name:@"getImageNotification"
                                               object:nil];
    
    if ([[segue identifier] isEqualToString:@"POST_MODIFY_PHLIB_MODAL"]) {
        UINavigationController *destination = segue.destinationViewController;
        PHLibListViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.fromSegue = segue.identifier;
        vc.listType = sender;
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
}

@end
