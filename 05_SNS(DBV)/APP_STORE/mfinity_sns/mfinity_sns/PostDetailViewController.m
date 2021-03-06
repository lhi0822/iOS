//
//  PostDetailViewController.m
//  mfinity_sns
//
//  Created by hilee on 07/02/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "PostDetailViewController.h"
#import "UILabel+Copyable.h"
#import "ImgDownloadViewController.h"
#import "UIImageView+WebCache.h"
#import <ImageIO/ImageIO.h>
#import "SDImageCache.h"

#import "PostOrderModifyViewController.h"
#import "PostModifyTableViewController.h"
#import "PHLibListViewController.h"

#import "MFPostNameCell.h"
#import "PostCommViewCell.h"
#import "TextLabelTableViewCell.h"
#import "ImageTableViewCell.h"
#import "VideoTableViewCell.h"
#import "FileTableViewCell.h"
#import "SectionLineTableCell.h"
#import "CommHeaderViewCell.h"

//#import "AttachView.h"
#import "AttachViewController.h"
#import "NotiChatViewController.h"

#define ROW_TAG 1000

#define REFRESH_TABLEVIEW_DEFAULT_ROW               64.f
#define REFRESH_HEADER_DEFAULT_HEIGHT               64.f
#define REFRESH_TITLE_TABLE_PULL                    @"당겼다 놔주세요."
#define REFRESH_TITLE_TABLE_RELEASE                 @"당겼다 놔주세요."
#define REFRESH_TITLE_TABLE_LOAD                    @"새로고치는 중..."
#define REFRESH_TIME_FORMAT                         @"MM/dd (HH:mm:ss)"

#define MODEL_NAME [[UIDevice currentDevice] modelName]

#define LABEL_DEFAULT_HEIGHT            21.f
#define LABEL_DEFAUlT_WIDTH             280.f
#define LABEL_MAX_HEIGHT                460.f

@interface PostDetailViewController () {
    AppDelegate *appDelegate;
    SDImageCache *imgCache;
    
    int idx;
    
    NSString *commentUsrId;
    NSString *commentNo;
    NSIndexPath *commentIdx;
    NSString *snsNo;

    BOOL isComment;
    int commentCnt;
    
    int pSize;
    NSMutableArray *commDataArr;
    NSString *mediaType;
    int commUploadCnt;
    int commFileNameCnt;
    BOOL prevComment;
    NSString *prevCommentNo;
    
    NSString *videoThumbName;
    
    int setCount;
    NSMutableArray *resultArr;
    
    NSMutableAttributedString *inputText;
    NSInteger prevLoc;
    NSInteger prevLen;
    
    NSMutableArray *resultCommArr;
    
    NSString *textVal;
    int attrCount;
    BOOL isTagSpace;
    NSString *newRefNo;
    
    int cachingCnt;
    int commCachingCnt;
    
    int dataCnt;
    int commDataCnt;
    
    int cellHeight;
    int imgH;
    NSMutableDictionary *cellDict;
    
    NSString *myUserNo;
    
    int timerCount;
    int timerEndCount;
    NSTimer *myTimer;
    
//    BOOL isTap;
    PostCommViewCell *commCell;
    
    NSString *fileTypeName;
}

@property (strong, nonatomic) AttachViewController *attachView;

@end

@implementation PostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    isTap = NO;
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_PostDetailView:) name:@"noti_PostDetailView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_PostProfileChat:) name:@"noti_PostProfileChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewChatPush:) name:@"noti_NewChatPush" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_CommentEdit:) name:@"noti_CommentEdit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_PostModify:) name:@"noti_PostModify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TeamExit:) name:@"noti_TeamExit" object:nil];
    
    imgCache = [SDImageCache sharedImageCache];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    [imgCache makeDiskCachePath:cachePath];
    
    //캐시삭제
//    [[SDImageCache sharedImageCache] clearMemory];
//    [[SDImageCache sharedImageCache] clearDisk];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTable:)];
    [self.tableView addGestureRecognizer:tap];
    tap.cancelsTouchesInView = NO;
    
    inputText = [[NSMutableAttributedString alloc] initWithString:@""];
    
    self.inputToolbar.delegate = self;
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"post_comment_hint", @"post_comment_hint");
    self.inputToolbar.contentView.rightBarButtonItem.titleLabel.text = NSLocalizedString(@"regist", @"regist");
    self.inputToolbar.contentView.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    self.inputToolbar.contentView.textView.textContainer.maximumNumberOfLines = 0;
    self.inputToolbar.contentView.textView.fromSegue = @"POST_COMMENT";
    self.inputToolbar.contentView.textView.layer.borderWidth = 0.5f;
    self.inputToolbar.contentView.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inputToolbar.contentView.textView.font = [UIFont systemFontOfSize:13];
    
    self.fileDictionary = [NSMutableDictionary dictionary];
    self.imageUrlDictionary = [NSMutableDictionary dictionary];
    self.contentArray = [NSMutableArray array];
    
    self.commentArray = [NSMutableArray array];
    commDataArr = [NSMutableArray array];
    self.commFileArr = [NSMutableArray array];
    self.commFilePathArr = [NSMutableArray array];
    self.commFileThumbPathArr = [NSMutableArray array];
    
    cellHeight=0;
    cellDict = [NSMutableDictionary dictionary];
    
    prevLoc = 0;
    prevLen = 0;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    self.tableView.prefetchDataSource = self;
    
    self.isEdit = @"";
    pSize = 50;
    mediaType = @"";
    commUploadCnt = 0;
    commFileNameCnt = 0;
    prevComment = NO;
    prevCommentNo = @"";
    newRefNo = @"";
    cachingCnt = 0;
    commCachingCnt = 0;
    
    dataCnt = 0;
    commDataCnt = 0;
    
    @try {
        myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
        if([self.fromSegue isEqualToString:@"NOTI_POST_DETAIL"]){
            NSArray *dataSet = [self.notiPostDic objectForKey:@"DATASET"];
            NSString *postNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_NO"];
            NSString *snsName = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"];
            self._postNo = postNo;
            
            self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:[NSString urlDecodeString:snsName]];
            self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClick)];
            
            self.inputToolbar.contentView.textView.autocorrectionType = UITextAutocorrectionTypeNo;
            self.fromSegue = nil;
            
        } else if([self.fromSegue isEqualToString:@"PROFILE_POST_DETAIL"]||[self.fromSegue isEqualToString:@"PROFILE_COMM_DETAIL"]||[self.fromSegue isEqualToString:@"PROFILE_FILE_DETAIL"]){
            self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:[NSString urlDecodeString:self._snsName]];
            
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClick)];
            
            self.inputToolbar.contentView.textView.autocorrectionType = UITextAutocorrectionTypeNo;
            self.fromSegue = nil;
            
        } else {
            self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:[NSString urlDecodeString:self._snsName]];
            self.inputToolbar.contentView.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        
        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&postNo=%@&readStatus=%@&pSize=%d", myUserNo, self._postNo, self._isRead, pSize];
        [self callWebService:@"getPostDetail" WithParameter:paramString];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SelectMedia:) name:@"noti_SelectMedia" object:nil];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    @try{
        NSArray *subViews = [self.navigationController.navigationBar subviews];
        for (UIView *subview in subViews) {
            NSString *viewName = [NSString stringWithFormat:@"%@",[subview class]];
            if ([viewName isEqualToString:@"UITextField"]) {
                [subview removeFromSuperview];
            }
        }
        [self.tabBarController.tabBar setHidden:YES];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_SelectMedia" object:nil];
}

-(void)closeButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)tapOnTable:(UITapGestureRecognizer*)tap{
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return [super canPerformAction:action withSender:sender];
}
- (BOOL)canBecomeFirstResponder {
    return NO;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JSQMessagesInputToolbarDelegate
- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender{
    @try{
        _mediaButton = sender;
        _mediaButton.contentMode = UIViewContentModeScaleAspectFit;
        _mediaButton.imageEdgeInsets = UIEdgeInsetsMake(13,13,13,13);
        
        if(!_isFlag){
            UIImage *accessoryImage = [UIImage imageNamed:@"btn_close.png"];
            UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
            [_mediaButton setImage:normalImage forState:UIControlStateNormal];
            
            if (!_attachView) {
                self.attachView = [[AttachViewController alloc] init];
            }
            
            self.inputToolbar.contentView.textView.inputView = self.attachView.view;
            [self.inputToolbar.contentView.textView reloadInputViews];
            
            _isFlag = true;
            
        } else{
            UIImage *accessoryImage = [UIImage imageNamed:@"btn_add.png"];
            UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
            [_mediaButton setImage:normalImage forState:UIControlStateNormal];
            
            _mediaButton.backgroundColor = [UIColor clearColor];
            
            self.inputToolbar.contentView.textView.inputView = nil;
            [self.inputToolbar.contentView.textView reloadInputViews];
            
            _isFlag = false;
        }
        [self.inputToolbar.contentView.textView becomeFirstResponder];
    
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender{
    [self.view endEditing:YES];
    sender.enabled = NO;
    [self setCommentMsg];
}
- (void)cameraButtonPressed:(id)sender{
    @try{
        mediaType = @"IMG";
        [self.inputToolbar.contentView.textView resignFirstResponder];
        
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
                            self.attachView.picker = [[UIImagePickerController alloc] init];
                            self.attachView.picker.delegate = self;
                            self.attachView.picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
                            self.attachView.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                            self.attachView.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
                            self.attachView.picker.videoMaximumDuration = 60.0f; //최대촬영시간설정
                            
                            [self.navigationController presentViewController:self.attachView.picker animated:YES completion:nil];
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
                        self.attachView.picker = [[UIImagePickerController alloc] init];
                        self.attachView.picker.delegate = self;
                        self.attachView.picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
                        self.attachView.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        self.attachView.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
                        self.attachView.picker.videoMaximumDuration = 60.0f; //최대촬영시간설정
                        
                        [self.navigationController presentViewController:self.attachView.picker animated:YES completion:nil];
                    }
                });
            }];
        }
        
        if(_isFlag){ //미디어버튼
            UIImage *accessoryImage = [UIImage imageNamed:@"btn_add.png"];
            UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
            [_mediaButton setImage:normalImage forState:UIControlStateNormal];
            
            _mediaButton.contentMode = UIViewContentModeScaleAspectFit;
            _mediaButton.backgroundColor = [UIColor clearColor];
            
            self.inputToolbar.contentView.textView.inputView = nil;
            
            _isFlag = false;
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)photoButtonPressed:(id)sender{
    @try{
        mediaType = @"IMG";
        
        [self.inputToolbar.contentView.textView resignFirstResponder];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
        if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                
                [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES) [self performSegueWithIdentifier:@"POST_DETAIL_PHLIB_MODAL" sender:@"PHOTO"];
                    });
                }];
                
            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(status==YES) [self performSegueWithIdentifier:@"POST_DETAIL_PHLIB_MODAL" sender:@"PHOTO"];
                });
            }];
        }
        
//        if([AccessAuthCheck photoAccessCheck]){
//            [self performSegueWithIdentifier:@"POST_DETAIL_PHLIB_MODAL" sender:@"PHOTO"];
//        }
        
        if(_isFlag){ //미디어버튼
            UIImage *accessoryImage = [UIImage imageNamed:@"btn_add.png"];
            UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
            [_mediaButton setImage:normalImage forState:UIControlStateNormal];
            
            _mediaButton.contentMode = UIViewContentModeScaleAspectFit;
            _mediaButton.backgroundColor = [UIColor clearColor];
            
            self.inputToolbar.contentView.textView.inputView = nil;
            
            _isFlag = false;
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)videoButtonPressed:(id)sender{
    @try{
        mediaType = @"VIDEO";
        
        [self.inputToolbar.contentView.textView resignFirstResponder];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
        if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                
                [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES) [self performSegueWithIdentifier:@"POST_DETAIL_PHLIB_MODAL" sender:@"VIDEO"];
                    });
                }];
                
            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(status==YES) [self performSegueWithIdentifier:@"POST_DETAIL_PHLIB_MODAL" sender:@"VIDEO"];
                });
            }];
        }
        
