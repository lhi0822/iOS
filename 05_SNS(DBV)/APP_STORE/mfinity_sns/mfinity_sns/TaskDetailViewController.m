//
//  TaskDetailViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 3. 12..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "TaskHistoryViewController.h"
#import "YLProgressBar.h"
#import "TaskNameCollectionViewCell.h"
#import "TaskDetailCollectionViewCell.h"
#import "TaskFileCollectionViewCell.h"
#import "TaskHistoryHeaderViewCell.h"
#import "TaskHistoryCollectionViewCell.h"
#import "TaskCommCollectionViewCell.h"
#import "SectionLineCCell.h"
#import "ImgDownloadViewController.h"
#import "UIImageView+WebCache.h"
#import <ImageIO/ImageIO.h>

#import "ImgDownloadViewController.h"
#import "WebViewController.h"
#import "TaskWriteViewController.h"
#import "TaskModifyViewController.h"

#import "MFUtil.h"
#import "MFDBHelper.h"
#import "NotiChatViewController.h"

#define REFRESH_HEADER_DEFAULT_HEIGHT               64.f

#define LABEL_DEFAULT_HEIGHT            21.f
#define LABEL_DEFAUlT_WIDTH             280.f
#define LABEL_MAX_HEIGHT                460.f
#define MODEL_NAME [[UIDevice currentDevice] modelName]

@interface TaskDetailViewController () <HorizontalScrollDelegate> {
    NSArray *images;
    NSMutableArray *commentArr;
    NSMutableArray *historyArr;
    
    float labelHeight;
    
    NSString *commentUsrId;
    NSString *commentNo;
    NSIndexPath *commentIdx;
    
    BOOL prevComment;
    
    float historyHeight;
    
    AppDelegate *appDelegate;
}

@end

static NSString* const CellIdentifier = @"TaskCommCollectionViewCell";

@implementation TaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:[NSString urlDecodeString:self._snsName]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TaskDetailView:) name:@"noti_TaskDetailView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TaskCommentEdit:) name:@"noti_TaskCommentEdit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TaskModify:) name:@"noti_TaskModify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
    
    
    self.inputToolbar.delegate = self;
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"post_comment_hint", @"post_comment_hint");
    //self.inputToolbar.contentView.textView.delegate = self;
    self.inputToolbar.contentView.rightBarButtonItem.titleLabel.text = NSLocalizedString(@"save", @"save");
    self.inputToolbar.contentView.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    self.inputToolbar.contentView.textView.textContainer.maximumNumberOfLines = 0;
    self.inputToolbar.contentView.textView.fromSegue = @"TASK_COMMENT";
    self.inputToolbar.contentView.textView.layer.borderWidth = 0.5f;
    self.inputToolbar.contentView.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    commentArr = [NSMutableArray array];
    historyArr = [NSMutableArray array];
    
    historyHeight = 0;
    
    self.isEdit = @"";
    prevComment = YES;
    
    self.lastHistNo = @"1";
    
    if([self.fromSegue isEqualToString:@"NOTI_TASK_DETAIL"]){
        NSArray *dataSet = [self.notiTaskDic objectForKey:@"DATASET"];
        NSString *taskNo = [[dataSet objectAtIndex:0] objectForKey:@"TASK_NO"];
        NSString *snsName = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"];
        self._taskNo = taskNo;
        
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:[NSString urlDecodeString:snsName]];
        
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClick)];
        
        self.inputToolbar.contentView.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        
        [self callWebService:@"getTaskDetail"];
        self.fromSegue = nil;
        
    } else {
        [self callWebService:@"getTaskDetail"];
    }
    
}