//        if([AccessAuthCheck photoAccessCheck]){
//            [self performSegueWithIdentifier:@"POST_DETAIL_PHLIB_MODAL" sender:@"VIDEO"];
//        }
        
        if(_isFlag){ //미디어버튼
            UIImage *accessoryImage = [UIImage imageNamed:@"btn_add.png"];
            UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
            [_mediaButton setImage:normalImage forState:UIControlStateNormal];
            
            _mediaButton.contentMode = UIViewContentModeScaleAspectFit;
            _mediaButton.backgroundColor = [UIColor clearColor];
            
            self.inputToolbar.contentView.textView.inputView = nil;
            //[self.inputToolbar.contentView.textView reloadInputViews];
            
            _isFlag = false;
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    @try {
        if (indexPath.section==0) {
            return 70;
        }else if (indexPath.section==1||indexPath.section==3) { //공백
            return 20;
        }else if (indexPath.section==2) {
            return UITableViewAutomaticDimension;
        }else if (indexPath.section==4) { //이전댓글
            return 50;
        }else if (indexPath.section==5) {
            return UITableViewAutomaticDimension;
        }else{
            return UITableViewAutomaticDimension;
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    @try {
        if (section==0) {
            return 1;
        }else if (section==1||section==3) {
            return 1;
        }else if (section==2) {
            return self.contentArray.count;
        }else if (section==4) {
            if(prevComment) return 1;
            else return 0;
        }else if (section==5) {
            if(self.commentArray.count>0) self.tableView.backgroundColor = [MFUtil myRGBfromHex:@"FAFAFA"];
            else self.tableView.backgroundColor = [MFUtil myRGBfromHex:@"FFFFFF"];
            return [self.commentArray count];
        }else{
            return 0;
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    @try {
        if (indexPath.section==0) {
            MFPostNameCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"MFPostNameCell"];
            if (userCell == nil) {
                NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"MFPostNameCell" owner:self options:nil];
                
                for (id currentObject in topLevelObject) {
                    if ([currentObject isKindOfClass:[MFPostNameCell class]]) {
                        userCell = (MFPostNameCell *) currentObject;
                        [userCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                }
            }
            if(self.postDetailInfo!=nil){
                [self setPostNameCell:userCell atIndexPath:indexPath];
            }
            return userCell;
            
        } else if(indexPath.section==1||indexPath.section==3){
            SectionLineTableCell *lineCell = [tableView dequeueReusableCellWithIdentifier:@"SectionLineTableCell"];
            if (lineCell == nil) {
                NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"SectionLineTableCell" owner:self options:nil];
                
                for (id currentObject in topLevelObject) {
                    if ([currentObject isKindOfClass:[SectionLineTableCell class]]) {
                        lineCell = (SectionLineTableCell *) currentObject;
                        [lineCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                }
            }
            return lineCell;
            
        } else if(indexPath.section==2){
            TextLabelTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"TextLabelTableViewCell"];
            ImageTableViewCell *imgCell = [tableView dequeueReusableCellWithIdentifier:@"ImageTableViewCell"];
            VideoTableViewCell *videoCell = [tableView dequeueReusableCellWithIdentifier:@"VideoTableViewCell"];
            FileTableViewCell *fileCell = [tableView dequeueReusableCellWithIdentifier:@"FileTableViewCell"];
            
            if(self.contentArray!=nil){
                @try{
                    NSString *type = [[self.contentArray objectAtIndex:indexPath.row] objectForKey:@"TYPE"];
                    if([type isEqualToString:@"TEXT"]){
                        if (textCell == nil) {
                            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"TextLabelTableViewCell" owner:self options:nil];
                            
                            for (id currentObject in topLevelObject) {
                                if ([currentObject isKindOfClass:[TextLabelTableViewCell class]]) {
                                    textCell = (TextLabelTableViewCell *) currentObject;
                                    [textCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                                }
                            }
                        }
                        [self setPostTextDataCell:textCell atIndexPath:indexPath];
                        return textCell;
                        
                    } else if([type isEqualToString:@"IMG"]){
                        if (imgCell == nil) {
                            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ImageTableViewCell" owner:self options:nil];
                            
                            for (id currentObject in topLevelObject) {
                                if ([currentObject isKindOfClass:[ImageTableViewCell class]]) {
                                    imgCell = (ImageTableViewCell *) currentObject;
                                    [imgCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                                }
                            }
                        }
                        [self setPostImageDataCell:imgCell atIndexPath:indexPath];
                        return imgCell;
                        
                    } else if([type isEqualToString:@"VIDEO"]){
                        if (videoCell == nil) {
                            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"VideoTableViewCell" owner:self options:nil];
                            
                            for (id currentObject in topLevelObject) {
                                if ([currentObject isKindOfClass:[VideoTableViewCell class]]) {
                                    videoCell = (VideoTableViewCell *) currentObject;
                                    [videoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                                }
                            }
                        }
                        [self setPostVideoDataCell:videoCell atIndexPath:indexPath];
                        return videoCell;
                        
                    } else if([type isEqualToString:@"FILE"]){
                        if (fileCell == nil) {
                            NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"FileTableViewCell" owner:self options:nil];
                            
                            for (id currentObject in topLevelObject) {
                                if ([currentObject isKindOfClass:[FileTableViewCell class]]) {
                                    fileCell = (FileTableViewCell *) currentObject;
                                    [fileCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                                }
                            }
                        }
                        [self setPostFileDataCell:fileCell atIndexPath:indexPath];
                        return fileCell;
                    }
                    
                } @catch (NSException *exception) {
                    NSLog(@"Exception : %@", exception);
                }
            }
            return nil;
        }
        //댓글-------------------------------------------------------------------------------------------------------------------------------------------------
        else if(indexPath.section==4){
            CommHeaderViewCell *commPrevCell = [tableView dequeueReusableCellWithIdentifier:@"CommHeaderViewCell"];
            if (commPrevCell == nil) {
                NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"CommHeaderViewCell" owner:self options:nil];
                
                for (id currentObject in topLevelObject) {
                    if ([currentObject isKindOfClass:[CommHeaderViewCell class]]) {
                        commPrevCell = (CommHeaderViewCell *) currentObject;
                        [commPrevCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                }
            }
            [self setCommHeaderCell:commPrevCell atIndexPath:indexPath];
            return commPrevCell;
            
        }else if(indexPath.section==5){
            commCell = [tableView dequeueReusableCellWithIdentifier:@"PostCommViewCell"];
            if (commCell == nil) {
                NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"PostCommViewCell" owner:self options:nil];
                
                for (id currentObject in topLevelObject) {
                    if ([currentObject isKindOfClass:[PostCommViewCell class]]) {
                        commCell = (PostCommViewCell *) currentObject;
                        [commCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                }
            }
            if(self.commentArray!=nil){
                [self setCommDataCell:commCell atIndexPath:indexPath];
            }
            return commCell;
            
        } else {
            return nil;
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)setPostNameCell:(MFPostNameCell *)userCell atIndexPath:(NSIndexPath *)indexPath {
    @try {
        UIImage *userImg = [[UIImage alloc] init];
        NSString *postDate = [NSString urlDecodeString:[self.postDetailInfo objectForKey:@"POST_DATE"]];
        NSString *userNo = [self.postDetailInfo objectForKey:@"CUSER_NO"];
        NSLog(@"postDetailInfo : %@", self.postDetailInfo);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *date = [formatter dateFromString:postDate];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:NSLocalizedString(@"date13", @"date13")];
        NSString *postDateString = [dateFormat stringFromDate:date];
        
        postDateString = [postDateString stringByAppendingString:[NSString stringWithFormat:@" ･ %@ %@ %@ %@", self._readCnt, NSLocalizedString(@"post_read", @"post_read"), self._commCnt, NSLocalizedString(@"comment", @"comment")]];
        
        NSString *profileImg = [NSString urlDecodeString:[self.postDetailInfo objectForKey:@"STATUS_IMG"]];
        NSString *userType = [self.postDetailInfo objectForKey:@"SNS_USER_TYPE"];
        if([userType isEqualToString:@"9"]){
            userImg = [UIImage imageNamed:@"profile_default.png"];
            userCell.userTypeLabel.hidden = NO;
            userCell.userTypeLabel.text = NSLocalizedString(@"withdraw", @"withdraw");
            
        } else {
            if(![profileImg isEqualToString:@""]){
                userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
            } else {
                userImg = [UIImage imageNamed:@"profile_default.png"];
            }
            
            userCell.userTypeLabel.hidden = YES;
        }
        
        [userCell.profileImageButton setImage:userImg forState:UIControlStateNormal];
        userCell.profileImageButton.tag = -1;
        [userCell.profileImageButton addTarget:self action:@selector(touchedProfileButton:) forControlEvents:UIControlEventTouchUpInside];
        [userCell.settingButton setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_more.png"] scaledToMaxWidth:24] forState:UIControlStateNormal];
        [userCell.settingButton addTarget:self action:@selector(touchedSettingButton:) forControlEvents:UIControlEventTouchUpInside];
        userCell.nameLabel.text = [NSString urlDecodeString:[self.postDetailInfo objectForKey:@"CUSER_NM"]];
        
        UITapGestureRecognizer *writerNameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writerNameTapDetected:)];
        [userCell.nameLabel setUserInteractionEnabled:YES];
        [userCell.nameLabel addGestureRecognizer:writerNameTap];
        
        userCell.dateLabel.text = postDateString;
        
        userCell.selectionStyle = UITableViewCellSelectionStyleNone;
        userCell.selected = NO;
        userCell.backgroundView.backgroundColor = [UIColor blackColor];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
-(void)setPostTextDataCell:(TextLabelTableViewCell *)textCell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        textCell.txtLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink|NSTextCheckingTypeAddress|NSTextCheckingTypePhoneNumber;
        textCell.txtLabel.userInteractionEnabled = YES;
        textCell.txtLabel.tttdelegate = self;
        
        NSString *value = [[self.contentArray objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
        value = [value stringByReplacingOccurrencesOfString:@"%5Cn" withString:@"%0A"];
        [textCell.txtLabel setText:[NSString urlDecodeString:value]];
        
        UILongPressGestureRecognizer *txtLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(txtLongTapDetected:)];
        txtLongPress.minimumPressDuration = 0.5;
        txtLongPress.delegate = self;
        [textCell.txtLabel addGestureRecognizer:txtLongPress];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
-(void)setPostImageDataCell:(ImageTableViewCell *)imgCell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        imgCell.imgView.image = nil;
        imgCell.imgView.gestureRecognizers = nil;
        imgCell.imgView.tag = indexPath.row;
        
        NSDictionary *value = [[self.contentArray objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
        NSString *origin = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
        origin = [origin stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        
        
        UIImage *phImg = [UIImage imageNamed:@"cover1-1.png"];
        [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:origin]
                           placeholderImage:nil
                                    options:0
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            NSLog(@"img... 있겠지? : %@", image);
            
            if(image.size.width>self.tableView.frame.size.width-20){
                image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width-20];
                NSLog(@"이미지 새로고침");
            }
            imgCell.imgView.image = image;
            
//            이걸 왜 사용했는지 테스트해봐야됨
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTapDetected:)];
        singleTap.delegate = self;
        [imgCell.imgView setUserInteractionEnabled:YES];
        [imgCell.imgView addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer *imgLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imgLongTapDetected:)];
        imgLongPress.minimumPressDuration = 0.5;
        imgLongPress.delegate = self;
        [imgCell.imgView addGestureRecognizer:imgLongPress];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
-(void)setPostVideoDataCell:(VideoTableViewCell *)videoCell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        videoCell.compressView.hidden = YES;
        videoCell.videoView.image = nil;
        videoCell.videoTmpView.gestureRecognizers = nil;
        videoCell.videoTmpView.tag = indexPath.row;
        
        NSDictionary *value = [[self.contentArray objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
        
        //서버 리턴 썸네일 있을때
        NSString *thumb = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
        thumb = [thumb stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        
        [videoCell.videoView sd_setImageWithURL:[NSURL URLWithString:thumb]
                               placeholderImage:nil
                                        options:0
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(image.size.width>self.tableView.frame.size.width-20){
                image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width-20];
            }
            videoCell.videoView.image = image;
        }];
        
        videoCell.playButton.tag = indexPath.row;
        [videoCell.playButton addTarget:self action:@selector(postPlayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTapDetected:)];
        singleTap.delegate = self;
        [videoCell.videoTmpView setUserInteractionEnabled:YES];
        [videoCell.videoTmpView addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer *videoLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(videoLongTapDetected:)];
        videoLongPress.minimumPressDuration = 0.5;
        videoLongPress.delegate = self;
        [videoCell.videoTmpView addGestureRecognizer:videoLongPress];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
-(void)setPostFileDataCell:(FileTableViewCell *)fileCell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        fileCell.fileButton.gestureRecognizers = nil;
        fileCell.fileButton.tag = indexPath.row;
        
        NSString *value = [NSString urlDecodeString:[[self.contentArray objectAtIndex:indexPath.row] objectForKey:@"VALUE"]];
        
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
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fileTapDetected:)];
        [fileCell.fileButton setUserInteractionEnabled:YES];
        [fileCell.fileButton addGestureRecognizer:gesture];
        
        UILongPressGestureRecognizer *fileLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fileLongTapDetected:)];
        fileLongPress.minimumPressDuration = 0.5;
        fileLongPress.delegate = self;
        [fileCell.fileButton addGestureRecognizer:fileLongPress];
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)setCommHeaderCell:(CommHeaderViewCell *)commPrevCell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        commPrevCell.headerLabel.text = NSLocalizedString(@"comment2", @"comment2");
        
        UITapGestureRecognizer *prevTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commPrevTapDetected:)];
        [commPrevCell.headerLabel setUserInteractionEnabled:YES];
        [commPrevCell.headerLabel addGestureRecognizer:prevTapGesture];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)setCommDataCell:(PostCommViewCell *)commCell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        commCell.gestureRecognizers = nil;
        commCell.commImgView.image = nil;
        commCell.commTxtView.text = @"";
        commCell.fileBtnConstraint.constant = 0;
        UIImage *userImg = [[UIImage alloc] init];
        
        commCell.profileImageButton.tag = indexPath.row;
        commCell.profileImageButton.layer.cornerRadius = commCell.profileImageButton.frame.size.width/2;
        commCell.profileImageButton.clipsToBounds = YES;
        commCell.profileImageButton.contentMode = UIViewContentModeScaleAspectFit;
        commCell.profileImageButton.backgroundColor = [UIColor whiteColor];
        commCell.profileImageButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        commCell.profileImageButton.layer.borderWidth = 0.3;
        
        [commCell.profileImageButton addTarget:self action:@selector(touchedProfileButton:) forControlEvents:UIControlEventTouchUpInside];
        NSDictionary *commentDic =[self.commentArray objectAtIndex:indexPath.row];
        
        NSString *userNo = [commentDic objectForKey:@"CUSER_NO"];
        NSString *profileImg = [NSString urlDecodeString:[commentDic objectForKey:@"STATUS_IMG"]];
        NSString *userType = [commentDic objectForKey:@"SNS_USER_TYPE"];
        if([userType isEqualToString:@"9"]){
            userImg = [UIImage imageNamed:@"profile_default.png"];
            commCell.userTypeLabel.hidden = NO;
            commCell.userTypeLabel.text = NSLocalizedString(@"withdraw", @"withdraw");
            
        } else {
            if(![profileImg isEqualToString:@""]){
                userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(90, 90) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
            } else {
                userImg = [UIImage imageNamed:@"profile_default.png"];
            }
            commCell.userTypeLabel.hidden = YES;
        }
        [commCell.profileImageButton setImage:userImg forState:UIControlStateNormal];
        
        NSString *postDate = [NSString urlDecodeString:[commentDic objectForKey:@"COMMENT_DATE"]];
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = NSLocalizedString(@"date9", @"date9");
        NSString *tmp = [postDate substringToIndex:postDate.length-3];
        NSDate *regiDate = [formatter dateFromString:tmp];
        
        NSCalendar *sysCalendar = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSCalendarUnitDay;
        NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:regiDate toDate:currentDate options:0];//날짜 비교해서 차이값 추출
        NSInteger date = dateComp.day;
        
        NSString *postDateString = [[NSString alloc]init];
        if(date > 0){
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
            formatter2.dateFormat = NSLocalizedString(@"date12", @"date12");
            postDateString = [formatter2 stringFromDate:regiDate];
            
        } else{
            postDateString = [MFUtil getTimeIntervalFromDate:regiDate ToDate:currentDate];
        }
        
        commCell.nameLabel.tag = indexPath.row;
        commCell.nameLabel.text = [NSString urlDecodeString:[commentDic objectForKey:@"CUSER_NM"]];
        
        //댓글태그기능
        UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCommentNameForTag:)];
        [commCell.nameLabel setUserInteractionEnabled:YES];
        [commCell.nameLabel addGestureRecognizer:nameTap];
        commCell.dateLabel.text = postDateString;
        
        NSString *comment = [commentDic objectForKey:@"CONTENT"];
        
        NSError *jsonError;
        NSData *commData = [[NSString urlDecodeString:comment] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
        //NSLog(@"jsonArr : %@", jsonArr);
        
        if(jsonArr==nil){
            //댓글 형식 변경 전 데이터
            commCell.commTxtView.hidden = NO;
            commCell.commImgView.hidden = YES;
            commCell.playButton.hidden = YES;
            commCell.commFileBtn.hidden = YES;
            commCell.fileBtnConstraint.constant = 0;
            
            comment = [comment stringByReplacingOccurrencesOfString:@"%5Cn" withString:@"%0A"];
            commCell.commTxtView.text = [NSString urlDecodeString:comment];
            
        } else {
            NSString *commType = [[resultCommArr objectAtIndex:indexPath.row] objectForKey:@"TYPE"];
            NSString *commValue;
            
            if([commType isEqualToString:@"TEXT"]){
                commCell.compressView.hidden = YES;
                
                commCell.commTxtView.hidden = NO;
                commCell.commImgView.hidden = YES;
                commCell.playButton.hidden = YES;
                commCell.commFileBtn.hidden = YES;
                commCell.fileBtnConstraint.constant = 0;
                
                commCell.commTxtView.scrollEnabled = NO;
                commCell.commTxtView.editable = NO;
                commCell.commTxtView.selectable = NO;
                commCell.commTxtView.textContainer.lineFragmentPadding = 0;
                commCell.commTxtView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
                commCell.commTxtView.delegate = self;
                
                commCell.commTxtConstraint.active = NO;
                
                NSMutableAttributedString *attrStr = [[resultCommArr objectAtIndex:indexPath.row] objectForKey:@"TEXT"];
                
                //commCell.commTxtView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
                commCell.commTxtView.linkTextAttributes = @{NSForegroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]};
                commCell.commTxtView.attributedText = attrStr;
                
            } else if([commType isEqualToString:@"IMG"]){
                commCell.compressView.hidden = YES;
                
                commValue = [[resultCommArr objectAtIndex:indexPath.row] objectForKey:@"FILE"];
                commValue = [commValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                
                commCell.commTxtConstraint.active = YES;
                commCell.commTxtView.hidden = NO;
                commCell.commImgView.hidden = NO;
                commCell.playButton.hidden = YES;
                commCell.commFileBtn.hidden = YES;
                commCell.fileBtnConstraint.constant = 0;
                
                [commCell.commImgView sd_setImageWithURL:[NSURL URLWithString:commValue]
                                        placeholderImage:nil
                                                 options:0
                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if(image.size.width>150){
                        image = [MFUtil getScaledImage:image scaledToMaxWidth:150];
                    }
                    commCell.commImgView.image = image;
                }];
                
                commCell.commMediaView.tag = indexPath.row;
                UITapGestureRecognizer *imgGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commImgTapDetected:)];
                [commCell.commMediaView setUserInteractionEnabled:YES];
                [commCell.commMediaView addGestureRecognizer:imgGesture];
                
            } else if([commType isEqualToString:@"VIDEO"]){
                commValue = [[resultCommArr objectAtIndex:indexPath.row] objectForKey:@"FILE"];
                commValue = [commValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                
                commCell.compressView.hidden = YES;
                
                commCell.commTxtConstraint.active = YES;
                commCell.commTxtView.hidden = YES;
                commCell.commImgView.hidden = NO;
                commCell.playButton.hidden = NO;
                commCell.commFileBtn.hidden = YES;
                commCell.fileBtnConstraint.constant = 0;
                
                //서버 리턴 썸네일 있을때
                NSString *thumbValue = [[resultCommArr objectAtIndex:indexPath.row] objectForKey:@"THUMB"];
                [commCell.commImgView sd_setImageWithURL:[NSURL URLWithString:thumbValue]
                                        placeholderImage:nil
                                                 options:0
                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if(image.size.width>150){
                        image = [MFUtil getScaledImage:image scaledToMaxWidth:150];
                    }
                    commCell.commImgView.image = image;
                }];
                
                commCell.playButton.tag = indexPath.row;
                [commCell.playButton addTarget:self action:@selector(commPlayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                commCell.commMediaView.tag = indexPath.row;
                UITapGestureRecognizer *imgGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commImgTapDetected:)];
                [commCell.commMediaView setUserInteractionEnabled:YES];
                [commCell.commMediaView addGestureRecognizer:imgGesture];
                
            } else if([commType isEqualToString:@"FILE"]){
                commCell.compressView.hidden = YES;
                
                commValue = [[resultCommArr objectAtIndex:indexPath.row] objectForKey:@"FILE"];
                
                commCell.commTxtConstraint.active = YES;
                commCell.commTxtView.hidden = YES;
                commCell.commImgView.hidden = YES;
                commCell.playButton.hidden = YES;
                commCell.commFileBtn.hidden = NO;
                commCell.fileBtnConstraint.constant = 45;
                commCell.commFileBtn.tag = indexPath.row;
                
                NSString *fileName = @"";
                @try{
                    fileName = [commValue lastPathComponent];
                    
                } @catch (NSException *exception) {
                    fileName = commValue;
                    NSLog(@"Exception : %@", exception);
                }
                [commCell.commFileBtn setTitle:fileName forState:UIControlStateNormal];
                
                NSRange range = [commValue rangeOfString:@"." options:NSBackwardsSearch];
                NSString *fileExt = [[commValue substringFromIndex:range.location+1] lowercaseString];
                
                if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_img.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_movie.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_music.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"psd"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_psd.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"ai"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_ai.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_word.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_ppt.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_excel.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"pdf"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_pdf.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"txt"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_txt.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"hwp"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_hwp.png"] forState:UIControlStateNormal];
                    
                } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_zip.png"] forState:UIControlStateNormal];
                    
                } else {
                    [commCell.commFileBtn setImage:[UIImage imageNamed:@"file_document.png"] forState:UIControlStateNormal];
                }
                
                commCell.commFileBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [commCell.commFileBtn setImageEdgeInsets:UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0)];
                [commCell.commFileBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -5.0, 0.0, 0.0)];
                
                [commCell.commFileBtn addTarget:self action:@selector(touchedCommFileButton:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(commentTapDetected:)];
        longPress.minimumPressDuration = 0.5;
        longPress.delegate = self;
        [commCell addGestureRecognizer:longPress];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

-(void)videoCompessToPercent:(float)progress{
    @try{
        dispatch_async(dispatch_get_main_queue(), ^{
            commCell.compressView.hidden = YES;
            commCell.playButton.hidden = YES;
//            [commCell.compressView setPrimaryColor:[MFUtil myRGBfromHex:@"0093D5"]];
            [commCell.compressView setPrimaryColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
            [commCell.compressView setProgress:progress animated: YES];
       });

    } @catch (NSException *exception) {
       NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - PREFETCH DATA
-(void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{

    //section 2 : post, 5 : comment
    
    @try{
        for(int i=0; i<indexPaths.count; i++){
            NSIndexPath *idx = [indexPaths objectAtIndex:i];
            NSInteger section = idx.section;
            NSInteger row = idx.row;
            
            if(section==2){
                NSString *type = [[self.contentArray objectAtIndex:row] objectForKey:@"TYPE"];
                if([type isEqualToString:@"TEXT"]){
                    
                } else if([type isEqualToString:@"IMG"]){
                    NSDictionary *valueDic = [[self.contentArray objectAtIndex:row] objectForKey:@"VALUE"];
                    NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                    originImg = [originImg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [self cachingUrlImage:originImg indexPath:row section:section];
                    });
                    
                } else if([type isEqualToString:@"VIDEO"]){
                    NSDictionary *valueDic = [[self.contentArray objectAtIndex:row] objectForKey:@"VALUE"];
                    NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                    thumbImg = [thumbImg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [self cachingUrlImage:thumbImg indexPath:row section:section];
                    });
                }
                
            } else if(section==5){
                NSString *comment = [[self.commentArray objectAtIndex:row] objectForKey:@"CONTENT"];
                NSError *jsonError;
                NSData *commData = [[NSString urlDecodeString:comment] dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
                
                NSString *type = [[jsonArr objectAtIndex:0] objectForKey:@"TYPE"];
                if([type isEqualToString:@"TEXT"]){
                    
                } else if ([type isEqualToString:@"IMG"]) {
                    NSString *value = [[jsonArr objectAtIndex:0] objectForKey:@"FILE"];
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [self cachingUrlImage:value indexPath:row section:section];
                    });
                    
                    
                } else if([type isEqualToString:@"VIDEO"]){
                    NSString *value = [[jsonArr objectAtIndex:0] objectForKey:@"THUMB"];
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [self cachingUrlImage:value indexPath:row section:section];
                    });
                }
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)cachingUrlImage:(NSString *)urlString indexPath:(NSInteger)index section:(NSInteger)section{
    @try{
        [imgCache queryDiskCacheForKey:urlString done:^(UIImage *image, SDImageCacheType cacheType) {
            if (image) {
                
            }else{
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //[SVProgressHUD show];
                    
                    SDWebImageDownloader *downLoader = [SDWebImageDownloader sharedDownloader];
                    [downLoader downloadImageWithURL:[NSURL URLWithString:urlString] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        
                    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        if (image && finished) {
//                            NSLog(@"이미지 다운 완료 (%ld)", index);
                            [[SDImageCache sharedImageCache]storeImage:image recalculateFromImage:NO imageData:data forKey:urlString toDisk:YES];
                            if(index<3){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:section];
                                    [CATransaction begin];
                                    [CATransaction setCompletionBlock:^{
                                        //[SVProgressHUD dismiss];
                                    }];
                                    [self.tableView beginUpdates];
                                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                    [self.tableView endUpdates];
                                    
                                    [CATransaction commit];
                                });
                            }
                        }
                    }];
                });
            }
        }];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - SET COMMENT DATA
-(void)setCommentData:(NSArray *)mediaArr :(NSString *)mediaType :(BOOL)isAlbum{
    @try{
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        
        commDataArr = [NSMutableArray array];
        self.commFileArr = [NSMutableArray array];
        self.commFilePathArr = [NSMutableArray array];
        commUploadCnt = 0;
        commFileNameCnt = 0;
        
        NSMutableArray *targetArr = [NSMutableArray array];
        
        if([mediaType isEqualToString:@"TEXT"]){
            [SVProgressHUD show];
            
            commDataArr = [[NSMutableArray alloc] initWithArray:mediaArr];
            
            NSString *postNo = [self.postDetailInfo objectForKey:@"POST_NO"];
            NSString *postUsrNo = [self.postDetailInfo objectForKey:@"CUSER_NO"];
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commDataArr options:0 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//            NSLog(@"jsonString !! : %@", jsonString);
            NSLog(@"SAVEPOSTCOMM myUserNo : %@", myUserNo);
            
            NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@&isNewComment=true&postUsrNo=%@", myUserNo, snsNo, postNo, jsonString, postUsrNo];
            [self callWebService:@"savePostComment" WithParameter:paramString];
            
        } else if([mediaType isEqualToString:@"IMG"]){
            [SVProgressHUD show];
            
            if(isAlbum){
                NSArray *imgList = [[mediaArr objectAtIndex:0] objectForKey:@"IMG_LIST"];
                
                for(int i=0; i<imgList.count; i++){
                    UIImage *image = [imgList objectAtIndex:i];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:mediaType forKey:@"TYPE"];
                    [dict setObject:targetArr forKey:@"TARGET"];
                    [dict setObject:image forKey:@"FILE"];
                    [dict setObject:@"" forKey:@"THUMB"];
                    
                    [commDataArr addObject:dict];
                    
                    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                    [dict2 setObject:@"IMG" forKey:@"TYPE"];
                    [dict2 setObject:image forKey:@"VALUE"];
                    [self.commFileArr addObject:dict2];
                    
                    [self convertDataSet:self.commFileArr];
                }
            } else {
                UIImage *image = [mediaArr objectAtIndex:0];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:mediaType forKey:@"TYPE"];
                [dict setObject:targetArr forKey:@"TARGET"];
                [dict setObject:image forKey:@"FILE"];
                [dict setObject:@"" forKey:@"THUMB"];
                
                [commDataArr addObject:dict];
                
                NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                [dict2 setObject:@"IMG" forKey:@"TYPE"];
                [dict2 setObject:image forKey:@"VALUE"];
                [self.commFileArr addObject:dict2];
                
                [self convertDataSet:self.commFileArr];
            }
            
        } else if([mediaType isEqualToString:@"VIDEO"]){
            [SVProgressHUD show];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:mediaType forKey:@"TYPE"];
            [dict setObject:targetArr forKey:@"TARGET"];
            [dict setObject:@"" forKey:@"FILE"];
            [dict setObject:@"" forKey:@"THUMB"];
            [commDataArr addObject:dict];
            
            if(isAlbum){
                NSArray *assetList = [[mediaArr objectAtIndex:0] objectForKey:@"ASSET_LIST"];
                PHAsset *asset = [assetList objectAtIndex:0];
                
                NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                [dict2 setObject:@"VIDEO" forKey:@"TYPE"];
                [dict2 setObject:asset forKey:@"VIDEO_VALUE"];
                [self.commFileArr addObject:dict2];
                
                [self convertDataSet:self.commFileArr];
                
            } else {
                NSString *videoPath = [mediaArr objectAtIndex:0];
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath] options:nil];
                
                NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                [dict2 setObject:@"VIDEO" forKey:@"TYPE"];
                [dict2 setObject:asset forKey:@"RECORD_VALUE"];
                [self.commFileArr addObject:dict2];
                
                [self convertDataSet:self.commFileArr];
            }
            
        } else if([mediaType isEqualToString:@"FILE"]){
            [SVProgressHUD show];
            
            NSData *data = [[mediaArr objectAtIndex:0] objectForKey:@"FILE_DATA"];
            NSString *value = [[mediaArr objectAtIndex:0] objectForKey:@"VALUE"];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:mediaType forKey:@"TYPE"];
            [dict setObject:targetArr forKey:@"TARGET"];
            [dict setObject:data forKey:@"FILE"];
            
            [commDataArr addObject:dict];
            
            NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
            [dict2 setObject:@"FILE" forKey:@"TYPE"];
            [dict2 setObject:data forKey:@"FILE_DATA"];
            [dict2 setObject:value forKey:@"VALUE"];
            [self.commFileArr addObject:dict2];
            
            [self convertDataSet:self.commFileArr];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)convertDataSet:(NSMutableArray *)array{
    @try{
        setCount = 0;
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
        
        NSUInteger count = array.count;
        
        for(int i=0; i<(int)count; i++){
            NSMutableDictionary *obj = [NSMutableDictionary dictionary];
            
            NSString *type = [[array objectAtIndex:i] objectForKey:@"TYPE"];
            if([type isEqualToString:@"IMG"]){
//                NSLog(@"이건 이미지 i=%d", i);
                
                [obj setObject:@"IMG" forKey:@"TYPE"];
                [obj setObject:[[array objectAtIndex:i] objectForKey:@"VALUE"] forKey:@"FILE"];
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
                         AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
//                          MFFileCompress *fc = [[MFFileCompress alloc] init];
                          [MFFileCompress compressVideoWithInputVideoUrl:URL asset:avAsset num:i mode:nil fileName:nil paramNo:nil completion:^(NSData *data) {
                              NSLog(@"변환된 데이터(Alb) : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);

                              AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                              imageGenerator.appliesPreferredTrackTransform = YES;
                              CMTime time = CMTimeMake(1, 1);
                              CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                              UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                              CGImageRelease(imageRef);

                              [obj setObject:@"VIDEO" forKey:@"TYPE"];
                              [obj setObject:data forKey:@"FILE"];

                              if(thumbnail!=nil) [obj setObject:thumbnail forKey:@"THUMB"];
                              [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];

                              setCount++;
                              if(setCount==count) [self dataConvertFinished:tmpDict];
                          }];
                      });
                    }];
                    
                } else {
//                    NSLog(@"이건 촬영한 비디오 i=%d", i);
                    //촬영한 비디오
                    AVURLAsset *avAsset = [[array objectAtIndex:i] objectForKey:@"RECORD_VALUE"];
                    
//                    MFFileCompress *fc = [[MFFileCompress alloc] init];
                    [MFFileCompress compressVideoWithInputVideoUrl:avAsset.URL asset:avAsset num:i mode:nil fileName:nil paramNo:nil completion:^(NSData *data) {
                        NSLog(@"변환된 데이터(Rec) : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);

                        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:avAsset];
                        imageGenerator.appliesPreferredTrackTransform = YES;
                        CMTime time = CMTimeMake(1, 1);
                        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                        CGImageRelease(imageRef);

                        [obj setObject:@"VIDEO" forKey:@"TYPE"];
                        [obj setObject:data forKey:@"FILE"];
                        if(thumbnail!=nil) [obj setObject:thumbnail forKey:@"THUMB"];
                        [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
                        
                        setCount++;
                        if(setCount==count) [self dataConvertFinished:tmpDict];
                    }];
                }
            } else if([type isEqualToString:@"FILE"]){
                [obj setObject:@"FILE" forKey:@"TYPE"];
                [obj setObject:[[array objectAtIndex:i] objectForKey:@"VALUE"] forKey:@"FILE"];
                [obj setObject:[[array objectAtIndex:i] objectForKey:@"FILE_DATA"] forKey:@"FILE_DATA"];
                [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
                
                setCount++;
                if(setCount==count) [self dataConvertFinished:tmpDict];
                
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)addThumbnailImage{
    
}

-(void)dataConvertFinished:(NSMutableDictionary *)dict{
    NSLog(@"dict : %@", dict);
    
    resultArr = [NSMutableArray array];
    
    for(int i=0; i<dict.count; i++){
        NSMutableDictionary *reDict = [NSMutableDictionary dictionary];
        
        NSDictionary *dataDict = [dict objectForKey:[NSString stringWithFormat:@"%d",i]];
        
        NSString *type = [dataDict objectForKey:@"TYPE"];
        if([type isEqualToString:@"IMG"]){
            [reDict setObject:@"IMG" forKey:@"TYPE"];
            [reDict setObject:[dataDict objectForKey:@"FILE"] forKey:@"FILE"]; //UIImage
            [resultArr addObject:reDict];
            
        } else if([type isEqualToString:@"VIDEO"]){
            NSMutableDictionary *thumbDict = [NSMutableDictionary dictionary];
            if([dataDict objectForKey:@"THUMB"]!=nil){
                [thumbDict setObject:@"VIDEO_THUMB" forKey:@"TYPE"];
                [thumbDict setObject:[dataDict objectForKey:@"THUMB"] forKey:@"VALUE"]; //UIImage
                [resultArr addObject:thumbDict];
            }
            
            [reDict setObject:@"VIDEO" forKey:@"TYPE"];
            [reDict setObject:[dataDict objectForKey:@"FILE"] forKey:@"FILE"]; //NSData
            
            [resultArr addObject:reDict];
            
        } else if([type isEqualToString:@"FILE"]){
            [reDict setObject:@"FILE" forKey:@"TYPE"];
            [reDict setObject:[dataDict objectForKey:@"FILE_DATA"] forKey:@"FILE_DATA"]; //NSData
            [reDict setObject:[dataDict objectForKey:@"FILE"] forKey:@"FILE"];
            [resultArr addObject:reDict];
        }
    }
    
    [self saveMediaFiles];
}
-(void)dataConvertFailed{
    [SVProgressHUD dismiss];

    @try{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"동영상 변환 실패" message:@"동영상 변환에 실패하였습니다.\n다시 시도하여 주십시오." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             commDataArr = [NSMutableArray array];
                                                             self.commFileArr = [NSMutableArray array];
                                                             self.commFilePathArr = [NSMutableArray array];
                                                             self.commFileThumbPathArr = [NSMutableArray array];
                                                             resultArr = [NSMutableArray array];
                                                             commUploadCnt = 0;
                                                             commFileNameCnt = 0;
                                                             
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
-(void)videoSizeCheck{
    commDataArr = [NSMutableArray array];
    self.commFileArr = [NSMutableArray array];
    self.commFilePathArr = [NSMutableArray array];
    self.commFileThumbPathArr = [NSMutableArray array];

    resultArr = [NSMutableArray array];
    commUploadCnt = 0;
    commFileNameCnt = 0;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"upload_fail_title", @"upload_fail_title") message:NSLocalizedString(@"upload_fail_size_limit", @"upload_fail_size_limit") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)saveMediaFiles{
    NSString *type = [[resultArr objectAtIndex:0] objectForKey:@"TYPE"];
    
    if([type isEqualToString:@"IMG"]){
        UIImage *value = [[resultArr objectAtIndex:0] objectForKey:@"FILE"];
        value = [MFUtil getResizeImageRatio:value];
        
        NSData *data = UIImageJPEGRepresentation(value, 0.7);
        NSLog(@"IMG File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
        [self saveMediaFiles:data mediaType:type];
        
    } else if([type isEqualToString:@"VIDEO"]){
        NSData *data = [[resultArr objectAtIndex:0] objectForKey:@"FILE"];
//        NSLog(@"VIDEO File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
        if((float)data.length/1024.0f/1024.0f>20){
            [self videoSizeCheck];
        } else {
            [self saveMediaFiles:data mediaType:type];
        }
        
    } else if([type isEqualToString:@"VIDEO_THUMB"]){
        UIImage *value = [[resultArr objectAtIndex:0] objectForKey:@"VALUE"];
        value = [MFUtil getResizeImageRatio:value];
        NSData *data = UIImageJPEGRepresentation(value, 0.7);
//        NSLog(@"VIDEO_THUMB File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
        [self saveMediaFiles:data mediaType:type];
    
    } else if([type isEqualToString:@"FILE"]){
        NSData *data = [[resultArr objectAtIndex:0] objectForKey:@"FILE_DATA"];
        fileTypeName = [[[resultArr objectAtIndex:0] objectForKey:@"FILE"] lastPathComponent];
        [self saveMediaFiles:data mediaType:type];
    }
}
-(void)saveMediaFiles:(NSData *)data mediaType:(NSString *)type{
    @try{
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
        urlString = [urlString stringByAppendingPathComponent:@"saveAttachedFile"];
        
        NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
        [sendFileParam setObject:snsNo forKey:@"snsNo"];
        [sendFileParam setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
        [sendFileParam setObject:myUserNo forKey:@"usrNo"];
        [sendFileParam setObject:@"2" forKey:@"refTy"];
        [sendFileParam setObject:self._postNo forKey:@"refNo"];
        [sendFileParam setObject:@"" forKey:@"aditInfo"];
        [sendFileParam setObject:@"false" forKey:@"isShared"];
        [sendFileParam setObject:@"" forKey:@"srcFileUrl"];
        
        NSString *fileName;
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
        }
        else if([type isEqualToString:@"FILE"]){
            [sendFileParam setObject:@"false" forKey:@"isThumb"];
            fileName = fileTypeName;
        }
        
        [self sessionFileUpload:urlString :sendFileParam :data :fileName];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
-(NSString *)createFileName :(NSString *)filetype{
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
-(void)imageToUrlString{
    int changeCnt = 0;
    
    @try {
        NSLog(@"commDataArr !!! : %@", commDataArr);
        for(int i=0; i<commDataArr.count; i++){
            NSString *type = [[commDataArr objectAtIndex:i] objectForKey:@"TYPE"];
            
            if(![type isEqualToString:@"TEXT"]){
                NSString *imgPath = [self.commFilePathArr objectAtIndex:changeCnt];
                NSString *imgThumbPath = [self.commFileThumbPathArr objectAtIndex:changeCnt];
                if(changeCnt<=commFileNameCnt){
                    [[commDataArr objectAtIndex:i] setObject:imgPath forKey:@"FILE"];
                    [[commDataArr objectAtIndex:i] setObject:imgThumbPath forKey:@"THUMB"];
                }
                changeCnt++;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UIImagePickerController Delegate
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
            [self setCommentData:imageArray :mediaType :YES];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getImageNotification" object:nil];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}


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
        mediaType = @"VIDEO";
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];
        
        NSArray *assetArr = [[NSArray alloc] initWithObjects:asset, nil];
        NSArray *imgArr = [[NSArray alloc] initWithObjects:@"NONE", nil];
        
        NSMutableDictionary *assetDict = [NSMutableDictionary dictionary];
        [assetDict setObject:assetArr forKey:@"ASSET_LIST"];
        [assetDict setObject:imgArr forKey:@"IMG_LIST"];
        
        NSArray *videoArray = [[NSArray alloc] initWithObjects:videoPath, nil];
        
        [self setCommentData:videoArray :mediaType :NO];
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
   //file:///private/var/mobile/Containers/Data/Application/FB9EBCA8-8B2E-4B2D-BE68-D6E340C8A297/tmp/hhi.mobile.ios.sns-Inbox/IMG_0715.PNG
   
    mediaType = @"FILE";

    NSData *data = [NSData dataWithContentsOfURL:url];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"FILE" forKey:@"TYPE"];
    [dict setObject:[NSString urlDecodeString:url.absoluteString] forKey:@"VALUE"];
    [dict setObject:data forKey:@"FILE_DATA"];
    [dict setObject:[NSString urlDecodeString:[url.absoluteString lastPathComponent]] forKey:@"FILE_NM"];
    [dict setObject:@"false" forKey:@"IS_SHARE"];

    NSArray *fileArray = [[NSArray alloc] initWithObjects:dict, nil];
    [self setCommentData:fileArray :mediaType :NO];
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
                                                                [self setCommentData:imageArray :mediaType :NO];
                                                             }];
        }
        
    }
}


#pragma mark - CALL WEB SERVICE
-(void)callWebService:(NSString *)serviceName WithParameter:(NSString *)paramString{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

-(void)postImgCaching:(NSArray *)contents{
    NSUInteger count = contents.count;
    
    @try{
        idx=0;
        
        for(int i=0; i<(int)count; i++){
            NSString *type = [[contents objectAtIndex:i] objectForKey:@"TYPE"];
            if([type isEqualToString:@"TEXT"]){
                idx++;
                
            } else if([type isEqualToString:@"IMG"]){
                dataCnt++;
                NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                NSString *originValue = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                
                if(i<3){
//                    [self cachingUrlImage:originValue indexPath:i section:2];
                }

                [self.imageUrlDictionary setObject:originValue forKey:[NSString stringWithFormat:@"%d",idx++]];
                
            } else if([type isEqualToString:@"VIDEO"]) {
                dataCnt++;
                
                NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                NSString *originValue = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];

                if(i<3){
//                    [self cachingUrlImage:thumbImg indexPath:i section:2];
                }
                
                [self.imageUrlDictionary setObject:originValue forKey:[NSString stringWithFormat:@"%d",idx++]];
            
            } else if([type isEqualToString:@"FILE"]){
                NSString *value = [NSString urlDecodeString:[[contents objectAtIndex:i] objectForKey:@"VALUE"]];
                [self.fileDictionary setObject:value forKey:[NSString stringWithFormat:@"%d",idx++]];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)cellRefresh{
    cachingCnt=0;
    dataCnt=0;
    [self.tableView reloadData];
}
-(void)commCellRefresh{
    commCachingCnt=0;
    commDataCnt=0;
    [self.tableView reloadData];
}

#pragma mark - MFURLSession Delegate
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    appDelegate.errorExecCnt = 0;
    
    if (error!=nil) {
        NSLog(@"return error : %@",error);
        
    }else{
        @try {
            NSString *wsName = [[session.url absoluteString] lastPathComponent];
            if ([wsName isEqualToString:@"getPostDetail"]) {
                resultCommArr = [NSMutableArray array];
                
                cachingCnt = 0;
                commCachingCnt = 0;
                dataCnt = 0;
                commDataCnt = 0;
                
                NSDictionary *dic = session.returnDictionary;
                NSArray *array = [dic objectForKey:@"DATASET"];
                
                if(array.count>0){
                    self.postDetailInfo = [array objectAtIndex:0];
//                    NSLog(@"postDetailInfo : %@", self.postDetailInfo);
                    
                    snsNo = [self.postDetailInfo objectForKey:@"SNS_NO"];
                    self._readCnt = [self.postDetailInfo objectForKey:@"POST_READ_COUNT"];
                    self._isRead = [self.postDetailInfo objectForKey:@"IS_READ"];
                    
                    self.commentArray = [NSMutableArray arrayWithArray:[self.postDetailInfo objectForKey:@"COMMENTS"]];
                    self._commCnt = [NSString stringWithFormat:@"%d", (int)_commentArray.count];
                    commentCnt = (int)_commentArray.count;
                    if(commentCnt>0) prevCommentNo = [[self.commentArray objectAtIndex:0] objectForKey:@"COMMENT_NO"];
                    
                    //NSLog(@"commentCnt : %d, [self._commCnt integerValue] : %ld", commentCnt, (long)[self._commCnt integerValue]);
                    if(commentCnt<[self._commCnt integerValue]) prevComment = YES;
                    else prevComment = NO;
                    
                    self.contentArray = [self.postDetailInfo objectForKey:@"CONTENT"];
                    
                    NSArray *arr = [self.postDetailInfo objectForKey:@"CONTENT"];
                    [self postImgCaching:arr];
                    [self commentSetTableData:self.commentArray];
                    
                    if(isComment){
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            NSInteger row = [self.tableView numberOfRowsInSection:5];
                            if(row>0){
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:5];
                                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                            }
                            isComment = NO;
                        });
                    }
                    
                    [self.tableView reloadData];
//                    NSLog(@"리로드 완료. 새로 저장된 캐시 : %d", cachingCnt+commCachingCnt);
                    
//                    if(cachingCnt+commCachingCnt>0){
//                        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
//                        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
//                        [SVProgressHUD show];
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                            NSLog(@"캐시 새로 저장했으니 새로고침 한다.");
//                            [self.tableView reloadData];
//                            [SVProgressHUD dismiss];
//                        });
//                    } else {
//                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                            NSLog(@"캐시 새로 저장하진 않았지만 새로고침 한다.");
//                            [self.tableView reloadData];
//                        });
//                    }
                    
                    
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"post_deleted", @"post_deleted") message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_DeletePost" object:nil userInfo:nil];
                                                                         [self.navigationController popViewControllerAnimated:YES];
                                                                     }];
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            } else if([wsName isEqualToString:@"getPostComments"]){
                NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
                NSUInteger count = dataSets.count;
                
                if(count>0){
                    for(int i=(int)count-1; i>=0; i--){
                        NSString *comment = [[self.commentArray objectAtIndex:i] objectForKey:@"CONTENT"];
                        NSError *jsonError;
                        NSData *commData = [[NSString urlDecodeString:comment] dataUsingEncoding:NSUTF8StringEncoding];
                        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
                        
                        NSString *value = [[jsonArr objectAtIndex:0] objectForKey:@"VALUE"];
                        
                        NSString *type = [[jsonArr objectAtIndex:0] objectForKey:@"TYPE"];
                        if ([type isEqualToString:@"IMG"]) {
                            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:value]];
                            if(data) {
                                UIImage *image = [[UIImage alloc] initWithData:data];
                                image = [MFUtil getScaledImage:image scaledToMaxWidth:150];
                                [imgCache storeImage:image forKey:value toDisk:YES];
                            }
                        } else if([type isEqualToString:@"VIDEO"]){
                            AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:value]];
                            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                            imageGenerator.appliesPreferredTrackTransform = YES;
                            CMTime time = CMTimeMake(1, 1);
                            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                            CGImageRelease(imageRef);
                            
                            thumbnail = [MFUtil getScaledImage:thumbnail scaledToMaxWidth:150];
                            [imgCache storeImage:thumbnail forKey:value toDisk:YES];
                        }
                        [self.commentArray insertObject:[dataSets objectAtIndex:i] atIndex:0];
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count-1 inSection:5];
                        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                    }
                    prevCommentNo = [[self.commentArray objectAtIndex:0] objectForKey:@"COMMENT_NO"];
                    