-(BOOL)textView:(MFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}
-(void)textViewDidChange:(MFTextView *)textView{
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    if (@available(iOS 11.0, *)) {
        self.collectionBottomConstraint.constant = 0;
    }
    
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)callWebService:(NSString *)serviceName{
    @try{
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
        NSString *paramString = nil;
        
        if([serviceName isEqualToString:@"getTaskDetail"]){
            NSString *readStatus = [self.taskInfo objectForKey:@"IS_READ"];
            paramString = [NSString stringWithFormat:@"taskNo=%@&usrNo=%@&readStatus=%@",self._taskNo, myUserNo, readStatus];
            
        } else if([serviceName isEqualToString:@"getTaskComments"]){
            int stSeq = [[[commentArr firstObject] objectForKey:@"SEQ"] intValue]+1;
            paramString = [NSString stringWithFormat:@"usrNo=%@&taskNo=%@&stSeq=%d", myUserNo, self._taskNo, stSeq];
            
        } else if([serviceName isEqualToString:@"deleteTaskComment"]){
            paramString = [NSString stringWithFormat:@"usrNo=%@&commentNo=%@&taskNo=%@", myUserNo, commentNo, self._taskNo];
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

#pragma mark - MFURLSessionDelegate
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    //Progress stop..gesture recognizers added to a view
    [SVProgressHUD dismiss];
    
    @try {
        if(error!=nil || [error isEqualToString:@"(null)"]) {
            if ([error isEqualToString:@"The request timed out."]) {
                
            } else {
                NSLog(@"Error Message : %@",error);
            }
        } else {
            NSString *wsName = [[session.url absoluteString] lastPathComponent];
            
            if([wsName isEqualToString:@"getTaskDetail"]){
                NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
                [commentArr setArray:[[dataSets objectAtIndex:0] objectForKey:@"COMMENTS"]];
                [historyArr setArray:[[dataSets objectAtIndex:0] objectForKey:@"HISTORYS"]];
                
                self.taskInfo = [[NSDictionary alloc]init];
                self.taskInfo = [dataSets objectAtIndex:0];
                [self.collectionView reloadData];
                
            } else if([wsName isEqualToString:@"getTaskComments"]){
                NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
                NSUInteger count = dataSets.count;
                
                if(count>0){
                    prevComment = YES;
                    for(int i=(int)count-1; i>=0; i--){
                        [commentArr insertObject:[dataSets objectAtIndex:i] atIndex:0];
                    }
                } else {
                    prevComment = NO;
                }
                
                [self.collectionView reloadData];
                
            } else if([wsName isEqualToString:@"saveTaskComment"]){
                self.inputToolbar.contentView.textView.text = @"";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SaveTask" object:nil userInfo:nil];
                [self callWebService:@"getTaskDetail"];
                
            } else if([wsName isEqualToString:@"deleteTaskComment"]){
                [self.collectionView reloadData];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);
    @try{
        if(error.code == -1009){
            [SVProgressHUD dismiss];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"인터넷 연결이 오프라인 상태입니다." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                 [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                 
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UICollectionViewDataSource

- (CGFloat)calculateHeightForConfiguredSizingCell:(UICollectionViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 8;
}


// 컬렉션 크기 설정
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    @try{
        CGRect screen = [[UIScreen mainScreen]bounds];
        CGFloat screenWidth = screen.size.width;
        
        if (indexPath.section==0) {
            return CGSizeMake(screenWidth, 80);
            
        } else if (indexPath.section==1) {
            static TaskDetailCollectionViewCell *sizingCell   = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                sizingCell = [[NSBundle mainBundle] loadNibNamed:@"TaskDetailCollectionViewCell" owner:self options:nil][0];
            });
            return CGSizeMake(screenWidth, [self tmpSetUpTaskDetailCell:sizingCell atIndexPath:indexPath]);
            
        } else if (indexPath.section==2) {
            return CGSizeMake(screenWidth, 105);
            
        } else if (indexPath.section==3) {
            return CGSizeMake(screenWidth, 55);
            
        } else if (indexPath.section==4) {
            static TaskHistoryCollectionViewCell *sizingCell   = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                sizingCell = [[NSBundle mainBundle] loadNibNamed:@"TaskHistoryCollectionViewCell" owner:self options:nil][0];
            });
            [self tmpSetUpHistoryCell:sizingCell atIndexPath:indexPath];
            return CGSizeMake(screenWidth, historyHeight+50);
            
        } else if (indexPath.section==5) {
            return CGSizeMake(screenWidth, 12);
            
        } else if (indexPath.section==6) {
            return CGSizeMake(screenWidth, 55);
            
        } else if (indexPath.section==7) {
            static TaskCommCollectionViewCell *sizingCell   = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                sizingCell = [[NSBundle mainBundle] loadNibNamed:@"TaskCommCollectionViewCell" owner:self options:nil][0];
            });
            
            if([self setUpCommentCell:sizingCell atIndexPath:indexPath]){
                return CGSizeMake(screenWidth, labelHeight+50);
            } else {
                return CGSizeMake(screenWidth, 60);
            }
            
        } else {
            return CGSizeMake(0, 0);
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}


- (CGFloat)sizingForRowAtIndexPath:(UICollectionViewCell *)sizingCell :(NSIndexPath *)indexPath {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    CGSize cellSize = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return cellSize.height;
}

// 컬렉션 뷰 셀 갯수
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    @try{
        if (section==0) {
            return 1;
        } else if (section==1) {
            return 1;
        } else if (section==2) {
            NSArray *fileArray = [self.taskInfo objectForKey:@"TASK_ATTACHED_FILE"];
            if(fileArray.count > 0) return 1;
            else return 0;
        } else if (section==3) {
            return 1;
        } else if (section==4) {
            return historyArr.count;
        } else if (section==5) {
            if(commentArr.count>=20&&prevComment) return 0;
            else if(commentArr.count>=20&&!prevComment) return 1;
            else return 1;
        } else if (section==6) {
            if(commentArr.count>=20&&prevComment) return 1;
            else if(commentArr.count>=20&&!prevComment) return 0;
            else return 0;
        } else if (section==7) {
            return commentArr.count;
        } else {
            return 0;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

// 컬렉션과 컬렉션 height 간격
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section==4) {
        return 0;
    }
    
    return 0;
    
}

// 컬렉션 뷰 셀 설정
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    @try{
        if (indexPath.section==0) {
            [self.collectionView registerNib:[UINib nibWithNibName:@"TaskNameCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TaskNameCollectionViewCell"];
            TaskNameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaskNameCollectionViewCell" forIndexPath:indexPath];
            [self setUpProfileCell:cell atIndexPath:indexPath];
            return cell;
            
        } else if (indexPath.section==1) {
            [self.collectionView registerNib:[UINib nibWithNibName:@"TaskDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TaskDetailCollectionViewCell"];
            TaskDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaskDetailCollectionViewCell" forIndexPath:indexPath];
            [self setUpTaskDetailCell:cell atIndexPath:indexPath];
            return cell;
            
        } else if(indexPath.section==2){
            [self.collectionView registerNib:[UINib nibWithNibName:@"TaskFileCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TaskFileCollectionViewCell"];
            TaskFileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaskFileCollectionViewCell" forIndexPath:indexPath];
            
            NSArray *fileArray = [self.taskInfo objectForKey:@"TASK_ATTACHED_FILE"];
            
            NSMutableArray *tmp = [[NSMutableArray alloc]init];
            
            for (NSDictionary *attachedFile in fileArray) {
                if ([[attachedFile objectForKey:@"TYPE"] isEqualToString:@"IMG"]) {
                    
                    NSDictionary *value = [attachedFile objectForKey:@"VALUE"];
                    NSString *thumbImagePath = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                    //NSString *originImagePath = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
                    
                    [tmp addObject:thumbImagePath];
                }
                
                if ([[attachedFile objectForKey:@"TYPE"] isEqualToString:@"FILE"]) {
                    NSString *filePath = [NSString urlDecodeString:[attachedFile objectForKey:@"VALUE"]];
                    [tmp addObject:filePath];
                    
                }
            }
            images = [[NSArray alloc]initWithArray:tmp];
            
            [self setUpTaskFileCell:cell atIndexPath:indexPath];
            
            return cell;
            
        } else if (indexPath.section==3) {
            [self.collectionView registerNib:[UINib nibWithNibName:@"TaskHistoryHeaderViewCell" bundle:nil] forCellWithReuseIdentifier:@"TaskHistoryHeaderViewCell"];
            TaskHistoryHeaderViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaskHistoryHeaderViewCell" forIndexPath:indexPath];
            [self setUpHistoryHeaderCell:cell atIndexPath:indexPath];
            return cell;
            
        } else if (indexPath.section==4) {
            [self.collectionView registerNib:[UINib nibWithNibName:@"TaskHistoryCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TaskHistoryCollectionViewCell"];
            TaskHistoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaskHistoryCollectionViewCell" forIndexPath:indexPath];
            [self setUpHistoryCell:cell atIndexPath:indexPath];
            return cell;
            
        } else if (indexPath.section==5) {
            [self.collectionView registerNib:[UINib nibWithNibName:@"SectionLineCCell" bundle:nil] forCellWithReuseIdentifier:@"SectionLineCCell"];
            SectionLineCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SectionLineCCell" forIndexPath:indexPath];
            return cell;
            
        } else if (indexPath.section==6) {
            [self.collectionView registerNib:[UINib nibWithNibName:@"TaskHistoryHeaderViewCell" bundle:nil] forCellWithReuseIdentifier:@"TaskHistoryHeaderViewCell"];
            TaskHistoryHeaderViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaskHistoryHeaderViewCell" forIndexPath:indexPath];
            [self setUpHistoryHeaderCell:cell atIndexPath:indexPath];
            return cell;
            
        } else if (indexPath.section==7) {
            [self.collectionView registerNib:[UINib nibWithNibName:@"TaskCommCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TaskCommCollectionViewCell"];
            TaskCommCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaskCommCollectionViewCell" forIndexPath:indexPath];
            [self setUpCommentCell:cell atIndexPath:indexPath];
            return cell;
            
        } else {
            return nil;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}



- (void)setUpProfileCell:(TaskNameCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        NSString *userNo = [self.taskInfo objectForKey:@"CUSER_NO"];
        NSString *userName = [NSString urlDecodeString:[self.taskInfo objectForKey:@"CUSER_NM"]];
        NSString *taskDate = [NSString urlDecodeString:[self.taskInfo objectForKey:@"TASK_DATE"]];
        
        NSString *profileImagePath = [NSString urlDecodeString:[self.taskInfo objectForKey:@"STATUS_IMG"]];
        if (![profileImagePath isEqual:@""]) {
            UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImagePath num:userNo]];
            [cell.profileImageButton setImage:userImg forState:UIControlStateNormal];
            
        } else{
            [cell.profileImageButton setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
        }
        
        cell.profileImageButton.tag = -1;
        [cell.profileImageButton addTarget:self action:@selector(profileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.nameLabel.text = userName;
        cell.dateLabel.text = taskDate;
        
        //touchedSettingButton
        [cell.settingButton addTarget:self action:@selector(touchedSettingButton:) forControlEvents:UIControlEventTouchUpInside];
        
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)touchedSettingButton:(UIButton *)sender{
    BOOL isEditor = NO;
    
    NSString *createUserNo = [self.taskInfo objectForKey:@"CUSER_NO"];
    
    NSString *managerStr = [NSString urlDecodeString:[self.taskInfo objectForKey:@"MANAGER_LIST"]];
    NSMutableString *managerStr2 = [[NSMutableString alloc] initWithString:managerStr];
    [managerStr2 deleteCharactersInRange:[managerStr2 rangeOfString:@"["]];
    [managerStr2 deleteCharactersInRange:[managerStr2 rangeOfString:@"]"]];
    NSArray *managerArr = [managerStr2 componentsSeparatedByString:@","];
    
    NSString *referencerStr = [NSString urlDecodeString:[self.taskInfo objectForKey:@"REFERENCER_LIST"]];
    NSMutableString *referencerStr2 = [[NSMutableString alloc] initWithString:referencerStr];
    [referencerStr2 deleteCharactersInRange:[referencerStr2 rangeOfString:@"["]];
    [referencerStr2 deleteCharactersInRange:[referencerStr2 rangeOfString:@"]"]];
    NSArray *referencerArr = [referencerStr2 componentsSeparatedByString:@","];
    
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    for (int i=0; i<managerArr.count; i++) {
        if([[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", [managerArr objectAtIndex:i]]]){
            isEditor = YES;
            break;
        }
    }
    
    for (int i=0; i<referencerArr.count; i++) {
        if([[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", [referencerArr objectAtIndex:i]]]){
            isEditor = YES;
            break;
        }
    }
    
    if([[NSString stringWithFormat:@"%@", myUserNo] isEqualToString:[NSString stringWithFormat:@"%@", createUserNo]]) isEditor = YES;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (isEditor) {
        UIAlertAction *editAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"수정", @"수정")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action){
                                                               self.isEdit = @"TASK";
                                                               //[self performSegueWithIdentifier:@"POST_MODIFY_MODAL" sender:self.postDetailInfo];
                                                               
                                                               UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                               TaskModifyViewController *destination = (TaskModifyViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TaskModifyViewController"];
                                                               UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                                                               
                                                               destination.fromSegue = @"TASK_MODIFY_MODAL";
                                                               destination.taskInfoDic = self.taskInfo;
                                                               destination.snsName = [NSString urlDecodeString:[self.taskInfo objectForKey:@"SNS_NM"]];
                                                               
                                                               navController.modalTransitionStyle = UIModalPresentationNone;
                                                                navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                               [self presentViewController:navController animated:YES completion:nil];
                                                               
                                                               [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                           }];
        [actionSheet addAction:editAction];
    }
    
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

-(void)profileBtnClick:(UIButton *)sender{
    NSString *userNo = nil;
    if(sender.tag>-1){
        userNo = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    }else{
        userNo = [self.taskInfo objectForKey:@"CUSER_NO"];
    }
    NSString *userType = [self.taskInfo objectForKey:@"SNS_USER_TYPE"];
    
    CustomHeaderViewController *destination = [[CustomHeaderViewController alloc] initwithUserNo:userNo userType:userType];
    destination.userNo = userNo;
    destination.userType = userType;
    destination.fromSegue = @"POST_DETAIL_PROFILE_MODAL";
    
    destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:destination animated:YES completion:nil];
}

- (void)setUpTaskDetailCell:(TaskDetailCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        NSString *taskTitle = [NSString urlDecodeString:[self.taskInfo objectForKey:@"TASK_TITLE"]];
        NSString *taskStartDate = [NSString urlDecodeString:[self.taskInfo objectForKey:@"TASK_START_DATE"]];
        NSString *taskEndDate = [NSString urlDecodeString:[self.taskInfo objectForKey:@"TASK_END_DATE"]];
        NSNumber *taskStatus = [self.taskInfo objectForKey:@"STATUS"];
        NSString *managerName = [NSString urlDecodeString:[self.taskInfo objectForKey:@"MANAGER_NAME_LIST"]];
        NSString *refName = [NSString urlDecodeString:[self.taskInfo objectForKey:@"REFERENCER_NAME_LIST"]];
        NSNumber *taskProgress = [self.taskInfo objectForKey:@"PROGRESS"];
        NSString *taskCaption = [NSString urlDecodeString:[self.taskInfo objectForKey:@"TASK_CAPTION"]];
//        NSArray *fileArray = [self.taskInfo objectForKey:@"TASK_ATTACHED_FILE"];
        
        cell.projectIcon.image = [UIImage imageNamed:@"project_schedule_blue.png"];
        cell.projectTitle.text = taskTitle;
        
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
        [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
        
        NSDate *sDate = [formatter2 dateFromString:taskStartDate];
        NSDate *eDate = [formatter2 dateFromString:taskEndDate];
        
        NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
        [formatter3 setDateFormat:@"yyyy-MM-dd"];
        NSString *sDateStr = [formatter3 stringFromDate:sDate];
        NSString *eDateStr = [formatter3 stringFromDate:eDate];
        
        if(taskStartDate.length<=0 && taskEndDate.length<=0){
            cell.projectDate.text = @"미정";
        } else if(taskStartDate.length>0 && taskEndDate.length<=0){
            cell.projectDate.text = [NSString stringWithFormat:@"%@ ~ 미정", sDateStr];
        } else if(taskStartDate.length<=0 && taskEndDate.length>0){
            cell.projectDate.text = [NSString stringWithFormat:@"미정 ~ %@", eDateStr];
        } else {
            cell.projectDate.text = [NSString stringWithFormat:@"%@ ~ %@", sDateStr, eDateStr];
        }
        
        [cell.statusBtn setBackgroundColor:[UIColor clearColor]];
        [cell.statusBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_progress.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
        [cell.statusBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [cell.statusBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
        [cell.statusBtn setTitle:@"상태" forState:UIControlStateNormal];
        
        NSString *statusStr = nil;
        if([taskStatus intValue]==1){
            statusStr = NSLocalizedString(@"task_status1", @"task_status1");
        } else if([taskStatus intValue]==2){
            statusStr = @"진행";
        } else if([taskStatus intValue]==3){
            statusStr = NSLocalizedString(@"task_status3", @"task_status3");
        } else if([taskStatus intValue]==4){
            statusStr = @"보류";
        }
        cell.statusLbl.text = statusStr;
        
        [cell.userBtn setBackgroundColor:[UIColor clearColor]];
        [cell.userBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_member.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
        [cell.userBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [cell.userBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
        [cell.userBtn setTitle:@"수행자" forState:UIControlStateNormal];
        cell.userLbl.text = managerName;
        
        [cell.refUserBtn setBackgroundColor:[UIColor clearColor]];
        [cell.refUserBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_cc.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
        [cell.refUserBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [cell.refUserBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
        [cell.refUserBtn setTitle:@"참조자" forState:UIControlStateNormal];
        cell.refUserLbl.text = refName;
        
        [cell.proceedBtn setBackgroundColor:[UIColor clearColor]];
        [cell.proceedBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_graph.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
        [cell.proceedBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [cell.proceedBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
        [cell.proceedBtn setTitle:@"진행률" forState:UIControlStateNormal];
        
        [cell.ProgressView setProgress:[taskProgress intValue]*0.01 animated:NO];
        
        
        [cell.descBtn setBackgroundColor:[UIColor clearColor]];
        [cell.descBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_caption.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
        [cell.descBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [cell.descBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
        [cell.descBtn setTitle:@"설명" forState:UIControlStateNormal];
        
        cell.descLabel.numberOfLines = 0;
        cell.descLabel.text = taskCaption;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (CGFloat)tmpSetUpTaskDetailCell:(TaskDetailCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        NSString *taskCaption = [NSString urlDecodeString:[self.taskInfo objectForKey:@"TASK_CAPTION"]];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:taskCaption];
        CGSize maximumSize = CGSizeMake(300, 9999);
        CGRect rect = [str boundingRectWithSize:(CGSize)maximumSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGSize textStringSize = rect.size;
        
        return cell.frame.size.height + textStringSize.height + 15;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}


- (void)setUpTaskFileCell:(TaskFileCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        cell.cellDelegate = self;
        [cell setUpCellWithArray:images];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)setUpHistoryHeaderCell:(TaskHistoryHeaderViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        if(indexPath.section==3){
            cell.titleLabel.text = @"최근변동이력";
            [cell.moreButton setTitle:@"모두보기 >" forState:UIControlStateNormal];
            [cell.moreButton setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
            [cell.moreButton addTarget:self action:@selector(moreHistory) forControlEvents:UIControlEventTouchUpInside];
            
        } else if(indexPath.section==6){
            cell.titleLabel.text = NSLocalizedString(@"comment2", @"comment2");
            cell.titleLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPrevComment:)];
            cell.titleLabel.userInteractionEnabled = YES;
            [cell.titleLabel addGestureRecognizer:tap];
            [cell.moreButton setTitle:@"" forState:UIControlStateNormal];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)tapOnPrevComment:(UITapGestureRecognizer*)tap{
    [self callWebService:@"getTaskComments"];
}

- (void)setUpHistoryCell:(TaskHistoryCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        if(historyArr.count>0){
            NSString *content = [NSString urlDecodeString:[[historyArr objectAtIndex:indexPath.item] objectForKey:@"CONTENT"]];
            NSString *histDate = [NSString urlDecodeString:[[historyArr objectAtIndex:indexPath.item] objectForKey:@"HISTORY_DATE"]];
            NSString *histUserNo = [[historyArr objectAtIndex:indexPath.item] objectForKey:@"CUSER_NO"];
            NSString *createUserNo = [self.taskInfo objectForKey:@"CUSER_NO"];
            
            NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            
            NSString *histType = [dict objectForKey:@"TYPE"];
            NSString *histName = [dict objectForKey:@"NAME"];
            NSString *histContent = [dict objectForKey:@"CONTENT"];
            
            NSString *tyStr = nil;
            NSString *postPosition = nil;;
            
            if([histType isEqualToString:@"TITLE"]){
                tyStr = @"업무명";
                postPosition = @"을";
            } else if([histType isEqualToString:@"STATUS"]){
                tyStr = @"상태";
                postPosition = @"를";
                
                if([histContent isEqualToString:@"1"]) histContent=NSLocalizedString(@"task_status1", @"task_status1");
                else if([histContent isEqualToString:@"2"]) histContent=@"진행";
                else if([histContent isEqualToString:@"3"]) histContent=NSLocalizedString(@"task_status3", @"task_status3");
                else if([histContent isEqualToString:@"4"]) histContent=@"보류";
                
                
            } else if([histType isEqualToString:@"MANAGER"]){
                tyStr = @"수행자";
                postPosition = @"를";
                
            } else if([histType isEqualToString:@"REFERENCER"]){
                tyStr = @"참조자";
                postPosition = @"를";
                
            } else if([histType isEqualToString:@"START_DATE"]){
                tyStr = @"시작일";
                postPosition = @"을";
                
            } else if([histType isEqualToString:@"END_DATE"]){
                tyStr = @"완료일";
                postPosition = @"을";
                
            }  else if([histType isEqualToString:@"PROGRESS"]){
                tyStr = @"진행률";
                postPosition = @"을";
                
            } else if([histType isEqualToString:@"CAPTION"]){
                tyStr = @"설명";
                postPosition = @"을";
                
            } else if([histType isEqualToString:@"ATTACHED_FILE"]){
                tyStr = @"첨부파일";
                postPosition = @"을";
            }
            
            if([[NSString stringWithFormat:@"%@", createUserNo] isEqualToString:[NSString stringWithFormat:@"%@", histUserNo]]){
                cell.imgIcon.image = [UIImage imageNamed:@"icon_crown.png"];
            } else {
                
            }
            
            NSMutableAttributedString *attrHistName = [[NSMutableAttributedString alloc] initWithString:histName attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13]}];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
            [str appendAttributedString:attrHistName];
            
            NSAttributedString *str3;
            if(histContent==nil||[histContent isEqualToString:@""]){
                NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"님이 %@%@ ", tyStr, postPosition] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
                if([histType isEqualToString:@"ATTACHED_FILE"]){
                    [str appendAttributedString:str2];
                    str3 = [[NSAttributedString alloc] initWithString:@"변경하였습니다." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
                } else {
                    [str appendAttributedString:str2];
                    str3 = [[NSAttributedString alloc] initWithString:@"미지정 하였습니다." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
                }
                
            } else {
                NSMutableAttributedString *attrHistContent = [[NSMutableAttributedString alloc] initWithString:histContent attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],  NSForegroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]}];
                
                NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"님이 %@%@ ", tyStr, postPosition] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
                [str appendAttributedString:str2];
                [str appendAttributedString:attrHistContent];
                str3 = [[NSAttributedString alloc] initWithString:@"(으)로 변경하였습니다." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
                
            }
            [str appendAttributedString:str3];
            
            cell.msgLabel.attributedText = str;
            cell.dateLabel.text = histDate;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)tmpSetUpHistoryCell:(TaskHistoryCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        if(historyArr.count>0){
            historyHeight = 0;
            NSString *content = [NSString urlDecodeString:[[historyArr objectAtIndex:indexPath.item] objectForKey:@"CONTENT"]];
            
            NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            
            NSString *histType = [dict objectForKey:@"TYPE"];
            NSString *histName = [dict objectForKey:@"NAME"];
            NSString *histContent = [dict objectForKey:@"CONTENT"];
            
            NSString *tyStr = nil;
            NSString *postPosition = nil;;
            
            if([histType isEqualToString:@"TITLE"]){
                tyStr = @"업무명";
                postPosition = @"을";
            } else if([histType isEqualToString:@"STATUS"]){
                tyStr = @"상태";
                postPosition = @"를";
                
                if([histContent isEqualToString:@"1"]) histContent=NSLocalizedString(@"task_status1", @"task_status1");
                else if([histContent isEqualToString:@"2"]) histContent=@"진행";
                else if([histContent isEqualToString:@"3"]) histContent=NSLocalizedString(@"task_status3", @"task_status3");
                else if([histContent isEqualToString:@"4"]) histContent=@"보류";
                
            } else if([histType isEqualToString:@"MANAGER"]){
                tyStr = @"수행자";
                postPosition = @"를";
                
            } else if([histType isEqualToString:@"REFERENCER"]){
                tyStr = @"참조자";
                postPosition = @"를";
                
            } else if([histType isEqualToString:@"START_DATE"]){
                tyStr = @"시작일";
                postPosition = @"을";
                
            } else if([histType isEqualToString:@"END_DATE"]){
                tyStr = @"완료일";
                postPosition = @"을";
                
            }  else if([histType isEqualToString:@"PROGRESS"]){
                tyStr = @"진행률";
                postPosition = @"을";
                
            } else if([histType isEqualToString:@"CAPTION"]){
                tyStr = @"설명";
                postPosition = @"을";
                
            } else if([histType isEqualToString:@"ATTACHED_FILE"]){
                tyStr = @"첨부파일";
                postPosition = @"을";
            }
            
            NSMutableAttributedString *attrHistName = [[NSMutableAttributedString alloc] initWithString:histName attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13]}];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
            [str appendAttributedString:attrHistName];
            
            NSAttributedString *str3;
            if(histContent==nil||[histContent isEqualToString:@""]){
                NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"님이 %@%@ ", tyStr, postPosition]];
                if([histType isEqualToString:@"ATTACHED_FILE"]){
                    [str appendAttributedString:str2];
                    str3 = [[NSAttributedString alloc] initWithString:@"변경하였습니다."];
                } else {
                    [str appendAttributedString:str2];
                    str3 = [[NSAttributedString alloc] initWithString:@"미지정 하였습니다."];
                }
                
            } else {
                NSMutableAttributedString *attrHistContent = [[NSMutableAttributedString alloc] initWithString:histContent attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],  NSForegroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]}];
                
                NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"님이 %@%@ ", tyStr, postPosition]];
                [str appendAttributedString:str2];
                [str appendAttributedString:attrHistContent];
                str3 = [[NSAttributedString alloc] initWithString:@"(으)로 변경하였습니다."];
            }
            
            [str appendAttributedString:str3];
            
            CGSize maximumSize = CGSizeMake(300, 9999);
            CGRect rect = [str boundingRectWithSize:(CGSize)maximumSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            CGSize textStringSize = rect.size;
            
            if(textStringSize.height>cell.msgLabel.frame.size.height){
                historyHeight = textStringSize.height-cell.msgLabel.frame.size.height;
            }
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (BOOL)setUpCommentCell:(TaskCommCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        if(commentArr.count>0){
            NSString *content = [NSString urlDecodeString:[[commentArr objectAtIndex:indexPath.item] objectForKey:@"CONTENT"]];
            NSString *commDate = [NSString urlDecodeString:[[commentArr objectAtIndex:indexPath.item] objectForKey:@"COMMENT_DATE"]];
            NSString *commUserNm = [NSString urlDecodeString:[[commentArr objectAtIndex:indexPath.item] objectForKey:@"CUSER_NM"]];
            NSString *commUserNo = [[commentArr objectAtIndex:indexPath.item] objectForKey:@"CUSER_NO"];
            NSString *commUserImg = [NSString urlDecodeString:[[commentArr objectAtIndex:indexPath.item] objectForKey:@"STATUS_IMG"]];
            
            if (![commUserImg isEqual:@""]) {
                UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:commUserImg num:commUserNo]];
                [cell.userImg setImage:userImg forState:UIControlStateNormal];
                
            } else{
                [cell.userImg setImage:[UIImage imageNamed:@"profile_default.png"] forState:UIControlStateNormal];
            }
            cell.userImg.tag = [commUserNo intValue];
            [cell.userImg addTarget:self action:@selector(profileBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDate *currentDate = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            NSString *tmp = [commDate substringToIndex:commDate.length-3];
            NSDate *regiDate = [formatter dateFromString:tmp];
            
            NSCalendar *sysCalendar = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSCalendarUnitDay;
            NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:regiDate toDate:currentDate options:0];//날짜 비교해서 차이값 추출
            NSInteger date = dateComp.day;
            
            NSString *commDateString = [[NSString alloc]init];
            if(date > 0){
                commDateString = tmp;
            } else{
                commDateString = [MFUtil getTimeIntervalFromDate:regiDate ToDate:currentDate];
            }
            
            cell.userName.text = commUserNm;
            cell.dateLabel.text = commDateString;
            
            [cell.commContent setFont:[UIFont systemFontOfSize:14]];
            [cell.commContent setNumberOfLines:0];
            //[cell.comment setLineBreakMode:NSLineBreakByClipping];
            [cell.commContent setLineBreakMode:NSLineBreakByCharWrapping];
            
            CGSize constraintSize = CGSizeMake(LABEL_DEFAUlT_WIDTH, LABEL_MAX_HEIGHT);
            
            //CGSize newSize = [[NSString urlDecodeString:comment] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByClipping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:[NSString urlDecodeString:content] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize)constraintSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            CGSize newSize = rect.size;
            
            labelHeight = MAX(newSize.height, LABEL_DEFAULT_HEIGHT);
            
            cell.commContent.text = [NSString urlDecodeString:content];
            [cell.commContent setFrame:CGRectMake(cell.commContent.frame.origin.x, cell.commContent.frame.origin.y, cell.commContent.frame.size.width, labelHeight)];
            
            cell.gestureRecognizers = nil;
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(commentTabDetected:)];
            longPress.minimumPressDuration = 0.5;
            longPress.delegate = self;
            [cell addGestureRecognizer:longPress];
        }
        
        return YES;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)commentTabDetected:(UILongPressGestureRecognizer *)gesture{
    CGPoint p = [gesture locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil) {
        //NSLog(@"long press on table view but not on a row");
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
//        NSLog(@"long press on table view at row %ld", indexPath.item);
        
        [self commentSelect:indexPath];
    } else {
        //NSLog(@"gestureRecognizer.state = %ld", gesture.state);
    }
}

- (void)commentSelect:(NSIndexPath *)indexPath{
    @try{
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *copyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"copy", @"copy")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action){
                                                               NSString *comment = [[commentArr objectAtIndex:indexPath.item]objectForKey:@"CONTENT"];
                                                               
                                                               UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                               NSString *decodeString = [NSString urlDecodeString:comment];
                                                               pasteboard.string = decodeString;
                                                               
                                                               [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                           }];
        [actionSheet addAction:copyAction];
        
        NSNumber *subcriber = [self.taskInfo objectForKey:@"CUSER_NO"];
        NSNumber *writer = [[commentArr objectAtIndex:indexPath.row]objectForKey:@"CUSER_NO"];
        
        if ([subcriber isEqual:writer]) {
            UIAlertAction *updateAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"수정", @"수정")
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action){
                                                                     commentUsrId = [appDelegate.appPrefs objectForKey:@"USERID"];
                                                                     commentNo = [[commentArr objectAtIndex:indexPath.item]objectForKey:@"DATA_NO"];
                                                                     commentIdx = indexPath;
                                                                     self.isEdit = @"COMMENT";
                                                                     
                                                                     [self performSegueWithIdentifier:@"TASK_COMM_MODIFY_MODAL" sender:[commentArr objectAtIndex:indexPath.row]];
                                                                     
                                                                     [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            
            
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
                                                                   style:UIAlertActionStyleDestructive
                                                                 handler:^(UIAlertAction * action){
                                                                     commentUsrId = [appDelegate.appPrefs objectForKey:@"USERID"];
                                                                     commentNo = [[commentArr objectAtIndex:indexPath.item]objectForKey:@"DATA_NO"];
                                                                     
                                                                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"delete1", @"delete1") preferredStyle:UIAlertControllerStyleAlert];
                                                                     UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                                                                      handler:^(UIAlertAction * action) {
                                                                                                                          [commentArr removeObjectAtIndex:indexPath.item];
                                                                                                                          [self callWebService:@"deleteTaskComment"];
                                                                                                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                      }];
                                                                     
                                                                     UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                                                                          handler:^(UIAlertAction * action) {
                                                                                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                          }];
                                                                     [alert addAction:okButton];
                                                                     [alert addAction:cancelButton];
                                                                     [self presentViewController:alert animated:YES completion:nil];
                                                                     
                                                                     commentIdx = indexPath;
                                                                     
                                                                     [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
            [deleteAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
            
            [actionSheet addAction:updateAction];
            [actionSheet addAction:deleteAction];
        }
        
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

-(void)moreHistory{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TaskHistoryViewController *destination = (TaskHistoryViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TaskHistoryViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    
    destination.taskNo = self._taskNo;
    destination.createUserNo = [self.taskInfo objectForKey:@"CUSER_NO"];
    
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)cellSelected:(UIView *)view{
    NSInteger index = view.tag-1;
    NSArray *fileArray = [self.taskInfo objectForKey:@"TASK_ATTACHED_FILE"];
    
    NSDictionary *fileDic = [fileArray objectAtIndex:index];
    
    if([[fileDic objectForKey:@"TYPE"] isEqualToString:@"IMG"]){
        NSDictionary *value = [fileDic objectForKey:@"VALUE"];
        NSString *originImagePath = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
        NSURL *imageUrl = [NSURL URLWithString:originImagePath];
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        ImgDownloadViewController *destination = (ImgDownloadViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ImgDownloadViewController"];
                        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                        
                        destination.imgPath = originImagePath;
                        destination.imgName = [originImagePath lastPathComponent];
                        destination.fromSegue = @"TASK_IMG_DOWN_MODAL";
                        
                        navController.modalTransitionStyle = UIModalPresentationNone;
                        navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                        [self presentViewController:navController animated:YES completion:nil];
                    });
                }
            }
        }];
        [task resume];
        
    } else if([[fileDic objectForKey:@"TYPE"] isEqualToString:@"FILE"]){
        NSString *filePath = [NSString urlDecodeString:[fileDic objectForKey:@"VALUE"]];
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *fileOpenAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"file_open", @"file_open")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action){
                                                                   UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                   WebViewController *destination = (WebViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
                                                                   UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                                                                   
                                                                   destination.fileUrl = filePath;
                                                                   
                                                                   navController.modalTransitionStyle = UIModalPresentationNone;
                                                                    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                                   [self presentViewController:navController animated:YES completion:nil];
                                                                   
                                                                   [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                               }];
        [actionSheet addAction:fileOpenAction];
        
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
}


#pragma mark - JSQMessagesInputToolbarDelegate
- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
    
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    [self.view endEditing:YES];
    
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveTaskComment"]];
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSString *content = toolbar.contentView.textView.text;
    content = [content urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *taskNo = [self.taskInfo objectForKey:@"TASK_NO"];
    NSString *snsNo = [self.taskInfo objectForKey:@"SNS_NO"];
    
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&taskNo=%@&commentNo=&content=%@&isNewComment=true", myUserNo, snsNo, taskNo, content];
    sender.enabled = NO;
    
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

#pragma mark - Push Notification
- (void)noti_TaskDetailView:(NSNotification *)notification{
    NSLog(@"notification.userInfo : %@", notification.userInfo);
    
    @try {
        NSArray *dataSet = [notification.userInfo objectForKey:@"DATASET"];
        NSString *taskNo = [[dataSet objectAtIndex:0] objectForKey:@"TASK_NO"];
        
        if(![[NSString stringWithFormat:@"%@", taskNo] isEqualToString:[NSString stringWithFormat:@"%@", self._taskNo]]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TaskDetailViewController *vc = (TaskDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TaskDetailViewController"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            vc.fromSegue = @"NOTI_TASK_DETAIL";
            vc.notiTaskDic = notification.userInfo;
            
            [self presentViewController:nav animated:YES completion:nil];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
}

- (void)noti_TaskCommentEdit:(NSNotification *)notification {
    @try {
        [self callWebService:@"getTaskDetail"];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_TaskModify:(NSNotification *)notification {
    @try {
        [self callWebService:@"getTaskDetail"];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)noti_NewPostPush:(NSNotification *)notification {
    @try{
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
            
            NSString *currentClass = NSStringFromClass([[UIViewController currentViewController] class]);
            NSString *postDetailClass = NSStringFromClass([vc class]);
            
            vc.fromSegue = @"NOTI_POST_DETAIL";
            vc.notiPostDic = dict;
            
            if([currentClass isEqualToString:postDetailClass]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_PostDetailView" object:nil userInfo:dict];
            } else {
                [self presentViewController:nav animated:YES completion:nil];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    appDelegate.inactivePostPushInfo=nil;
}

- (void)noti_NewChatPush:(NSNotification *)notification {
    @try{
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
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
    
    appDelegate.inactiveChatPushInfo=nil;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"FILE_OPEN_MODAL"]){
        UINavigationController *destination = segue.destinationViewController;
        WebViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.fileUrl = sender;
        
    } else if([segue.identifier isEqualToString:@"TASK_COMM_MODIFY_MODAL"]){
        UINavigationController *destination = segue.destinationViewController;
        PostModifyTableViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.snsNo = self._snsNo;
        vc.taskNo = self._taskNo;
        vc.isEdit = self.isEdit;
        vc.fromSegue = @"MODIFY_TASK_COMMENT";
        
        if([self.isEdit isEqualToString:@"COMMENT"]){
            NSDictionary *commentDic = sender;
            vc.commDic = commentDic;
            
        }
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
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (@available(iOS 11.0, *)) {
        kbSize.height = kbSize.height - self.view.safeAreaInsets.bottom;
    } else {
        kbSize.height = kbSize.height;
    }
    
    if ([notification name]==UIKeyboardWillShowNotification) {
        self.keyboardHeight.constant = kbSize.height;
        [self.view layoutIfNeeded];
        
    }else if([notification name]==UIKeyboardWillHideNotification){
        self.keyboardHeight.constant = 0;
        [self.view layoutIfNeeded];
    }
    [UIView commitAnimations];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    @try {
        CGRect screen = [[UIScreen mainScreen]bounds];
        CGFloat screenWidth = screen.size.width;
        CGFloat screenHeight = screen.size.height;
        if ([MFUtil retinaDisplayCapable]) {
            screenHeight = screenHeight*2;
            screenWidth = screenWidth*2;
        }
        
        if (scrollView.contentSize.height-scrollView.contentOffset.y<self.view.frame.size.height) {
            CGPoint offset = scrollView.contentOffset;
            CGRect bounds = scrollView.bounds;
            CGSize size = scrollView.contentSize;
            UIEdgeInsets inset = scrollView.contentInset;
            float y = offset.y + bounds.size.height - inset.bottom;
            float h = size.height;
            
            float reload_distance = 10;
            
            
            if(y > h + reload_distance) {
                //데이터로드
                //NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_ID"];
                //            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                //            NSString *myUserNo = [prefs objectForKey:@"CUSER_NO"];
                //            NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&postNo=%@", myUserNo, self._postNo];
                //            [self callWebService:@"getPostDetail" WithParameter:paramString];
            }
        }
        
        if(scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT)
        {
            [self startLoading];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)startLoading
{
    @try {
        //데이터새로고침
        [self callWebService:@"getTaskDetail"];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
}


@end