//                    NSLog(@"self.commentArray.count : %lu, [self._commCnt integerValue] : %ld", self.commentArray.count, (long)[self._commCnt integerValue]);
                    if(self.commentArray.count<[self._commCnt integerValue]) prevComment = YES;
                    else prevComment = NO;
                } else {
                    prevComment = NO;
                }
                [self.tableView reloadData];
                
            } else if([wsName isEqualToString:@"savePostComment"]){
                isComment = YES;
                self.inputToolbar.contentView.textView.text = @"";
                
                commDataArr = [NSMutableArray array];
                self.commFileArr = [NSMutableArray array];
                self.commFilePathArr = [NSMutableArray array];
                self.commFileThumbPathArr = [NSMutableArray array];
                
                resultArr = [NSMutableArray array];
                commUploadCnt = 0;
                commFileNameCnt = 0;
                newRefNo = @"";
                
                NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&postNo=%@&snsNo=%@&readStatus=%@&pSize=%d", myUserNo, self._postNo, snsNo, self._isRead, pSize];
                [self callWebService:@"getPostDetail" WithParameter:paramString];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SavePost" object:nil userInfo:nil];
                
            } else if([wsName isEqualToString:@"saveBookmark"]){
                //                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"msg21", @"") message:@"성공" delegate:self cancelButtonTitle:NSLocalizedString(@"msg3", @"") otherButtonTitles:nil, nil];
                //                [alert show];
                
                
            } else if([wsName isEqualToString:@"deletePost"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_DeletePost"
                                                                    object:nil
                                                                  userInfo:@{@"POST_NO":self._postNo,
                                                                             @"INDEX_PATH":self.indexPath}];
                [self.navigationController popViewControllerAnimated:YES];
                
                
            } else if([wsName isEqualToString:@"deletePostComment"]){
                commentCnt--;
                //[self.tableView reloadData];
            }
            
        } @catch (NSException *exception) {
            [SVProgressHUD dismiss];
            NSLog(@"Exception : %@", exception);
        }
    }
}

-(void)commentSetTableData:(NSMutableArray *)array{
    NSUInteger count = array.count;
    
    @try{
        for(int i=0; i<(int)count; i++){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            NSString *comment = [[array objectAtIndex:i] objectForKey:@"CONTENT"];
            NSError *jsonError;
            NSData *commData = [[NSString urlDecodeString:comment] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
            
            NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc] initWithString:@""];
            
            for(int k=0; k<jsonArr.count; k++){
                NSString *commType = [[jsonArr objectAtIndex:k] objectForKey:@"TYPE"];
                NSArray *commTarget = [[jsonArr objectAtIndex:k] objectForKey:@"TARGET"];
                
                if([commType isEqualToString:@"TEXT"]){
                    NSString *commValue = [[jsonArr objectAtIndex:k] objectForKey:@"TEXT"];
                    NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                    
                    if(commTarget.count>0){
                        for(int j=0; j<commTarget.count; j++){
                            NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                            NSString *usrNo = [[commTarget objectAtIndex:j] objectForKey:@"USER_NO"];
                            
                            NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor], /*NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]],*/ NSLinkAttributeName:[NSString stringWithFormat:@"%@", usrNo]}];
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
                    commDataCnt++;
                    NSString *commValue = [[jsonArr objectAtIndex:k] objectForKey:@"VALUE"];
                    NSString *origin = [[jsonArr objectAtIndex:k] objectForKey:@"FILE"];
                
                    if(commValue!=nil&&![commValue isEqualToString:@""]) {
                        NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                        
                        if(commTarget.count>0){
                            for(int j=0; j<commTarget.count; j++){
                                NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                                NSString *usrNo = [[commTarget objectAtIndex:j] objectForKey:@"USER_NO"];
                                
                                NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor], /*NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]],*/ NSLinkAttributeName:[NSString stringWithFormat:@"%@", usrNo]}];
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
                    
                    if(i<3){
                        [self cachingUrlImage:origin indexPath:i section:5];
                    }
                    /*
                    if(![imgCache diskImageExistsWithKey:origin]){
                        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:origin]];
                        if(data) {
                            UIImage *image = [[UIImage alloc] initWithData:data];
                            image = [MFUtil getScaledImage:image scaledToMaxWidth:150];
                            [imgCache storeImage:image forKey:origin toDisk:YES];
                            commCachingCnt++;
                        }
                    }
                    
                    if(![imgCache diskImageExistsWithKey:origin]){
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            SDWebImageDownloader *downLoader = [SDWebImageDownloader sharedDownloader];
                            [downLoader downloadImageWithURL:[NSURL URLWithString:origin] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {

                            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                if (image && finished) {
                                    NSLog(@"이미지 다운 완료!");
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        UIImage *img = [MFUtil getScaledImage:image scaledToMaxWidth:150];
                                        [[SDImageCache sharedImageCache]storeImage:img recalculateFromImage:NO imageData:data forKey:origin toDisk:YES];

                                        //NSLog(@"이미지 인덱스 : %d", idx);

                                        commCachingCnt++;

                                        NSLog(@"11 commDataCnt : %d, commCachingCnt : %d", commDataCnt, commCachingCnt);

                                        if(commDataCnt==commCachingCnt){
                                            commCachingCnt=0;
                                            commDataCnt=0;
                                            [self commCellRefresh];
                                        }

//                                        imgH = img.size.height;
//                                        cellHeight = textH+imgH+fileH;
//                                        [cellDict setObject:[NSString stringWithFormat:@"%d", cellHeight] forKey:[NSString stringWithFormat:@"%d", i]];
//
//                                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:5];
//                                        [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                                    });
                                }
                            }];
                        });
                    }
                     */
                } else if([commType isEqualToString:@"VIDEO"]){
                    NSString *commValue = [[jsonArr objectAtIndex:k] objectForKey:@"VALUE"];
                    NSString *origin = [[jsonArr objectAtIndex:k] objectForKey:@"FILE"];
                    NSString *thumb = [[jsonArr objectAtIndex:k] objectForKey:@"THUMB"];
                    
                    if(commValue!=nil&&![commValue isEqualToString:@""]) {
                        NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                        
                        if(commTarget.count>0){
                            for(int j=0; j<commTarget.count; j++){
                                NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                                NSString *usrNo = [[commTarget objectAtIndex:j] objectForKey:@"USER_NO"];
                                
                                NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor], /*NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]],*/ NSLinkAttributeName:[NSString stringWithFormat:@"%@", usrNo]}];
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
                    
                    if(i<3){
                        [self cachingUrlImage:thumb indexPath:i section:5];
                    }
                    /*
                    if(![imgCache diskImageExistsWithKey:thumb]){
                        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumb]];
                        if(data) {
                            UIImage *image = [[UIImage alloc] initWithData:data];
                            image = [MFUtil getScaledImage:image scaledToMaxWidth:150];
                            [imgCache storeImage:image forKey:thumb toDisk:YES];
                            commCachingCnt++;
                        }
                    }
                    
                    if(![imgCache diskImageExistsWithKey:thumb]){
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            SDWebImageDownloader *downLoader = [SDWebImageDownloader sharedDownloader];
                            [downLoader downloadImageWithURL:[NSURL URLWithString:thumb] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {

                            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                if (image && finished) {
                                    //NSLog(@"이미지 다운 완료!");
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        UIImage *img = [MFUtil getScaledImage:image scaledToMaxWidth:150];
                                        [[SDImageCache sharedImageCache]storeImage:img recalculateFromImage:NO imageData:data forKey:thumb toDisk:YES];

                                        //NSLog(@"이미지 인덱스 : %d", idx);

                                        commCachingCnt++;

                                        NSLog(@"22 commDataCnt : %d, commCachingCnt : %d", commDataCnt, commCachingCnt);

                                        if(commDataCnt==commCachingCnt){
                                            commCachingCnt=0;
                                            commDataCnt=0;
                                            [self commCellRefresh];
                                        }

//                                        imgH = img.size.height;
//                                        cellHeight = textH+imgH+fileH;
//                                        [cellDict setObject:[NSString stringWithFormat:@"%d", cellHeight] forKey:[NSString stringWithFormat:@"%d", i]];
//
//                                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:5];
//                                        [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
                                    });
                                }
                            }];
                        });
                    }
                */
                } else if([commType isEqualToString:@"FILE"]){
                    NSString *commValue = [[jsonArr objectAtIndex:k] objectForKey:@"VALUE"];
                    NSString *origin = [[jsonArr objectAtIndex:k] objectForKey:@"FILE"];
                    
                    if(commValue!=nil&&![commValue isEqualToString:@""]) {
                        NSMutableAttributedString *commStr = [[NSMutableAttributedString alloc] initWithString:@""];
                        
                        if(commTarget.count>0){
                            for(int j=0; j<commTarget.count; j++){
                                NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                                NSString *usrNo = [[commTarget objectAtIndex:j] objectForKey:@"USER_NO"];
                                
                                NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:usrNm attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor], /*NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]],*/ NSLinkAttributeName:[NSString stringWithFormat:@"%@", usrNo]}];
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
        }
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
        
    }
}

-(void)returnError:(MFURLSession *)session error:(NSError *)error{
    [SVProgressHUD dismiss];
    NSLog(@"error : %@", error);
    
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
        //[self startLoading];
    }
    [self reconnectFromError];
}
-(void)setTimer{
    timerCount = 0;
    timerEndCount = 1;
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}
-(void)handleTimer:(NSTimer *)timer {
    timerCount++;
    if (timerCount==timerEndCount) {
        [self startLoading];
        [myTimer invalidate];
    }
}

-(void)reconnectFromError{
    if(appDelegate.errorExecCnt<[[MFSingleton sharedInstance] errorMaxCnt]){
        [self setTimer];
    } else {
        appDelegate.errorExecCnt = 0;
        [SVProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"exception_msg_unknownhostexception", @"exception_msg_unknownhostexception") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    appDelegate.errorExecCnt++;
}

#pragma mark - MFURLSession Upload Delegate
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error{
    @try{
        commUploadCnt++;
        if (error != nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:error preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else{
            NSLog(@"dictionary : %@", dictionary);
            
            NSString *result = [dictionary objectForKey:@"RESULT"];
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([dictionary objectForKey:@"FILE_URL"]==nil) {
                    
                }else{
                    videoThumbName = @"";
                    newRefNo = [dictionary objectForKey:@"NEW_REF_NO"];
                    
                    NSString *ttype = [[resultArr objectAtIndex:commUploadCnt-1] objectForKey:@"TYPE"];
                    
                    if([ttype isEqualToString:@"IMG"]){
                        [self.commFilePathArr addObject:[dictionary objectForKey:@"FILE_URL"]];
                        [self.commFileThumbPathArr addObject:[dictionary objectForKey:@"FILE_URL_THUMB"]];
                        commFileNameCnt++;
                        
                    } else if([ttype isEqualToString:@"VIDEO"]){
                        [self.commFilePathArr addObject:[dictionary objectForKey:@"FILE_URL"]];
                        [self.commFileThumbPathArr addObject:[dictionary objectForKey:@"FILE_URL_THUMB"]];
                        commFileNameCnt++;
                        
                    } else if([ttype isEqualToString:@"VIDEO_THUMB"]){
                        videoThumbName = [[dictionary objectForKey:@"FILE_URL"] lastPathComponent];
                        
                    } else if([ttype isEqualToString:@"FILE"]){
                        [self.commFilePathArr addObject:[dictionary objectForKey:@"FILE_URL"]];
                        [self.commFileThumbPathArr addObject:[dictionary objectForKey:@"FILE_URL_THUMB"]];
                        commFileNameCnt++;
                    }
                    
                    if(commUploadCnt<resultArr.count){
                        //첫번째 파일 먼저 올리고, 순차적으로 업로드 하기 위해 재호출
                        NSString *type = [[resultArr objectAtIndex:commUploadCnt] objectForKey:@"TYPE"];
                        
                        if([type isEqualToString:@"IMG"]){
                            UIImage *value = [[resultArr objectAtIndex:commUploadCnt] objectForKey:@"FILE"];
                            value = [MFUtil getResizeImageRatio:value];
                            NSData * data = UIImageJPEGRepresentation(value, 0.7);
                            [self saveMediaFiles:data mediaType:type];
                            
                        } else if([type isEqualToString:@"VIDEO"]){
                            NSData *data = [[resultArr objectAtIndex:commUploadCnt] objectForKey:@"FILE"];
                            if((float)data.length/1024.0f/1024.0f>20){
                                [self videoSizeCheck];
                            } else {
                                [self saveMediaFiles:data mediaType:type];
                            }
                            
                        } else if([type isEqualToString:@"VIDEO_THUMB"]){
                            UIImage *value = [[resultArr objectAtIndex:commUploadCnt] objectForKey:@"VALUE"];
                            value = [MFUtil getResizeImageRatio:value];
                            NSData * data = UIImageJPEGRepresentation(value, 0.7);
                            [self saveMediaFiles:data mediaType:type];
                            
                        } else if([type isEqualToString:@"FILE"]){
                            NSData *data = [[resultArr objectAtIndex:commUploadCnt] objectForKey:@"FILE_DATA"];
                            [self saveMediaFiles:data mediaType:type];
                        }
                        
                    } else if (commUploadCnt==resultArr.count) {
                        //dataArr에 있는 이미지데이터를 URL String으로 바꾸기위해.
                        [self imageToUrlString];
                        
                        NSError *error;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commDataArr options:0 error:&error];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        NSString *postNo = [self.postDetailInfo objectForKey:@"POST_NO"];
                        NSString *postUsrNo = [self.postDetailInfo objectForKey:@"CUSER_NO"];
                        
                        [SVProgressHUD dismiss];
                        
                        NSLog(@"SAVEPOSTCOMM I/V myUserNo : %@", myUserNo);
                        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@&isNewComment=true&postUsrNo=%@&commentNo=%@", myUserNo, snsNo, postNo, jsonString, postUsrNo, newRefNo];
                        [self callWebService:@"savePostComment" WithParameter:paramString];
                    }
                }
                
            } else {
                [SVProgressHUD dismiss];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"업로드실패" message:@"다시 시도하여 주십시오." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     commDataArr = [NSMutableArray array];
                                                                     self.commFileArr = [NSMutableArray array];
                                                                     self.commFilePathArr = [NSMutableArray array];
                                                                     self.commFileThumbPathArr = [NSMutableArray array];
                                                                     
                                                                     resultArr = [NSMutableArray array];
                                                                     commUploadCnt = 0;
                                                                     commFileNameCnt = 0;
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    } @catch (NSException *exception) {
        [SVProgressHUD dismiss];
        NSLog(@"Exception : %@", exception);
    }
}

- (void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error{
    [SVProgressHUD dismiss];
    NSLog(@"%@", error);
    
    commDataArr = [NSMutableArray array];
    self.commFileArr = [NSMutableArray array];
    self.commFilePathArr = [NSMutableArray array];
    self.commFileThumbPathArr = [NSMutableArray array];
    
    resultArr = [NSMutableArray array];
    commUploadCnt = 0;
    commFileNameCnt = 0;
}

#pragma mark - POST EVENT
-(void)touchedProfileButton:(UIButton *)sender{
    NSString *userNo = @"";
    NSString *userType = @"";
    if(sender.tag>-1){
        userNo = [[self.commentArray objectAtIndex:sender.tag] objectForKey:@"CUSER_NO"];
        userType = [[self.commentArray objectAtIndex:sender.tag] objectForKey:@"SNS_USER_TYPE"];
    }else{
        userNo = [self.postInfo objectForKey:@"CUSER_NO"];
        userType = [self.postInfo objectForKey:@"SNS_USER_TYPE"];
    }
    
    CustomHeaderViewController *destination = [[CustomHeaderViewController alloc] initwithUserNo:userNo userType:userType];
    destination.userNo = userNo;
    destination.userType = userType;
    destination.fromSegue = @"POST_DETAIL_PROFILE_MODAL";
    
    destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:destination animated:YES completion:nil];
}
-(void)touchedSettingButton:(UIButton *)sender{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSNumber *subcriber = [self.postDetailInfo objectForKey:@"SUB_CUSER_NO"];
    NSNumber *writer = [self.postDetailInfo objectForKey:@"CUSER_NO"];
    
    if ([subcriber isEqual:writer]) {
        UIAlertAction *editAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"수정", @"수정")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action){
                                                               self.isEdit = @"POST";
                                                               [self performSegueWithIdentifier:@"POST_MODIFY_MODAL" sender:self.postDetailInfo];
                                                               [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                           }];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * action){
                                                                 
                                                                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"delete1", @"delete1") preferredStyle:UIAlertControllerStyleAlert];
                                                                 UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                                                                      handler:^(UIAlertAction * action) {
                                                                                                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                      }];
                                                                 UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                                                                  handler:^(UIAlertAction * action) {
                                                                                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                      
                                                                                                                      NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&postNo=%@", writer, self._postNo];
                                                                                                                      [self callWebService:@"deletePost" WithParameter:paramString];
                                                                                                                      
                                                                                                                  }];
                                                                 [alert addAction:cancelButton];
                                                                 [alert addAction:okButton];
                                                                 [self presentViewController:alert animated:YES completion:nil];
                                                                 
                                                                 [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        [actionSheet addAction:editAction];
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
}
-(void)writerNameTapDetected:(id)sender{
    self.inputToolbar.contentView.rightBarButtonItem.enabled = YES;
    
    [self.inputToolbar.contentView.textView becomeFirstResponder];
    self.inputToolbar.contentView.textView.placeHolder = nil;
    
    NSMutableAttributedString *tagName = [[NSMutableAttributedString alloc] init];
    
    NSString *userName = [NSString urlDecodeString:[self.postDetailInfo objectForKey:@"CUSER_NM"]];
    NSString *userNo = [self.postDetailInfo objectForKey:@"CUSER_NO"];
    NSString *userId = [self.postDetailInfo objectForKey:@"CUSER_ID"];

    UITextRange *tagRange = self.inputToolbar.contentView.textView.selectedTextRange;
    UITextPosition* beginning = self.inputToolbar.contentView.textView.beginningOfDocument;
    UITextPosition* selectionStart = tagRange.start;
    //UITextPosition* selectionEnd = tagRange.end;
    NSInteger location = [self.inputToolbar.contentView.textView offsetFromPosition:beginning toPosition:selectionStart];
    //NSInteger length = [self.inputToolbar.contentView.textView offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:userName attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]], NSLinkAttributeName:[NSString stringWithFormat:@"%@&%@", userNo, userId]}];
    self.inputToolbar.contentView.textView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};

    NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];

    [tagName appendAttributedString:attrName];
    [tagName appendAttributedString:attrSpace];

    [self.inputToolbar.contentView.textView.textStorage insertAttributedString:tagName atIndex:location];
    self.inputToolbar.contentView.textView.selectedRange = NSMakeRange(self.inputToolbar.contentView.textView.text.length, 0);
}

-(void)imgTapDetected:(id)sender{
    NSLog();
    
    UITapGestureRecognizer *gesture = sender;
    UIImageView *imageView = (UIImageView *)gesture.view;
    
//    NSURL *imageUrl = [NSURL URLWithString:[[self.imageUrlDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)imageView.tag]] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
//
//    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (data) {
//            UIImage *image = [UIImage imageWithData:data];
//            if (image) {
//                dispatch_async(dispatch_get_main_queue(), ^{
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    ImgDownloadViewController *destination = (ImgDownloadViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ImgDownloadViewController"];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];

                    NSString *imgName = [[self.imageUrlDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)imageView.tag]] lastPathComponent];

                    destination.imgPath = [self.imageUrlDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)imageView.tag]];
                    destination.imgName = imgName;
                    destination.writer = [NSString urlDecodeString:[self.postDetailInfo objectForKey:@"CUSER_NM"]];
                    destination.writeDate = [NSString urlDecodeString:[self.postDetailInfo objectForKey:@"POST_DATE"]];
                    destination.fromSegue = @"POST_IMG_DOWN_MODAL";

                    navController.modalTransitionStyle = UIModalPresentationNone;
                    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:navController animated:YES completion:nil];
//                });
//            }
//        }
//    }];
//    [task resume];
}
-(void)videoTapDetected:(id)sender{
    UITapGestureRecognizer *gesture = sender;
    UIView *videoView = (UIView *)gesture.view;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *destination = (WebViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    
    NSString *imgPath = [self.imageUrlDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)videoView.tag]];
    destination.fileUrl = imgPath;
    
    navController.modalTransitionStyle = UIModalPresentationNone;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    //navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navController animated:YES completion:nil];
}
-(void)postPlayButtonClick:(UIButton *)sender{
    NSString *imgPath = [self.imageUrlDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *destination = (WebViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    destination.fileUrl = imgPath;
    navController.modalTransitionStyle = UIModalPresentationNone;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    //navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navController animated:YES completion:nil];
}
-(void)fileTapDetected:(UITapGestureRecognizer *)sender{
    UIView *fileView = (UIView *)sender.view;
    NSString *fileUrl = [self.fileDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)fileView.tag]];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *fileOpenAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"file_open", @"file_open")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action){
                                                               [self performSegueWithIdentifier:@"FILE_OPEN_MODAL" sender:fileUrl];
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

#pragma mark - Long Tap Event Handler
-(void)txtLongTapDetected:(UILongPressGestureRecognizer *)gesture{
    CGPoint p = [gesture locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"share", @"share")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action){
                                                                [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                
                                                                NSString *value = [NSString urlDecodeString:[[self.contentArray objectAtIndex:indexPath.row] objectForKey:@"VALUE"]];
                                                                
                                                                NSMutableArray *arr = [NSMutableArray array];
                                                                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                                                
                                                                [dict setObject:@"TEXT" forKey:@"TYPE"];
                                                                [dict setObject:value forKey:@"VALUE"];
                                                                [dict setObject:@"true" forKey:@"IS_SHARE"];
                                                                [arr addObject:dict];
                                                                
                                                                [appDelegate.appPrefs setObject:arr forKey:@"SHARE_ITEM_FROM_POST"];
                                                                [appDelegate.appPrefs synchronize];
                                                                
                                                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                ShareSelectViewController *destination = (ShareSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareSelectViewController"];
                                                                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                                                                destination.fromSegue = @"SHARE_FROM_POST_MODAL";
                                                                navController.modalTransitionStyle = UIModalPresentationNone;
                                                                navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                                [self presentViewController:navController animated:YES completion:nil];
                                                            }];
        [actionSheet addAction:shareAction];
        
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
        
    } else {
        
        
    }
}

-(void)imgLongTapDetected:(UILongPressGestureRecognizer *)gesture{
    CGPoint p = [gesture locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"share", @"share")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action){
                                                                [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                               
                                                                //NSLog(@"SHARE MSG DATA : %@", [self.contentArray objectAtIndex:indexPath.row]);
                                                                NSDictionary *value = [[self.contentArray objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
                                                                NSString *origin = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
//                                                                NSString *thumb = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                                                                origin = [origin stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

                                                                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:origin]]; //이게 오래걸리네

                                                                NSMutableArray *arr = [NSMutableArray array];
                                                                NSMutableDictionary *dict = [NSMutableDictionary dictionary];

                                                                [dict setObject:@"IMG" forKey:@"TYPE"];
                                                                [dict setObject:imgData forKey:@"VALUE"];
                                                                [dict setObject:origin forKey:@"URL"];
                                                                [dict setObject:@"true" forKey:@"IS_SHARE"];
                                                                [arr addObject:dict];

                                                                [appDelegate.appPrefs setObject:arr forKey:@"SHARE_ITEM_FROM_POST"];
                                                                [appDelegate.appPrefs synchronize];

                                                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                ShareSelectViewController *destination = (ShareSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareSelectViewController"];
                                                                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                                                                destination.fromSegue = @"SHARE_FROM_POST_MODAL";
                                                                navController.modalTransitionStyle = UIModalPresentationNone;
                                                                navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                                [self presentViewController:navController animated:YES completion:nil];
                                                                
                                                            }];
        [actionSheet addAction:shareAction];
        
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
        
    } else {
        
    }
}

-(void)videoLongTapDetected:(UILongPressGestureRecognizer *)gesture{
    CGPoint p = [gesture locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"share", @"share")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action){
                                                                [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                
//                                                                NSLog(@"SHARE VIDEO MSG DATA : %@", [self.contentArray objectAtIndex:indexPath.row]);
                                                                NSDictionary *value = [[self.contentArray objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
                                                                NSString *origin = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
                                                                NSString *thumb = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                                                                thumb = [thumb stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                                                                
                                                                NSData *thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumb]];

                                                                NSMutableArray *arr = [NSMutableArray array];
                                                                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                                                [dict setObject:@"VIDEO" forKey:@"TYPE"];
                                                                [dict setObject:thumbData forKey:@"VIDEO_THUMB"];
                                                                [dict setObject:@"" forKey:@"VIDEO_DATA"];
                                                                [dict setObject:origin forKey:@"URL"];
                                                                [dict setObject:@"true" forKey:@"IS_SHARE"];
                                                                [arr addObject:dict];

                                                                [appDelegate.appPrefs setObject:arr forKey:@"SHARE_ITEM_FROM_POST"];
                                                                [appDelegate.appPrefs synchronize];

                                                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                ShareSelectViewController *destination = (ShareSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareSelectViewController"];
                                                                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                                                                destination.fromSegue = @"SHARE_FROM_POST_MODAL";
                                                                navController.modalTransitionStyle = UIModalPresentationNone;
                                                                navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                                [self presentViewController:navController animated:YES completion:nil];
                                                            }];
        [actionSheet addAction:shareAction];
        
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
        
    } else {
        
    }
}

-(void)fileLongTapDetected:(UILongPressGestureRecognizer *)gesture{
    CGPoint p = [gesture locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"share", @"share")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action){
                                                                [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                
//                                                                NSLog(@"SHARE FILE MSG DATA : %@", [self.contentArray objectAtIndex:indexPath.row]);
                                                                NSString *content = [NSString urlDecodeString:[[self.contentArray objectAtIndex:indexPath.row] objectForKey:@"VALUE"]];
                                                                
                                                                NSMutableArray *arr = [NSMutableArray array];
                                                                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                                                [dict setObject:@"FILE" forKey:@"TYPE"];
                                                                [dict setObject:content forKey:@"VALUE"];
                                                                [dict setObject:@"true" forKey:@"IS_SHARE"];
                                                                [arr addObject:dict];

                                                                [appDelegate.appPrefs setObject:arr forKey:@"SHARE_ITEM_FROM_POST"];
                                                                [appDelegate.appPrefs synchronize];

                                                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                ShareSelectViewController *destination = (ShareSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareSelectViewController"];
                                                                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                                                                destination.fromSegue = @"SHARE_FROM_POST_MODAL";
                                                                navController.modalTransitionStyle = UIModalPresentationNone;
                                                                navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                                [self presentViewController:navController animated:YES completion:nil];
                                                                
                                                            }];
        [actionSheet addAction:shareAction];
        
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
        
    } else {
        //NSLog(@"gestureRecognizer.state = %ld", gesture.state);
        
    }
}

#pragma mark - COMMENT EVENT
-(void)commentTapDetected:(UILongPressGestureRecognizer *)gesture{
    NSLog();
    
    CGPoint p = [gesture locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        //NSLog(@"long press on table view but not on a row");
        
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
//        if(!isTap){
            [self commentSelect:indexPath];
//            isTap = YES;
//        }
        
    } else {
        //NSLog(@"gestureRecognizer.state = %ld", gesture.state);
    }
}
- (void)commentSelect:(NSIndexPath *)indexPath{
    @try{
        NSString *commContent = [[self.commentArray objectAtIndex:indexPath.row]objectForKey:@"CONTENT"];
        NSError *jsonError;
        NSData *commData = [[NSString urlDecodeString:commContent] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
        NSString *commType = [[jsonArr objectAtIndex:0] objectForKey:@"TYPE"];
        //NSString *commValue = [[jsonArr objectAtIndex:0] objectForKey:@"VALUE"];
        
        NSNumber *subcriber = [self.postDetailInfo objectForKey:@"SUB_CUSER_NO"];
        NSNumber *writer = [[self.commentArray objectAtIndex:indexPath.row]objectForKey:@"CUSER_NO"];
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        if([commType isEqualToString:@"TEXT"]){
            UIAlertAction *copyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"copy", @"copy")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action){
                                                                   NSString *comment = [[self.commentArray objectAtIndex:indexPath.row]objectForKey:@"CONTENT"];
                                                                   
                                                                   NSError *jsonError;
                                                                   NSData *commData = [[NSString urlDecodeString:comment] dataUsingEncoding:NSUTF8StringEncoding];
                                                                   NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
                                                                   
                                                                   NSString *copyStr = @"";
                                                                   
                                                                   for(int i=0; i<jsonArr.count; i++){
                                                                       NSString *commType = [[jsonArr objectAtIndex:i] objectForKey:@"TYPE"];
                                                                       NSArray *commTarget = [[jsonArr objectAtIndex:i] objectForKey:@"TARGET"];
                                                                       
                                                                       if([commType isEqualToString:@"TEXT"]){
                                                                           NSString *commValue = [[jsonArr objectAtIndex:i] objectForKey:@"TEXT"];
                                                                           
                                                                           if(commTarget.count>0){
                                                                               for(int j=0; j<commTarget.count; j++){
                                                                                   NSString *usrNm = [[commTarget objectAtIndex:j] objectForKey:@"USER_NM"];
                                                                                   
                                                                                   copyStr = [copyStr stringByAppendingString:[NSString stringWithFormat:@"%@ ", usrNm]];
                                                                               }
                                                                           }
                                                                           copyStr = [copyStr stringByAppendingString:commValue];
                                                                       }
                                                                   }
                                                                   
                                                                   UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                                   pasteboard.string = copyStr;
                                                                   
                
                
                                                                   [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                               }];
            [actionSheet addAction:copyAction];
            
            if ([subcriber isEqual:writer]) {
                UIAlertAction *updateAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"수정", @"수정")
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action){
                                                                         commentUsrId = [appDelegate.appPrefs objectForKey:@"USERID"];
                                                                         commentNo = [[self.commentArray objectAtIndex:indexPath.row]objectForKey:@"COMMENT_NO"];
                                                                         commentIdx = indexPath;
                                                                         self.isEdit = @"COMMENT";
                                                                         
                                                                         [self performSegueWithIdentifier:@"POST_MODIFY_MODAL" sender:[self.commentArray objectAtIndex:indexPath.row]];
                                                                         [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                
                
                UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
                                                                       style:UIAlertActionStyleDestructive
                                                                     handler:^(UIAlertAction * action){
                                                                         commentUsrId = [appDelegate.appPrefs objectForKey:@"USERID"];
                                                                         //NSString *postNo = [self.postInfo objectForKey:@"POST_NO"];
                                                                         commentNo = [[self.commentArray objectAtIndex:indexPath.row]objectForKey:@"COMMENT_NO"];
                                                                         
                                                                         UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"delete1", @"delete1") preferredStyle:UIAlertControllerStyleAlert];
                                                                         UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                                                                              handler:^(UIAlertAction * action) {
                                                                                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                              }];
                                                                         UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                                                                          handler:^(UIAlertAction * action) {
                                                                                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                              NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&commentNo=%@&postNo=%@", writer, commentNo, self._postNo];
                                                                                                                              
                                                                                                                              [self.commentArray removeObjectAtIndex:commentIdx.row];
                                                                                                                              [resultCommArr removeObjectAtIndex:commentIdx.row];
                                                                                                                              
                                                                                                                              [self.tableView beginUpdates];
                                                                                                                              [self.tableView deleteRowsAtIndexPaths:@[commentIdx] withRowAnimation:UITableViewRowAnimationNone];
                                                                                                                              [self.tableView endUpdates];
                                                                                                                              
                                                                                                                              [self callWebService:@"deletePostComment" WithParameter:paramString];

                                                                                                                          }];
                                                                         [alert addAction:cancelButton];
                                                                         [alert addAction:okButton];
                                                                         [self presentViewController:alert animated:YES completion:nil];
                                                                         
                                                                         commentIdx = indexPath;
                                                                         
                                                                         [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [deleteAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
                
                [actionSheet addAction:updateAction];
                [actionSheet addAction:deleteAction];
            }
        } else {
            if ([subcriber isEqual:writer]) {
                UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
                                                                       style:UIAlertActionStyleDestructive
                                                                     handler:^(UIAlertAction * action){
                                                                         commentUsrId = [appDelegate.appPrefs objectForKey:@"USERID"];
                                                                         //NSString *postNo = [self.postInfo objectForKey:@"POST_NO"];
                                                                         commentNo = [[self.commentArray objectAtIndex:indexPath.row]objectForKey:@"COMMENT_NO"];
                                                                         
                                                                         UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"delete1", @"delete1") preferredStyle:UIAlertControllerStyleAlert];
                                                                         UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                                                                              handler:^(UIAlertAction * action) {
                                                                                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                              }];
                                                                         UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                                                                          handler:^(UIAlertAction * action) {
                                                                                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                              //NSLog(@"commentNo : %@", commentNo);
                                                                                                                              NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&commentNo=%@&postNo=%@", writer, commentNo, self._postNo];
                                                                                                                              
                                                                                                                              [self.commentArray removeObjectAtIndex:commentIdx.row];
                                                                                                                              [resultCommArr removeObjectAtIndex:commentIdx.row];
                                                                                                                              
                                                                                                                              [self.tableView beginUpdates];
                                                                                                                              [self.tableView deleteRowsAtIndexPaths:@[commentIdx] withRowAnimation:UITableViewRowAnimationNone];
                                                                                                                              [self.tableView endUpdates];
                                                                                                                              
                                                                                                                              [self callWebService:@"deletePostComment" WithParameter:paramString];
                                                                                                                          }];
                                                                         [alert addAction:cancelButton];
                                                                         [alert addAction:okButton];
                                                                         [self presentViewController:alert animated:YES completion:nil];
                                                                         
                                                                         commentIdx = indexPath;
                                                                         
                                                                         [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [deleteAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
                
                [actionSheet addAction:deleteAction];
            }
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

-(void)commImgTapDetected:(id)sender{
    UITapGestureRecognizer *gesture = sender;
    //UIImageView *imageView = (UIImageView *)gesture.view;
    UIView *mediaView = (UIView *)gesture.view;
    
    NSString *userName = [[self.commentArray objectAtIndex:mediaView.tag] objectForKey:@"CUSER_NM"];
    NSString *postDate = [[self.commentArray objectAtIndex:mediaView.tag] objectForKey:@"COMMENT_DATE"];
    NSString *comment = [[self.commentArray objectAtIndex:mediaView.tag] objectForKey:@"CONTENT"];
    //comment = [comment stringByReplacingOccurrencesOfString:@"%5Cn" withString:@"%0A"];
    NSError *jsonError;
    NSData *commData = [[NSString urlDecodeString:comment] dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
    NSString *commType = [[jsonArr objectAtIndex:0] objectForKey:@"TYPE"];
    NSString *commValue = [[jsonArr objectAtIndex:0] objectForKey:@"FILE"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if([commType isEqualToString:@"IMG"]){
//        NSURL *imageUrl = [NSURL URLWithString:[commValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
//        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            if (data) {
//                UIImage *image = [UIImage imageWithData:data];
//                if (image) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
                        ImgDownloadViewController *destination = (ImgDownloadViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ImgDownloadViewController"];
                        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    
                        NSString *imgName = [commValue lastPathComponent];
    
                        destination.imgPath = commValue;
                        destination.imgName = imgName;
                        destination.writer = [NSString urlDecodeString:userName];
                        destination.writeDate = [NSString urlDecodeString:postDate];
                        destination.fromSegue = @"POST_IMG_DOWN_MODAL";
                        
                        navController.modalTransitionStyle = UIModalPresentationNone;
                        navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                        [self presentViewController:navController animated:YES completion:nil];
//                    });
//                }
//            }
//        }];
//        [task resume];
        
    } else if([commType isEqualToString:@"VIDEO"]||[commType isEqualToString:@"FILE"]){
        WebViewController *destination = (WebViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        
        destination.fileUrl = commValue;
        navController.modalTransitionStyle = UIModalPresentationNone;
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        //navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

-(void)commPlayButtonClick:(UIButton *)sender{
    NSString *comment = [[self.commentArray objectAtIndex:sender.tag] objectForKey:@"CONTENT"];
    //comment = [comment stringByReplacingOccurrencesOfString:@"%5Cn" withString:@"%0A"];
    NSError *jsonError;
    NSData *commData = [[NSString urlDecodeString:comment] dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
    NSString *commValue = [[jsonArr objectAtIndex:0] objectForKey:@"FILE"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *destination = (WebViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
    destination.fileUrl = commValue;
    navController.modalTransitionStyle = UIModalPresentationNone;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    //navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)commPrevTapDetected:(id)sender{
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&postNo=%@&pSize=%d&commentNo=%@", myUserNo, self._postNo, pSize, prevCommentNo];
    [self callWebService:@"getPostComments" WithParameter:paramString];
}
-(void)touchedCommFileButton:(UIButton *)sender{
    NSString *comment = [[self.commentArray objectAtIndex:sender.tag] objectForKey:@"CONTENT"];
    //comment = [comment stringByReplacingOccurrencesOfString:@"%5Cn" withString:@"%0A"];
    NSError *jsonError;
    NSData *commData = [[NSString urlDecodeString:comment] dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:commData options:0 error:&jsonError];
    NSString *commValue = [[jsonArr objectAtIndex:0] objectForKey:@"FILE"];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *fileOpenAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"file_open", @"file_open")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action){
                                                               [self performSegueWithIdentifier:@"FILE_OPEN_MODAL" sender:commValue];
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
#pragma mark - COMMENT TAG
-(void)tapCommentNameForTag:(UITapGestureRecognizer *)sender{
    NSLog();
    self.inputToolbar.contentView.rightBarButtonItem.enabled = YES;
    
    [self.inputToolbar.contentView.textView becomeFirstResponder];
    self.inputToolbar.contentView.textView.placeHolder = nil;
    
    NSMutableAttributedString *tagName = [[NSMutableAttributedString alloc] init];
    
    CGPoint p = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    NSString *userName = [NSString urlDecodeString:[[self.commentArray objectAtIndex:indexPath.row] objectForKey:@"CUSER_NM"]];
    NSString *userNo = [[self.commentArray objectAtIndex:indexPath.row] objectForKey:@"CUSER_NO"];
    NSString *userId = [[self.commentArray objectAtIndex:indexPath.row] objectForKey:@"CUSER_ID"];
    
    UITextRange *tagRange = self.inputToolbar.contentView.textView.selectedTextRange;
    UITextPosition* beginning = self.inputToolbar.contentView.textView.beginningOfDocument;
    UITextPosition* selectionStart = tagRange.start;
    //UITextPosition* selectionEnd = tagRange.end;
    NSInteger location = [self.inputToolbar.contentView.textView offsetFromPosition:beginning toPosition:selectionStart];
    //NSInteger length = [self.inputToolbar.contentView.textView offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc] initWithString:userName attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]], NSLinkAttributeName:[NSString stringWithFormat:@"%@&%@", userNo, userId]}];
    self.inputToolbar.contentView.textView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];
    //NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor], NSBackgroundColorAttributeName:[UIColor whiteColor]}];
    
    [tagName appendAttributedString:attrName];
    [tagName appendAttributedString:attrSpace];
    
    NSLog(@"tagName : %@", tagName);
    
    [self.inputToolbar.contentView.textView.textStorage insertAttributedString:tagName atIndex:location];
    self.inputToolbar.contentView.textView.selectedRange = NSMakeRange(self.inputToolbar.contentView.textView.text.length, 0);
}

-(void)setCommentMsg{
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithAttributedString:self.inputToolbar.contentView.textView.attributedText];
    
    NSMutableArray *testArr = [NSMutableArray array];
    textVal = @"";
    attrCount = 0;
    isTagSpace = NO;
    
    [attrStr enumerateAttributesInRange:NSMakeRange(0, attrStr.length)
                                options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                             usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop){
                                 NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
                                 //NSLog(@"mutableAttributes : %@", mutableAttributes);
                                 
                                 UIFont *currentFont = [mutableAttributes objectForKey:NSFontAttributeName];
                                 NSString *currFontName = [currentFont.fontName lowercaseString];
                                 NSMutableDictionary *testDic = [NSMutableDictionary dictionary];
                                 
                                 if([currFontName rangeOfString:@"bold"].location!=NSNotFound){
                                     
                                     if(![[attrStr attributedSubstringFromRange:range].string isEqualToString:@" "]){
                                         NSString *userInfo = [mutableAttributes objectForKey:NSLinkAttributeName];
                                         
                                         NSRange infoRange = [userInfo rangeOfString:@"&" options:0];
                                         NSString *userNo = [userInfo substringToIndex:infoRange.location];
                                         NSString *userId = [userInfo substringFromIndex:infoRange.location+1];
                                         
                                         [testDic setObject:[attrStr attributedSubstringFromRange:range].string forKey:@"TARGET_NM"];
                                         [testDic setObject:userNo forKey:@"TARGET_NO"];
                                         [testDic setObject:userId forKey:@"TARGET_ID"];
                                         [testArr addObject:testDic];
                                         
                                         attrCount++;
                                         isTagSpace = YES;
                                     }
                                     
                                     
                                 } else {
                                     NSString *str = [attrStr attributedSubstringFromRange:range].string;
                                     str = [MFUtil replaceEncodeToChar:str];
                                     
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
                                 }
                             }];
    
    NSMutableArray *dataArr = [NSMutableArray array];
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
                
                [dataArr addObject:dataDic];
                
            } else{
                if([[testArr objectAtIndex:i-1] objectForKey:@"VALUE"]==nil){
                    [dataDic setObject:@"TEXT" forKey:@"TYPE"];
                    [dataDic setObject:targetArr forKey:@"TARGET"];
                    [dataDic setObject:[[testArr objectAtIndex:i] objectForKey:@"TEXT"] forKey:@"TEXT"];
                    
                    targetArr = [NSMutableArray array];
                    
                    [dataArr addObject:dataDic];
                    
                } else if([[testArr objectAtIndex:i-1] objectForKey:@"TEXT"]!=nil){
                    [dataDic setObject:@"TEXT" forKey:@"TYPE"];
                    [dataDic setObject:[[dataArr objectAtIndex:i-1] objectForKey:@"TARGET"] forKey:@"TARGET"];
                    
                    NSString *value = [[[testArr objectAtIndex:i-1] objectForKey:@"TEXT"] stringByAppendingString:[[testArr objectAtIndex:i] objectForKey:@"TEXT"]];
                    [dataDic setObject:value forKey:@"TEXT"];
                    
                    [dataArr replaceObjectAtIndex:i-1 withObject:dataDic];
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
                
                [dataArr addObject:dataDic];
            }
        }
    }
    
    NSMutableAttributedString *attrSpace = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:[UIColor blackColor]}];
    [self.inputToolbar.contentView.textView.textStorage insertAttributedString:attrSpace atIndex:0];
    
    NSArray *contentArr = [[NSArray alloc] initWithArray:dataArr];
    [self setCommentData:contentArr :@"TEXT" :NO];
}

-(void)textViewDidChange:(MFTextView *)textView{
    //UITextRange *textRange = textView.selectedTextRange;
    
    //UITextPosition* beginning = textView.beginningOfDocument;
    //UITextPosition* selectionStart = textRange.start;
    //UITextPosition* selectionEnd = textRange.end;
    
    //NSInteger location = [self.inputToolbar.contentView.textView offsetFromPosition:beginning toPosition:selectionStart];
    //NSInteger length = [self.inputToolbar.contentView.textView offsetFromPosition:selectionStart toPosition:selectionEnd];
    //NSLog(@"location : %ld", (long)location);
    
    inputText = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
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

-(BOOL)textView:(MFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
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
                                                                 [textView.textStorage deleteCharactersInRange:NSMakeRange(textRange.location-range.length, range.length+1)];
                                                                 
                                                                 NSRange delRange = textView.selectedRange;
                                                                 
                                                                 NSAttributedString *emptyStr = [[NSAttributedString alloc] initWithString:@" "];
                                                                 [textView.textStorage insertAttributedString:emptyStr atIndex:delRange.location];
                                                                 
                                                                 [textView setSelectedRange:NSMakeRange(delRange.location+1, 0)];
                                                             }
                                                             *stop = YES;
                                                         }];
            }
            
        } @catch(NSException* exception){
            NSLog(@"Exception : %@", exception);
        }
    }
    return YES;
}

-(BOOL)composerTextView:(MFTextView *)textView shouldPasteWithSender:(id)sender{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    UIFont *dic = [textView.attributedText attribute:NSFontAttributeName atIndex:characterRange.location effectiveRange:&characterRange];
    NSString *fontName = [dic.fontName lowercaseString];
    
    if([fontName rangeOfString:@"bold"].location!=NSNotFound){
        //이름태그
        NSString *userNo = [NSString stringWithFormat:@"%@", URL];
        
        CustomHeaderViewController *destination = [[CustomHeaderViewController alloc] initwithUserNo:userNo userType:@""];
        destination.userNo = userNo;
        destination.userType = @"";
        destination.fromSegue = @"POST_DETAIL_PROFILE_MODAL";
        
        destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:destination animated:YES completion:nil];
        
    } else {
        //그 외(URL,이메일,전화번호 등)
    }
    
    return YES;
}

#pragma mark - PUSH NOTIFICATION
- (void)noti_PostDetailView:(NSNotification *)notification{
    @try {
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
        
        NSArray *dataSet = [notification.userInfo objectForKey:@"DATASET"];
        NSString *postNo = [[dataSet objectAtIndex:0] objectForKey:@"POST_NO"];
        
        if(![[NSString stringWithFormat:@"%@", postNo] isEqualToString:[NSString stringWithFormat:@"%@", self._postNo]]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PostDetailViewController *vc = (PostDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            vc.fromSegue = @"NOTI_POST_DETAIL";
            vc.notiPostDic = notification.userInfo;
            
            [self presentViewController:nav animated:YES completion:nil];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_PostProfileChat:(NSNotification *)notification {
    NSLog();
    appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
    
    @try {
        //글상세보기에서 푸시받았을경우
        NSString *nRoomNo = [notification.userInfo objectForKey:@"NEW_ROOM_NO"];
        NSString *nRoomNm = [NSString urlDecodeString:[notification.userInfo objectForKey:@"NEW_ROOM_NM"]];
        NSString *roomType = [notification.userInfo objectForKey:@"NEW_ROOM_TY"];
        NSArray *users = [notification.userInfo objectForKey:@"NEW_USERS"];
        
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
//        NSString *userNm = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
//        NSString *decodeUserNm = [NSString urlDecodeString:userNm];
//
//        NSArray *roomNmArr = [NSArray array];
//        if([nRoomNm rangeOfString:@","].location != NSNotFound){
//            roomNmArr = [nRoomNm componentsSeparatedByString:@","];
//        }
//
//        NSMutableString *resultRoomNm = [NSMutableString string];
//        if(roomNmArr.count>0){
//            for(int i=0; i<roomNmArr.count; i++){
//                NSString *arrUserNm = [roomNmArr objectAtIndex:i];
//                if(![arrUserNm isEqualToString:[NSString stringWithFormat:@"%@", decodeUserNm]]){
//                    [resultRoomNm appendString:[NSString stringWithFormat:@",%@", arrUserNm]];
//                }
//            }
//            resultRoomNm = [[resultRoomNm substringFromIndex:1] mutableCopy];
//        }else {
//            resultRoomNm = [nRoomNm mutableCopy];
//        }
        
        NSString *resultRoomNm = @"";
        if([roomType isEqualToString:@"3"]) resultRoomNm = nRoomNm;
        else resultRoomNm = [MFUtil createChatRoomName:nRoomNm roomType:roomType];
        
        NSString *sqlStr = [appDelegate.dbHelper getUpdateRoomList:myUserNo roomNo:nRoomNo];
        NSMutableArray *roomChatArr = [appDelegate.dbHelper selectMutableArray:sqlStr];
        if(roomChatArr.count==0){
            NSString *sqlString1 = [appDelegate.dbHelper insertChatRooms:nRoomNo roomName:resultRoomNm roomType:roomType];
            
            for (int i=0; i<users.count; i++) {
                NSString *userNo = [[users objectAtIndex:i] objectForKey:@"USER_NO"];
                NSString *userNm = [[users objectAtIndex:i] objectForKey:@"USER_NM"];
                NSString *decodeUserNm = [NSString urlDecodeString:userNm];
                NSString *userMsg = [[users objectAtIndex:i] objectForKey:@"USER_MSG"];
                NSString *decodeUserMsg = [NSString urlDecodeString:userMsg];
                NSString *usrImg = [[users objectAtIndex:i] objectForKey:@"USER_IMG"];
                NSString *decodeUserImg = [NSString urlDecodeString:usrImg];
                NSString *userId = [[users objectAtIndex:i] objectForKey:@"USER_ID"];
                NSString *phoneNo = [[users objectAtIndex:i] objectForKey:@"PHONE_NO"];
                NSString *deptNo = [[users objectAtIndex:i] objectForKey:@"DEPT_NO"];
                NSString *userBgImg = [[users objectAtIndex:i] objectForKey:@"USER_BG_IMG"];
                
                NSString *deptName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DEPT_NM"]];
                NSString *levelName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NM"]];
                NSString *dutyName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NM"]];
                NSString *jobGrpName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"JOB_GRP_NM"]];
                NSString *exCompNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY"]];
                NSString *exCompName = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"EX_COMPANY_NM"]];
                NSString *levelNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"LEVEL_NO"]];
                NSString *dutyNo = [NSString urlDecodeString:[[users objectAtIndex:i] objectForKey:@"DUTY_NO"]];
                NSString *userType = [[users objectAtIndex:i] objectForKey:@"SNS_USER_TYPE"];
                
                NSString *sqlString2 = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:decodeUserNm userImg:decodeUserImg userMsg:decodeUserMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                NSString *sqlString3 = [appDelegate.dbHelper insertChatUsers:nRoomNo userNo:userNo];
                
                [appDelegate.dbHelper crudStatement:sqlString2];
                [appDelegate.dbHelper crudStatement:sqlString3];
                
                //프로필 썸네일 로컬저장
                //            NSString *tmpPath = NSTemporaryDirectory();
                //            UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[decodeUserImg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]]];
                //            NSData *imageData = UIImagePNGRepresentation(thumbImage);
                //            NSString *fileName = [decodeUserImg lastPathComponent];
                //
                //            NSString *thumbImgPath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"mThumb_%@",fileName]];
                //            [imageData writeToFile:thumbImgPath atomically:YES];
            }
            
            [appDelegate.dbHelper crudStatement:sqlString1];
            
        }
        
        self.navigationController.navigationBar.topItem.title = @"";
        
        RightSideViewController *rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightSideViewController"];
        CGRect screen = [[UIScreen mainScreen]bounds];
        CGFloat screenWidth = screen.size.width;
        CGFloat screenHeight = screen.size.height;
        
        rightViewController.view.frame = CGRectMake(rightViewController.view.frame.origin.x, rightViewController.view.frame.origin.y, screenWidth, screenHeight);
        
        if([roomType isEqualToString:@"0"]){
            NotiChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"NotiChatViewController"];
            
            destination.roomName = resultRoomNm;
            destination.roomNo = nRoomNo;
            destination.roomNoti = @"1";
            rightViewController.roomNo = nRoomNo;
            rightViewController.roomNoti = @"1";
            rightViewController.roomName = resultRoomNm;
            rightViewController.roomType = roomType;
            
            LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
            [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
            
            NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:nRoomNo];
            [appDelegate.dbHelper crudStatement:sqlString];
            
            [self.tabBarController.tabBar setHidden:YES];
            [self.navigationController pushViewController:container animated:YES];
            
        } else {
            ChatViewController *destination = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
            
            destination.roomName = resultRoomNm;
            destination.roomNo = nRoomNo;
            destination.roomNoti = @"1";
            rightViewController.roomNo = nRoomNo;
            rightViewController.roomNoti = @"1";
            rightViewController.roomName = resultRoomNm;
            rightViewController.roomType = roomType;
            
            LGSideMenuController *container = [LGSideMenuController sideMenuControllerWithRootViewController:destination leftViewController:nil rightViewController:rightViewController];
            [container setNavigationItemTitle:[NSString urlDecodeString:destination.roomName]];
            
            NSString *sqlString = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:nRoomNo];
            [appDelegate.dbHelper crudStatement:sqlString];
            
            [self.tabBarController.tabBar setHidden:YES];
            [self.navigationController pushViewController:container animated:YES];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_NewChatPush:(NSNotification *)notification {
    NSLog();
    
    @try {
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
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    appDelegate.inactiveChatPushInfo=nil;
}
- (void)noti_CommentEdit:(NSNotification *)notification {
    @try {
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&postNo=%@&readStatus=%@", myUserNo, self._postNo, self._isRead];
        [self callWebService:@"getPostDetail" WithParameter:paramString];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)noti_PostModify:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    if([[userInfo objectForKey:@"TYPE"] isEqualToString:@"COMMENT"]) isComment = YES;
    else isComment = NO;
    
    [self startLoading];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_PostModify" object:nil];
}
- (void)noti_TeamExit:(NSNotification *)notification {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self popoverPresentationController];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamSelectExit" object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_TeamExit" object:nil];
}

- (void)noti_SelectMedia:(NSNotification *)notification {
   NSLog(@"type : %@", notification.object);
   if([notification.object isEqual:@"CAMERA"]){
      [self cameraButtonPressed:self];
   } else if([notification.object isEqual:@"PHOTO"]){
      [self photoButtonPressed:self];
   } else if([notification.object isEqual:@"VIDEO"]){
      [self videoButtonPressed:self];
   } else if([notification.object isEqual:@"FILE"]){
       UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
       
       NSArray *types = [[NSArray alloc] initWithObjects:@"public.data", nil];
       self.attachView.docPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
       self.attachView.docPicker.delegate = self;
       if (@available(iOS 11.0, *)) {
          self.attachView.docPicker.allowsMultipleSelection = NO;
       } else {
          // Fallback on earlier versions
       }
       
       self.attachView.docPicker.modalPresentationStyle = UIModalPresentationFullScreen;
       [top presentViewController:self.attachView.docPicker animated:YES completion:NULL];
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
    
    if(kbSize.height==199) kbSize.height = 257; //아이폰X에서만 키보드 이슈가 생겨서
    
    if ([notification name]==UIKeyboardWillShowNotification) {
        self.keyboardHeight.constant = kbSize.height;
        [self.view layoutIfNeeded];
    }else if([notification name]==UIKeyboardWillHideNotification){
        self.keyboardHeight.constant = 0;
        [self.view layoutIfNeeded];
    }
    [UIView commitAnimations];
}

#pragma mark - NAVIGATION
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"FILE_OPEN_MODAL"]){
        UINavigationController *destination = segue.destinationViewController;
        WebViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.fileUrl = sender;
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
    } else if([segue.identifier isEqualToString:@"POST_MODIFY_MODAL"]){
        UINavigationController *destination = segue.destinationViewController;
        PostModifyTableViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.snsNo = snsNo;
        vc.postNo = self._postNo;
        vc.isEdit = self.isEdit;
        
        if([self.isEdit isEqualToString:@"COMMENT"]){
            NSDictionary *commentDic = sender;
            vc.commDic = commentDic;
            vc.postDic = self.postDetailInfo;
            
        } else if([self.isEdit isEqualToString:@"POST"]){
            //NSLog(@"postDetailInfo : %@", self.postDetailInfo);
            NSDictionary *postDic = sender;
            vc.postDic = postDic;
        }
        
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
    } else if([segue.identifier isEqualToString:@"POST_DETAIL_PHLIB_MODAL"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getImageNotification:) name:@"getImageNotification" object:nil];
        UINavigationController *destination = segue.destinationViewController;
        PHLibListViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.listType = sender;
        vc.fromSegue = @"POST_DETAIL_PHLIB_MODAL";
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
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
        
        if (scrollView.contentSize.height-scrollView.contentOffset.y<self.tableView.frame.size.height) {
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
        [self scrollViewDidEndDragging2:scrollView willDecelerate:NO];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)scrollViewDidEndDragging2:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    @try {
        if(isRefresh) {
            return ;
        }
        
        if(scrollView.contentOffset.y <= -REFRESH_HEADER_DEFAULT_HEIGHT){
            [self startLoading];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)startLoading {
    @try {
        //데이터새로고침
        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&postNo=%@&readStatus=%@&pSize=%d", myUserNo, self._postNo, self._isRead, pSize];
        [self callWebService:@"getPostDetail" WithParameter:paramString];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollOffsetY = scrollView.contentOffset.y;
    
    @try {
        if(isRefresh)
        {
            if(scrollOffsetY > 0) {
                self.tableView.contentInset = UIEdgeInsetsZero;
            } else if(scrollOffsetY >= - REFRESH_HEADER_DEFAULT_HEIGHT) {
                self.tableView.contentInset = UIEdgeInsetsMake(-scrollOffsetY, 0, 0, 0);
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - TTTAttributedLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    NSLog();
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        
    }];
}
-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneNumber]] options:@{} completionHandler:nil];
}

@end
