//
//  ChatViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 4. 21..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatViewController.h"

#import "RightSideViewController.h"
#import "PHLibListViewController.h"
#import "ImgDownloadViewController.h"
#import "LongChatViewController.h"
#import "WebViewController.h"
#import "CustomHeaderViewController.h"
#import "SetMediaDataHandler.h"

#import "ChatSendTextCell.h"
#import "ChatSendImgCell.h"
#import "ChatSendVideoCell.h"
#import "ChatSendFileCell.h"
#import "ChatSendInviteCell.h"
#import "LongChatSendCell.h"

#import "ChatRecvTextCell.h"
#import "ChatRecvImgCell.h"
#import "ChatRecvVideoCell.h"
#import "ChatRecvFileCell.h"
#import "ChatRecvInviteCell.h"
#import "LongChatRecvCell.h"
#import "ChatRecvSysLineCell.h"

#import "HDNotificationView.h"
#import "MFDBHelper.h"
#import "ChatToastView.h"

#define CHAT_LOAD_COUNT 50

@interface ChatViewController() {
   AppDelegate *appDelegate;
   SDImageCache *imgCache;
   ChatConnectSocket *socket;
   
   BOOL isScroll;
   
   float tableBottom;
   int loadMsgCnt;
   int beforeRowCnt;
   int afterRowCnt;
   
   NSUInteger msgDataCnt;
   NSInteger msg_rIdx;
   int missedCnt;
   int tmpMissedCnt;
   
   NSMutableDictionary *snsDict;
   NSString *mediaType;
   NSMutableArray *mediaFileArr;
   NSMutableArray *resultArr;
   
   NSString *chatRoomType;
   NSString *joinSnsName;
   
   SetMediaDataHandler *dh;
   ChatSendVideoCell *sendVideoCell;
   
   BOOL isLoad;
   int pChatSize;
   NSString *stChatSeq;
   
   UIImage *sendImgMsg;
   UIImage *sendVdoMsg;
   UIImage *recvImgMsg;
   
}

@property (strong, nonatomic) AttachViewController *attachView;
@property (strong, nonatomic) ChatToastView *toastView;

@property (strong, nonatomic) ChatMessageData *msgData;
@property (weak, nonatomic) NSString *myUserNo;

@property (strong, nonatomic) NSMutableDictionary *firstAddMsg;
@property (strong, nonatomic) NSMutableDictionary *msgResendDict;

@end

@implementation ChatViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   
   NSLog(@"fromSegue : %@, roomNo : %@", self.fromSegue, self.roomNo);
   appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
   
   NSString *dvcID = [appDelegate.appPrefs objectForKey:@"DVC_ID"];
   NSLog(@"11111 DVCID!!! : %@", dvcID);
   
   dh = [[SetMediaDataHandler alloc] init];
   dh.mode = @"CHAT";
   dh.roomNo = self.roomNo;
   
   stChatSeq = @"1";
   isLoad = YES;
   isScroll = NO;
   pChatSize = 30;
   
   @try{
      socket = [[ChatConnectSocket alloc] init];
      socket.delegate = self;
      [socket connectSocket];
      
      self.tableView.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_Chat:) name:@"noti_Chat" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChatReadPush:) name:@"noti_ChatReadPush" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChatExit:) name:@"noti_ChatExit" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_APNS_ChatReadPush:) name:@"noti_APNS_ChatReadPush" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_applicationDidBecomeActive:) name:@"noti_applicationDidBecomeActive" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_applicationDidEnterBackground:) name:@"noti_applicationDidEnterBackground" object:nil];
   
      isHideKeyboard = YES;
      
      beforeRowCnt=0;
      afterRowCnt=0;
      missedCnt = 0;
      tmpMissedCnt = 0;
      rowCnt = 0;
      loadMsgCnt = 0;
      tableBottom = self.tableView.contentOffset.y;
      mediaType = @"";
      joinSnsName = @"";
      
      self.msgData = [[ChatMessageData alloc] initwithRoomNo:_roomNo];
      self.sendingMsgArr = [[NSMutableArray alloc] init];
      
      _myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
      
      imgCache = [SDImageCache sharedImageCache];
      NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
      NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
      [imgCache makeDiskCachePath:cachePath];
      
      chatRoomType = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getRoomType:self.roomNo]];
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTable:)];
      [self.tableView addGestureRecognizer:tap];
      tap.cancelsTouchesInView = NO;
      
      self.inputToolbar.delegate = self;
      self.inputToolbar.contentView.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
      [self.inputToolbar.contentView.textView setShowsVerticalScrollIndicator:NO];
      self.inputToolbar.contentView.textView.pasteDelegate = self;
      self.inputToolbar.contentView.textView.textContainer.maximumNumberOfLines = 0;
      self.inputToolbar.contentView.textView.layer.borderWidth = 0.5f;
      self.inputToolbar.contentView.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
      self.inputToolbar.contentView.textView.fromSegue = @"CHAT_CONTENT";
      self.inputToolbar.contentView.textView.autocorrectionType = UITextAutocorrectionTypeNo; //자동완성끄기
      
      if([chatRoomType isEqualToString:@"0"]){
         //알림톡
         self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"readonly_chatroom_input_msg", @"readonly_chatroom_input_msg");
         self.inputToolbar.contentView.textView.editable = NO;
         
      } else {
         self.inputToolbar.contentView.textView.placeHolder = nil;
         self.inputToolbar.contentView.textView.editable = YES;
      }
      
      //채팅웹서비스 호출
      [self syncChat];
      
      msgDataCnt = self.msgData.chatArray.count;
      for(int i=0; i<msgDataCnt; i++){
         NSString *pushType = [[self.msgData.chatArray objectAtIndex:i]objectForKey:@"TYPE"];
         
         if([pushType isEqualToString:@"MISSED"]){
            missedCnt++;
         }
      }
      
      //테이블 마지막 셀로 스크롤 이동
      if(msgDataCnt > 0) {
         //UITableViewAutomaticDimension사용하니 아래 주석 실행안됨 임시적용코드, 수정필요
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSInteger row = [self.tableView numberOfRowsInSection:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
            tableBottom = self.tableView.contentOffset.y;
         });
         
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [socket socketCheck:@"CHAT_READ_STATUS" roomNo:self.roomNo message:nil dictionary:nil];
         });
         
      } else {
         [self scrollToBottomAnimated:YES];
      }
      
   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
   for(UIView *subview in [self.view subviews]) {
      if([subview isKindOfClass:[self.toastView class]]) {
         [self.toastView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-self.inputToolbar.frame.size.height-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-60, [UIScreen mainScreen].bounds.size.width, 60)];
         break;
      }
   }
}

-(void)syncChat{
   NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
   NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getChatList"]];
   NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&stSeq=%@&pSize=%d&stDate=%@", _myUserNo, self.roomNo,stChatSeq, pChatSize, [appDelegate.appPrefs objectForKey:@"INSTALL_DATE"]];

   MFURLSession *session = [[MFURLSession alloc] initWithURL:url option:paramString];
   session.delegate = self;
   [session start];
}

- (void)viewWillAppear:(BOOL)animated {
   [super viewWillAppear:animated];
   [self.tabBarController.tabBar setHidden:YES];
   
   [SVProgressHUD dismiss];
   
   appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
   appDelegate.toolBarBtnTitle = NSLocalizedString(@"send", @"send");
   appDelegate.isChatViewing = YES;
   
   isScroll = YES;
   
   self.navigationController.navigationBar.translucent = NO;
   self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
   self.navigationController.navigationBar.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
   
   self.tableView.rowHeight = UITableViewAutomaticDimension;
   self.tableView.estimatedRowHeight = 50;
   
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChatDetailView:) name:@"noti_ChatDetailView" object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SelectMedia:) name:@"noti_SelectMedia" object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
   NSLog();
   [super viewDidAppear:animated];

   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ShareChatUpdate:) name:@"noti_ShareChatUpdate" object:nil];
   
   @try{
      if([self.fromSegue isEqualToString:@"NOTI_CHAT_DETAIL"]){
         NSArray *dataSet = [self.notiChatDic objectForKey:@"DATASET"];
         NSString *snsName = [[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"];
         NSString *decodeRoomName = [NSString urlDecodeString:snsName];
         self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:decodeRoomName];
         self.fromSegue = nil;

      } else if([self.fromSegue isEqualToString:@"BOARD_ADD_USER_MODAL"]){
         NSString *decodeRoomName = [NSString urlDecodeString:_roomName];
         self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:decodeRoomName];
         [self sendInviteMessage];

      } else if([self.fromSegue isEqualToString:@"SHARE_CHAT_MODAL"]){
         //앨범->채팅 공유
         NSString *decodeRoomName = [NSString urlDecodeString:_roomName];
         self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:decodeRoomName];
         
         NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[MFSingleton sharedInstance] shareExtScheme]];
         NSArray *shareArr = [shareDefaults objectForKey:@"SHARE_ITEM"];
         NSLog(@"앨범->채팅 shareArr : %@", shareArr);

         resultArr = [NSMutableArray array];

         for(int i=0; i<shareArr.count; i++){
            NSString *type = [[shareArr objectAtIndex:i] objectForKey:@"TYPE"];
            if([type isEqualToString:@"IMG"]){
               NSData *value = [[shareArr objectAtIndex:i] objectForKey:@"VALUE"];
               UIImage *originImg = [MFUtil getResizeImageRatio:[UIImage imageWithData:value]]; //원본이지만 화질 설정에 맞춘 것.
               originImg = [MFUtil getScaledImage:originImg scaledToMaxWidth:self.view.frame.size.width];
               UIImage *thumbImg = [MFUtil getScaledLowImage:originImg scaledToMaxWidth:180.0f];
               
               NSMutableDictionary *dict = [NSMutableDictionary dictionary];
               [dict setObject:@"IMG" forKey:@"TYPE"];
               [dict setObject:thumbImg forKey:@"THUMB"];
               [dict setObject:originImg forKey:@"ORIGIN"];

               [resultArr addObject:dict];

            } else if([type isEqualToString:@"VIDEO"]){
               NSData *videoData = [[shareArr objectAtIndex:i] objectForKey:@"VIDEO_DATA"];
               NSData *videoThumb = [[shareArr objectAtIndex:i] objectForKey:@"VIDEO_THUMB"];
               UIImage *image = [UIImage imageWithData:videoThumb];
               UIImage *thumbImage = [MFUtil getScaledImage:image scaledToMaxWidth:180];
               
               NSMutableDictionary *dict = [NSMutableDictionary dictionary];
               [dict setObject:@"VIDEO" forKey:@"TYPE"];
               [dict setObject:thumbImage forKey:@"VIDEO_THUMB"];
               [dict setObject:videoData forKey:@"VIDEO_DATA"];
               [dict setObject:image forKey:@"ORIGIN"];
               
               if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                  [dict setObject:@"false" forKey:@"IS_SHARE"];
               }
               
               [resultArr addObject:dict];

            } else if([type isEqualToString:@"FILE"]){

            }
         }

         if(resultArr.count>0) {
            [self addThumbnailImage:resultArr];
         }

      } else if([self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]){
         //채팅/게시판->채팅 공유
         NSArray *shareArr = [NSArray array];
         if([self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]){
            shareArr = [appDelegate.appPrefs objectForKey:@"SHARE_ITEM_FROM_CHAT"];
         } else if([self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]){
            shareArr = [appDelegate.appPrefs objectForKey:@"SHARE_ITEM_FROM_POST"];
         }
         
         NSLog(@"채팅/게시판->채팅 shareArr : %@", shareArr);
         resultArr = [NSMutableArray array];

         for(int i=0; i<shareArr.count; i++){
            NSString *type = [[shareArr objectAtIndex:i] objectForKey:@"TYPE"];
            if([type isEqualToString:@"TEXT"]){
               NSString *content = [[shareArr objectAtIndex:i] objectForKey:@"VALUE"];
               [self sendMessage:content];

            } else if([type isEqualToString:@"IMG"]){
               NSData *value = [[shareArr objectAtIndex:i] objectForKey:@"VALUE"];
               
               UIImage *originImg = [MFUtil getResizeImageRatio:[UIImage imageWithData:value]]; //원본이지만 화질 설정에 맞춘 것.
               UIImage *thumbImg = [MFUtil getScaledLowImage:originImg scaledToMaxWidth:180.0f];

               NSMutableDictionary *dict = [NSMutableDictionary dictionary];
               [dict setObject:@"IMG" forKey:@"TYPE"];
               [dict setObject:thumbImg forKey:@"THUMB"];
               [dict setObject:originImg forKey:@"ORIGIN"];

               if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                  [dict setObject:@"true" forKey:@"IS_SHARE"];
                  [dict setObject:[[shareArr objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
               }
               [resultArr addObject:dict];

            } else if([type isEqualToString:@"VIDEO"]){
               NSData *videoData = [[shareArr objectAtIndex:i] objectForKey:@"VIDEO_DATA"];
               NSData *data = [[shareArr objectAtIndex:i] objectForKey:@"VIDEO_THUMB"];
               
               UIImage *originImg = [MFUtil getResizeImageRatio:[UIImage imageWithData:data]]; //원본이지만 화질 설정에 맞춘 것.
               UIImage *thumbImg = [MFUtil getScaledLowImage:[UIImage imageWithData:data] scaledToMaxWidth:180.0f];

               NSMutableDictionary *dict = [NSMutableDictionary dictionary];
               [dict setObject:@"VIDEO" forKey:@"TYPE"];
               [dict setObject:thumbImg forKey:@"VIDEO_THUMB"];
               [dict setObject:videoData forKey:@"VIDEO_DATA"];
               [dict setObject:originImg forKey:@"ORIGIN"];

               if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                  [dict setObject:@"true" forKey:@"IS_SHARE"];
                  [dict setObject:[[shareArr objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
               }
               [resultArr addObject:dict];

            } else if([type isEqualToString:@"FILE"]){
               NSString *value = [[shareArr objectAtIndex:i] objectForKey:@"VALUE"];
               value = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
               NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:value]];

               NSMutableDictionary *dict = [NSMutableDictionary dictionary];
               [dict setObject:@"FILE" forKey:@"TYPE"];
               [dict setObject:value forKey:@"VALUE"];
               [dict setObject:data forKey:@"FILE_DATA"];
               [dict setObject:[value lastPathComponent] forKey:@"FILE_NM"];

               if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                  [dict setObject:@"true" forKey:@"IS_SHARE"];
               }
               [resultArr addObject:dict];
            }
         }
         
         if(resultArr.count>0) {
            [self addThumbnailImage:resultArr];
         }

      } else {
         NSString *decodeRoomName = [NSString urlDecodeString:_roomName];
         self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:decodeRoomName];
      }

   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}

- (void)viewWillDisappear:(BOOL)animated {
   [super viewWillDisappear:animated];
   
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_SelectMedia" object:nil];
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_ShareChatUpdate" object:nil];
   
   @try{
      if(self.tableView.contentSize.height>self.tableView.frame.size.height){
         //NSLog(@"스크롤 내려야함");
         NSString *sqlString = [appDelegate.dbHelper updateChatRoomScrolled:1 roomNo:self.roomNo];
         [appDelegate.dbHelper crudStatement:sqlString];
         
      } else {
         //NSLog(@"스크롤 없어도돼");
         NSString *sqlString = [appDelegate.dbHelper updateChatRoomScrolled:0 roomNo:self.roomNo];
         [appDelegate.dbHelper crudStatement:sqlString];
      }
      
      self.navigationController.navigationBar.translucent = YES;
      appDelegate.isChatViewing = NO;
      
      if (self.isMovingFromParentViewController || self.isBeingDismissed) {
         appDelegate.currChatRoomNo = nil;
         
         if([self.fromSegue isEqualToString:@"SHARE_CHAT_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]){
            self.fromSegue = @"";
            NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[MFSingleton sharedInstance] shareExtScheme]];
            [shareDefaults removeObjectForKey:@"SHARE_ITEM"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ShareViewClose" object:nil];
         }
      }
      
      //이거쓰면 노티호출이 안되긴한데.. 어쩔땐 두번씩 호출돼서ㅠㅠ
   //   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_Chat" object:nil];
      
      [socket socketClose];
      
   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

- (void)tapOnTable:(UITapGestureRecognizer*)tap{
   @try{
      [self.inputToolbar.contentView.textView resignFirstResponder];
      
      for(UIView *subview in [self.view subviews]) {
         if([subview isKindOfClass:[self.toastView class]]) {
            [self.toastView setFrame:CGRectMake(0, self.inputToolbar.frame.origin.y-60, self.tableView.frame.size.width, 60)];
            break;
         }
      }
      
      [self changeMediaButton:NO];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

#pragma mark - SEND MESSAGE
- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
   @try{
      _mediaButton = sender;
      _mediaButton.contentMode = UIViewContentModeScaleAspectFit;
      _mediaButton.imageEdgeInsets = UIEdgeInsetsMake(13,13,13,13);
      
      if([chatRoomType isEqualToString:@"0"]){
         //알림톡
      } else {
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
            [self changeMediaButton:NO];
         }
         [self.inputToolbar.contentView.textView becomeFirstResponder];
      }

   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}

//메시지 전송버튼 클릭이벤트
- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
   NSString *content = self.inputToolbar.contentView.textView.text;
   [self sendMessage:content];
}

#pragma mark Text Msg
-(void)sendMessage:(NSString *)content{
   @try{
      NSString *trimContent = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      trimContent = [MFUtil replaceEncodeToChar:trimContent];
      
      NSUInteger textByte = [trimContent lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
      
      int count = [self getMissedChatCount];
      
      if(![trimContent isEqualToString:@""] && trimContent != nil){
         NSUInteger msgDataCnt = self.msgData.chatArray.count;
         
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//         [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
         [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
         NSString *date = [dateFormatter stringFromDate:[NSDate date]];
         NSString *dvcID = [appDelegate.appPrefs objectForKey:@"DVC_ID"];
         NSLog(@"DVCID!!! : %@", dvcID);
         
         self.firstAddMsg = [[NSMutableDictionary alloc]init];
         [self.firstAddMsg setObject:self.myUserNo forKey:@"USER_NO"];
         [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];
         [self.firstAddMsg setObject:date forKey:@"DATE"];
         
         if(textByte>1000) {
            NSData *contentData = [trimContent dataUsingEncoding:NSASCIIStringEncoding];
            contentData = [contentData subdataWithRange:NSMakeRange(0, 1000)];
            NSString *prevStr = [[NSString alloc] initWithBytes:[contentData bytes] length:[contentData length] encoding:NSASCIIStringEncoding];
            
            [self.firstAddMsg setObject:@"LONG_TEXT" forKey:@"CONTENT_TY"];
            [self.firstAddMsg setObject:@"" forKey:@"CONTENT"];
            [self.firstAddMsg setObject:prevStr forKey:@"CONTENT_PREV"];
            
         } else {
            [self.firstAddMsg setObject:@"TEXT" forKey:@"CONTENT_TY"];
            [self.firstAddMsg setObject:trimContent forKey:@"CONTENT"];
            [self.firstAddMsg setObject:@"" forKey:@"CONTENT_PREV"];
         }
         
         [self.firstAddMsg setObject:@"" forKey:@"FILE_NM"];
         
         self.editInfoDic = [NSMutableDictionary dictionary];
         NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(msgDataCnt-count) inSection:0];
         [self.editInfoDic setObject:@"SENDING" forKey:@"TYPE"];
         [self.editInfoDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
         [self.editInfoDic setObject:dvcID forKey:@"DEVICE_ID"];
         [self.editInfoDic setObject:@"" forKey:@"LOCAL_CONTENT"];
         
         NSError *error;
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.editInfoDic options:0 error:&error];
         NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         
         [self.firstAddMsg setObject:jsonString forKey:@"ADIT_INFO"];
         
//         NSLog(@"@@@@sendMessage self.firstAddMsg : %@", self.firstAddMsg);
         
         [self addChatTableView];
         self.inputToolbar.contentView.textView.text = nil;
         
         dispatch_async(dispatch_get_main_queue(), ^{
            socket.editInfoDic = self.editInfoDic;
            [socket socketCheck:@"SAVE_CHAT" roomNo:self.roomNo message:trimContent dictionary:nil];
         });
         
         content = nil;
         trimContent = nil;
      }
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (BOOL)textView:(MFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
   return YES;
}
//- (NSString *)fetchStringWithOriginalString:(NSString *)originalString withByteLength:(NSUInteger)length {
//   @try{
//      NSData* originalData=[originalString dataUsingEncoding:NSUTF8StringEncoding];
//      const char *originalBytes = originalData.bytes;
//
//      for (NSUInteger i = length; i > 0; i--) {
//         NSData *data = [NSData dataWithBytes:originalBytes length:i];
//         NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//         if (string) {
//            return string;
//         }
//      }
//
//   } @catch (NSException *exception) {
//      NSLog(@"Exception : %@", exception);
//   }
//
//   return @"";
//}

-(void)textViewDidChange:(MFTextView *)textView{
}
- (void)textViewDidChangeSelection:(MFTextView *)textView {
}
-(BOOL)composerTextView:(MFTextView *)textView shouldPasteWithSender:(id)sender{
   return YES;
}

#pragma mark Invite Msg
-(void)sendInviteMessage{
   snsDict = [NSMutableDictionary dictionary];
   
   NSString *snsNo = @"";
   NSString *snsNm = @"";
   NSString *snsKind = @"";
   NSString *snsTy = @"";
   NSString *snsNeedAllow = @"";
   NSString *snsDesc = @"";
   NSString *snsCoverImg = @"";
   NSString *snsCreateDate = @"";
   NSString *snsCreateUserNo = @"";
   NSString *snsCreateUserNm = @"";
   NSString *snsMemberCount = @"";
   
   @try {
      snsNo = [self.snsInfoDic objectForKey:@"SNS_NO"];
      snsNm = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"SNS_NM"]];
      snsKind = [self.snsInfoDic objectForKey:@"SNS_KIND"];
      snsTy = [self.snsInfoDic objectForKey:@"SNS_TY"];
      snsNeedAllow = [self.snsInfoDic objectForKey:@"NEED_ALLOW"];
      snsDesc = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"SNS_DESC"]];
      snsCoverImg = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"COVER_IMG"]];
      if([snsCoverImg isEqualToString:@"(null)"]) snsCoverImg = @"";
      snsCreateDate = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"CREATE_DATE"]];
      snsCreateUserNo = [self.snsInfoDic objectForKey:@"CREATE_USER_NO"];
      snsCreateUserNm = [NSString urlDecodeString:[self.snsInfoDic objectForKey:@"CREATE_USER_NM"]];
      snsMemberCount = [self.snsInfoDic objectForKey:@"USER_COUNT"];
      
      [snsDict setObject:snsNo forKey:@"SNS_NO"];
      [snsDict setObject:snsNm forKey:@"SNS_NM"];
      [snsDict setObject:snsKind forKey:@"SNS_KIND"];
      [snsDict setObject:snsTy forKey:@"SNS_TY"];
      [snsDict setObject:snsNeedAllow forKey:@"SNS_NEED_ALLOW"];
      [snsDict setObject:snsDesc forKey:@"SNS_DESC"];
      [snsDict setObject:snsCoverImg forKey:@"SNS_COVER_IMG"];
      [snsDict setObject:snsCreateDate forKey:@"SNS_CREATE_DATE"];
      [snsDict setObject:snsCreateUserNo forKey:@"SNS_CREATE_USER_NO"];
      [snsDict setObject:snsCreateUserNm forKey:@"SNS_CREATE_USER_NM"];
      [snsDict setObject:snsMemberCount forKey:@"SNS_MEMBER_COUNT"];
      [snsDict setObject:@"INVITE_SNS" forKey:@"INVITE_TYPE"];
      
      NSError *error;
      NSData *snsJsonData = [NSJSONSerialization dataWithJSONObject:snsDict options:0 error:&error];
      NSString *snsJsonStr = [[NSString alloc] initWithData:snsJsonData encoding:NSUTF8StringEncoding];
      
      int count = [self getMissedChatCount];
      NSUInteger msgDataCnt = self.msgData.chatArray.count;
      
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      NSString *date = [dateFormatter stringFromDate:[NSDate date]];
      NSString *dvcID = [appDelegate.appPrefs objectForKey:@"DVC_ID"];//[MFUtil getUUID];
      
      self.firstAddMsg = [[NSMutableDictionary alloc]init];
      [self.firstAddMsg setObject:self.myUserNo forKey:@"USER_NO"];
      [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];
      [self.firstAddMsg setObject:snsJsonStr forKey:@"CONTENT"];
      [self.firstAddMsg setObject:date forKey:@"DATE"];
      
      [self.firstAddMsg setObject:@"INVITE" forKey:@"CONTENT_TY"];
      [self.firstAddMsg setObject:@"" forKey:@"FILE_NM"];
      
      self.editInfoDic = [NSMutableDictionary dictionary];
      NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(msgDataCnt-count) inSection:0];
      [self.editInfoDic setObject:@"SENDING" forKey:@"TYPE"];
      [self.editInfoDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
      [self.editInfoDic setObject:dvcID forKey:@"DEVICE_ID"];
      [self.editInfoDic setObject:@"" forKey:@"LOCAL_CONTENT"];
      
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.editInfoDic options:0 error:&error];
      NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      
      [self.firstAddMsg setObject:jsonString forKey:@"ADIT_INFO"];
      
      [self addChatTableView];
      self.inputToolbar.contentView.textView.text = nil;
      
      dispatch_async(dispatch_get_main_queue(), ^{
         socket.editInfoDic = self.editInfoDic;
         [socket socketCheck:@"SAVE_CHAT" roomNo:self.roomNo message:nil dictionary:snsDict];
      });
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

#pragma mark Image Msg
-(void)sendImageMessage:(NSArray *)mediaArr isAlbum:(BOOL)isAlbum{
   @try{
      NSMutableArray *mediaImgArr = [NSMutableArray array];
      
      if(isAlbum){
         NSArray *imgList = [[mediaArr objectAtIndex:0] objectForKey:@"IMG_LIST"];
         for(int i=0; i<imgList.count; i++){
            UIImage *originImg = [MFUtil getResizeImageRatio:[imgList objectAtIndex:i]]; //원본이지만 화질 설정에 맞춘 것.
            originImg = [MFUtil getScaledImage:originImg scaledToMaxWidth:self.view.frame.size.width];
//            UIImage *orginImg = [MFUtil getResizeImageRatio:[imgList objectAtIndex:i]];
            UIImage *thumbImg = [MFUtil getScaledLowImage:[imgList objectAtIndex:i] scaledToMaxWidth:180.0f];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"IMG" forKey:@"TYPE"];
            [dict setObject:thumbImg forKey:@"THUMB"];
            [dict setObject:originImg forKey:@"ORIGIN"];
            [mediaImgArr addObject:dict];
         }
         
         [self addThumbnailImage:mediaImgArr];
         
      }
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

#pragma mark Video Msg
-(void)sendVideoMessage:(NSArray *)mediaArr isAlbum:(BOOL)isAlbum{
   @try{
      NSMutableArray *mediaVideoArr = [NSMutableArray array];
      
      if(isAlbum){
         NSArray *assetList = [[mediaArr objectAtIndex:0] objectForKey:@"ASSET_LIST"];
         PHAsset *asset = [assetList objectAtIndex:0];
         
         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         [dict setObject:@"VIDEO" forKey:@"TYPE"];
         [dict setObject:asset forKey:@"VIDEO_VALUE"];
         [mediaVideoArr addObject:dict];
         
      } else {
         NSString *videoPath = [mediaArr objectAtIndex:0];
         AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath] options:nil];
         
         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         [dict setObject:@"VIDEO" forKey:@"TYPE"];
         [dict setObject:asset forKey:@"RECORD_VALUE"];
         [mediaVideoArr addObject:dict];
      }
      
      [self addThumbnailImage:mediaVideoArr];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

#pragma mark File Msg
-(void)sendFileMessage:(NSArray *)mediaArr isAlbum:(BOOL)isAlbum{
   @try{
      NSLog(@"sendFileMsg mediaArr : %@", mediaArr);
      NSMutableArray *mediaVideoArr = [[NSMutableArray alloc] initWithArray:mediaArr];
      [self addThumbnailImage:mediaVideoArr];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

-(void)addThumbnailImage:(NSMutableArray *)array{
   int setCount=0;
   NSLog(@"[ChatView] addThumbnailImage ARRAY : %@", array);
   
   @try{
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//      [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSString *date = [dateFormatter stringFromDate:[NSDate date]];
      NSMutableArray *resultArr = [[NSMutableArray alloc] init];
      
      NSUInteger count = array.count;
      for(int i=0; i<(int)count; i++){
         setCount++;
         NSUInteger msgCnt = self.msgData.chatArray.count;
         int missedCnt = [self getMissedChatCount];
         self.firstAddMsg = [[NSMutableDictionary alloc]init];
         
         NSString *type = [[array objectAtIndex:i] objectForKey:@"TYPE"];
         
         //로컬tmp경로 ADIT_INFO에 추가
         NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
         NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
         
         NSDate *today = [NSDate date];
         NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
         [dateFormat setDateFormat:@"yyyyMMdd"];
         NSString *currentTime = [dateFormat stringFromDate:today];
         
         NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@/", self.roomNo, [MFUtil getFolderName:type], currentTime];
         NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@/thumb/", self.roomNo, [MFUtil getFolderName:type], currentTime];
         
         NSFileManager *fileManager = [NSFileManager defaultManager];
         BOOL issue = [fileManager isReadableFileAtPath:saveThumbPath];
         if (issue) {
            
         }else{
            [fileManager createDirectoryAtPath:saveThumbPath withIntermediateDirectories:YES attributes:nil error:nil];
         }
         
         if([type isEqualToString:@"IMG"]){
            NSString *fileName = [self createFileName:type];
            NSString *originImgPath =[saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
            NSString *imagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
            
            UIImage *orginImg = [[array objectAtIndex:i] objectForKey:@"ORIGIN"];
            NSData *originData = UIImageJPEGRepresentation(orginImg, 1.0);
            
            NSString *orientation;
            if(orginImg.size.width > orginImg.size.height) orientation = @"HORIZONTAL";
            else orientation = @"VERTICAL";
            
            [self.firstAddMsg setObject:_myUserNo forKey:@"USER_NO"];
            [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];
            [self.firstAddMsg setObject:@"" forKey:@"CONTENT"];
            [self.firstAddMsg setObject:date forKey:@"DATE"];
            [self.firstAddMsg setObject:orientation forKey:@"ORIENTATION"];
            [self.firstAddMsg setObject:fileName forKey:@"FILE_NM"];
            [self.firstAddMsg setObject:type forKey:@"CONTENT_TY"];
            
            //썸네일이미지 로컬경로에 저장
            NSData *thumbData = UIImagePNGRepresentation([[array objectAtIndex:i] objectForKey:@"THUMB"]);
            NSString *thumbImgPath =[saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
            [thumbData writeToFile:thumbImgPath atomically:YES];
            [originData writeToFile:originImgPath atomically:YES];
            
            NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
            NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(msgCnt-missedCnt) inSection:0];
            [aditDic setObject:@"SENDING" forKey:@"TYPE"];
            [aditDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
            [aditDic setObject:imagePath forKey:@"LOCAL_CONTENT"];
            [aditDic setObject:type forKey:@"DATA_TYPE"];
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:&error];
            NSString *infoStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [self.firstAddMsg setObject:infoStr forKey:@"ADIT_INFO"];
            
            [self addChatTableView];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:type forKey:@"TYPE"];
            [dict setObject:[[array objectAtIndex:i] objectForKey:@"THUMB"] forKey:@"THUMB"];
            [dict setObject:orginImg forKey:@"ORIGIN"];
            [dict setObject:infoStr forKey:@"ADIT_INFO"];
            [dict setObject:fileName forKey:@"FILE_NM"];
            if([[array objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil&&[[[array objectAtIndex:i] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
               [dict setObject:[[array objectAtIndex:i] objectForKey:@"IS_SHARE"] forKey:@"IS_SHARE"];
               [dict setObject:[[array objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
            }
            [resultArr addObject:dict];
            
            if(setCount==count){
               dh.delegate = self;
               [dh convertChatDataSet:resultArr];
            }
            
         } else if([type isEqualToString:@"VIDEO"]){
            if([[array objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
               UIImage *thumb = [[array objectAtIndex:i] objectForKey:@"VIDEO_THUMB"];
               NSString *fileName = [self createFileName:@"VIDEO_THUMB"];
               
               NSString *orientation;
               if(thumb.size.width > thumb.size.height) orientation = @"HORIZONTAL";
               else orientation = @"VERTICAL";
               
               //썸네일이미지 로컬경로에 저장
               NSData *thumbData = UIImagePNGRepresentation(thumb);
               NSString *thumbImgPath =[saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
               NSLog(@"thumbImgPath : %@", thumbImgPath);
               [thumbData writeToFile:thumbImgPath atomically:YES];
               
               [self.firstAddMsg setObject:_myUserNo forKey:@"USER_NO"];
               [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];
               [self.firstAddMsg setObject:@"" forKey:@"CONTENT"];
               [self.firstAddMsg setObject:date forKey:@"DATE"];
               [self.firstAddMsg setObject:orientation forKey:@"ORIENTATION"];
               [self.firstAddMsg setObject:fileName forKey:@"FILE_NM"];
               [self.firstAddMsg setObject:@"VIDEO" forKey:@"CONTENT_TY"];
               
               NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
               NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(msgCnt-missedCnt) inSection:0];
               [aditDic setObject:@"SENDING" forKey:@"TYPE"];
               [aditDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
               [aditDic setObject:thumbImgPath forKey:@"LOCAL_CONTENT"];
               [aditDic setObject:type forKey:@"DATA_TYPE"];
               
               NSError *error;
               NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:&error];
               NSString *infoStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
               [self.firstAddMsg setObject:infoStr forKey:@"ADIT_INFO"];
               
               [self addChatTableView];
               
               NSRange range2 = [fileName rangeOfString:@"." options:NSBackwardsSearch];
               NSString *videoName = [NSString stringWithFormat:@"%@.mp4",[fileName substringToIndex:range2.location]];
               
               NSMutableDictionary *thumbDict = [NSMutableDictionary dictionary];
               [thumbDict setObject:@"VIDEO_THUMB" forKey:@"TYPE"];
               [thumbDict setObject:thumb forKey:@"ORIGIN"]; //UIImage
               [thumbDict setObject:fileName forKey:@"FILE_NM"];
               [resultArr addObject:thumbDict];
               
               NSMutableDictionary *dict = [NSMutableDictionary dictionary];
               [dict setObject:type forKey:@"TYPE"];
               [dict setObject:infoStr forKey:@"ADIT_INFO"];
               [dict setObject:videoName forKey:@"FILE_NM"];
               
               if([[[array objectAtIndex:i] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
                  [dict setObject:[[array objectAtIndex:i] objectForKey:@"IS_SHARE"] forKey:@"IS_SHARE"];
                  [dict setObject:[[array objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
                  
               } else {
                  [dict setObject:[[array objectAtIndex:i] objectForKey:@"IS_SHARE"] forKey:@"IS_SHARE"];
                  [dict setObject:[[array objectAtIndex:i] objectForKey:@"VIDEO_DATA"] forKey:@"ORIGIN"];
               }
               
               [resultArr addObject:dict];
               
               if(setCount==count){
                  dh.delegate = self;
                  [dh convertChatDataSet:resultArr];
               }
               
            } else {
               if([[array objectAtIndex:i] objectForKey:@"VIDEO_VALUE"]!=nil){
                  PHAsset *value = [[array objectAtIndex:i] objectForKey:@"VIDEO_VALUE"]; //or RECORD_VALUE
                  
                  PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                  options.version = PHVideoRequestOptionsVersionOriginal;
                  options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                  options.networkAccessAllowed = YES;
                  
                  //동영상 변환
                  [[PHImageManager defaultManager] requestAVAssetForVideo:value options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                        [self makeThumbImgFromVideo:(AVURLAsset *)avAsset completion:^(UIImage *thumb) {
                           thumb = [MFUtil getResizeImageRatio:thumb];
                           NSString *fileName = [self createFileName:@"VIDEO_THUMB"];
                           
                           NSString *orientation;
                           if(thumb.size.width > thumb.size.height) orientation = @"HORIZONTAL";
                           else orientation = @"VERTICAL";
                           
                           //썸네일이미지 로컬경로에 저장
                           NSData *thumbData = UIImagePNGRepresentation([MFUtil getScaledLowImage:thumb scaledToMaxWidth:180.0f]);
                           NSString *thumbImgPath =[saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
                           NSLog(@"thumbImgPath : %@", thumbImgPath);
                           [thumbData writeToFile:thumbImgPath atomically:YES];
                           
                           [self.firstAddMsg setObject:_myUserNo forKey:@"USER_NO"];
                           [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];
                           [self.firstAddMsg setObject:@"" forKey:@"CONTENT"];
                           [self.firstAddMsg setObject:date forKey:@"DATE"];
                           [self.firstAddMsg setObject:orientation forKey:@"ORIENTATION"];
                           [self.firstAddMsg setObject:fileName forKey:@"FILE_NM"];
                           [self.firstAddMsg setObject:@"VIDEO" forKey:@"CONTENT_TY"];
                           
                           NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
                           NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(msgCnt-missedCnt) inSection:0];
                           [aditDic setObject:@"SENDING" forKey:@"TYPE"];
                           [aditDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
                           [aditDic setObject:thumbImgPath forKey:@"LOCAL_CONTENT"];
                           [aditDic setObject:type forKey:@"DATA_TYPE"];
                           
                           NSError *error;
                           NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:&error];
                           NSString *infoStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                           
                           [self.firstAddMsg setObject:infoStr forKey:@"ADIT_INFO"];
                           
                           [self addChatTableView];
                           
                           NSRange range2 = [fileName rangeOfString:@"." options:NSBackwardsSearch];
                           NSString *videoName = [NSString stringWithFormat:@"%@.mp4",[fileName substringToIndex:range2.location]];
                           
                           NSMutableDictionary *thumbDict = [NSMutableDictionary dictionary];
                           [thumbDict setObject:@"VIDEO_THUMB" forKey:@"TYPE"];
                           [thumbDict setObject:thumb forKey:@"ORIGIN"]; //UIImage
                           [thumbDict setObject:fileName forKey:@"FILE_NM"];
                           [resultArr addObject:thumbDict];
                           
                           NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                           [dict setObject:type forKey:@"TYPE"];
                           [dict setObject:avAsset forKey:@"VIDEO_VALUE"];
                           [dict setObject:infoStr forKey:@"ADIT_INFO"];
                           [dict setObject:videoName forKey:@"FILE_NM"];
                           [resultArr addObject:dict];
                           
                           if(setCount==count){
                              dh.delegate = self;
                              [dh convertChatDataSet:resultArr];
                           }
                        }];
                     });
                  }];
                  
               } else if([[array objectAtIndex:i] objectForKey:@"RECORD_VALUE"]!=nil){
                  AVURLAsset *avAsset = [[array objectAtIndex:i] objectForKey:@"RECORD_VALUE"];
                  
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ //선등록 시 처리가 빨라 스크롤이 안내려가서 0.2초 딜레이 줌.
                     [self makeThumbImgFromVideo:avAsset completion:^(UIImage *thumb) {
                        thumb = [MFUtil getResizeImageRatio:thumb];
                        NSString *fileName = [self createFileName:@"VIDEO_THUMB"];
                        
                        NSString *orientation;
                        if(thumb.size.width > thumb.size.height) orientation = @"HORIZONTAL";
                        else orientation = @"VERTICAL";
                        
                        //썸네일이미지 로컬경로에 저장
                        NSData *thumbData = UIImagePNGRepresentation([MFUtil getScaledLowImage:thumb scaledToMaxWidth:180.0f]);
                        NSString *thumbImgPath =[saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
                        NSLog(@"thumbImgPath : %@", thumbImgPath);
                        [thumbData writeToFile:thumbImgPath atomically:YES];
                        
                        [self.firstAddMsg setObject:_myUserNo forKey:@"USER_NO"];
                        [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];
                        [self.firstAddMsg setObject:@"" forKey:@"CONTENT"];
                        [self.firstAddMsg setObject:date forKey:@"DATE"];
                        [self.firstAddMsg setObject:orientation forKey:@"ORIENTATION"];
                        [self.firstAddMsg setObject:fileName forKey:@"FILE_NM"];
                        [self.firstAddMsg setObject:@"VIDEO" forKey:@"CONTENT_TY"];
                        
                        NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
                        NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(msgCnt-missedCnt) inSection:0];
                        [aditDic setObject:@"SENDING" forKey:@"TYPE"];
                        [aditDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
                        [aditDic setObject:thumbImgPath forKey:@"LOCAL_CONTENT"];
                        [aditDic setObject:type forKey:@"DATA_TYPE"];
                        
                        NSError *error;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:&error];
                        NSString *infoStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        [self.firstAddMsg setObject:infoStr forKey:@"ADIT_INFO"];
                        
                        [self addChatTableView];
                        
                        NSRange range2 = [fileName rangeOfString:@"." options:NSBackwardsSearch];
                        NSString *videoName = [NSString stringWithFormat:@"%@.mp4",[fileName substringToIndex:range2.location]];
                        
                        NSMutableDictionary *thumbDict = [NSMutableDictionary dictionary];
                        [thumbDict setObject:@"VIDEO_THUMB" forKey:@"TYPE"];
                        [thumbDict setObject:thumb forKey:@"ORIGIN"]; //UIImage
                        [thumbDict setObject:fileName forKey:@"FILE_NM"];
                        [resultArr addObject:thumbDict];
                        
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [dict setObject:type forKey:@"TYPE"];
                        [dict setObject:avAsset forKey:@"RECORD_VALUE"];
                        [dict setObject:infoStr forKey:@"ADIT_INFO"];
                        [dict setObject:videoName forKey:@"FILE_NM"];
                        [resultArr addObject:dict];
                        
                        if(setCount==count){
                           dh.delegate = self;
                           [dh convertChatDataSet:resultArr];
                        }
                     }];
                  });
               }
            }
            
         } else if([type isEqualToString:@"FILE"]){
            NSString *fileName = [[array objectAtIndex:i] objectForKey:@"FILE_NM"];
            
            [self.firstAddMsg setObject:_myUserNo forKey:@"USER_NO"];
            [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];
            [self.firstAddMsg setObject:[[array objectAtIndex:i] objectForKey:@"VALUE"] forKey:@"CONTENT"];
            [self.firstAddMsg setObject:date forKey:@"DATE"];
            [self.firstAddMsg setObject:fileName forKey:@"FILE_NM"];
            [self.firstAddMsg setObject:type forKey:@"CONTENT_TY"];
            
            NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
            NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(msgCnt-missedCnt) inSection:0];
            [aditDic setObject:@"SENDING" forKey:@"TYPE"];
            [aditDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
            [aditDic setObject:@"" forKey:@"LOCAL_CONTENT"];
            [aditDic setObject:type forKey:@"DATA_TYPE"];
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:&error];
            NSString *infoStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [self.firstAddMsg setObject:infoStr forKey:@"ADIT_INFO"];
            
            [self addChatTableView];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:type forKey:@"TYPE"];
            [dict setObject:infoStr forKey:@"ADIT_INFO"];
            [dict setObject:fileName forKey:@"FILE_NM"];
            [dict setObject:[[array objectAtIndex:i] objectForKey:@"FILE_DATA"] forKey:@"FILE_DATA"];
            if([[array objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil&&[[[array objectAtIndex:i] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
               [dict setObject:[[array objectAtIndex:i] objectForKey:@"IS_SHARE"] forKey:@"IS_SHARE"];
               [dict setObject:[[array objectAtIndex:i] objectForKey:@"VALUE"] forKey:@"URL"];
            }
            [resultArr addObject:dict];
            
            if(setCount==count){
               dh.delegate = self;
               [dh convertChatDataSet:resultArr]; //재전송할때 인덱스가 +1 되어버림.
            }
         }
      }
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

-(void)makeThumbImgFromVideo:(AVURLAsset *)asset completion:(void (^)(UIImage *))completion{
   @try{
      AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
      imageGenerator.appliesPreferredTrackTransform = YES;
      CMTime time = CMTimeMake(1, 1);
      CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
      UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
      CGImageRelease(imageRef);
      
      completion(thumbnail);
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

#pragma mark - RECEIVE MESSAGE
-(void)addChatTableView{
   @try{
      int count = [self getMissedChatCount];
      NSUInteger msgDataCnt = self.msgData.chatArray.count;
      
      [self.sendingMsgArr addObject:self.firstAddMsg];
      NSLog(@"send msg !!!!! : %@", self.sendingMsgArr);
      
//      NSLog(@"인덱스 : %lu",msgDataCnt-count);
      if(msgDataCnt > 0){
         //메시지가 있는 채팅방일 경우
         [self.msgData.chatArray insertObject:self.firstAddMsg atIndex:msgDataCnt-count];
         
         NSLog(@"갱신이 안되니..");
         
         NSIndexPath *lastCell = [NSIndexPath indexPathForItem:msgDataCnt-count inSection:0];
         [self.tableView beginUpdates];
         [self.tableView insertRowsAtIndexPaths:@[lastCell] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView endUpdates];
         [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:YES];
         
      } else {
         //메시지가 없는 새로운 채팅방일 경우
         [self.msgData.chatArray addObject:self.firstAddMsg];
         
         dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            NSIndexPath *lastCell = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:YES];
         });
      }
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}
   
-(void)receiveMyChatPush:(NSDictionary *)pushDict{
   @try{
      NSUInteger msgDataCnt = self.msgData.chatArray.count;
         
      NSArray *dataSet = [pushDict objectForKey:@"DATASET"];
      NSDictionary *aditInfoDic = [[dataSet objectAtIndex:0] objectForKey:@"ADITINFO"];
      NSString *chatNo = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"];
      NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
      NSString *pushType = [pushDict objectForKey:@"TYPE"];
      NSString *content = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
      NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
      NSString *chatDate = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CHAT_DATE"]];
      NSString *fileThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FILE_THUMB"]];
      NSString *fileName = [fileThumb lastPathComponent];
      NSString *profileImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG"]];
      NSString *userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
      NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
      NSString *unRead = [[dataSet objectAtIndex:0] objectForKey:@"UNREAD_COUNT"];

      if([contentType isEqualToString:@"INVITE"]){
         content = [NSString urlDecodeString:content];
      }

      NSString *tmpLocal = [aditInfoDic objectForKey:@"LOCAL_CONTENT"];
      NSInteger tmpIdx = [[aditInfoDic objectForKey:@"TMP_IDX"] intValue];

      NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc]init];
      [userInfoDic setObject:[[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"] forKey:@"CHAT_NO"];
      [userInfoDic setObject:contentType forKey:@"CONTENT_TY"];
      [userInfoDic setObject:chatDate forKey:@"DATE"];
      [userInfoDic setObject:roomNo forKey:@"ROOM_NO"];
      [userInfoDic setObject:pushType forKey:@"TYPE"];
      [userInfoDic setObject:userName forKey:@"USER_NM"];
      [userInfoDic setObject:userNo forKey:@"USER_NO"];
      [userInfoDic setObject:unRead forKey:@"UNREAD_COUNT"];

      if([fileName isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"FILE_NM"];
      else [userInfoDic setObject:fileName forKey:@"FILE_NM"];

      if([fileThumb isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"FILE_THUMB"];
      else [userInfoDic setObject:fileThumb forKey:@"FILE_THUMB"];

      if([profileImg isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"USER_IMG"];
      else [userInfoDic setObject:profileImg forKey:@"USER_IMG"];

      //해당 채팅방 보고있는 경우
      if([[NSString stringWithFormat:@"%@", roomNo] isEqualToString:[NSString stringWithFormat:@"%@", self.roomNo]]){
         [HDNotificationView hideNotificationView];
         
         if([contentType isEqualToString:@"LONG_TEXT"]){
            [userInfoDic setObject:@"" forKey:@"CONTENT"];
            [userInfoDic setObject:content forKey:@"CONTENT_PREV"];
         } else {
            [userInfoDic setObject:content forKey:@"CONTENT"];
            [userInfoDic setObject:@"" forKey:@"CONTENT_PREV"];
         }
         
         content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
         
         //선등록메시지(SENDING) 교체(SUCCEED)
         NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
         [tmpDic setValue:[NSNumber numberWithInteger:tmpIdx] forKey:@"TMP_IDX"];
         [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
         [tmpDic setValue:tmpLocal forKey:@"LOCAL_CONTENT"];
         
         NSError *error;
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
         NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         
         [userInfoDic setObject:jsonString forKey:@"ADIT_INFO"];
//         NSLog(@"userInfoDic : %@", userInfoDic);
         
         NSDictionary *msgEditDic = [NSDictionary dictionary];
         int sendingArrIdx=0;
         //RMQ푸시받아서 선등록한 메시지 교체
         if(msgDataCnt > 0){
            //이미 선등록된 데이터(sendingMsgArr)의 tmp_idx를 찾아서 그 tmp_idx와 sendingMsgArr에서의 인덱스를 저장해두었다가 푸시 처리 완료 시 sendingMsgArr에서 저장된 인덱스로 데이터 삭제
            NSLog(@"self.sendingMsgArr : %@", self.sendingMsgArr);
            for(int i=0; i<self.sendingMsgArr.count; i++){
               NSString *editInfo = [[self.sendingMsgArr objectAtIndex:i] objectForKey:@"ADIT_INFO"]; //메시지 데이터는 ADIT_INFO, 푸시 받은건 ADITINFO
               NSData *jsonData = [editInfo dataUsingEncoding:NSUTF8StringEncoding];
               NSDictionary *editDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

               NSString *editIdx = [editDic objectForKey:@"TMP_IDX"];
               //sendingMsgArr의 TMP_IDX와 푸시받은 데이터의 TMP_IDX가 같은지 비교
               if(tmpIdx == [editIdx integerValue]){
                  //같으면 전체Array에서 TMP_IDX번째 데이터를 저장
                  msgEditDic = [self.sendingMsgArr objectAtIndex:i];
                  sendingArrIdx = i;
//                  [self.sendingMsgArr removeObjectAtIndex:i];
               }
            }
            
            //전체Array의 TMP_IDX번째 데이터
            NSString *msgEditInfo = [msgEditDic objectForKey:@"ADIT_INFO"];
            if(msgEditInfo!=nil){
               NSData *msgJsonData = [msgEditInfo dataUsingEncoding:NSUTF8StringEncoding];
               NSDictionary *msgEditDic2 = [NSJSONSerialization JSONObjectWithData:msgJsonData options:0 error:&error];
               NSString *msgEditIdx = [msgEditDic2 objectForKey:@"TMP_IDX"];
               
               //푸시 TMP_IDX와 전체Array의 TMP_IDX번째 데이터의 TMP_IDX가 같은지 비교
               if(tmpIdx == [msgEditIdx integerValue]) {
                  NSString *logUserNo = [[self.msgData.chatArray objectAtIndex:[msgEditIdx integerValue]] objectForKey:@"USER_NO"];
                  
                  //전체Array의 TMP_IDX번째 데이터의 userNo, 내 userNo가 같은지 비교
                  if([[NSString stringWithFormat:@"%@", logUserNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
                     [self.msgData.chatArray replaceObjectAtIndex:[msgEditIdx integerValue] withObject:userInfoDic];
//                     NSLog(@"바꾼데이터 : %@", [self.msgData.chatArray objectAtIndex:[msgEditIdx integerValue]]);
                     
                     NSIndexPath *reloadCell = [NSIndexPath indexPathForItem:[msgEditIdx integerValue] inSection:0];
                     [self.tableView beginUpdates];
                     [self.tableView reloadRowsAtIndexPaths:@[reloadCell] withRowAnimation:UITableViewRowAnimationNone];
                     [self.tableView endUpdates];
                     
                     NSLog(@"4-1.테이블 갱신");
                     [self scrollToBottomAnimated:YES]; //채팅 빨리 보냈을 때 위로 올라가는게 완화됨
                     
                  } else {
                     for(int i=(int)msgDataCnt-1; i>=0; i--){
                        NSString *msgEditInfo = [[self.msgData.chatArray objectAtIndex:i] objectForKey:@"ADIT_INFO"];
                        NSData *msgJsonData = [msgEditInfo dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *msgEditDic = [NSJSONSerialization JSONObjectWithData:msgJsonData options:0 error:&error];
                        NSString *msgEditTy = [msgEditDic objectForKey:@"TYPE"];
                        NSString *msgTmpIdx = [msgEditDic objectForKey:@"TMP_IDX"];
                        
                        //전체 Array 역순으로 돌면서 SENDING이고 푸시 TMP_IDX와 전체Array의 TMP_IDX가 같은것을 찾음
                        
//                        if([msgEditTy isEqualToString:@"SENDING"] && tmpIdx == [msgTmpIdx integerValue]){ //sendType에 \^P 이런기호가 포함될때가 있어서 수정
                        if([msgEditTy rangeOfString:@"SENDING"].location!=NSNotFound && tmpIdx == [msgTmpIdx integerValue]){
                           NSString *logUserNo = [[self.msgData.chatArray objectAtIndex:i] objectForKey:@"USER_NO"];
                           
                           //찾은 Array의 userNo, 내 userNo가 같은지 비교
                           if([[NSString stringWithFormat:@"%@", logUserNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
                              [self.msgData.chatArray replaceObjectAtIndex:i withObject:userInfoDic];
                              
                              NSIndexPath *reloadCell = [NSIndexPath indexPathForItem:i inSection:0];
                              [self.tableView beginUpdates];
                              [self.tableView reloadRowsAtIndexPaths:@[reloadCell] withRowAnimation:UITableViewRowAnimationNone];
                              [self.tableView endUpdates];
                              NSLog(@"4-2.테이블 갱신(전체)");
                              [self scrollToBottomAnimated:YES];
                           }
                           break;
                        }
                     }
                  }
                  
               } else {
                  //푸시 TMP_IDX와 전체Array의 TMP_IDX번째 데이터의 TMP_IDX가 다르면
                  for(int i=(int)msgDataCnt-1; i>=0; i--){
                     NSString *msgEditInfo = [[self.msgData.chatArray objectAtIndex:i] objectForKey:@"ADIT_INFO"];
                     NSData *msgJsonData = [msgEditInfo dataUsingEncoding:NSUTF8StringEncoding];
                     NSDictionary *msgEditDic = [NSJSONSerialization JSONObjectWithData:msgJsonData options:0 error:&error];
                     NSString *msgEditTy = [msgEditDic objectForKey:@"TYPE"];
                     NSString *msgTmpIdx = [msgEditDic objectForKey:@"TMP_IDX"];
                     
                     //전체 Array 역순으로 돌면서 SENDING이고 푸시 TMP_IDX와 전체Array의 TMP_IDX가 같은것을 찾음
//                     if([msgEditTy isEqualToString:@"SENDING"] && tmpIdx == [msgTmpIdx integerValue]){ //sendType에 \^P 이런기호가 포함될때가 있어서 수정
                     if([msgEditTy rangeOfString:@"SENDING"].location!=NSNotFound && tmpIdx == [msgTmpIdx integerValue]){
                        NSString *logUserNo = [[self.msgData.chatArray objectAtIndex:i] objectForKey:@"USER_NO"];
                        
                        //찾은 Array의 userNo, 내 userNo가 같은지 비교
                        if([[NSString stringWithFormat:@"%@", logUserNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
                           [self.msgData.chatArray replaceObjectAtIndex:i withObject:userInfoDic];
                           
                           NSIndexPath *reloadCell = [NSIndexPath indexPathForItem:i inSection:0];
                           [self.tableView beginUpdates];
                           [self.tableView reloadRowsAtIndexPaths:@[reloadCell] withRowAnimation:UITableViewRowAnimationNone];
                           [self.tableView endUpdates];
                           NSLog(@"4-3.테이블 갱신(전체)");
                           [self scrollToBottomAnimated:YES];
                        }
                        break;
                     }
                  }
               }
               [self.sendingMsgArr removeObjectAtIndex:sendingArrIdx];
               NSLog(@"========================================================");
            }
            
         } else {
            //msgDataCnt가 없을때
            [self.msgData.chatArray addObject:userInfoDic];
         }
         
         if(appDelegate.isChatViewing) {
             [socket socketCheck:@"CHAT_READ_STATUS" roomNo:self.roomNo message:nil dictionary:nil];
         }
      }
  
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

-(void)receiveYourChatPush:(NSDictionary *)pushDict{
   @try{
      NSUInteger msgDataCnt = self.msgData.chatArray.count;
      int count = [self getMissedChatCount];
      
      NSArray *dataSet = [pushDict objectForKey:@"DATASET"];
      NSDictionary *aditInfoDic = [[dataSet objectAtIndex:0] objectForKey:@"ADITINFO"];
      NSString *chatNo = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"];
      NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
      NSString *pushType = [pushDict objectForKey:@"TYPE"];
      NSString *content = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
      NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
      NSString *chatDate = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CHAT_DATE"]];
      NSString *fileThumb = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"FILE_THUMB"]];
      NSString *fileName = [fileThumb lastPathComponent];
      NSString *profileImg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_IMG"]];
      NSString *userName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"USER_NM"]];
      NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
      NSString *unRead = [[dataSet objectAtIndex:0] objectForKey:@"UNREAD_COUNT"];

      //if([contentType isEqualToString:@"INVITE"]){
         content = [NSString urlDecodeString:content];
      //}
      
      NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc]init];
      [userInfoDic setObject:[[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"] forKey:@"CHAT_NO"];
      [userInfoDic setObject:contentType forKey:@"CONTENT_TY"];
      [userInfoDic setObject:chatDate forKey:@"DATE"];
      [userInfoDic setObject:roomNo forKey:@"ROOM_NO"];
      [userInfoDic setObject:pushType forKey:@"TYPE"];
      [userInfoDic setObject:userName forKey:@"USER_NM"];
      [userInfoDic setObject:userNo forKey:@"USER_NO"];
      [userInfoDic setObject:unRead forKey:@"UNREAD_COUNT"];
      
      if([fileName isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"FILE_NM"];
      else [userInfoDic setObject:fileName forKey:@"FILE_NM"];
      
      if([fileThumb isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"FILE_THUMB"];
      else [userInfoDic setObject:fileThumb forKey:@"FILE_THUMB"];
      
      if([profileImg isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"USER_IMG"];
      else [userInfoDic setObject:profileImg forKey:@"USER_IMG"];
      
      //해당 채팅방 보고있는 경우
      if([[NSString stringWithFormat:@"%@", roomNo] isEqualToString:[NSString stringWithFormat:@"%@", self.roomNo]]){
         [HDNotificationView hideNotificationView];
         
         if(![contentType isEqualToString:@"SYS"]){
            if([contentType isEqualToString:@"LONG_TEXT"]){
               [userInfoDic setObject:@"" forKey:@"CONTENT"];
               [userInfoDic setObject:content forKey:@"CONTENT_PREV"];
            } else {
               [userInfoDic setObject:content forKey:@"CONTENT"];
               [userInfoDic setObject:@"" forKey:@"CONTENT_PREV"];
            }
            
            if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
               NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:0 roomNo:roomNo];
               [appDelegate.dbHelper crudStatement:sqlString2];
            }
         } else {
            NSString *sender = [NSString urlDecodeString:[aditInfoDic objectForKey:@"SENDER"]];
            NSString *sysMsgType = [aditInfoDic objectForKey:@"SYS_MSG_TY"];
            
            if([sysMsgType isEqualToString:@"ADD_USER"]){
               NSString *addSysMsg = [NSString stringWithFormat:NSLocalizedString(@"add_chat_user", @"add_chat_user"), sender, content];
               if([addSysMsg rangeOfString:@","].location != NSNotFound){
                  addSysMsg = [addSysMsg stringByReplacingOccurrencesOfString:@"," withString:NSLocalizedString(@"add_chat_user_conj", @"add_chat_user_conj")];
               }
               content = [[NSMutableString alloc]initWithString:addSysMsg];
            } else {
               //DELETE_USER
               NSString *deleteSysMsg = [NSString stringWithFormat:NSLocalizedString(@"delete_chat_user", @"delete_chat_user"), content];
               content = [[NSMutableString alloc]initWithString:deleteSysMsg];
            }
            [userInfoDic setObject:content forKey:@"CONTENT"];
         }
         
         content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
         NSLog(@"2.받은메시지 DB저장 : %@ / %@", content, chatDate);
         
         NSError *error;
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditInfoDic options:0 error:&error];
         NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         [userInfoDic setObject:jsonString forKey:@"ADIT_INFO"];
         
         [self.msgData.chatArray insertObject:userInfoDic atIndex:msgDataCnt-(count+self.sendingMsgArr.count)];
         
         NSLog(@"3.받은메시지 데이터 추가 (%lu) : %@ ", msgDataCnt-(count+self.sendingMsgArr.count), userInfoDic);
         NSIndexPath *lastCell = [NSIndexPath indexPathForItem:msgDataCnt inSection:0];
         [self.tableView beginUpdates];
         [self.tableView insertRowsAtIndexPaths:@[lastCell] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView endUpdates];
         
         NSLog(@"4.받은메시지 테이블 갱신");
         NSLog(@"========================================================");

         //받은메시지 등록될 때 읽음처리
         if(appDelegate.isChatViewing) {
            [socket socketCheck:@"CHAT_READ_STATUS" roomNo:self.roomNo message:nil dictionary:nil];
         }
         
         CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath:lastCell];
         CGRect rectOfCellInSuperview = [self.tableView convertRect: rectOfCellInTableView toView: self.tableView.superview];
         
         int rectSuperview = rectOfCellInSuperview.origin.y;
         int toolbarY = self.inputToolbar.frame.origin.y;
         
         if(rectSuperview > toolbarY){
            //채팅 토스트
//            NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ChatToastView" owner:self options:nil];
//            self.toastView = [subviewArray objectAtIndex:0];
//            [self.toastView setFrame:CGRectMake(0, self.inputToolbar.frame.origin.y-60, self.tableView.frame.size.width, 60)];
//
//            UIImage *image = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
//
//            self.toastView.imgView.image = image; //[UIImage imageNamed:@"profile_default.png"];
//            if([contentType isEqualToString:@"TEXT"]||[contentType isEqualToString:@"LONG_TEXT"]){
//               self.toastView.contentLabel.text = content;
//            } else if([contentType isEqualToString:@"IMG"]){
//               self.toastView.contentLabel.text = NSLocalizedString(@"chat_receive_image", @"chat_receive_image");
//
//            } else if([contentType isEqualToString:@"VIDEO"]){
//               self.toastView.contentLabel.text = NSLocalizedString(@"chat_receive_video", @"chat_receive_video");
//
//            }  else if([contentType isEqualToString:@"FILE"]){
//               self.toastView.contentLabel.text = NSLocalizedString(@"chat_receive_file", @"chat_receive_file");
//
//            } else if([contentType isEqualToString:@"INVITE"]){
//               self.toastView.contentLabel.text = NSLocalizedString(@"chat_receive_invite", @"chat_receive_invite");
//            } else {
//               self.toastView.contentLabel.text = content;
//            }
//
//            self.toastView.userLabel.text = userName;
//
//            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnToastView:)];
//            [self.toastView addGestureRecognizer:tap];
//            [self.toastView setUserInteractionEnabled:YES];
//
//            for(UIView *subview in [self.view subviews]) {
//               if([subview isKindOfClass:[self.toastView class]]) {
//                  [subview removeFromSuperview];
//               }
//            }
//            [self.view addSubview:self.toastView];
         
         } else {
            NSIndexPath *lastCell2 = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:0]-1) inSection:0];
            [self.tableView scrollToRowAtIndexPath:lastCell2 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
         }
      }
      
      if([self.fromSegue isEqualToString:@"SHARE_CHAT_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_CHAT_MODAL"]||[self.fromSegue isEqualToString:@"SHARE_FROM_POST_MODAL"]){
         [self dismissViewControllerAnimated:YES completion:^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ShareViewClose" object:nil];
         }];
      }
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

#pragma mark - FAILED MESSAGE

//201207 수정
- (void)resendMessage:(NSDictionary *)dictionary {
   NSString *contentType = [dictionary objectForKey:@"CONTENT_TY"];
   NSString *content = [dictionary objectForKey:@"CONTENT"];
   
   ResendChatMessage *rc = [[ResendChatMessage alloc] init];
   NSDictionary *resultDict = [rc resendMessage:dictionary roomNo:self.roomNo];
   NSLog(@"resultDict : %@", resultDict);
   
   if(resultDict!=nil){
      NSDictionary *resultMsgDict = [resultDict objectForKey:@"MSG_RESEND_DICT"];
      
      NSMutableArray *imgArray;
      NSMutableArray *vdoArray;
      if([resultDict objectForKey:@"IMG_ARRAY"]) imgArray = [resultDict objectForKey:@"IMG_ARRAY"];
      if([resultDict objectForKey:@"VIDEO_ARRAY"]) vdoArray = [resultDict objectForKey:@"VIDEO_ARRAY"];
      
      if(tmpMissedCnt>0) tmpMissedCnt--;
      
      if([contentType isEqualToString:@"TEXT"]||[contentType isEqualToString:@"LONG_TEXT"]){
         [self.sendingMsgArr addObject:resultMsgDict];
         [self.msgData.chatArray replaceObjectAtIndex:msg_rIdx withObject:resultMsgDict];
         
         NSIndexPath *reloadCell = [NSIndexPath indexPathForItem:msg_rIdx inSection:0];
         [self.tableView beginUpdates];
         [self.tableView reloadRowsAtIndexPaths:@[reloadCell] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView endUpdates];
         
         socket.editInfoDic = self.editInfoDic;
         [socket socketCheck:@"SAVE_CHAT" roomNo:self.roomNo message:content dictionary:nil];
         
         [self scrollToBottomAnimated:YES];
         
      } else if([contentType isEqualToString:@"IMG"]){
         [self.msgData.chatArray removeObjectAtIndex:msg_rIdx];
         [self sendImageMessage:imgArray isAlbum:YES];
         
         NSIndexPath *reloadCell = [NSIndexPath indexPathForItem:msg_rIdx inSection:0];
         [self.tableView beginUpdates];
         [self.tableView deleteRowsAtIndexPaths:@[reloadCell] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView endUpdates];
      
      } else if([contentType isEqualToString:@"VIDEO"]){
         [self.sendingMsgArr addObject:resultMsgDict];
         [self.msgData.chatArray replaceObjectAtIndex:msg_rIdx withObject:resultMsgDict];
         
         NSIndexPath *reloadCell = [NSIndexPath indexPathForItem:msg_rIdx inSection:0];
         [self.tableView beginUpdates];
         [self.tableView reloadRowsAtIndexPaths:@[reloadCell] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView endUpdates];
         
         dh.delegate = self;
         [dh dataConvertFinished:vdoArray];
         
         [self scrollToBottomAnimated:YES];
      }
   }
}

/*
- (void)resendMessage:(NSDictionary *)dictionary {
   NSLog(@"Resend Dict : %@", dictionary);
   NSMutableArray *resendArr = [NSMutableArray array];

   @try{
      NSMutableDictionary *thumbDict = [NSMutableDictionary dictionary];
      NSString *chatNo = [dictionary objectForKey:@"CHAT_NO"];
      NSString *contentType = [dictionary objectForKey:@"CONTENT_TY"];
      NSString *content = [dictionary objectForKey:@"CONTENT"];
      NSString *fileName = [dictionary objectForKey:@"FILE_NM"];
      
      NSError *error;
      NSString *editInfo = [dictionary objectForKey:@"ADIT_INFO"];
      NSData *editInfoData = [editInfo dataUsingEncoding:NSUTF8StringEncoding];
      NSDictionary *editDic = [NSJSONSerialization JSONObjectWithData:editInfoData options:0 error:&error];
      NSString *tmpIdx = [editDic objectForKey:@"TMP_IDX"];
      NSString *localContent = [editDic objectForKey:@"LOCAL_CONTENT"];
      
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      NSString *date = [dateFormatter stringFromDate:[NSDate date]];
      
      self.editInfoDic = [NSMutableDictionary dictionary];
      [self.editInfoDic setObject:@"SENDING" forKey:@"TYPE"];
      [self.editInfoDic setObject:tmpIdx forKey:@"TMP_IDX"];
      [self.editInfoDic setObject:localContent forKey:@"LOCAL_CONTENT"];
      
      NSData* editData = [NSJSONSerialization dataWithJSONObject:self.editInfoDic options:0 error:nil];
      NSString* editJsonData = [[NSString alloc] initWithData:editData encoding:NSUTF8StringEncoding];
      
      [_msgResendDict setObject:editJsonData forKey:@"ADIT_INFO"];
      [_msgResendDict setObject:date forKey:@"DATE"];
      [_msgResendDict setObject:_myUserNo forKey:@"USER_NO"]; //MISSED 일 때 USER_NO가 10으로 들어옴.
      
      NSString *sqlString = [appDelegate.dbHelper deleteMissedChat:self.roomNo chatNo:chatNo];
      [appDelegate.dbHelper crudStatement:sqlString];
      
      if(tmpMissedCnt>0) tmpMissedCnt--;
      
      if([contentType isEqualToString:@"TEXT"]||[contentType isEqualToString:@"LONG_TEXT"]){
         [self.sendingMsgArr addObject:_msgResendDict];
         [self.msgData.chatArray replaceObjectAtIndex:msg_rIdx withObject:_msgResendDict];
   
         NSIndexPath *reloadCell = [NSIndexPath indexPathForItem:msg_rIdx inSection:0];
         [self.tableView beginUpdates];
         [self.tableView reloadRowsAtIndexPaths:@[reloadCell] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView endUpdates];
         
         socket.editInfoDic = self.editInfoDic;
         [socket socketCheck:@"SAVE_CHAT" roomNo:self.roomNo message:content dictionary:nil];
         
         [self scrollToBottomAnimated:YES];
         
      } else if([contentType isEqualToString:@"IMG"]){
         [self.msgData.chatArray removeObjectAtIndex:msg_rIdx];
         
         NSIndexPath *reloadCell = [NSIndexPath indexPathForItem:msg_rIdx inSection:0];
         [self.tableView beginUpdates];
         [self.tableView deleteRowsAtIndexPaths:@[reloadCell] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView endUpdates];
         
         NSRange range = [fileName rangeOfString:@"-" options:0];
         NSString *fileDate = [fileName substringToIndex:range.location];
         
         //로컬경로에 저장되어있는 이미지 재업로드
         NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
         NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
         
         NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Image/%@/", self.roomNo, fileDate];
         NSString *imagePath =[saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
         
         NSData *data = [NSData dataWithContentsOfFile:imagePath];
         
         //mediaArr 형태로 만들어 주기 위해
         UIImage *image = [[UIImage alloc] initWithData:data];
         NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:image, nil];
         NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:arr, @"IMG_LIST", nil];
         NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:dic, nil];
         [self sendImageMessage:array isAlbum:YES];
      
      } else if([contentType isEqualToString:@"VIDEO"]){
         //썸네일이랑 비디오 데이터를(로컬에서 가져와서) 어레이에 넣고 썸네일 먼저 업로드 후 비디오 업로드..
         NSRange range = [fileName rangeOfString:@"-" options:0];
         NSString *fileDate = [fileName substringToIndex:range.location];
         
         //로컬경로에 저장되어있는 이미지 재업로드
         NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
         NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
         
         //local thumb path
         NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Video/%@/thumb/", self.roomNo, fileDate];
         NSString *thumbPath =[saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
         //NSData *originData = UIImageJPEGRepresentation(image, 1.0);
         NSData *thumbData = [NSData dataWithContentsOfFile:thumbPath];
         UIImage *thumbImage = [UIImage imageWithData:thumbData];
         
         NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Video/%@/", self.roomNo, fileDate];
         NSRange range2 = [fileName rangeOfString:@"." options:NSBackwardsSearch];
         NSString *videoName = [NSString stringWithFormat:@"%@.mp4",[fileName substringToIndex:range2.location]];
         NSString *videoPath = [saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",videoName]];
//         NSLog(@"videoPath : %@", videoPath);
         NSData *videoData = [NSData dataWithContentsOfFile:videoPath];

         if ([[NSFileManager defaultManager]fileExistsAtPath:videoPath]){
            //NSLog(@"재전송 동영상 데이터 삭제");
            [[NSFileManager defaultManager]removeItemAtPath:videoPath error:nil];
         }
         
         [thumbDict setObject:fileName forKey:@"FILE_NM"];
         [thumbDict setObject:thumbImage forKey:@"ORIGIN"];
         [thumbDict setObject:@"VIDEO_THUMB" forKey:@"TYPE"];
         [resendArr addObject:thumbDict];
         
         NSMutableDictionary *originDict = [NSMutableDictionary dictionary];
         [originDict setObject:editJsonData forKey:@"ADIT_INFO"];
         [originDict setObject:videoName forKey:@"FILE_NM"];
         [originDict setObject:videoData forKey:@"ORIGIN"];
         [originDict setObject:contentType forKey:@"TYPE"];
         [resendArr addObject:originDict];
         
         [self.sendingMsgArr addObject:_msgResendDict];
         [self.msgData.chatArray replaceObjectAtIndex:msg_rIdx withObject:_msgResendDict];
   
         NSIndexPath *reloadCell = [NSIndexPath indexPathForItem:msg_rIdx inSection:0];
         [self.tableView beginUpdates];
         [self.tableView reloadRowsAtIndexPaths:@[reloadCell] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView endUpdates];
         
         dh.delegate = self;
         [dh dataConvertFinished:resendArr];
         
         [self scrollToBottomAnimated:YES];
      }
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}
*/

- (void)touchedMsgFailButton:(NSInteger)indexPath{
   UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
   UIAlertAction *resendAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_resend", @"chat_resend")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action){
                                                           _msgResendDict = [[NSMutableDictionary alloc]init];
      
                                                           @try{
                                                              [_msgResendDict setObject:[[self.msgData.chatArray objectAtIndex:indexPath]objectForKey:@"CHAT_NO"] forKey:@"CHAT_NO"];
                                                              [_msgResendDict setObject:[[self.msgData.chatArray objectAtIndex:indexPath]objectForKey:@"CONTENT_TY"] forKey:@"CONTENT_TY"];
                                                              [_msgResendDict setObject:[[self.msgData.chatArray objectAtIndex:indexPath]objectForKey:@"CONTENT"] forKey:@"CONTENT"];
                                                              [_msgResendDict setObject:[[self.msgData.chatArray objectAtIndex:indexPath]objectForKey:@"USER_NO"] forKey:@"USER_NO"];
                                                              [_msgResendDict setObject:[[self.msgData.chatArray objectAtIndex:indexPath]objectForKey:@"FILE_NM"] forKey:@"FILE_NM"];
                                                              [_msgResendDict setObject:[[self.msgData.chatArray objectAtIndex:indexPath]objectForKey:@"ADIT_INFO"] forKey:@"ADIT_INFO"];
                                                              
                                                              msg_rIdx = indexPath;
                                                              
                                                              [self resendMessage:_msgResendDict];
                                                              [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                              
                                                           } @catch (NSException *exception) {
                                                              NSLog(@"Exception : %@", exception);
                                                           }
                                                        }];
   
   UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction * action){
                                                           
                                                           @try{
                                                              [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                              
                                                              UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_select_msg_delete", @"chat_select_msg_delete") preferredStyle:UIAlertControllerStyleAlert];
                                                              UIAlertAction *deleteMsg = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done")
                                                                           style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * action){
                                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                                              
                                                                              @try{
                                                                                 NSString *chatNo = [[self.msgData.chatArray objectAtIndex:indexPath]objectForKey:@"CHAT_NO"];
                                                                                 
                                                                                 NSString *sqlString = [appDelegate.dbHelper deleteMissedChat:self.roomNo chatNo:chatNo];
                                                                                 [appDelegate.dbHelper crudStatement:sqlString];
                                                                                 
                                                                                 [self.msgData.chatArray removeObjectAtIndex:indexPath];
                                                                                 tmpMissedCnt--;
                                                                                 
                                                                                 [self.tableView reloadData];
                                                                                 
                                                                              } @catch (NSException *exception) {
                                                                                 NSLog(@"Exception : %@", exception);
                                                                              }
                                                                           }];
                                                              [alert addAction:deleteMsg];
                                                              [self presentViewController:alert animated:YES completion:nil];
                                                              
                                                           } @catch (NSException *exception) {
                                                              NSLog(@"Exception : %@", exception);
                                                           }
                                                        }];
   [actionSheet addAction:resendAction];
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

#pragma mark - Call Webservice
- (void)callChatReadStatus {
   NSString *sqlString = [appDelegate.dbHelper getUnreadChatNoRange:self.roomNo myUserNo:self.myUserNo];
   NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:sqlString];
   
   @try{
      NSNumber *firstChat = [[selectArr objectAtIndex:0] objectForKey:@"FIRST_CHAT"];
      NSNumber *lastChat = [[selectArr objectAtIndex:0] objectForKey:@"LAST_CHAT"];
      
      if(![[NSString stringWithFormat:@"%@", firstChat] isEqualToString:@"-1"] && ![[NSString stringWithFormat:@"%@", lastChat] isEqualToString:@"-1"]){
         
         NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
         NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveChatReadStatus"]];
         NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&firstChatNo=%@&lastChatNo=%@&dvcId=%@", self.myUserNo, self.roomNo, firstChat, lastChat, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
         MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
         session.delegate = self;
         [session start];
      } else {
         //NSLog(@"FIRST AND LAST CHATS ARE NULL---------");
      }
      
      appDelegate.currChatRoomNo = self.roomNo;
      
      NSString *sqlString2 = [appDelegate.dbHelper updateChatReadStatus:self.roomNo];
      [appDelegate.dbHelper crudStatement:sqlString2];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

//텍스트메시지 전송/재전송 웹서비스
- (void)callSaveChat:(NSString *)message{
   NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
   NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
   
   @try{
      NSError *error;
       NSData* editData = [NSJSONSerialization dataWithJSONObject:self.editInfoDic options:0 error:&error];
      NSString* editJsonData = [[NSString alloc] initWithData:editData encoding:NSUTF8StringEncoding];
      
      message = [MFUtil replaceEncodeToChar:message];
      
      NSUInteger textByte = [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
      if(textByte>1000) [contentDic setObject:@"LONG_TEXT" forKey:@"TYPE"];
      else [contentDic setObject:@"TEXT" forKey:@"TYPE"];
      
      [contentDic setObject:message forKey:@"VALUE"];
      
      if(![message isEqualToString:@""]){
         NSData* data = [NSJSONSerialization dataWithJSONObject:contentDic options:0 error:nil];
         NSString* jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveChat"]];
         
         //aditInfo : 메시지번호 등의 추가정보
         NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&content=%@&aditInfo=%@&dvcId=%@", self.myUserNo, self.roomNo, jsonData, editJsonData, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
         
         MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
         session.delegate = self;
         [session start];
      }
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)callSaveInviteChat:(NSDictionary *)dict{
   NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
   NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
   
   @try {
      NSError *error;
      NSData* editData = [NSJSONSerialization dataWithJSONObject:self.editInfoDic options:0 error:&error];
      NSString* editJsonData = [[NSString alloc] initWithData:editData encoding:NSUTF8StringEncoding];
      
      [contentDic setObject:@"INVITE" forKey:@"TYPE"];
      [contentDic setObject:dict forKey:@"VALUE"];
      
      NSData* data = [NSJSONSerialization dataWithJSONObject:contentDic options:0 error:nil];
      NSString* jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      //NSLog(@"jsonData : %@", jsonData);
      
      NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveChat"]];
      
      //aditInfo : 메시지번호 등의 추가정보
      NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&content=%@&aditInfo=%@&dvcId=%@", self.myUserNo, self.roomNo, jsonData, editJsonData, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
      MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
      session.delegate = self;
      [session start];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)callJoinSns:(NSString *)snsNo{
   NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
   NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"joinSNS"]];
   
   //aditInfo : 메시지번호 등의 추가정보
   NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&dvcId=%@", self.myUserNo, snsNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
   MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
   session.delegate = self;
   [session start];
}

-(void)callSyncChatUser{
   NSString *sqlString = [appDelegate.dbHelper getRoomUserNo:self.roomNo];
   NSMutableArray *selectArr = [appDelegate.dbHelper selectValueMutableArray:sqlString];
   NSString *usrLists = [[selectArr valueForKey:@"description"] componentsJoinedByString:@","];
   
   NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
   NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"syncChatUsers"]];

   NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&usrLists=%@", self.myUserNo, self.roomNo, usrLists];
//   NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&usrLists=120818", self.myUserNo, self.roomNo];
   MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
   session.delegate = self;
   [session start];
}

-(void)failedChatData:(NSDictionary *)dict{
   //실패테이블에 저장
   NSLog(@"메시지 전송에 실패했어요 : %@", dict);
   
   @try{
      tmpMissedCnt++;
      NSError *error;
      
      if(dict!=nil){
         NSArray *dataSet = [dict objectForKey:@"DATASET"];
         NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
         NSString *contentType = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT_TY"];
         NSString *content = [[dataSet objectAtIndex:0] objectForKey:@"CONTENT"];
         NSString *decodeContent = [NSString urlDecodeString:content];
         NSString *fileName = [[dataSet objectAtIndex:0] objectForKey:@"FILE_NM"];
         NSString *decodeFileNm = [NSString urlDecodeString:fileName];
         
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.editInfoDic options:0 error:&error];
         NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         
         if([contentType isEqualToString:@"LONG_TEXT"]){
            decodeContent = @"";
            NSString *sqlString = [appDelegate.dbHelper insertMissedChat:roomNo contentType:contentType content:decodeContent fileName:decodeFileNm contentThumb:@"" aditInfo:jsonString];
            [appDelegate.dbHelper crudStatement:sqlString];
            
         } else {
            NSString *sqlString = [appDelegate.dbHelper insertMissedChat:roomNo contentType:contentType content:decodeContent fileName:decodeFileNm contentThumb:@"" aditInfo:jsonString];
            [appDelegate.dbHelper crudStatement:sqlString];
         }
         
         NSString *sqlString2 = [appDelegate.dbHelper getLastInsertRowID];
         [appDelegate.dbHelper selectMutableArray:sqlString2];
      
      } else {
         NSLog(@"실패 self.firstAddMsg : %@", self.firstAddMsg);
         NSLog(@"11 실패했을때 sendingMsgArr : %@", self.sendingMsgArr);
         
         NSUInteger msgDataCnt = self.msgData.chatArray.count;
         int count = [self getMissedChatCount];
         NSString *dvcID = [appDelegate.appPrefs objectForKey:@"DVC_ID"];
         
         NSString *roomNo = [self.firstAddMsg objectForKey:@"ROOM_NO"];
         NSString *contentType = [self.firstAddMsg objectForKey:@"CONTENT_TY"];
         NSString *fileName = [self.firstAddMsg objectForKey:@"FILE_NM"];
         NSString *editInfo = [self.firstAddMsg objectForKey:@"ADIT_INFO"];
         
         NSData *editInfoData = [editInfo dataUsingEncoding:NSUTF8StringEncoding];
         NSDictionary *editDic = [NSJSONSerialization JSONObjectWithData:editInfoData options:0 error:&error];
         NSLog(@"eidtDic : %@", editDic);
         NSString *localContent = [editDic objectForKey:@"LOCAL_CONTENT"];
         
         NSString *content;
         content = [NSString urlDecodeString:[self.firstAddMsg objectForKey:@"CONTENT"]];
         
         NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(msgDataCnt-count) inSection:0];
         self.editInfoDic = [NSMutableDictionary dictionary];
         [self.editInfoDic setObject:@"FAILED" forKey:@"TYPE"];
         [self.editInfoDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
         [self.editInfoDic setObject:dvcID forKey:@"DEVICE_ID"];
         [self.editInfoDic setObject:localContent forKey:@"LOCAL_CONTENT"];
         
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.editInfoDic options:0 error:&error];
         NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         
         [self.firstAddMsg setObject:jsonString forKey:@"ADIT_INFO"];
         
         for(int i=0; i<self.sendingMsgArr.count; i++){
            NSString *editInfo = [[self.sendingMsgArr objectAtIndex:i] objectForKey:@"ADIT_INFO"];
            NSData *jsonData = [editInfo dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *editDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

            NSString *editIdx = [editDic objectForKey:@"TMP_IDX"];
            if(rowNo.row == [editIdx integerValue]){
               [self.sendingMsgArr removeObjectAtIndex:i];
            }
         }
         NSLog(@"22 실패했을때 sendingMsgArr : %@", self.sendingMsgArr);
         
         if([contentType isEqualToString:@"TEXT"]||[contentType isEqualToString:@"LONG_TEXT"]){
            NSString *sqlString = [appDelegate.dbHelper insertMissedChat:roomNo contentType:contentType content:content fileName:@"" contentThumb:@"" aditInfo:jsonString];
            [appDelegate.dbHelper crudStatement:sqlString];
            
         } else {
            NSString *sqlString = [appDelegate.dbHelper insertMissedChat:roomNo contentType:contentType content:content fileName:fileName contentThumb:@"" aditInfo:jsonString];
            [appDelegate.dbHelper crudStatement:sqlString];
         }
         
         NSString *sqlString2 = [appDelegate.dbHelper getLastInsertRowID];
         NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:sqlString2];
         [self.firstAddMsg setObject:[[selectArr objectAtIndex:0]objectForKey:@"CHAT_NO"] forKey:@"CHAT_NO"];
         
         [self.msgData.chatArray removeObjectAtIndex:rowNo.row];
         [self.msgData.chatArray insertObject:self.firstAddMsg atIndex:self.msgData.chatArray.count];
         
         [self.tableView reloadData];
      }
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

#pragma mark - MFURLSession delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
   if (error != nil) {
      [self failedChatData:session.returnDictionary];
      
   } else {
//      NSLog(@"session.returnDictionary : %@", session.returnDictionary);
      if(session.returnDictionary != nil){
         NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
         NSString *wsName = [[session.url absoluteString] lastPathComponent];
         
         if ([result isEqualToString:@"SUCCESS"]) {
            @try{
               if([wsName isEqualToString:@"saveChatReadStatus"]){
                  if(appDelegate.isChatViewing){
                     NSString *roomNo = [session.returnDictionary objectForKey:@"ROOM_NO"];
                     NSArray *dataSet = [session.returnDictionary objectForKey:@"DATASET"];
                     for(int i=0; i<dataSet.count; i++){
                        NSString *chatNoList = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CHAT_NO_LIST"]];
                        NSNumber *unreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"UNREAD_COUNT"];
                        
                        NSString *sqlString = [appDelegate.dbHelper updateChatUnReadCount:unreadCnt roomNo:roomNo chatNoList:chatNoList];
                        [appDelegate.dbHelper crudStatement:sqlString];
                     }
                     
                     if([[NSString stringWithFormat:@"%@", roomNo] isEqualToString:[NSString stringWithFormat:@"%@", self.roomNo]]){
                        NSLog(@"읽음카운트 처리");

                        //읽음카운트 처리 (reload하니 채팅이 버벅거리면서 올라감. reload안해도 읽음 처리는 됨. 왜지? 테스트 계속 해봐야 할듯)
                        //[self.tableView reloadData];
                        
                     } else {
                        
                     }
                  }
                  
               } else if([wsName isEqualToString:@"saveChat"]){
                  //웹서비스 리턴 결과 무시(SUCCESS)
                  //NSLog(@"웹서비스 리턴 결과 무시(SUCCESS)");
                  
               } else if([wsName isEqualToString:@"joinSNS"]){
                  NSMutableArray *dataSet = [session.returnDictionary objectForKey:@"DATASET"];
                  NSString *message = [session.returnDictionary objectForKey:@"MESSAGE"];
                  if([message isEqualToString:@"SNS_IS_NULL"]){
                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast5", @"join_sns_toast5"), joinSnsName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                      }];
                     [alert addAction:okButton];
                     [self presentViewController:alert animated:YES completion:nil];
                     
                  } else {
                     NSString *snsName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
                     NSString *affected = [[dataSet objectAtIndex:0] objectForKey:@"AFFECTED"];
                     NSString *needAllow = [[dataSet objectAtIndex:0] objectForKey:@"NEED_ALLOW"];
                     
                     if([affected intValue]==1){
                        if([needAllow intValue]==0){
                           //가입완료
                           UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast1_1", @"join_sns_toast1_1"), snsName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                           UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction * action) {
                                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                                               
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:nil];
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamSelect" object:nil userInfo:nil];
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshFeed" object:nil userInfo:nil];
                                                                            }];
                           
                           [alert addAction:okButton];
                           [self presentViewController:alert animated:YES completion:nil];
                           
                        } else if([needAllow intValue]==1){
                           //가입 신청 완료
                           UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast2", @"join_sns_toast2"), snsName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                           UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction * action) {
                                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                                               
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamList" object:nil userInfo:nil];
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshTeamSelect" object:nil userInfo:nil];
                                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_RefreshFeed" object:nil userInfo:nil];
                                                                            }];
                           
                           [alert addAction:okButton];
                           [self presentViewController:alert animated:YES completion:nil];
                        }
                        
                     } else if ([affected intValue]==0) {
                        if([needAllow intValue]==0){
                           //이미 가입된 상태
                           UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast3", @"join_sns_toast3"), snsName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                           UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction * action) {
                                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                                            }];
                           
                           [alert addAction:okButton];
                           [self presentViewController:alert animated:YES completion:nil];
                           
                        } else if([needAllow intValue]==1){
                           //이미 가입 신청된 상태
                           UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast4", @"join_sns_toast4"), snsName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                           UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction * action) {
                                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                                            }];
                           [alert addAction:okButton];
                           [self presentViewController:alert animated:YES completion:nil];
                        }
                     }
                  }
                  
               } else if([wsName isEqualToString:@"syncChatUsers"]){
                  NSLog(@"session.returnDictionary : %@", session.returnDictionary);
                  NSDictionary *dic = session.returnDictionary;
                  NSArray *dataSetArr = [dic objectForKey:@"DATASET"];
                  
                  for(int i=0; i<dataSetArr.count; i++){
                     NSDictionary *dataSet = [dataSetArr objectAtIndex:i];
                     NSString *userNo = [dataSet objectForKey:@"NODE_NO"];
                     NSString *userId = [NSString urlDecodeString:[dataSet objectForKey:@"CUSER_ID"]];
                     NSString *userName = [NSString urlDecodeString:[dataSet objectForKey:@"USER_NM"]];
                     NSString *userImg = [NSString urlDecodeString:[dataSet objectForKey:@"NODE_IMG"]];
                     NSString *userMsg = [NSString urlDecodeString:[dataSet objectForKey:@"PROFILE_MSG"]];
                     NSString *phoneNo = [NSString urlDecodeString:[dataSet objectForKey:@"PHONE_NO"]];
                     NSString *deptNo = [dataSet objectForKey:@"DEPT_NO"];
                     NSString *userBgImg = [NSString urlDecodeString:[dataSet objectForKey:@"NODE_BG_IMG"]];
                     
                     NSString *deptName = [NSString urlDecodeString:[dataSet objectForKey:@"DEPT_NM"]];
                     NSString *levelNo = [NSString urlDecodeString:[dataSet objectForKey:@"LEVEL_NO"]];
                     NSString *levelName = [NSString urlDecodeString:[dataSet objectForKey:@"LEVEL_NM"]];
                     NSString *dutyNo = [NSString urlDecodeString:[dataSet objectForKey:@"DUTY_NO"]];
                     NSString *dutyName = [NSString urlDecodeString:[dataSet objectForKey:@"DUTY_NM"]];
                     NSString *jobGrpName = [NSString urlDecodeString:[dataSet objectForKey:@"JOB_GRP_NM"]];
                     NSString *exCompNo = [NSString urlDecodeString:[dataSet objectForKey:@"EX_COMPANY"]];
                     NSString *exCompName = [NSString urlDecodeString:[dataSet objectForKey:@"EX_COMPANY_NM"]];
                     NSString *userType = [dataSet objectForKey:@"SNS_USER_TYPE"];
                     
                     NSString *sqlString = [appDelegate.dbHelper insertOrUpdateUsers:userNo userId:userId userName:userName userImg:userImg userMsg:userMsg phoneNo:phoneNo deptNo:deptNo userBgImg:userBgImg deptName:deptName levelNo:levelNo levelName:levelName dutyNo:dutyNo dutyName:dutyName jobGrpName:jobGrpName exCompNo:exCompNo exCompName:exCompName userType:userType];
                     [appDelegate.dbHelper crudStatement:sqlString];
                     
                     NSString *sqlString2 = [appDelegate.dbHelper insertChatUsers:self.roomNo userNo:userNo];
                     [appDelegate.dbHelper crudStatement:sqlString2];
                  }
                  
//                  [self syncChat]; //싱크유저시키고 채팅 불러와보자
                  NSLog(@"USER SYNC AND DATA LOAD.");
                  self.msgData = [[ChatMessageData alloc] initwithRoomNo:_roomNo];
                  [self tabledraw];
               
               } else if([wsName isEqualToString:@"getChatList"]){
                  NSDictionary *dic = session.returnDictionary;
//                  NSLog(@"getChatList : %@", dic);
                  
                  NSArray *dataSet = [dic objectForKey:@"DATASET"];
                  
                  NSUInteger count = dataSet.count;
                  if(count==0||count<pChatSize) isLoad = NO;
                  else isLoad = YES;
                  
                  if(count > 0){
                     NSString *seq = [[NSString alloc]init];
                     
                     NSMutableArray *indexPaths = [NSMutableArray array];
                     for(int i=1; i<=count; i++){
                        seq = [NSString stringWithFormat:@"%d", [stChatSeq intValue]+i];
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i-1 inSection:0]];
                     }
                     
//                     stChatSeq = seq;
//                     isScroll = YES;
                     
                     //채팅읽음처리호출
                     NSString *wsFirstChatNo = [[dataSet lastObject] objectForKey:@"CHAT_NO"]; //서버에서 가져온 제일 오래된 채팅
                     NSString *wsLastChatNo = [[dataSet firstObject] objectForKey:@"CHAT_NO"]; //서버에서 가져온 제일 최근 채팅
                     NSMutableArray *firstChatInfo = [appDelegate.dbHelper selectMutableArray:[NSString stringWithFormat:@"SELECT IS_READ FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@", self.roomNo, wsFirstChatNo]];
                     NSLog(@"firstChatInfo: %@", firstChatInfo);
                     if(firstChatInfo.count>0){
                        //db에 있음
                        NSString *firstIsRead = [[firstChatInfo objectAtIndex:0] objectForKey:@"IS_READ"];
                        if([[NSString stringWithFormat:@"%@", firstIsRead] isEqualToString:@"1"]){
                           //읽음
                           //서버에서 가져왔는데 디비에 있고 isRead 1이면(읽음) 이면 읽음처리 호출할 필요가 없지 -> 가 아니고,  first : 해당넘버, last : 마지막넘버?? 아닌가
                           [socket socketCheck:@"CHAT_READ_STATUS" roomNo:self.roomNo message:nil dictionary:nil];
                        } else {
                           //안읽음
                           NSDictionary *readChatDic = [[NSDictionary alloc] initWithObjectsAndKeys:wsFirstChatNo,@"FIRST_CHAT", wsLastChatNo,@"LAST_CHAT", nil];
                           [socket socketCheck:@"CHAT_READ_STATUS" roomNo:self.roomNo message:nil dictionary:readChatDic];
                        }
                     } else {
                        //db에 없음
                        NSDictionary *readChatDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"-1",@"FIRST_CHAT", wsLastChatNo,@"LAST_CHAT", nil];
                        [socket socketCheck:@"CHAT_READ_STATUS" roomNo:self.roomNo message:nil dictionary:readChatDic];
                     }
                     
                     NSMutableArray *chatInfoArr = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getChatRoomInfo:self.roomNo]];
                     NSLog(@"chatinfoArr: %@", chatInfoArr);
                     
                     if(chatInfoArr.count>0 && [[[chatInfoArr objectAtIndex:0] objectForKey:@"EXIT_FLAG"] isEqualToString:@"Y"]){
                        //1:1인데 나가기 한 방
                        int chatCnt=0;
                        NSString *dbLastChatNo = [[chatInfoArr objectAtIndex:0] objectForKey:@"LAST_CHAT_NO"];
                        
                        for(int i=0; i<dataSet.count; i++){
                           chatCnt++;
                           NSString *chatDate = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CHAT_DATE"]];
                           NSString *chatNo = [[dataSet objectAtIndex:i] objectForKey:@"CHAT_NO"];
                           
                           if([chatNo intValue] > [dbLastChatNo intValue]){
                              //나가기했지만 새로운 채팅이 생겼을 경우 채팅 추가
                              
                              NSString *content = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CONTENT"]];
                              NSString *contentTy = [[dataSet objectAtIndex:i] objectForKey:@"CONTENT_TY"];
                              NSString *cuserNo = [[dataSet objectAtIndex:i] objectForKey:@"CUSER_NO"];
                              NSString *profileImg = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"PROFILE_IMG"]];
                              NSString *roomNo = [[dataSet objectAtIndex:i] objectForKey:@"ROOM_NO"];
                              NSString *unreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"UNREAD_COUNT"];
                              NSString *userNm = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"USER_NM"]];
                              
                              NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                              [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
                              
                              if ([contentTy isEqualToString:@"INVITE"]) {
                                 content = [NSString urlDecodeString:content];
                                 
                              } else if([contentTy isEqualToString:@"SYS"]){
                                 NSDictionary *aditInfo = [[dataSet objectAtIndex:i] objectForKey:@"ADIT_INFO"];
                                 NSString *sysMsgType = [aditInfo objectForKey:@"SYS_MSG_TY"];
                                 
                                 if([sysMsgType isEqualToString:@"ADD_USER"]){
                                    NSString *sender = [NSString urlDecodeString:[aditInfo objectForKey:@"SENDER"]];
                                    NSString *addSysMsg = [NSString stringWithFormat:NSLocalizedString(@"add_chat_user", @"add_chat_user"), sender, content];
                                    if([addSysMsg rangeOfString:@","].location != NSNotFound){
                                       addSysMsg = [addSysMsg stringByReplacingOccurrencesOfString:@"," withString:NSLocalizedString(@"add_chat_user_conj", @"add_chat_user_conj")];
                                    }
                                    content = [[NSMutableString alloc]initWithString:addSysMsg];
                                    
                                 } else if([sysMsgType isEqualToString:@"DELETE_USER"]){
                                    NSString *deleteSysMsg = [NSString stringWithFormat:NSLocalizedString(@"delete_chat_user", @"delete_chat_user"), content];
                                    content = [[NSMutableString alloc]initWithString:deleteSysMsg];
                                 }
                              }
                              
                              content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                              
                              NSError *error;
                              NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
                              NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                              
                              
                              NSString *insertQuery;
                              if([contentTy isEqualToString:@"LONG_TEXT"]){
                                 insertQuery = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:cuserNo contentType:contentTy content:@"" localContent:@"" chatDate:chatDate fileName:@"" aditInfo:jsonString isRead:@"0" unReadCnt:unreadCnt contentPrev:content];
                              } else {
                                 insertQuery = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:cuserNo contentType:contentTy content:content localContent:@"" chatDate:chatDate fileName:@"" aditInfo:jsonString isRead:@"0" unReadCnt:unreadCnt contentPrev:@""];
                              }
                              
                              NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc]init];
                              [userInfoDic setObject:chatNo forKey:@"CHAT_NO"];
                              [userInfoDic setObject:contentTy forKey:@"CONTENT_TY"];
                              [userInfoDic setObject:chatDate forKey:@"DATE"];
                              [userInfoDic setObject:roomNo forKey:@"ROOM_NO"];
                              [userInfoDic setObject:userNm forKey:@"USER_NM"];
                              [userInfoDic setObject:cuserNo forKey:@"USER_NO"];
                              [userInfoDic setObject:unreadCnt forKey:@"UNREAD_COUNT"];
                              [userInfoDic setObject:@"" forKey:@"FILE_NM"];
                              [userInfoDic setObject:@"" forKey:@"FILE_THUMB"];
                              if([profileImg isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"USER_IMG"];
                              else [userInfoDic setObject:profileImg forKey:@"USER_IMG"];
                              
                              if([contentTy isEqualToString:@"LONG_TEXT"]){
                                 [userInfoDic setObject:@"" forKey:@"CONTENT"];
                                 [userInfoDic setObject:content forKey:@"CONTENT_PREV"];
                              } else {
                                 [userInfoDic setObject:content forKey:@"CONTENT"];
                                 [userInfoDic setObject:@"" forKey:@"CONTENT_PREV"];
                              }
                              
                              [userInfoDic setObject:jsonString forKey:@"ADIT_INFO"];
                              
                              [self.msgData.chatArray insertObject:userInfoDic atIndex:0];
                              
                              if(chatCnt == dataSet.count){
                                 NSLog(@"EXIE CHAT / MAINTAIN SCROLL");
                                 [self.tableView beginUpdates];
                                 [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                 [self.tableView endUpdates];
                                 
                                 NSIndexPath *lastCell2 = [NSIndexPath indexPathForRow:(chatCnt-1) inSection:0];
                                 [self.tableView scrollToRowAtIndexPath:lastCell2 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                              }
                              
                              [appDelegate.dbHelper crudStatement:insertQuery completion:^{
                                 //                                 if(chatCnt == dataSet.count){
                                 NSLog(@"EXIT CHAT INSERT COMPLETION !");
                                 //                                 }
                              }];
                              
                           } else {
                              //나갔던 방이므로 이전데이터는 불러올 필요 없음
                           }
                        }
                        
                     } else {
                        int chatCnt=0;
                        for(int i=0; i<dataSet.count; i++){
                           chatCnt++;
                           
                           NSString *chatDate = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CHAT_DATE"]];
                           NSString *chatNo = [[dataSet objectAtIndex:i] objectForKey:@"CHAT_NO"];
                           NSString *content = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CONTENT"]];
                           NSString *contentTy = [[dataSet objectAtIndex:i] objectForKey:@"CONTENT_TY"];
                           NSString *cuserNo = [[dataSet objectAtIndex:i] objectForKey:@"CUSER_NO"];
                           NSString *profileImg = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"PROFILE_IMG"]];
                           NSString *roomNo = [[dataSet objectAtIndex:i] objectForKey:@"ROOM_NO"];
                           NSString *unreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"UNREAD_COUNT"];
                           NSString *userNm = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"USER_NM"]];
                           
                           NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                           [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
                           
                           if ([contentTy isEqualToString:@"INVITE"]) {
                              content = [NSString urlDecodeString:content];
                              
                           } else if([contentTy isEqualToString:@"SYS"]){
                              NSDictionary *aditInfo = [[dataSet objectAtIndex:i] objectForKey:@"ADIT_INFO"];
                              NSString *sysMsgType = [aditInfo objectForKey:@"SYS_MSG_TY"];
                              
                              if([sysMsgType isEqualToString:@"ADD_USER"]){
                                 NSString *sender = [NSString urlDecodeString:[aditInfo objectForKey:@"SENDER"]];
                                 NSString *addSysMsg = [NSString stringWithFormat:NSLocalizedString(@"add_chat_user", @"add_chat_user"), sender, content];
                                 if([addSysMsg rangeOfString:@","].location != NSNotFound){
                                    addSysMsg = [addSysMsg stringByReplacingOccurrencesOfString:@"," withString:NSLocalizedString(@"add_chat_user_conj", @"add_chat_user_conj")];
                                 }
                                 content = [[NSMutableString alloc]initWithString:addSysMsg];
                                 
                              } else if([sysMsgType isEqualToString:@"DELETE_USER"]){
                                 NSString *deleteSysMsg = [NSString stringWithFormat:NSLocalizedString(@"delete_chat_user", @"delete_chat_user"), content];
                                 content = [[NSMutableString alloc]initWithString:deleteSysMsg];
                              }
                           }
                           content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                           
                           NSError *error;
                           NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
                           NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                           
                           NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM CHATS WHERE ROOM_NO = %@ AND CHAT_NO = %@;", roomNo, chatNo];
                           NSString *chatCount = [appDelegate.dbHelper selectString:sqlString];
                           if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]||chatCount==nil){
                              NSLog(@"채팅이 없을때만 인서트");
                              NSString *insertQuery;
                              if([contentTy isEqualToString:@"LONG_TEXT"]){
                                 insertQuery = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:cuserNo contentType:contentTy content:@"" localContent:@"" chatDate:chatDate fileName:@"" aditInfo:jsonString isRead:@"0" unReadCnt:unreadCnt contentPrev:content];
                              } else {
                                 insertQuery = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:cuserNo contentType:contentTy content:content localContent:@"" chatDate:chatDate fileName:@"" aditInfo:jsonString isRead:@"0" unReadCnt:unreadCnt contentPrev:@""];
                              }
                              
                              NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc]init];
                              [userInfoDic setObject:chatNo forKey:@"CHAT_NO"];
                              [userInfoDic setObject:contentTy forKey:@"CONTENT_TY"];
                              [userInfoDic setObject:chatDate forKey:@"DATE"];
                              [userInfoDic setObject:roomNo forKey:@"ROOM_NO"];
                              [userInfoDic setObject:userNm forKey:@"USER_NM"];
                              [userInfoDic setObject:cuserNo forKey:@"USER_NO"];
                              [userInfoDic setObject:unreadCnt forKey:@"UNREAD_COUNT"];
                              [userInfoDic setObject:@"" forKey:@"FILE_NM"];
                              [userInfoDic setObject:@"" forKey:@"FILE_THUMB"];
                              if([profileImg isEqualToString:@""]) [userInfoDic setObject:@"" forKey:@"USER_IMG"];
                              else [userInfoDic setObject:profileImg forKey:@"USER_IMG"];
                              
                              if([contentTy isEqualToString:@"LONG_TEXT"]){
                                 [userInfoDic setObject:@"" forKey:@"CONTENT"];
                                 [userInfoDic setObject:content forKey:@"CONTENT_PREV"];
                              } else {
                                 [userInfoDic setObject:content forKey:@"CONTENT"];
                                 [userInfoDic setObject:@"" forKey:@"CONTENT_PREV"];
                              }
                              
                              //선등록메시지(SENDING) 교체(SUCCEED)
                              NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                              [tmpDic setValue:@"SUCCEED" forKey:@"TYPE"];
                              NSError *error;
                              NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:0 error:&error];
                              NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                              [userInfoDic setObject:jsonString forKey:@"ADIT_INFO"];
                              
                              [self.msgData.chatArray insertObject:userInfoDic atIndex:0];
                              
                              if(chatCnt == dataSet.count){
                                 NSLog(@"CHAT / MAINTAIN SCROLL");
                                 [self.tableView beginUpdates];
                                 [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                 [self.tableView endUpdates];
                                 
                                 NSIndexPath *lastCell2 = [NSIndexPath indexPathForRow:(chatCnt-1) inSection:0];
                                 [self.tableView scrollToRowAtIndexPath:lastCell2 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                              }
                              
                              [appDelegate.dbHelper crudStatement:insertQuery completion:^{
                                 //                                 if(chatCnt == dataSet.count){
                                 NSLog(@"CHAT INSERT COMPLETION !");
                                 //                                 }
                              }];
                              
                           } else {
                              if(![stChatSeq isEqualToString:@"1"]){
                                 if(chatCnt == dataSet.count){
                                    NSLog(@"DRAW TABLE.");
                                    [self tabledraw];
                                 }
                              } else {
                                 //NSLog(@"여기라는거지? (마지막채팅하나만 있어도 여기로 들어옴..) rowCnt : %d", rowCnt);
                              }
                           }
                        }
                     }
                     
                     stChatSeq = seq;
                     isScroll = YES;
                  }
                  if([stChatSeq isEqualToString:@"1"]){
                     NSLog(@"CALL SYNC USER.");
                     [self callSyncChatUser];
                  }
                  
               }
               
            } @catch (NSException *exception) {
               NSLog(@"Exception : %@", exception);
            }
            
         } else{
            //실패테이블에 저장
            @try{
               if([wsName isEqualToString:@"saveChat"]){
                  [self failedChatData:session.returnDictionary];
                  
               } else if([wsName isEqualToString:@"joinSNS"]){
                  NSString *message = [session.returnDictionary objectForKey:@"MESSAGE"];
                  if([message isEqualToString:@"SNS_IS_NULL"]){
                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast5", @"join_sns_toast5"), joinSnsName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                      }];
                     [alert addAction:okButton];
                     [self presentViewController:alert animated:YES completion:nil];
                  }
               }
               
            } @catch (NSException *exception) {
               NSLog(@"Exception : %@", exception);
            }
         }
      } else{
         //데이터,와이파이 둘 다 꺼져있을경우
         NSLog(@"인터넷 연결이 오프라인으로 나타납니다.");
         [self failedChatData:session.returnDictionary];
      }
   }
}

- (void)returnError:(MFURLSession *)session error:(NSError *)error{
   NSLog(@"2 메시지 전송 실패 ! : %@", error);
   
   [SVProgressHUD dismiss];
   if(error.code == -1009){
      //Code=-1009 : 인터넷연결 꺼져있을경우?
   } else if(error.code == -1001){
      //요청한 시간이 초과되었습니다.
   }
   
   [self failedChatData:nil];
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return self.msgData.chatArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   ChatSendTextCell *sendTxtCell = [tableView dequeueReusableCellWithIdentifier:@"ChatSendTextCell"];
   ChatSendImgCell *sendImgCell = [tableView dequeueReusableCellWithIdentifier:@"ChatSendImgCell"];
//   ChatSendVideoCell *sendVideoCell = [tableView dequeueReusableCellWithIdentifier:@"ChatSendVideoCell"];
   sendVideoCell = [tableView dequeueReusableCellWithIdentifier:@"ChatSendVideoCell"];
   
   ChatSendFileCell *sendFileCell = [tableView dequeueReusableCellWithIdentifier:@"ChatSendFileCell"];
   ChatSendInviteCell *sendInviteCell = [tableView dequeueReusableCellWithIdentifier:@"ChatSendInviteCell"];
   LongChatSendCell *sendLongCell = [tableView dequeueReusableCellWithIdentifier:@"LongChatSendCell"];
   
   ChatRecvTextCell *recvTxtCell = [tableView dequeueReusableCellWithIdentifier:@"ChatRecvTextCell"];
   ChatRecvImgCell *recvImgCell = [tableView dequeueReusableCellWithIdentifier:@"ChatRecvImgCell"];
   ChatRecvVideoCell *recvVideoCell = [tableView dequeueReusableCellWithIdentifier:@"ChatRecvVideoCell"];
   ChatRecvFileCell *recvFileCell = [tableView dequeueReusableCellWithIdentifier:@"ChatRecvFileCell"];
   ChatRecvInviteCell *recvInviteCell = [tableView dequeueReusableCellWithIdentifier:@"ChatRecvInviteCell"];
   LongChatRecvCell *recvLongCell = [tableView dequeueReusableCellWithIdentifier:@"LongChatRecvCell"];
   
   ChatRecvSysLineCell *sysLineCell = [tableView dequeueReusableCellWithIdentifier:@"ChatRecvSysLineCell"];
   
   if(self.msgData.chatArray!=nil){
      @try{
         NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
//         NSLog(@"msgDict : %@", msgDict);
         
         NSString *userNo = [msgDict objectForKey:@"USER_NO"];
         NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
         NSString *type = [msgDict objectForKey:@"TYPE"];
         
         //내가보낸 메시지일 경우
         if([type isEqualToString:@"MISSED"] || [[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
            
            if([contentType isEqualToString:@"TEXT"]){
               if (sendTxtCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatSendTextCell" owner:self options:nil];
                  
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[ChatSendTextCell class]]) {
                        sendTxtCell = (ChatSendTextCell *) currentObject;
                        [sendTxtCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
 
               sendTxtCell.dateLabel.text = nil;
               
               sendTxtCell.msgLabel.text = nil;
               sendTxtCell.readCntLabel.text = nil;
               sendTxtCell.timeLabel.text = nil;
               
               sendTxtCell.msgLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink|NSTextCheckingTypeAddress|NSTextCheckingTypePhoneNumber;
               sendTxtCell.msgLabel.userInteractionEnabled = YES;
               sendTxtCell.msgLabel.tttdelegate = self;
               
               [self setTextSendCell:sendTxtCell atIndexPath:indexPath];
               sendTxtCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               
               return sendTxtCell;
               
            } else if([contentType isEqualToString:@"IMG"]){
               if (sendImgCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatSendImgCell" owner:self options:nil];
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[ChatSendImgCell class]]) {
                        sendImgCell = (ChatSendImgCell *) currentObject;
                        [sendImgCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               sendImgCell.dateLabel.text = nil;
               sendImgCell.readCntLabel.text = nil;
               sendImgCell.timeLabel.text = nil;
               
               [self setImgSendCell:sendImgCell atIndexPath:indexPath];
               sendImgCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               
               return sendImgCell;
               
            } else if([contentType isEqualToString:@"VIDEO"]){
               if (sendVideoCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatSendVideoCell" owner:self options:nil];
                 
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[ChatSendVideoCell class]]) {
                        sendVideoCell = (ChatSendVideoCell *) currentObject;
                        [sendVideoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }

               sendVideoCell.dateLabel.text = nil;
               sendVideoCell.readCntLabel.text = nil;
               sendVideoCell.timeLabel.text = nil;
                 
               [self setVideoSendCell:sendVideoCell atIndexPath:indexPath];
               sendVideoCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
                 
               return sendVideoCell;
               
            } else if([contentType isEqualToString:@"FILE"]){
               if (sendFileCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatSendFileCell" owner:self options:nil];
                  
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[ChatSendFileCell class]]) {
                        sendFileCell = (ChatSendFileCell *) currentObject;
                        [sendFileCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               sendFileCell.timeLabel.text = nil;
               sendFileCell.dateLabel.text = nil;
               sendFileCell.readLabel.text = nil;
               sendFileCell.msgLabel.text = nil;
               sendFileCell.fileIcon.image = nil;
               
               [self setFileSendCell:sendFileCell atIndexPath:indexPath];
               sendFileCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               return sendFileCell;
               
            } else if([contentType isEqualToString:@"INVITE"]){
               if (sendInviteCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatSendInviteCell" owner:self options:nil];
                  
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[ChatSendInviteCell class]]) {
                        sendInviteCell = (ChatSendInviteCell *) currentObject;
                        [sendInviteCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               sendInviteCell.dateLabel.text = nil;
               sendInviteCell.readLabel.text = nil;
               sendInviteCell.timeLabel.text = nil;
               sendInviteCell.imgView.image = nil;
               sendInviteCell.titleLabel.text = nil;
               sendInviteCell.contentLabel.text = nil;
               
               [self setInviteSendCell:sendInviteCell atIndexPath:indexPath];
               sendInviteCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               return sendInviteCell;
               
            } else if([contentType isEqualToString:@"LONG_TEXT"]){
               if (sendLongCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"LongChatSendCell" owner:self options:nil];
                  
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[LongChatSendCell class]]) {
                        sendLongCell = (LongChatSendCell *) currentObject;
                        [sendLongCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               sendLongCell.dateLabel.text = nil;
               sendLongCell.readLabel.text = nil;
               sendLongCell.timeLabel.text = nil;
               sendLongCell.msgLabel.text = nil;
               
               [self setLongSendCell:sendLongCell atIndexPath:indexPath];
               sendLongCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               return sendLongCell;
               
            } else {
               
            }
            
         } else {
            if([contentType isEqualToString:@"TEXT"]){
               if (recvTxtCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatRecvTextCell" owner:self options:nil];
                  
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[ChatRecvTextCell class]]) {
                        recvTxtCell = (ChatRecvTextCell *) currentObject;
                        [recvTxtCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               recvTxtCell.dateLabel.text = nil;
               recvTxtCell.userImgView.image = nil;
               recvTxtCell.userName.text = nil;
               recvTxtCell.bubbleImage.image = nil;
               recvTxtCell.msgLabel.text = nil;
               recvTxtCell.readLabel.text = nil;
               recvTxtCell.timeLabel.text = nil;
               
               recvTxtCell.msgLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink|NSTextCheckingTypeAddress|NSTextCheckingTypePhoneNumber;
               recvTxtCell.msgLabel.userInteractionEnabled = YES;
               recvTxtCell.msgLabel.tttdelegate = self;
               
               [self setUpRecvCell:recvTxtCell atIndexPath:indexPath];
               recvTxtCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               
               return recvTxtCell;
               
            } else if([contentType isEqualToString:@"IMG"]){
               if (recvImgCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatRecvImgCell" owner:self options:nil];
                  
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[ChatRecvImgCell class]]) {
                        recvImgCell = (ChatRecvImgCell *) currentObject;
                        [recvImgCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               recvImgCell.dateLabel.text = nil;
               recvImgCell.userImgView.image = nil;
               recvImgCell.userName.text = nil;
               recvImgCell.imgMessage.image = nil;
               recvImgCell.readLabel.text = nil;
               recvImgCell.timeLabel.text = nil;
               
               [self setImgRecvCell:recvImgCell atIndexPath:indexPath];
               recvImgCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               
               return recvImgCell;
               
            } else if([contentType isEqualToString:@"VIDEO"]){
               if (recvVideoCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatRecvVideoCell" owner:self options:nil];
                  
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[ChatRecvVideoCell class]]) {
                        recvVideoCell = (ChatRecvVideoCell *) currentObject;
                        [recvVideoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               recvVideoCell.dateLabel.text = nil;
               recvVideoCell.userImgView.image = nil;
               recvVideoCell.userName.text = nil;
               recvVideoCell.imgMessage.image = nil;
               recvVideoCell.readLabel.text = nil;
               recvVideoCell.timeLabel.text = nil;
               
               [self setVideoRecvCell:recvVideoCell atIndexPath:indexPath];
               recvVideoCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               
               return recvVideoCell;
               
            } else if([contentType isEqualToString:@"FILE"]){
               if (recvFileCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatRecvFileCell" owner:self options:nil];
                  
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[ChatRecvFileCell class]]) {
                        recvFileCell = (ChatRecvFileCell *) currentObject;
                        [recvFileCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               recvFileCell.userName.text = nil;
               recvFileCell.userImgView.image = nil;
               recvFileCell.timeLabel.text = nil;
               recvFileCell.dateLabel.text = nil;
               recvFileCell.readLabel.text = nil;
               recvFileCell.msgLabel.text = nil;
               recvFileCell.fileIcon.image = nil;
               
               [self setFileRevcCell:recvFileCell atIndexPath:indexPath];
               recvFileCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               
               return recvFileCell;
               
            } else if([contentType isEqualToString:@"INVITE"]){
               if(recvInviteCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatRecvInviteCell" owner:self options:nil];
                  
                  for(id currentObject in topLevelObject) {
                     if([currentObject isKindOfClass:[ChatRecvInviteCell class]]){
                        recvInviteCell = (ChatRecvInviteCell *) currentObject;
                        [recvInviteCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               recvInviteCell.userImgView.image = nil;
               recvInviteCell.userName.text = nil;
               recvInviteCell.dateLabel.text = nil;
               recvInviteCell.readLabel.text = nil;
               recvInviteCell.timeLabel.text = nil;
               recvInviteCell.imgView.image = nil;
               recvInviteCell.titleLabel.text = nil;
               recvInviteCell.contentLabel.text = nil;
               
               [self setInviteRecvCell:recvInviteCell atIndexPath:indexPath];
               recvInviteCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               return recvInviteCell;
               
            } else if([contentType isEqualToString:@"LONG_TEXT"]){
               if (recvLongCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"LongChatRecvCell" owner:self options:nil];
                  
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[LongChatRecvCell class]]) {
                        recvLongCell = (LongChatRecvCell *) currentObject;
                        [recvLongCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               recvLongCell.dateLabel.text = nil;
               recvLongCell.userImgView.image = nil;
               recvLongCell.userName.text = nil;
               recvLongCell.readLabel.text = nil;
               recvLongCell.timeLabel.text = nil;
               recvLongCell.msgLabel.text = nil;
               
               [self setLongRecvCell:recvLongCell atIndexPath:indexPath];
               recvLongCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               return recvLongCell;
               
            } else if([contentType isEqualToString:@"SYS"]){
               if (sysLineCell == nil) {
                  NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatRecvSysLineCell" owner:self options:nil];
                  
                  for (id currentObject in topLevelObject) {
                     if ([currentObject isKindOfClass:[ChatRecvSysLineCell class]]) {
                        sysLineCell = (ChatRecvSysLineCell *) currentObject;
                        [sysLineCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                     }
                  }
               }
               
               sysLineCell.systemLabel.text = nil;
               
               [self setUpSysCell:sysLineCell atIndexPath:indexPath];
               sysLineCell.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatBgColor]];
               return sysLineCell;
               
            }
         }
      } @catch (NSException *exception) {
         NSLog(@"Exception : %@", exception);
      }
   }
   return nil;
}

#pragma mark - Setting Send TableView Cell
- (void)setTextSendCell:(ChatSendTextCell *)sendTxtCell atIndexPath:(NSIndexPath *)indexPath {
   NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
//   NSLog(@"sendText : %@", msgDict);
   
   @try{
//      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      NSString *decodeContent = [NSString urlDecodeString:content];
      NSString *date = [msgDict objectForKey:@"DATE"];
      NSString *decodeDate = [NSString urlDecodeString:date];
      NSString *aditInfo = [msgDict objectForKey:@"ADIT_INFO"];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSData *jsonData = [aditInfo dataUsingEncoding:NSUTF8StringEncoding];
      NSError *e;
      NSDictionary *aditDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
      
      NSString *localImgPath = @"";
      if([aditDic objectForKey:@"LOCAL_CONTENT"] !=nil) {
         localImgPath = [aditDic objectForKey:@"LOCAL_CONTENT"];
      }
      NSString *sendType = [aditDic objectForKey:@"TYPE"];
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:decodeDate];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      UIImage *bubble = [[UIImage imageNamed:@"bubble.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
      UIColor *color = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatSendBubbleColor]];
      sendTxtCell.bubbleImage.image = [bubble imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      [sendTxtCell.bubbleImage setTintColor:color];
      
      sendTxtCell.timeLabel.text = decodeTime;
      
      if([chatRoomType isEqualToString:@"0"]||[chatRoomType isEqualToString:@"3"]){
         //알림톡이거나 나와의채팅일 경우 읽음카운트 숨김
         sendTxtCell.readCntLabel.hidden = YES;
         
      } else {
         if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
            sendTxtCell.readCntLabel.hidden = NO;
            sendTxtCell.readCntLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
            sendTxtCell.readCntLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
            
         } else {
            sendTxtCell.readCntLabel.hidden = YES;
         }
      }
      
//      NSLog(@"sendType : %@", sendType);
      
//      if([sendType isEqualToString:@"SENDING"]){ //계속 앞에 \^PSUCCEED 이런식으로 들어와서 수정. 왜 저렇게 들어오는지 원인은 모르겠음
      if([sendType rangeOfString:@"SENDING"].location!=NSNotFound){
         sendTxtCell.timeLabel.hidden = YES;
         sendTxtCell.failButton.hidden = YES;
         [sendTxtCell.indicator startAnimating];
         
      } else if([sendType rangeOfString:@"SUCCEED"].location!=NSNotFound){
//      } else if([sendType isEqualToString:@"SUCCEED"]){
         sendTxtCell.timeLabel.hidden = NO;
         sendTxtCell.failButton.hidden = YES;
         [sendTxtCell.indicator setHidesWhenStopped:YES];
         [sendTxtCell.indicator stopAnimating];
         
      } else if([sendType rangeOfString:@"FAILED"].location!=NSNotFound){
//      } else if([sendType isEqualToString:@"FAILED"]){
         sendTxtCell.timeLabel.hidden = YES;
         sendTxtCell.failButton.hidden = NO;
         [sendTxtCell.indicator setHidesWhenStopped:YES];
         [sendTxtCell.indicator stopAnimating];
         
      } else {
         //DATE
         sendTxtCell.timeLabel.hidden = YES;
         sendTxtCell.failButton.hidden = YES;
         [sendTxtCell.indicator setHidesWhenStopped:YES];
         [sendTxtCell.indicator stopAnimating];
      }
      
      if (indexPath.item == 0) {
         sendTxtCell.dateLabel.text = dateStr;
         sendTxtCell.dateContainer.hidden = NO;
         sendTxtCell.dateContainerConstraint.constant=40;
      
      } else if (indexPath.item > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         if (![pDateStr isEqualToString:cDateStr]) {
            sendTxtCell.dateLabel.text = dateStr;
            sendTxtCell.dateContainer.hidden = NO;
            sendTxtCell.dateContainerConstraint.constant=40;
            
         } else {
            sendTxtCell.dateContainer.hidden = YES;
            sendTxtCell.dateContainerConstraint.constant=0;
         }
      }
      
      [sendTxtCell.msgLabel setText:decodeContent];
      
      //채팅내용 검색결과
      if(self.searchText.length>0){
         if([decodeContent rangeOfString:[NSString stringWithFormat:@"%@", self.searchText]].location != NSNotFound){
            sendTxtCell.msgLabel.attributedText = [self textGetRanges:decodeContent keyword:self.searchText];
         }
      }
      
      UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
      sendTxtCell.failButton.tag = indexPath.row;
      [sendTxtCell.failButton addGestureRecognizer:gesture];
      
      UILongPressGestureRecognizer *txtLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(txtLongTapDetected:)];
      txtLongPress.minimumPressDuration = 0.5;
      txtLongPress.delegate = self;
      [sendTxtCell.msgLabel addGestureRecognizer:txtLongPress];

   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)setImgSendCell:(ChatSendImgCell *)sendImgCell atIndexPath:(NSIndexPath *)indexPath {
   NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
//   UIImage *imgMsg = [[UIImage alloc] init];
    sendImgMsg = [[UIImage alloc] init];
   
   @try{
      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      NSString *decodeContent = [NSString urlDecodeString:content];
      NSString *date = [msgDict objectForKey:@"DATE"];
      NSString *decodeDate = [NSString urlDecodeString:date];
      NSString *fileThumb = [msgDict objectForKey:@"FILE_THUMB"];
      NSString *decodeFileThumb = [NSString urlDecodeString:fileThumb];
      NSString *aditInfo = [msgDict objectForKey:@"ADIT_INFO"];
//      NSString *fileName = [msgDict objectForKey:@"FILE_NM"];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSData *jsonData = [aditInfo dataUsingEncoding:NSUTF8StringEncoding];
      NSError *e;
      NSDictionary *aditDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
      
      NSString *localImgPath = @"";
      if([aditDic objectForKey:@"LOCAL_CONTENT"] !=nil) {
         localImgPath = [aditDic objectForKey:@"LOCAL_CONTENT"];
      }
      NSString *sendType = [aditDic objectForKey:@"TYPE"];
      
      NSString *loacalThumbPath = [self creatLocalChatFolder:contentType roomNo:self.roomNo chatDate:decodeDate];
      
      NSMutableString *contentStr = nil;
               
      if([content isEqualToString:@""]){
         contentStr = [[NSMutableString alloc]initWithString:localImgPath];
//            NSLog(@"I_실패한데이터 contentStr : %@", contentStr);
      } else if(![content isEqualToString:@""] && decodeFileThumb == nil){
         contentStr = [[NSMutableString alloc]initWithString:localImgPath];
         if([contentStr isEqualToString:@""]) contentStr = [decodeContent mutableCopy];
         //NSLog(@"I_불러온데이터 contentStr : %@", contentStr);
      } else {
         contentStr = [[NSMutableString alloc]initWithString:decodeContent];
         //NSLog(@"I_전송한데이터 contentStr : %@", contentStr);
      }
      
      NSRange range = [contentStr rangeOfString:@"/" options:NSBackwardsSearch];
      NSMutableString *localStr = [[NSMutableString alloc]initWithString:contentStr];
      if(![content isEqualToString:@""] && decodeFileThumb != nil){
         [localStr insertString:@"/thumb" atIndex:range.location];
      }
      
      @try {
         if([content isEqualToString:@""]){
            NSString *thumbfileName = [contentStr substringFromIndex:range.location+1];
            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",thumbfileName]];
//            NSLog(@"실패,사진촬영 imagePath : %@", imagePath);
            
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            UIImage *image = [UIImage imageWithData:data];
            if(image){
               //큰이미지 사이즈조절
               if(image.size.height > image.size.width*2) {
                  UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : image];
                  image = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
               } else {
                  image = [MFUtil getScaledLowImage:image scaledToMaxWidth:180.0f];
               }
               
               if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
                  //실패이미지를 위해 이미지 저장
                  NSData *imageThumbData = UIImagePNGRepresentation(image);
                  [imageThumbData writeToFile:imagePath atomically:YES];
                  
                  NSLog(@"실패이미지를 위해 이미지 저장(이미지있음) : %@", imagePath);
               }
               
               sendImgMsg = image;
               
            } else {
               //서버에서 이미지 만료에 대한 값을 줌. 그 값 받아서 만료 이미지 처리하면 됨.
               
               if([self checkExpireChatImg:decodeDate]){
                  //이미지 만료됨
                  UIImage *expireImg = [UIImage imageNamed:@""];
                  sendImgMsg = expireImg;
                  
               } else {
                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:decodeContent]];
                     UIImage *urlImg = [UIImage imageWithData:data];

                     //큰이미지 사이즈조절
                     if(urlImg.size.height > urlImg.size.width*2) {
                        UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : urlImg];
                        urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
                     } else {
                        urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
                     }

                     if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
                        //실패이미지를 위해 이미지 저장
                        NSData *imageThumbData = UIImagePNGRepresentation(image);
                        [imageThumbData writeToFile:imagePath atomically:YES];

                        NSLog(@"실패이미지를 위해 이미지 저장(이미지없음) : %@", imagePath);
                     }

                     sendImgMsg = urlImg;
                     
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                     [self.tableView beginUpdates];
//                     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                     [self.tableView endUpdates];
//                     });
                     
//                  imgMsg = nil;
                  });
               }
            }
            
         } else {
            NSString *fileName = [contentStr substringFromIndex:range.location+1]; //msgDict의 FILE_NM과 같은지 확인. 같으면 msgDict데이터 사용.
            
            //썸네일이미지
            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
//               NSLog(@"불러온데이터 imagePath : %@", imagePath);
            
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            UIImage *image = [UIImage imageWithData:data];
            if(image){
               sendImgMsg = image;
               
            } else {
               if([self checkExpireChatImg:decodeDate]){
                  //이미지 만료됨
                  UIImage *expireImg = [UIImage imageNamed:@""];
                  sendImgMsg = expireImg;
                  
               } else {
                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:decodeContent]];
                     UIImage *urlImg = [UIImage imageWithData:data];
                     
                     //큰이미지 사이즈조절
                     if(urlImg.size.height > urlImg.size.width*2) {
                        UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : urlImg];
                        urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
                     } else {
                        urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
                     }
                     
                     if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
                        //실패이미지를 위해 이미지 저장
                        NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
                        [imageThumbData writeToFile:imagePath atomically:YES];
                        
                        NSLog(@"이미지없을때 이미지 저장 : %@", imagePath);
                     }
                     
                     sendImgMsg = urlImg;
                     //                  imgMsg = nil;
                     
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                     [self.tableView beginUpdates];
//                     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                     [self.tableView endUpdates];
//                     });
                  });
               }
            }
         }
      } @catch (NSException *exception) {
//            NSLog(@"setUpSendCell img exception : %@", exception);
      }
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:decodeDate];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      sendImgCell.timeLabel.text = decodeTime;
      
      if([chatRoomType isEqualToString:@"0"]||[chatRoomType isEqualToString:@"3"]){
         //알림톡이거나 나와의채팅일 경우 읽음카운트 숨김
         sendImgCell.readCntLabel.hidden = YES;
         
      } else {
         if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
            sendImgCell.readCntLabel.hidden = NO;
            sendImgCell.readCntLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
            sendImgCell.readCntLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
            
         } else {
            sendImgCell.readCntLabel.hidden = YES;
         }
      }
      
      if([sendType rangeOfString:@"SENDING"].location!=NSNotFound){
//      if([sendType isEqualToString:@"SENDING"]){
         sendImgCell.timeLabel.hidden = YES;
         sendImgCell.failButton.hidden = YES;
         [sendImgCell.indicator startAnimating];
        
      } else if([sendType rangeOfString:@"SUCCEED"].location!=NSNotFound){
//      } else if([sendType isEqualToString:@"SUCCEED"]){
         sendImgCell.timeLabel.hidden = NO;
         sendImgCell.failButton.hidden = YES;
         [sendImgCell.indicator setHidesWhenStopped:YES];
         [sendImgCell.indicator stopAnimating];
         
      } else if([sendType rangeOfString:@"FAILED"].location!=NSNotFound){
//      } else if([sendType isEqualToString:@"FAILED"]){
         sendImgCell.timeLabel.hidden = YES;
         sendImgCell.failButton.hidden = NO;
         [sendImgCell.indicator setHidesWhenStopped:YES];
         [sendImgCell.indicator stopAnimating];
         
      } else {
         //DATE
         sendImgCell.timeLabel.hidden = YES;
         sendImgCell.failButton.hidden = YES;
         [sendImgCell.indicator setHidesWhenStopped:YES];
         [sendImgCell.indicator stopAnimating];
      }
      
      if (indexPath.item == 0) {
         sendImgCell.dateLabel.text = dateStr;
         sendImgCell.dateContainer.hidden = NO;
         sendImgCell.dateContainerConstraint.constant=40;
         
      } else if (indexPath.item > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         if (![pDateStr isEqualToString:cDateStr]) {
            sendImgCell.dateLabel.text = dateStr;
            sendImgCell.dateContainer.hidden = NO;
            sendImgCell.dateContainerConstraint.constant=40;
            
         } else {
            sendImgCell.dateContainer.hidden = YES;
            sendImgCell.dateContainerConstraint.constant=0;
         }
      }
      
      if([decodeContent rangeOfString:@"https://"].location != NSNotFound || [decodeContent rangeOfString:@"http://"].location != NSNotFound){
         sendImgCell.imgMessage.tag = indexPath.row;
         
         if(sendImgMsg==nil){
            if([decodeContent rangeOfString:@" "].location != NSNotFound){
               decodeContent = [decodeContent stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            }

//            [sendImgCell.imgMessage sd_setImageWithURL:[NSURL URLWithString:decodeContent]
//                               placeholderImage:[UIImage imageNamed:@"chat_trans.png"]
//                                        options:0
//                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                         //큰이미지 사이즈조절
//                                         UIImage *urlImg = image;
//                                         if(urlImg.size.height > urlImg.size.width*2) {
//                                            UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) :urlImg];
//                                            urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
//                                         } else {
//                                            urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
//                                         }
//                                         sendImgCell.imgMessage.image = urlImg;
//
//                                         NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[decodeContent lastPathComponent]]];
//
//                                         if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
//                                            //실패이미지를 위해 이미지 저장
//                                            NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
//                                            [imageThumbData writeToFile:imagePath atomically:YES];
////                                                  NSLog(@"1이미지 실패이미지를 위해 이미지 저장(이미지없음) : %@", imagePath);
//                                         }
//                                    }];
            sendImgCell.imgMessage.image = sendImgMsg;
            
         } else {
            sendImgCell.imgMessage.image = sendImgMsg;
         }
         
      } else{
         //전송실패 IMG메시지
         NSString *thumbFilePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[localImgPath lastPathComponent]]];
         
         if(aditInfo != nil){
            NSData *data = [NSData dataWithContentsOfFile:thumbFilePath];
            UIImage *image = [UIImage imageWithData:data];
            
            sendImgCell.imgMessage.image = image;
         }
         
         //indexpath>0일때는 sendImgCell.imgMessage.image = imgMsg; 이렇게 되있었음
      }
      
      UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
      sendImgCell.failButton.tag = indexPath.row;
      [sendImgCell.failButton addGestureRecognizer:gesture];

      UITapGestureRecognizer *sendImgGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatImgTapGesture:)];
      sendImgCell.imgMessage.tag = indexPath.row;
      [sendImgCell.imgMessage setUserInteractionEnabled:YES];
      [sendImgCell.imgMessage addGestureRecognizer:sendImgGesture];

      UILongPressGestureRecognizer *imgLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imgLongTapDetected:)];
      imgLongPress.minimumPressDuration = 0.5;
      imgLongPress.delegate = self;
      [sendImgCell.imgMessage addGestureRecognizer:imgLongPress];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

-(void)videoCompessing:(float)progress{
   dispatch_async(dispatch_get_main_queue(), ^{
//      NSLog(@"progress : %f", progress);
      sendVideoCell.playButton.hidden = YES;
      sendVideoCell.compressView.hidden = NO;
      
      [sendVideoCell.compressView setPrimaryColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]]];
      [sendVideoCell.compressView setProgress:progress animated: YES];
   });
}

- (void)setVideoSendCell:(ChatSendVideoCell *)sendVideoCell atIndexPath:(NSIndexPath *)indexPath {
   NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
//   UIImage *imgMsg = [[UIImage alloc] init];
   sendVdoMsg = [[UIImage alloc] init];
//   NSLog(@"video msgDict : %@", msgDict);
   
   sendVideoCell.playButton.hidden = YES;
   sendVideoCell.compressView.hidden = YES;
   
   @try{
      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      NSString *decodeContent = [NSString urlDecodeString:content];
      NSString *date = [msgDict objectForKey:@"DATE"];
      NSString *decodeDate = [NSString urlDecodeString:date];
      NSString *fileThumb = [msgDict objectForKey:@"FILE_THUMB"];
      NSString *decodeFileThumb = [NSString urlDecodeString:fileThumb];
      NSString *aditInfo = [msgDict objectForKey:@"ADIT_INFO"];
      NSString *fileName = [msgDict objectForKey:@"FILE_NM"];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSRange fileRange = [decodeContent rangeOfString:@"/" options:NSBackwardsSearch];
      if([fileName isEqualToString:@""] || fileName==nil){
         NSString *fNamePath = [decodeContent substringFromIndex:fileRange.location+1];
         NSRange range2 = [fNamePath rangeOfString:@"." options:NSBackwardsSearch];
         NSString *fName = [fNamePath substringToIndex:range2.location];
         fileName = [NSString stringWithFormat:@"%@.png", fName];
      }
      
      NSData *jsonData = [aditInfo dataUsingEncoding:NSUTF8StringEncoding];
      NSError *e;
      NSDictionary *aditDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
      
      NSString *localImgPath = @"";
      if([aditDic objectForKey:@"LOCAL_CONTENT"] !=nil) {
         localImgPath = [aditDic objectForKey:@"LOCAL_CONTENT"];
      }
      NSString *sendType = [aditDic objectForKey:@"TYPE"];
      
      NSString *loacalThumbPath = [self creatLocalChatFolder:contentType roomNo:self.roomNo chatDate:decodeDate];
      
      NSMutableString *contentStr = nil;
               
      if([content isEqualToString:@""]){
         contentStr = [[NSMutableString alloc]initWithString:localImgPath];
//            NSLog(@"V_실패한데이터 contentStr : %@", contentStr);
      } else if(![content isEqualToString:@""] && decodeFileThumb == nil){
         contentStr = [[NSMutableString alloc]initWithString:localImgPath];
         if([contentStr isEqualToString:@""]) contentStr = [decodeContent mutableCopy];
//            NSLog(@"V_불러온데이터 contentStr : %@", contentStr);
      } else {
         contentStr = [[NSMutableString alloc]initWithString:decodeFileThumb];
//            NSLog(@"V_전송한데이터 contentStr : %@", contentStr);
      }
      
      NSRange range = [contentStr rangeOfString:@"/" options:NSBackwardsSearch];
      NSMutableString *localStr = [[NSMutableString alloc]initWithString:contentStr];
      if(![content isEqualToString:@""] && decodeFileThumb != nil){
         [localStr insertString:@"/thumb" atIndex:range.location];
      }
      
      @try {
         if([content isEqualToString:@""]){
            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
            
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            UIImage *image = [UIImage imageWithData:data];
            
            if(image){
               //큰이미지 사이즈조절
               if(image.size.height > image.size.width*2) {
                  UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : image];
                  image = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
               } else {
                  image = [MFUtil getScaledLowImage:image scaledToMaxWidth:180.0f];
               }
               
               if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
                  //실패이미지를 위해 이미지 저장
                  NSData *imageThumbData = UIImagePNGRepresentation(image);
                  [imageThumbData writeToFile:imagePath atomically:YES];
                  
                  NSLog(@"실패이미지를 위해 비디오이미지 저장(비디오이미지있음) : %@", imagePath);
               }
               
               sendVdoMsg = image;
               
            } else {
               if([self checkExpireChatImg:decodeDate]){
                  //이미지 만료됨
                  UIImage *expireImg = [UIImage imageNamed:@""];
                  sendVdoMsg = expireImg;
                  
               } else {
//                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                  NSRange range = [decodeContent rangeOfString:@"/" options:NSBackwardsSearch];
                  NSString *filePath = [decodeContent substringToIndex:range.location+1];
                  NSString *filePath2 = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb/%@",fileName]];

                  NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath2]];
                  UIImage *urlImg = [UIImage imageWithData:data];

                  //큰이미지 사이즈조절
                  if(urlImg.size.height > urlImg.size.width*2) {
                     UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : urlImg];
                     urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
                  } else {
                     urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
                  }

                  if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
                     //실패이미지를 위해 이미지 저장
                     NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
                     [imageThumbData writeToFile:imagePath atomically:YES];

                     NSLog(@"실패이미지를 위해 비디오이미지 저장(비디오이미지없음) : %@", imagePath);
                  }

                  sendVdoMsg = urlImg;
//                     imgMsg = nil;
                     
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                     [self.tableView beginUpdates];
//                     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                     [self.tableView endUpdates];
//                     });
//                  });
               }
               
            }
            
         } else {
            //NSString *fileName = [contentStr substringFromIndex:range.location+1];
            //썸네일이미지
            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
//               NSLog(@"불러온데이터 imagePath : %@", imagePath);
            
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            UIImage *image = [UIImage imageWithData:data];
//               NSLog(@"이미지 없냐 ? : %@", image);
            
            if(image){
//                  NSLog(@"이미지 있는데..?");
               sendVdoMsg = image;
               
            } else {
               if([self checkExpireChatImg:decodeDate]){
                  //이미지 만료됨
                  UIImage *expireImg = [UIImage imageNamed:@""];
                  sendVdoMsg = expireImg;
                  
               } else {
//                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                  NSRange range = [decodeContent rangeOfString:@"/" options:NSBackwardsSearch];
                  NSString *filePath = [decodeContent substringToIndex:range.location+1];
                  NSString *filePath2 = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb/%@",fileName]];

                  NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath2]];
                  UIImage *urlImg = [UIImage imageWithData:data];
                  
                  
                  //큰이미지 사이즈조절
                  if(urlImg.size.height > urlImg.size.width*2) {
                     UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : urlImg];
                     urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
                  } else {
                     urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
                  }

                  if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
                     //실패이미지를 위해 이미지 저장
                     NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
                     [imageThumbData writeToFile:imagePath atomically:YES];

                     NSLog(@"비디오이미지 없을때 비디오이미지 저장(비디오이미지없음) : %@", imagePath);
                  }

                  sendVdoMsg = urlImg;
                  
//                     imgMsg = nil;
                     
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                     [self.tableView beginUpdates];
//                     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                     [self.tableView endUpdates];
//                     });
//                  });
               }
            }
         }
      } @catch (NSException *exception) {
//            NSLog(@"setUpSendCell VIDEO exception : %@", exception);
      }
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:decodeDate];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      sendVideoCell.timeLabel.text = decodeTime;
      
      if([chatRoomType isEqualToString:@"0"]||[chatRoomType isEqualToString:@"3"]){
         //알림톡이거나 나와의채팅일 경우 읽음카운트 숨김
         sendVideoCell.readCntLabel.hidden = YES;
         
      } else {
         if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
            sendVideoCell.readCntLabel.hidden = NO;
            sendVideoCell.readCntLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
            sendVideoCell.readCntLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
            
         } else {
            sendVideoCell.readCntLabel.hidden = YES;
         }
      }
      
//      if([sendType isEqualToString:@"SENDING"]){
      if([sendType rangeOfString:@"SENDING"].location!=NSNotFound){
         sendVideoCell.timeLabel.hidden = YES;
         sendVideoCell.failButton.hidden = YES;
         [sendVideoCell.indicator startAnimating];
         
//      } else if([sendType isEqualToString:@"SUCCEED"]){
      } else if([sendType rangeOfString:@"SUCCEED"].location!=NSNotFound){
         sendVideoCell.timeLabel.hidden = NO;
         sendVideoCell.failButton.hidden = YES;
         [sendVideoCell.indicator setHidesWhenStopped:YES];
         [sendVideoCell.indicator stopAnimating];
         
         sendVideoCell.playButton.hidden = NO;
         sendVideoCell.compressView.hidden = YES;
         
//      } else if([sendType isEqualToString:@"FAILED"]){
      } else if([sendType rangeOfString:@"FAILED"].location!=NSNotFound){
         sendVideoCell.timeLabel.hidden = YES;
         sendVideoCell.failButton.hidden = NO;
         [sendVideoCell.indicator setHidesWhenStopped:YES];
         [sendVideoCell.indicator stopAnimating];
         
      } else {
         //DATE
         sendVideoCell.timeLabel.hidden = YES;
         sendVideoCell.failButton.hidden = YES;
         [sendVideoCell.indicator setHidesWhenStopped:YES];
         [sendVideoCell.indicator stopAnimating];
      }
      
      if (indexPath.item == 0) {
         sendVideoCell.dateLabel.text = dateStr;
         sendVideoCell.dateContainer.hidden = NO;
         sendVideoCell.dateContainerConstraint.constant=40;
         
      } else if (indexPath.item > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         if (![pDateStr isEqualToString:cDateStr]) {
            sendVideoCell.dateLabel.text = dateStr;
            sendVideoCell.dateContainer.hidden = NO;
            sendVideoCell.dateContainerConstraint.constant=40;
            
         } else {
            sendVideoCell.dateContainer.hidden = YES;
            sendVideoCell.dateContainerConstraint.constant=0;
         }
      }
      
      if([decodeFileThumb rangeOfString:@"https://"].location != NSNotFound || [decodeFileThumb rangeOfString:@"http://"].location != NSNotFound){
         sendVideoCell.imgMessage.tag = indexPath.row;
         sendVideoCell.playButton.tag = indexPath.row;

         if(sendVdoMsg==nil){
            NSLog(@"이미지가 없다");
            NSRange range = [decodeContent rangeOfString:@"/" options:NSBackwardsSearch];
            NSString *filePath = [decodeContent substringToIndex:range.location+1];
            NSString *filePath2 = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb/%@",fileName]];

            if([filePath2 rangeOfString:@" "].location != NSNotFound){
               filePath2 = [filePath2 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            }

            sendVideoCell.imgMessage.image = sendVdoMsg;
            
//               [sendVideoCell.imgMessage sd_setImageWithURL:[NSURL URLWithString:filePath2]
//                                      placeholderImage:[UIImage imageNamed:@"chat_trans.png"]
//                                               options:0
//                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                                //큰이미지 사이즈조절
//                                                UIImage *urlImg = image;
//
//                                                //큰이미지 사이즈조절
//                                                if(urlImg.size.height > urlImg.size.width*2) {
//                                                   UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : urlImg];
//                                                   urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
//                                                } else {
//                                                   urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
//                                                }
//
//                                                sendVideoCell.imgMessage.image = urlImg;
//
//                                                NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
//
//                                                if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
//                                                   //실패이미지를 위해 이미지 저장
//                                                   NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
//                                                   [imageThumbData writeToFile:imagePath atomically:YES];
////                                                      NSLog(@"1비디오 실패이미지를 위해 비디오이미지 저장(비디오이미지없음) : %@", imagePath);
//                                                }
//                                             }];

         } else {
            sendVideoCell.imgMessage.image = sendVdoMsg;
         }

      } else {
         //전송실패 IMG메시지
         NSString *thumbFilePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[localImgPath lastPathComponent]]];

         if(aditInfo != nil){
            NSData *data = [NSData dataWithContentsOfFile:thumbFilePath];
            UIImage *image = [UIImage imageWithData:data];

            sendVideoCell.imgMessage.image = image;
         }
         
         //indexpath>0일때는 sendVideoCell.imgMessage.image = imgMsg; 이렇게 되있었음
      }
      
      UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
      sendVideoCell.failButton.tag = indexPath.row;
      [sendVideoCell.failButton addGestureRecognizer:gesture];

      UITapGestureRecognizer *sendVideoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatVideoTapGesture:)];
      sendVideoCell.videoContainer.tag = indexPath.row;
      [sendVideoCell.videoContainer setUserInteractionEnabled:YES];
      [sendVideoCell.videoContainer addGestureRecognizer:sendVideoGesture];

      [sendVideoCell.playButton addTarget:self action:@selector(chatVideoTapGesture:) forControlEvents:UIControlEventTouchUpInside];

      UILongPressGestureRecognizer *videoLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(videoLongTapDetected:)];
      videoLongPress.minimumPressDuration = 0.5;
      videoLongPress.delegate = self;
      [sendVideoCell.videoContainer addGestureRecognizer:videoLongPress];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)setFileSendCell:(ChatSendFileCell *)sendFileCell atIndexPath:(NSIndexPath *)indexPath {
   NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
   
   @try{
      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      content = [MFUtil replaceEncodeToChar:content];
      
      NSString *decodeContent = [NSString urlDecodeString:content];
      NSString *date = [msgDict objectForKey:@"DATE"];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:date];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      UIImage *bubble = [[UIImage imageNamed:@"bubble.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
      UIColor *color = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatSendBubbleColor]];
      
      sendFileCell.bubbleImage.image = [bubble imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      [sendFileCell.bubbleImage setTintColor:color];
      
      sendFileCell.timeLabel.text = decodeTime;
     
      if([chatRoomType isEqualToString:@"0"]||[chatRoomType isEqualToString:@"3"]){
         //알림톡이거나 나와의채팅일 경우 읽음카운트 숨김
         sendFileCell.readLabel.hidden = YES;
         
      } else {
         if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
            sendFileCell.readLabel.hidden = NO;
            sendFileCell.readLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
            sendFileCell.readLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
            
         } else {
            sendFileCell.readLabel.hidden = YES;
         }
      }
      
      if (indexPath.item == 0) {
         sendFileCell.dateLabel.text = dateStr;
         sendFileCell.dateContainer.hidden = NO;
         sendFileCell.dateContainerConstraint.constant = 40;
      
      } else if (indexPath.item  > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         //NSLog(@"pd : %@, cd : %@", pDateStr, cDateStr);
         
         if (![pDateStr isEqualToString:cDateStr]) {
            sendFileCell.dateLabel.text = dateStr;
            sendFileCell.dateContainer.hidden = NO;
            sendFileCell.dateContainerConstraint.constant = 40;
            
         } else {
            sendFileCell.dateContainer.hidden = YES;
            sendFileCell.dateContainerConstraint.constant = 0;
         }
      }
      
      NSString *file = @"";
      @try{
         file = [decodeContent lastPathComponent];
         
      } @catch (NSException *exception) {
         file = decodeContent;
         NSLog(@"Exception : %@", exception);
      }
      
      sendFileCell.msgLabel.text = file;
      
      NSRange range = [file rangeOfString:@"." options:NSBackwardsSearch];
      NSString *fileExt = [[file substringFromIndex:range.location+1] lowercaseString];
      
      if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_img.png"];
         
      } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_movie.png"];
         
      } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_music.png"];
         
      } else if([fileExt isEqualToString:@"psd"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_psd.png"];
         
      } else if([fileExt isEqualToString:@"ai"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_ai.png"];
         
      } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_word.png"];
         
      } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_ppt.png"];
         
      } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_excel.png"];
         
      } else if([fileExt isEqualToString:@"pdf"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_pdf.png"];
         
      } else if([fileExt isEqualToString:@"txt"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_txt.png"];
         
      } else if([fileExt isEqualToString:@"hwp"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_hwp.png"];
         
      } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_zip.png"];
         
      } else {
         sendFileCell.fileIcon.image = [UIImage imageNamed:@"file_document.png"];
      }
      
      UITapGestureRecognizer *fileTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFileOnTable:)];
      sendFileCell.msgLabel.tag = indexPath.row;
      [sendFileCell.msgLabel setUserInteractionEnabled:YES];
      [sendFileCell.msgLabel addGestureRecognizer:fileTap];
      
      UILongPressGestureRecognizer *fileLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fileLongTapDetected:)];
      fileLongPress.minimumPressDuration = 0.5;
      fileLongPress.delegate = self;
      [sendFileCell.msgLabel addGestureRecognizer:fileLongPress];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)setInviteSendCell:(ChatSendInviteCell *)sendInviteCell atIndexPath:(NSIndexPath *)indexPath {
   @try{
      NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
      NSLog(@"Send MsgDict : %@", msgDict);
      
//      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      //        if([content rangeOfString:@"%"].location != NSNotFound){dict :
      //            content = [content stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
      //        }
      //        if([content rangeOfString:@"&"].location != NSNotFound){
      //            content = [content stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
      //        }
      
      NSString *date = [msgDict objectForKey:@"DATE"];
//      NSString *pushType = [msgDict objectForKey:@"TYPE"];
//      NSString *fileThumb = [NSString urlDecodeString:[msgDict objectForKey:@"FILE_THUMB"]];
      NSString *aditInfo = [msgDict objectForKey:@"ADIT_INFO"];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
      NSError *error;
      NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
      
      NSString *snsNm = [dict objectForKey:@"SNS_NM"];
      NSLog(@"snsNM : %@", snsNm);
      NSString *snsDesc = [dict objectForKey:@"SNS_DESC"];
      NSString *snsCoverImage = [dict objectForKey:@"SNS_COVER_IMG"];
      
      NSData *jsonData2 = [aditInfo dataUsingEncoding:NSUTF8StringEncoding];
      NSError *e;
      NSDictionary *aditDic = [NSJSONSerialization JSONObjectWithData:jsonData2 options:0 error:&e];
      
      NSString *sendType = [aditDic objectForKey:@"TYPE"];
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:date];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      UIImage *bubble = [[UIImage imageNamed:@"bubble.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
      UIColor *color = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatSendBubbleColor]];
      
      sendInviteCell.bubbleImg.image = [bubble imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      [sendInviteCell.bubbleImg setTintColor:color];
      
      UITapGestureRecognizer *bubbleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMoreHandler:)];
      sendInviteCell.bubbleImg.tag = indexPath.row;
      [sendInviteCell.bubbleImg setUserInteractionEnabled:YES];
      [sendInviteCell.bubbleImg addGestureRecognizer:bubbleTap];
      
      sendInviteCell.imgView.layer.cornerRadius = sendInviteCell.imgView.frame.size.width/10;
      sendInviteCell.imgView.clipsToBounds = YES;
      
      if(![snsCoverImage isEqualToString:@""]&&![snsCoverImage isEqualToString:@"null"]&&snsCoverImage!=nil){
         UIImage *image = [MFUtil saveThumbImage:@"Cover" path:snsCoverImage num:nil];
         if(image!=nil){
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(185, 105) :image];
            sendInviteCell.imgView.image = postCover;
         } else {
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(185, 105) :[UIImage imageNamed:@"cover3-2.png"]];
            sendInviteCell.imgView.image = postCover;
         }
      } else {
         UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(185, 105) :[UIImage imageNamed:@"cover3-2.png"]];
         sendInviteCell.imgView.image = postCover;
      }
      
      [sendInviteCell.titleLabel setNumberOfLines:0];
      
      [sendInviteCell.contentLabel setNumberOfLines:3];
      [sendInviteCell.contentLabel setLineBreakMode:NSLineBreakByTruncatingTail];
      
      sendInviteCell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"invite_title", @"invite_title"), snsNm];
      sendInviteCell.contentLabel.text = snsDesc;
      
      [sendInviteCell.moreButton setImage:[MFUtil getScaledLowImage:[UIImage imageNamed:@"icon_popup.png"] scaledToMaxWidth:10.0f] forState:UIControlStateNormal];
      [sendInviteCell.moreButton setImageEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0)];
      [sendInviteCell.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
      [sendInviteCell.moreButton setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
      [sendInviteCell.moreButton setTitle:NSLocalizedString(@"invite_more", @"invite_more") forState:UIControlStateNormal];
      sendInviteCell.moreButton.tag = indexPath.row;
      [sendInviteCell.moreButton addTarget:self action:@selector(tapMoreButton:) forControlEvents:UIControlEventTouchUpInside];
      
      sendInviteCell.timeLabel.text = decodeTime;
 
      if([chatRoomType isEqualToString:@"0"]||[chatRoomType isEqualToString:@"3"]){
         //알림톡이거나 나와의채팅일 경우 읽음카운트 숨김
         sendInviteCell.readLabel.hidden = YES;
         
      } else {
         if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
            sendInviteCell.readLabel.hidden = NO;
            sendInviteCell.readLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
            sendInviteCell.readLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
            
         } else {
            sendInviteCell.readLabel.hidden = YES;
         }
      }
      
      if([sendType rangeOfString:@"SENDING"].location!=NSNotFound){
//      if([sendType isEqualToString:@"SENDING"]){
         sendInviteCell.timeLabel.hidden = YES;
         sendInviteCell.failButton.hidden = YES;
         [sendInviteCell.indicator startAnimating];
         
      } else if([sendType rangeOfString:@"SUCCEED"].location!=NSNotFound){
//      } else if([sendType isEqualToString:@"SUCCEED"]){
         sendInviteCell.timeLabel.hidden = NO;
         sendInviteCell.failButton.hidden = YES;
         [sendInviteCell.indicator setHidesWhenStopped:YES];
         [sendInviteCell.indicator stopAnimating];
         
      } else if([sendType rangeOfString:@"FAILED"].location!=NSNotFound){
//      } else if([sendType isEqualToString:@"FAILED"]){
         sendInviteCell.timeLabel.hidden = YES;
         sendInviteCell.failButton.hidden = NO;
         [sendInviteCell.indicator setHidesWhenStopped:YES];
         [sendInviteCell.indicator stopAnimating];
         
      } else {
         //DATE
         sendInviteCell.timeLabel.hidden = YES;
         sendInviteCell.failButton.hidden = YES;
         [sendInviteCell.indicator setHidesWhenStopped:YES];
         [sendInviteCell.indicator stopAnimating];
      }
      
      if (indexPath.item == 0) {
         sendInviteCell.dateLabel.text = dateStr;
         sendInviteCell.dateContainer.hidden = NO;
         sendInviteCell.dateContainerConstraint.constant=40;
      }
      
      if (indexPath.item > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         
         if (![pDateStr isEqualToString:cDateStr]) {
            sendInviteCell.dateLabel.text = dateStr;
            sendInviteCell.dateContainer.hidden = NO;
            sendInviteCell.dateContainerConstraint.constant=40;
            
         } else {
            sendInviteCell.dateContainer.hidden = YES;
            sendInviteCell.dateContainerConstraint.constant=0;
         }
      }
      
      UILongPressGestureRecognizer *inviteLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(inviteLongTapDetected:)];
      inviteLongPress.minimumPressDuration = 0.5;
      inviteLongPress.delegate = self;
      [sendInviteCell addGestureRecognizer:inviteLongPress];
      
   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}

- (void)setLongSendCell:(LongChatSendCell *)sendLongCell atIndexPath:(NSIndexPath *)indexPath {
   @try{
      NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
//      NSLog(@"Long Send MsgDict : %@", msgDict);
      
      NSString *chatNo = [msgDict objectForKey:@"CHAT_NO"];
      NSString *contentPrev = [msgDict objectForKey:@"CONTENT_PREV"];
      contentPrev = [MFUtil replaceEncodeToChar:contentPrev];
      
      sendLongCell.msgLabel.text = contentPrev;
      sendLongCell.msgLabel.userInteractionEnabled = NO;
      
      NSString *date = [msgDict objectForKey:@"DATE"];
      NSString *aditInfo = [msgDict objectForKey:@"ADIT_INFO"];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSData *jsonData2 = [aditInfo dataUsingEncoding:NSUTF8StringEncoding];
      NSError *e;
      NSDictionary *aditDic = [NSJSONSerialization JSONObjectWithData:jsonData2 options:0 error:&e];
      //NSLog(@"aditDic : %@", aditDic);
      
      NSString *sendType = [aditDic objectForKey:@"TYPE"];
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:date];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      UIImage *bubble = [[UIImage imageNamed:@"bubble.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
      UIColor *color = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatSendBubbleColor]];
      
      sendLongCell.bubbleImage.image = [bubble imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      [sendLongCell.bubbleImage setTintColor:color];
      
      [sendLongCell.viewButton setImage:[MFUtil getScaledLowImage:[UIImage imageNamed:@"icon_popup.png"] scaledToMaxWidth:10.0f] forState:UIControlStateNormal];
      [sendLongCell.viewButton setImageEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 0.0)];
      [sendLongCell.viewButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
      [sendLongCell.viewButton setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
      [sendLongCell.viewButton setTitle:NSLocalizedString(@"chat_long_text_view_all", @"chat_long_text_view_all") forState:UIControlStateNormal];
      sendLongCell.viewButton.tag = [chatNo integerValue];
      [sendLongCell.viewButton addTarget:self action:@selector(tapChatMoreButton:) forControlEvents:UIControlEventTouchUpInside];
      
      sendLongCell.timeLabel.text = decodeTime;
      
      if([chatRoomType isEqualToString:@"0"]||[chatRoomType isEqualToString:@"3"]){
         //알림톡이거나 나와의채팅일 경우 읽음카운트 숨김
         sendLongCell.readLabel.hidden = YES;
         
      } else {
         if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
            sendLongCell.readLabel.hidden = NO;
            sendLongCell.readLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
            sendLongCell.readLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
            
         } else {
            sendLongCell.readLabel.hidden = YES;
         }
      }
      //NSLog(@"#sendType# : %@", sendType);
      
      if([sendType rangeOfString:@"SENDING"].location!=NSNotFound){
//      if([sendType isEqualToString:@"SENDING"]){
         sendLongCell.timeLabel.hidden = YES;
         sendLongCell.failButton.hidden = YES;
         [sendLongCell.indicator startAnimating];
         
      } else if([sendType rangeOfString:@"SUCCEED"].location!=NSNotFound){
//      } else if([sendType isEqualToString:@"SUCCEED"]){
         sendLongCell.timeLabel.hidden = NO;
         sendLongCell.failButton.hidden = YES;
         [sendLongCell.indicator setHidesWhenStopped:YES];
         [sendLongCell.indicator stopAnimating];
         
      } else if([sendType rangeOfString:@"FAILED"].location!=NSNotFound){
//      } else if([sendType isEqualToString:@"FAILED"]){
         sendLongCell.timeLabel.hidden = YES;
         sendLongCell.failButton.hidden = NO;
         [sendLongCell.indicator setHidesWhenStopped:YES];
         [sendLongCell.indicator stopAnimating];
         
      } else {
         //DATE
         sendLongCell.timeLabel.hidden = YES;
         sendLongCell.failButton.hidden = YES;
         [sendLongCell.indicator setHidesWhenStopped:YES];
         [sendLongCell.indicator stopAnimating];
      }
      
      if (indexPath.item == 0) {
         sendLongCell.dateLabel.text = dateStr;
         sendLongCell.dateContainer.hidden = NO;
         sendLongCell.dateContainerConstraint.constant=40;
      }
      
      if (indexPath.item > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         if (![pDateStr isEqualToString:cDateStr]) {
            //NSLog(@"pd : %@, cd : %@", pDateStr, cDateStr);
            sendLongCell.dateLabel.text = dateStr;
            sendLongCell.dateContainer.hidden = NO;
            sendLongCell.dateContainerConstraint.constant=40;
            
         } else {
            sendLongCell.dateContainer.hidden = YES;
            sendLongCell.dateContainerConstraint.constant=0;
         }
      }
      
      UILongPressGestureRecognizer *largeTxtLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(largeTxtLongTapDetected:)];
      largeTxtLongPress.minimumPressDuration = 0.5;
      largeTxtLongPress.delegate = self;
      [sendLongCell addGestureRecognizer:largeTxtLongPress];
      
   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}

#pragma mark - Setting Receive TableView Cell
- (void)setUpRecvCell:(ChatRecvTextCell *)recvTxtCell atIndexPath:(NSIndexPath *)indexPath {
   NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
   
   @try{
      NSString *userNo = [msgDict objectForKey:@"USER_NO"];
      NSString *userName = [msgDict objectForKey:@"USER_NM"];
      NSString *decodeUserNm = [NSString urlDecodeString:userName];
//      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      content = [MFUtil replaceEncodeToChar:content];
      
      NSString *decodeContent = [NSString urlDecodeString:content];
//      NSString *fileName = [msgDict objectForKey:@"FILE_NM"];
      NSString *date = [msgDict objectForKey:@"DATE"];
//      NSString *decodeDate = [NSString urlDecodeString:date];
      NSString *profileImg = [NSString urlDecodeString:[msgDict objectForKey:@"USER_IMG"]];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:date];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      UIImage *bubble = [[UIImage imageNamed:@"bubbleReceive.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
      
      recvTxtCell.bubbleImage.image = [bubble imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      [recvTxtCell.bubbleImage setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatRecvBubbleColor]]];
      
      recvTxtCell.userName.text = decodeUserNm;
      recvTxtCell.timeLabel.text = decodeTime;
      
      [recvTxtCell.msgLabel setUserInteractionEnabled:YES];
      
      if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
         recvTxtCell.readLabel.hidden = NO;
         recvTxtCell.readLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
         recvTxtCell.readLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
      } else {
         recvTxtCell.readLabel.hidden = YES;
      }
      
      if(![profileImg isEqualToString:@""]){
         UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
         recvTxtCell.userImgView.image = userImg;
         
      } else {
         UIImage *defaultImg = [UIImage imageNamed:@"profile_default.png"];
         recvTxtCell.userImgView.image = defaultImg;
      }
      
      if (indexPath.item == 0) {
         recvTxtCell.dateLabel.text = dateStr;
         recvTxtCell.dateContainer.hidden = NO;
         recvTxtCell.dateContainerConstraint.constant = 40;
         
      } else if (indexPath.item  > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         if (![pDateStr isEqualToString:cDateStr]) {
            recvTxtCell.dateLabel.text = dateStr;
            recvTxtCell.dateContainer.hidden = NO;
            recvTxtCell.dateContainerConstraint.constant = 40;
            
         } else {
            recvTxtCell.dateContainer.hidden = YES;
            recvTxtCell.dateContainerConstraint.constant = 0;
         }
      }
      
      [recvTxtCell.msgLabel setText:decodeContent];
      
      //채팅내용 검색결과
      if(self.searchText.length>0){
         if([decodeContent rangeOfString:[NSString stringWithFormat:@"%@", self.searchText]].location != NSNotFound){
            recvTxtCell.msgLabel.attributedText = [self textGetRanges:decodeContent keyword:self.searchText];
         }
      }
      
      UILongPressGestureRecognizer *txtLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(txtLongTapDetected:)];
      txtLongPress.minimumPressDuration = 0.5;
      txtLongPress.delegate = self;
      [recvTxtCell.msgLabel addGestureRecognizer:txtLongPress];
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileOnTable:)];
      recvTxtCell.userImgView.tag = indexPath.row;
      [recvTxtCell.userImgView setUserInteractionEnabled:YES];
      [recvTxtCell.userImgView addGestureRecognizer:tap];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)setImgRecvCell:(ChatRecvImgCell *)recvImgCell atIndexPath:(NSIndexPath *)indexPath {
   NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
//   UIImage *imgRecvMsg = [[UIImage alloc] init];
   recvImgMsg = [[UIImage alloc] init];
   
   @try{
      NSString *userNo = [msgDict objectForKey:@"USER_NO"];
      NSString *userName = [msgDict objectForKey:@"USER_NM"];
      NSString *decodeUserNm = [NSString urlDecodeString:userName];
      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      //content = [MFUtil replaceEncodeToChar:content];
      
      NSString *decodeContent = [NSString urlDecodeString:content];
      NSString *fileName = [msgDict objectForKey:@"FILE_NM"];
      NSString *date = [msgDict objectForKey:@"DATE"];
      NSString *decodeDate = [NSString urlDecodeString:date];
      NSString *profileImg = [NSString urlDecodeString:[msgDict objectForKey:@"USER_IMG"]];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:date];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      NSString *loacalThumbPath = [self creatLocalChatFolder:contentType roomNo:self.roomNo chatDate:decodeDate];
      
      NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
//      NSLog(@"### imagePath : %@", imagePath);
      
      NSData *data = [NSData dataWithContentsOfFile:imagePath];
      UIImage *image = [UIImage imageWithData:data];
      
//      NSLog(@"RECV decodeContent : %@", decodeContent);
      
      if(image){
         if(image.size.height > image.size.width*2) {
            UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : image];
            image = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
         } else {
            image = [MFUtil getScaledLowImage:image scaledToMaxWidth:180.0f];
         }
         
         recvImgMsg = image;
         
      } else {
         NSLog(@"이미지 없음");
         if([self checkExpireChatImg:decodeDate]){
            UIImage *expireImg = [UIImage imageNamed:@""];
            recvImgMsg = expireImg;
            
         } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:decodeContent]];
               UIImage *urlImg = [UIImage imageWithData:data];

            NSLog(@"URL IMG ; %@", urlImg);
               //큰이미지 사이즈조절
               if(urlImg.size.height > urlImg.size.width*2) {
                  UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : urlImg];
                  urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
               } else {
                  urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
               }
            

               if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
                  //실패이미지를 위해 이미지 저장
                  NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
                  [imageThumbData writeToFile:imagePath atomically:YES];
               }

               recvImgMsg = urlImg;
//            imgRecvMsg = nil;
               
//               dispatch_async(dispatch_get_main_queue(), ^{
//               [self.tableView beginUpdates];
//               [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//               [self.tableView endUpdates];
//               });
            });
         }
      }
      
      recvImgCell.userName.text = decodeUserNm;
      recvImgCell.timeLabel.text = decodeTime;
      
      if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
         recvImgCell.readLabel.hidden = NO;
         recvImgCell.readLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
         recvImgCell.readLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
      } else {
         recvImgCell.readLabel.hidden = YES;
      }
      
      if(![profileImg isEqualToString:@""]){
         UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
         recvImgCell.userImgView.image = userImg;
         
      } else {
         UIImage *defaultImg = [UIImage imageNamed:@"profile_default.png"];
         recvImgCell.userImgView.image = defaultImg;
      }
      
      if (indexPath.item == 0) {
         recvImgCell.dateLabel.text = dateStr;
         recvImgCell.dateContainer.hidden = NO;
         recvImgCell.dateContainerConstraint.constant = 40;
         
      } else if (indexPath.item  > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         if (![pDateStr isEqualToString:cDateStr]) {
            recvImgCell.dateLabel.text = dateStr;
            recvImgCell.dateContainer.hidden = NO;
            recvImgCell.dateContainerConstraint.constant = 40;
            
         } else {
            recvImgCell.dateContainer.hidden = YES;
            recvImgCell.dateContainerConstraint.constant = 0;
         }
      }
      
      recvImgCell.imgMessage.tag = indexPath.row;
               
      if(recvImgMsg==nil){
         if([decodeContent rangeOfString:@" "].location != NSNotFound){
            decodeContent = [decodeContent stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
         }
         [recvImgCell.imgMessage sd_setImageWithURL:[NSURL URLWithString:decodeContent]
                                placeholderImage:[UIImage imageNamed:@"chat_trans.png"]
                                         options:0
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          //큰이미지 사이즈조절
                                          UIImage *urlImg = image;
                                          if(urlImg.size.height > urlImg.size.width*2) {
                                             UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) :urlImg];
                                             urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
                                          } else {
                                             urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
                                          }
                                          recvImgCell.imgMessage.image = urlImg;
                                          
                                          NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[decodeContent lastPathComponent]]];
                                          
                                          if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
                                             //실패이미지를 위해 이미지 저장
                                             NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
                                             [imageThumbData writeToFile:imagePath atomically:YES];
//                                                   NSLog(@"받은 이미지 실패이미지를 위해 이미지 저장(이미지없음) : %@", imagePath);
                                          }
                                       }];
      } else {
         recvImgCell.imgMessage.image = recvImgMsg;
      }
      
      UITapGestureRecognizer *revcImgGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatImgTapGesture:)];
      recvImgCell.imgMessage.tag = indexPath.row;
      [recvImgCell.imgMessage setUserInteractionEnabled:YES];
      [recvImgCell.imgMessage addGestureRecognizer:revcImgGesture];
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileOnTable:)];
      recvImgCell.userImgView.tag = indexPath.row;
      [recvImgCell.userImgView setUserInteractionEnabled:YES];
      [recvImgCell.userImgView addGestureRecognizer:tap];
      
      UILongPressGestureRecognizer *imgLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imgLongTapDetected:)];
      imgLongPress.minimumPressDuration = 0.5;
      imgLongPress.delegate = self;
      [recvImgCell.imgMessage addGestureRecognizer:imgLongPress];

   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)setVideoRecvCell:(ChatRecvVideoCell *)recvVideoCell atIndexPath:(NSIndexPath *)indexPath {
   NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
//   NSLog(@"msgdict : %@", msgDict);
   UIImage *imgRecvMsg = [[UIImage alloc] init];
   
   @try{
      NSString *userNo = [msgDict objectForKey:@"USER_NO"];
      NSString *userName = [msgDict objectForKey:@"USER_NM"];
      NSString *decodeUserNm = [NSString urlDecodeString:userName];
      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      content = [MFUtil replaceEncodeToChar:content];
      
      NSString *decodeContent = [NSString urlDecodeString:content];
      NSString *fileName = [msgDict objectForKey:@"FILE_NM"];
      NSString *date = [msgDict objectForKey:@"DATE"];
      NSString *decodeDate = [NSString urlDecodeString:date];
      NSString *profileImg = [NSString urlDecodeString:[msgDict objectForKey:@"USER_IMG"]];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSRange fileRange = [decodeContent rangeOfString:@"/" options:NSBackwardsSearch];
      if([fileName isEqualToString:@""] || fileName==nil){
         NSString *fNamePath = [decodeContent substringFromIndex:fileRange.location+1];
         NSRange range2 = [fNamePath rangeOfString:@"." options:NSBackwardsSearch];
         NSString *fName = [fNamePath substringToIndex:range2.location];
         fileName = [NSString stringWithFormat:@"%@.png", fName];
      }
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:date];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      NSString *loacalThumbPath = [self creatLocalChatFolder:contentType roomNo:self.roomNo chatDate:decodeDate];
      
      NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
      
      NSData *data = [NSData dataWithContentsOfFile:imagePath];
      UIImage *image = [UIImage imageWithData:data];
      
      if(image){
//         NSLog(@"받은 비디오있음");
         if(image.size.height > image.size.width*2) {
            UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : image];
            image = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
         } else {
            image = [MFUtil getScaledLowImage:image scaledToMaxWidth:180.0f];
         }
         
         imgRecvMsg = image;
         
      } else {
//         NSLog(@"받은 비디오없음");
         
         if([self checkExpireChatImg:decodeDate]){
            UIImage *expireImg = [UIImage imageNamed:@""];
            imgRecvMsg = expireImg;
            
         } else {
            NSRange range = [decodeContent rangeOfString:@"/" options:NSBackwardsSearch];
            NSString *filePath = [decodeContent substringToIndex:range.location+1];
            NSString *filePath2 = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb/%@",fileName]];
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath2]];
            UIImage *urlImg = [UIImage imageWithData:data];
            //[data writeToFile:thumbStr2 atomically:YES];
            
            //큰이미지 사이즈조절
            if(urlImg.size.height > urlImg.size.width*2) {
               UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : urlImg];
               urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
            } else {
               urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
            }
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
               //실패이미지를 위해 이미지 저장
               NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
               [imageThumbData writeToFile:imagePath atomically:YES];
               
               imgRecvMsg = urlImg;
            }
            //            imgRecvMsg = nil;
         }
      }
      
      recvVideoCell.userName.text = decodeUserNm;
      recvVideoCell.timeLabel.text = decodeTime;
      
      if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
         recvVideoCell.readLabel.hidden = NO;
         recvVideoCell.readLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
         recvVideoCell.readLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
      } else {
         recvVideoCell.readLabel.hidden = YES;
      }
      
      if(![profileImg isEqualToString:@""]){
         UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
         recvVideoCell.userImgView.image = userImg;
         
      } else {
         UIImage *defaultImg = [UIImage imageNamed:@"profile_default.png"];
         recvVideoCell.userImgView.image = defaultImg;
      }
      
      if (indexPath.item == 0) {
         recvVideoCell.dateLabel.text = dateStr;
         recvVideoCell.dateContainer.hidden = NO;
         recvVideoCell.dateContainerConstraint.constant = 40;
         
      } else if (indexPath.item  > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         if (![pDateStr isEqualToString:cDateStr]) {
            recvVideoCell.dateLabel.text = dateStr;
            recvVideoCell.dateContainer.hidden = NO;
            recvVideoCell.dateContainerConstraint.constant = 40;
            
         } else {
            recvVideoCell.dateContainer.hidden = YES;
            recvVideoCell.dateContainerConstraint.constant = 0;
         }
      }
      
      recvVideoCell.userImgView.tag = indexPath.row;
      recvVideoCell.playButton.tag = indexPath.row;
      
      if(imgRecvMsg==nil){
         NSRange range = [decodeContent rangeOfString:@"/" options:NSBackwardsSearch];
         NSString *filePath = [decodeContent substringToIndex:range.location+1];
         NSString *filePath2 = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb/%@",fileName]];
         
         if([filePath2 rangeOfString:@" "].location != NSNotFound){
            filePath2 = [filePath2 stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
         }
         
         [recvVideoCell.imgMessage sd_setImageWithURL:[NSURL URLWithString:filePath2]
                                     placeholderImage:[UIImage imageNamed:@"chat_trans.png"]
                                              options:0
                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //큰이미지 사이즈조절
            UIImage *urlImg = image;
            if(urlImg.size.height > urlImg.size.width*2) {
               UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) :urlImg];
               urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
            } else {
               urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
            }
            recvVideoCell.imgMessage.image = urlImg;
            
            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[decodeContent lastPathComponent]]];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
               //실패이미지를 위해 이미지 저장
               NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
               [imageThumbData writeToFile:imagePath atomically:YES];
               //                                                   NSLog(@"받은 비디오 실패이미지를 위해 이미지 저장(이미지없음) : %@", imagePath);
            }
         }];
      } else {
         recvVideoCell.imgMessage.image = imgRecvMsg;
      }
      
      UITapGestureRecognizer *recvVideoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatVideoTapGesture:)];
      recvVideoCell.videoContainer.tag = indexPath.row;
      [recvVideoCell.videoContainer setUserInteractionEnabled:YES];
      [recvVideoCell.videoContainer addGestureRecognizer:recvVideoGesture];
      
      UILongPressGestureRecognizer *videoLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(videoLongTapDetected:)];
      videoLongPress.minimumPressDuration = 0.5;
      videoLongPress.delegate = self;
      [recvVideoCell.videoContainer addGestureRecognizer:videoLongPress];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)setFileRevcCell:(ChatRecvFileCell *)recvFileCell atIndexPath:(NSIndexPath *)indexPath {
   NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
   
   @try{
      NSString *userNo = [msgDict objectForKey:@"USER_NO"];
      NSString *userName = [msgDict objectForKey:@"USER_NM"];
      NSString *decodeUserNm = [NSString urlDecodeString:userName];
      //      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      content = [MFUtil replaceEncodeToChar:content];
      
      NSString *decodeContent = [NSString urlDecodeString:content];
      //      NSString *fileName = [msgDict objectForKey:@"FILE_NM"];
      NSString *date = [msgDict objectForKey:@"DATE"];
      NSString *profileImg = [NSString urlDecodeString:[msgDict objectForKey:@"USER_IMG"]];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:date];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      UIImage *bubble = [[UIImage imageNamed:@"bubbleReceive.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
      recvFileCell.bubbleImage.image = [bubble imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      [recvFileCell.bubbleImage setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatRecvBubbleColor]]];
      
      recvFileCell.userName.text = decodeUserNm;
      recvFileCell.timeLabel.text = decodeTime;
      
      if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
         recvFileCell.readLabel.hidden = NO;
         recvFileCell.readLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
         recvFileCell.readLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
      } else {
         recvFileCell.readLabel.hidden = YES;
      }
      
      if(![profileImg isEqualToString:@""]){
         UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
         recvFileCell.userImgView.image = userImg;
         
      } else {
         UIImage *defaultImg = [UIImage imageNamed:@"profile_default.png"];
         recvFileCell.userImgView.image = defaultImg;
      }
      
      if (indexPath.item == 0) {
         recvFileCell.dateLabel.text = dateStr;
         recvFileCell.dateContainer.hidden = NO;
         recvFileCell.dateContainerConstraint.constant = 40;
         
      } else if (indexPath.item  > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         if (![pDateStr isEqualToString:cDateStr]) {
            recvFileCell.dateLabel.text = dateStr;
            recvFileCell.dateContainer.hidden = NO;
            recvFileCell.dateContainerConstraint.constant = 40;
            
         } else {
            recvFileCell.dateLabel.hidden = YES;
            recvFileCell.dateContainerConstraint.constant = 0;
         }
      }
      
      NSString *file = @"";
      @try{
         file = [decodeContent lastPathComponent];
         
      } @catch (NSException *exception) {
         file = decodeContent;
         NSLog(@"Exception : %@", exception);
      }
      
      recvFileCell.msgLabel.text = file;
      
      NSRange range = [file rangeOfString:@"." options:NSBackwardsSearch];
      NSString *fileExt = [[file substringFromIndex:range.location+1] lowercaseString];
      
      if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_img.png"];
         
      } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_movie.png"];
         
      } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_music.png"];
         
      } else if([fileExt isEqualToString:@"psd"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_psd.png"];
         
      } else if([fileExt isEqualToString:@"ai"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_ai.png"];
         
      } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_word.png"];
         
      } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_ppt.png"];
         
      } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_excel.png"];
         
      } else if([fileExt isEqualToString:@"pdf"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_pdf.png"];
         
      } else if([fileExt isEqualToString:@"txt"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_txt.png"];
         
      } else if([fileExt isEqualToString:@"hwp"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_hwp.png"];
         
      } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_zip.png"];
         
      } else {
         recvFileCell.fileIcon.image = [UIImage imageNamed:@"file_document.png"];
      }
      
      UITapGestureRecognizer *fileTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFileOnTable:)];
      recvFileCell.msgLabel.tag = indexPath.row;
      [recvFileCell.msgLabel setUserInteractionEnabled:YES];
      [recvFileCell.msgLabel addGestureRecognizer:fileTap];
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileOnTable:)];
      recvFileCell.userImgView.tag = indexPath.row;
      [recvFileCell.userImgView setUserInteractionEnabled:YES];
      [recvFileCell.userImgView addGestureRecognizer:tap];
      
      UILongPressGestureRecognizer *fileLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fileLongTapDetected:)];
      fileLongPress.minimumPressDuration = 0.5;
      fileLongPress.delegate = self;
      [recvFileCell.msgLabel addGestureRecognizer:fileLongPress];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)setInviteRecvCell:(ChatRecvInviteCell *)recvInviteCell atIndexPath:(NSIndexPath *)indexPath {
   @try{
      NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
//      NSLog(@"msgDict : %@", msgDict);
      
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      //        if([content rangeOfString:@"%"].location != NSNotFound){
      //            content = [content stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
      //        }
      //        if([content rangeOfString:@"&"].location != NSNotFound){
      //            content = [content stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
      //        }
      
//      NSLog(@"content : %@", content);
      
      NSString *userNo = [msgDict objectForKey:@"USER_NO"];
      NSString *userName = [NSString urlDecodeString:[msgDict objectForKey:@"USER_NM"]];
      NSString *profileImg = [NSString urlDecodeString:[msgDict objectForKey:@"USER_IMG"]];
      NSString *date = [msgDict objectForKey:@"DATE"];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
      NSError *error;
      NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
//      NSLog(@"dict : %@", dict);
      
      NSString *snsNm = [dict objectForKey:@"SNS_NM"];
      NSString *snsDesc = [dict objectForKey:@"SNS_DESC"];
      NSString *snsCoverImage = [dict objectForKey:@"SNS_COVER_IMG"];
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:date];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      UIImage *bubble = [[UIImage imageNamed:@"bubbleReceive.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
      
      if(![profileImg isEqualToString:@""]){
         UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
         recvInviteCell.userImgView.image = userImg;
         
      } else {
         UIImage *defaultImg = [UIImage imageNamed:@"profile_default.png"];
         recvInviteCell.userImgView.image = defaultImg;
      }
      
      recvInviteCell.bubbleImage.image = [bubble imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      [recvInviteCell.bubbleImage setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatRecvBubbleColor]]];
      
      UITapGestureRecognizer *bubbleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMoreHandler:)];
      recvInviteCell.bubbleImage.tag = indexPath.row;
      [recvInviteCell.bubbleImage setUserInteractionEnabled:YES];
      [recvInviteCell.bubbleImage addGestureRecognizer:bubbleTap];
      
      recvInviteCell.imgView.layer.cornerRadius = recvInviteCell.imgView.frame.size.width/10;
      recvInviteCell.imgView.clipsToBounds = YES;
      
      recvInviteCell.userName.text = userName;
      
      [recvInviteCell.joinButton setTitle:NSLocalizedString(@"invite_done", @"invite_done") forState:UIControlStateNormal];
      recvInviteCell.joinButton.tag = indexPath.row;
      [recvInviteCell.joinButton addTarget:self action:@selector(tapJoinButton:) forControlEvents:UIControlEventTouchUpInside];
      
      if(![snsCoverImage isEqualToString:@""]&&![snsCoverImage isEqualToString:@"null"]&&snsCoverImage!=nil){
         UIImage *image = [MFUtil saveThumbImage:@"Cover" path:snsCoverImage num:nil];
         if(image!=nil){
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(125, 105) :image];
            recvInviteCell.imgView.image = postCover;
         } else {
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(125, 105) :[UIImage imageNamed:@"cover3-2.png"]];
            recvInviteCell.imgView.image = postCover;
         }
      } else {
         UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(125, 105) :[UIImage imageNamed:@"cover3-2.png"]];
         recvInviteCell.imgView.image = postCover;
      }
      
      [recvInviteCell.titleLabel setNumberOfLines:0];
      //[recvInviteCell.titleLabel setLineBreakMode:NSLineBreakByCharWrapping];
      
      [recvInviteCell.contentLabel setNumberOfLines:3];
      //[recvInviteCell.contentLabel setLineBreakMode:NSLineBreakByTruncatingTail];
      
      recvInviteCell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"invite_title", @"invite_title"), snsNm];
      recvInviteCell.contentLabel.text = snsDesc;
      
      [recvInviteCell.moreButton setImage:[MFUtil getScaledLowImage:[UIImage imageNamed:@"icon_popup.png"] scaledToMaxWidth:10.0f] forState:UIControlStateNormal];
      [recvInviteCell.moreButton setImageEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0)];
      [recvInviteCell.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
      [recvInviteCell.moreButton setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
      [recvInviteCell.moreButton setTitle:NSLocalizedString(@"invite_more", @"invite_more") forState:UIControlStateNormal];
      recvInviteCell.moreButton.tag = indexPath.row;
      [recvInviteCell.moreButton addTarget:self action:@selector(tapMoreButton:) forControlEvents:UIControlEventTouchUpInside];
      
      recvInviteCell.timeLabel.text = decodeTime;
      
      if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
         recvInviteCell.readLabel.hidden = NO;
         recvInviteCell.readLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
         recvInviteCell.readLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
      } else {
         recvInviteCell.readLabel.hidden = YES;
      }
      
      if (indexPath.item == 0) {
         recvInviteCell.dateLabel.text = dateStr;
         recvInviteCell.dateConatainer.hidden = NO;
         recvInviteCell.dateContainerConstraint.constant=40;
      }
      
      if (indexPath.item > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         
         if (![pDateStr isEqualToString:cDateStr]) {
            recvInviteCell.dateLabel.text = dateStr;
            recvInviteCell.dateConatainer.hidden = NO;
            recvInviteCell.dateContainerConstraint.constant=40;
            
         } else {
            recvInviteCell.dateConatainer.hidden = YES;
            recvInviteCell.dateContainerConstraint.constant=0;
         }
      }
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileOnTable:)];
      recvInviteCell.userImgView.tag = indexPath.row;
      [recvInviteCell.userImgView setUserInteractionEnabled:YES];
      [recvInviteCell.userImgView addGestureRecognizer:tap];
      
      UILongPressGestureRecognizer *inviteLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(inviteLongTapDetected:)];
      inviteLongPress.minimumPressDuration = 0.5;
      inviteLongPress.delegate = self;
      [recvInviteCell addGestureRecognizer:inviteLongPress];
      
   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}

- (void)setLongRecvCell:(LongChatRecvCell *)recvLongCell atIndexPath:(NSIndexPath *)indexPath {
   @try{
      NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
//       NSString *chatNo = [msgDict objectForKey:@"CHAT_NO"];
//       NSString *roomNo = [msgDict objectForKey:@"ROOM_NO"];
       NSString *userNo = [msgDict objectForKey:@"USER_NO"];
      NSString *userName = [msgDict objectForKey:@"USER_NM"];
      NSString *decodeUserNm = [NSString urlDecodeString:userName];
//      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *chatNo = [msgDict objectForKey:@"CHAT_NO"];
      //NSString *content = [msgDict objectForKey:@"CONTENT"];
      NSString *contentPrev = [msgDict objectForKey:@"CONTENT_PREV"];
      contentPrev = [MFUtil replaceEncodeToChar:contentPrev];
      
      NSString *date = [msgDict objectForKey:@"DATE"];
      NSString *profileImg = [NSString urlDecodeString:[msgDict objectForKey:@"USER_IMG"]];
      NSString *unReadCount = [msgDict objectForKey:@"UNREAD_COUNT"];
      
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
      NSDate *nsDate = [dateFormat dateFromString:date];
      
      NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
      [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
      NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
      
      NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
      [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
      NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
      NSString *decodeTime = [NSString urlDecodeString:timeStr];
      
      NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.item];
      
      UIImage *bubble = [[UIImage imageNamed:@"bubbleReceive.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
      
      recvLongCell.bubbleImage.image = [bubble imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      [recvLongCell.bubbleImage setTintColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatRecvBubbleColor]]];
      
      [recvLongCell.viewButton setImage:[MFUtil getScaledLowImage:[UIImage imageNamed:@"icon_popup.png"] scaledToMaxWidth:10.0f] forState:UIControlStateNormal];
      [recvLongCell.viewButton setImageEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 0.0)];
      [recvLongCell.viewButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
      [recvLongCell.viewButton setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
      [recvLongCell.viewButton setTitle:NSLocalizedString(@"chat_long_text_view_all", @"chat_long_text_view_all") forState:UIControlStateNormal];
      recvLongCell.viewButton.tag = [chatNo integerValue];
      [recvLongCell.viewButton addTarget:self action:@selector(tapChatMoreButton:) forControlEvents:UIControlEventTouchUpInside];
      
      recvLongCell.userName.text = decodeUserNm;
      recvLongCell.timeLabel.text = decodeTime;
      
      recvLongCell.msgLabel.text = contentPrev;
      recvLongCell.msgLabel.userInteractionEnabled = NO;
      
      
      if(![[NSString stringWithFormat:@"%@",unReadCount] isEqualToString:@"0"] && unReadCount!=nil){
         recvLongCell.readLabel.hidden = NO;
         recvLongCell.readLabel.text = [NSString stringWithFormat:@"%@", unReadCount];
         recvLongCell.readLabel.textColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] chatUnreadColor]];
      } else {
         recvLongCell.readLabel.hidden = YES;
      }
      
      if(![profileImg isEqualToString:@""]){
         UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
         recvLongCell.userImgView.image = userImg;
         
      } else {
         UIImage *defaultImg = [UIImage imageNamed:@"profile_default.png"];
         recvLongCell.userImgView.image = defaultImg;
      }
      
      if (indexPath.item == 0) {
         recvLongCell.dateLabel.text = dateStr;
         recvLongCell.dateContainer.hidden = NO;
         recvLongCell.dateContainerConstraint.constant = 40;
         
         //채팅내용 검색결과
         //         if(self.searchText.length>0){
         //            if([decodeContent rangeOfString:[NSString stringWithFormat:@"%@", self.searchText]].location != NSNotFound){
         //               recvLongCell.rMsgContent.attributedText = [self textGetRanges:decodeContent keyword:self.searchText];
         //            }
         //         }
         //
         //         NSDictionary *attributes = @{NSFontAttributeName: [recvTxtCell.rMsgContent font]};
         //         CGSize textSize = [[recvTxtCell.rMsgContent text] sizeWithAttributes:attributes];
         //         CGFloat strikeWidth = textSize.width;
         //
         //         if(strikeWidth < 23.0f){
         //            recvLongCell.rMsgContentWidth.constant = 40;
         //            recvLongCell.msgContent.textAlignment = NSTextAlignmentCenter;
         //         } else if(strikeWidth >= self.tableView.frame.size.width - 160){
         //            recvLongCell.rMsgContentWidth.constant = self.tableView.frame.size.width - 160;
         //            recvLongCell.msgContent.textAlignment = NSTextAlignmentLeft;
         //         } else {
         //            if(strikeWidth+15 >= self.tableView.frame.size.width - 160) recvLongCell.rMsgContentWidth.constant = self.tableView.frame.size.width - 160;
         //            else recvLongCell.rMsgContentWidth.constant = strikeWidth+15;
         //            recvLongCell.msgContent.textAlignment = NSTextAlignmentLeft;
         //         }
      }
      
      if (indexPath.item  > 0) {
         NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.item - 1];
         NSString *previousDate = [previousDic objectForKey:@"DATE"];
         NSString *currentDate = [currentDic objectForKey:@"DATE"];
         
         NSDate *pDate = [dateFormat dateFromString:previousDate];
         NSDate *cDate = [dateFormat dateFromString:currentDate];
         
         NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
         [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
         NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
         NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
         
         
         //채팅내용 검색결과
         //         if(self.searchText.length>0){
         //            if([decodeContent rangeOfString:[NSString stringWithFormat:@"%@", self.searchText]].location != NSNotFound){
         //               recvLongCell.rMsgContent.attributedText = [self textGetRanges:decodeContent keyword:self.searchText];
         //            }
         //         }
         //
         //         NSDictionary *attributes = @{NSFontAttributeName: [recvTxtCell.rMsgContent font]};
         //         CGSize textSize = [[recvTxtCell.rMsgContent text] sizeWithAttributes:attributes];
         //         CGFloat strikeWidth = textSize.width;
         //
         //         if(strikeWidth < 23.0f){
         //            recvTxtCell.rMsgContentWidth.constant = 40;
         //            recvTxtCell.rMsgContent.textAlignment = NSTextAlignmentCenter;
         //         } else if(strikeWidth >= self.tableView.frame.size.width - 160){
         //            recvTxtCell.rMsgContentWidth.constant = self.tableView.frame.size.width - 160;
         //            recvTxtCell.rMsgContent.textAlignment = NSTextAlignmentLeft;
         //         } else {
         //            if(strikeWidth+15 >= self.tableView.frame.size.width - 160) recvTxtCell.rMsgContentWidth.constant = self.tableView.frame.size.width - 160;
         //            else recvTxtCell.rMsgContentWidth.constant = strikeWidth+15;
         //            recvTxtCell.rMsgContent.textAlignment = NSTextAlignmentLeft;
         //         }
         
         
         if (![pDateStr isEqualToString:cDateStr]) {
            recvLongCell.dateLabel.text = dateStr;
            recvLongCell.dateContainer.hidden = NO;
            recvLongCell.dateContainerConstraint.constant = 40;
            
         } else {
            recvLongCell.dateContainer.hidden = YES;
            recvLongCell.dateContainerConstraint.constant = 0;
         }
      }
      
      UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileOnTable:)];
      recvLongCell.userImgView.tag = indexPath.row;
      [recvLongCell.userImgView setUserInteractionEnabled:YES];
      [recvLongCell.userImgView addGestureRecognizer:tap];
      
      UILongPressGestureRecognizer *largeTxtLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(largeTxtLongTapDetected:)];
      largeTxtLongPress.minimumPressDuration = 0.5;
      largeTxtLongPress.delegate = self;
      [recvLongCell addGestureRecognizer:largeTxtLongPress];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)setUpSysCell:(ChatRecvSysLineCell *)sysLineCell atIndexPath:(NSIndexPath *)indexPath {
   NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.item];
   
   @try{
      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      NSString *decodeContent = [NSString urlDecodeString:content];
      NSString *decodeContent2 = [NSString urlDecodeString:decodeContent];
      
      [sysLineCell.systemLabel setFrame:CGRectMake(sysLineCell.systemLabel.frame.origin.x, sysLineCell.systemLabel.frame.origin.y, sysLineCell.systemLabel.frame.size.width, 25)];
      
      
      if (indexPath.item == 0) {
         if([contentType isEqualToString:@"SYS"]){
            sysLineCell.systemLabel.text = decodeContent2;
            [sysLineCell.systemLabel setTextColor:[UIColor blackColor]];
            [sysLineCell.systemLabel setFont:[UIFont systemFontOfSize:13]];
            sysLineCell.systemLabel.numberOfLines = 0;
            [sysLineCell.systemLabel setLineBreakMode:NSLineBreakByWordWrapping];
            
            CGSize constraintSize = CGSizeMake(sysLineCell.systemLabel.frame.size.width, 460);
            //CGSize newSize = [decodeContent2 sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:decodeContent2 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize)constraintSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            CGSize newSize = rect.size;
            
            CGFloat labelHeight = MAX(newSize.height, sysLineCell.systemLabel.frame.size.height);
            [sysLineCell.systemLabel setFrame:CGRectMake(sysLineCell.systemLabel.frame.origin.x, sysLineCell.systemLabel.frame.origin.y, sysLineCell.systemLabel.frame.size.width, labelHeight)];
            [sysLineCell.systemLabel setText:decodeContent2];
         }
      }
      
      if (indexPath.item > 0) {
         if([contentType isEqualToString:@"SYS"]){
            sysLineCell.systemLabel.text = decodeContent2;
            [sysLineCell.systemLabel setTextColor:[UIColor blackColor]];
            
            [sysLineCell.systemLabel setFont:[UIFont systemFontOfSize:13]];
            sysLineCell.systemLabel.numberOfLines = 0;
            [sysLineCell.systemLabel setLineBreakMode:NSLineBreakByWordWrapping];
            
            CGSize constraintSize = CGSizeMake(sysLineCell.systemLabel.frame.size.width, 460);
            //CGSize newSize = [decodeContent2 sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:decodeContent2 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize)constraintSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            CGSize newSize = rect.size;
            
            CGFloat labelHeight = MAX(newSize.height, sysLineCell.systemLabel.frame.size.height);
            [sysLineCell.systemLabel setFrame:CGRectMake(sysLineCell.systemLabel.frame.origin.x, sysLineCell.systemLabel.frame.origin.y, sysLineCell.systemLabel.frame.size.width, labelHeight)];
            [sysLineCell.systemLabel setText:decodeContent2];
         }
      }
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

#pragma mark - Tap Event Handler
- (void)handleTapGesture:(UITapGestureRecognizer*)tap{
   @try {
      NSInteger index = tap.view.tag;
      if (index >= 0) {
         [self touchedMsgFailButton:(NSInteger)index];
      }
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}
- (void)tapFileOnTable:(id)sender{
   NSLog();
   UITapGestureRecognizer *gesture = sender;
   UIImageView *imageView = (UIImageView *)gesture.view;
   
   @try {
      NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:(long)imageView.tag];
      //NSLog(@"msgDic : %@", msgDict);
      
      NSString *fileUrl = [msgDict objectForKey:@"CONTENT"];
      
      UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
      UIAlertAction *fileOpenAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"file_open", @"file_open")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action){
                                                                //[self performSegueWithIdentifier:@"CHAT_FILE_OPEN_MODAL" sender:fileUrl];
                                                                [self handyViewerOpen:fileUrl];
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
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}
- (void)tapProfileOnTable:(id)sender{
   NSLog();
   UITapGestureRecognizer *gesture = sender;
   UIImageView *imageView = (UIImageView *)gesture.view;
   
   @try{
      NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:(long)imageView.tag];
      //NSLog(@"msgDic : %@", msgDict);
      
      //[self performSegueWithIdentifier:@"CHAT_PROFILE_MODAL" sender:msgDict];
      
      NSString *roomType = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getRoomType:self.roomNo]];
      
      NSString *userNo = [msgDict objectForKey:@"USER_NO"];
      NSString *userType = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getSnsUserType:userNo]];
      
      CustomHeaderViewController *destination = [[CustomHeaderViewController alloc] initwithUserNo:userNo userType:userType];
      destination.userNo = userNo;
      destination.fromSegue = @"CHAT_PROFILE_MODAL";
      destination.chatRoomTy = roomType;
      destination.userType = userType;
      
      destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
      destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
      [self presentViewController:destination animated:YES completion:nil];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}
- (void)chatImgTapGesture:(id)sender{
   UITapGestureRecognizer *gesture = sender;
   UIImageView *imageView = (UIImageView *)gesture.view;
   
   @try{
      //오리지널파일 경로를 이미지딕셔너리에 저장
      NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:(long)imageView.tag];
//      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      NSString *decodeContent = [NSString urlDecodeString:content];
//      NSString *fileName = [msgDict objectForKey:@"FILE_NM"];
//      NSString *aditInfo = [msgDict objectForKey:@"ADIT_INFO"];
//      NSString *pushType = [msgDict objectForKey:@"TYPE"];
      NSString *userName = [NSString urlDecodeString:[msgDict objectForKey:@"USER_NM"]];
      NSString *date = [msgDict objectForKey:@"DATE"];
      
      self.tapImgUser = userName;
      self.tapImgDate = date;
      
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
      ImgDownloadViewController *destination = (ImgDownloadViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ImgDownloadViewController"];
      UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
      
      destination.imgPath = decodeContent;
      destination.writer = self.tapImgUser;
      destination.writeDate = self.tapImgDate;
      destination.fromSegue = @"CHAT_IMG_DOWN_MODAL";

      navController.modalTransitionStyle = UIModalPresentationNone;
      navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
      [self presentViewController:navController animated:YES completion:nil];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}
- (void)chatVideoTapGesture:(id)sender{
   NSDictionary *msgDict = [NSDictionary dictionary];
   
   if ([sender isKindOfClass:[UITapGestureRecognizer class]]){
      UITapGestureRecognizer *gesture = sender;
      UIView *videoView = (UIView *)gesture.view;
      msgDict = [self.msgData.chatArray objectAtIndex:(long)videoView.tag];
      
   } else if([sender isKindOfClass:[UIButton class]]){
      UIButton *videoButton = sender;
      msgDict = [self.msgData.chatArray objectAtIndex:videoButton.tag];
   }
   
   @try{
      //오리지널파일 경로를 이미지딕셔너리에 저장
//      NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      NSString *decodeContent = [NSString urlDecodeString:content];
//      NSString *fileName = [msgDict objectForKey:@"FILE_NM"];
//      NSString *aditInfo = [msgDict objectForKey:@"ADIT_INFO"];
//      NSString *pushType = [msgDict objectForKey:@"TYPE"];
      NSString *userName = [NSString urlDecodeString:[msgDict objectForKey:@"USER_NM"]];
      NSString *date = [msgDict objectForKey:@"DATE"];
      
      self.tapImgUser = userName;
      self.tapImgDate = date;
      
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
      WebViewController *destination = (WebViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
      UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];

      destination.fileUrl = decodeContent;
      
      navController.modalTransitionStyle = UIModalPresentationNone;
      navController.modalPresentationStyle = UIModalPresentationFullScreen;
      //navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
      [self presentViewController:navController animated:YES completion:nil];

   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}
- (void)tapOnToastView:(id)sender{
   @try{
      for(UIView *subview in [self.view subviews]) {
         if([subview isKindOfClass:[self.toastView class]]) {
            [subview removeFromSuperview];
         }
      }
      
      NSIndexPath *lastCell = [NSIndexPath indexPathForItem:self.msgData.chatArray.count-1 inSection:0];
      [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:YES];
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}
- (void)tapMoreButton:(UIButton *)sender{
   NSInteger tag = sender.tag;
   [self boardMoreInfo:tag];
}
-(void)tapMoreHandler:(UITapGestureRecognizer *)tap{
   NSInteger tag = tap.view.tag;
   [self boardMoreInfo:tag];
}
-(void)boardMoreInfo:(NSInteger)tag{
   @try{
      NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:tag];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      NSString *userNo = [msgDict objectForKey:@"USER_NO"];
      
      NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
      NSError *error;
      NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
      
      NSString *snsNo = [dict objectForKey:@"SNS_NO"];
      NSString *snsNm = [dict objectForKey:@"SNS_NM"];
      NSString *snsDesc = [dict objectForKey:@"SNS_DESC"];
      NSString *snsLeader = [dict objectForKey:@"SNS_CREATE_USER_NM"];
      NSString *snsType = [dict objectForKey:@"SNS_TY"];
      NSString *snsAllow = [dict objectForKey:@"SNS_NEED_ALLOW"];
      NSString *snsMemCnt = [dict objectForKey:@"SNS_MEMBER_COUNT"];
      NSString *snsCreateDate = [dict objectForKey:@"SNS_CREATE_DATE"];
      
      if(snsDesc.length<1) snsDesc = @"";
      
      if([snsType isEqualToString:@"Public"]) snsType = NSLocalizedString(@"board_info_visible_type_public", @"board_info_visible_type_public");
      else if([snsType isEqualToString:@"Closed"]) snsType = NSLocalizedString(@"board_info_visible_type_closed", @"board_info_visible_type_closed");
      else snsType = NSLocalizedString(@"board_info_visible_type_secret", @"board_info_visible_type_secret");
      
      if([snsAllow isEqualToString:@"0"]) snsAllow = NSLocalizedString(@"board_info_need_allow_no", @"board_info_need_allow_no");
      else snsAllow = NSLocalizedString(@"board_info_need_allow_yes", @"board_info_need_allow_yes");
      
      NSRange range = [snsCreateDate rangeOfString:@" " options:NSBackwardsSearch];
      snsCreateDate = [snsCreateDate substringToIndex:range.location+1];
      
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"board_info_title", @"board_info_title") message:nil preferredStyle:UIAlertControllerStyleAlert];
      
      NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
      paraStyle.alignment = NSTextAlignmentLeft;
      
      NSString *str = [NSString stringWithFormat:@"%@ : %@ \n%@ : %@ \n\n%@ : %@ \n%@ : %@ \n%@ : %@ \n%@ : %@ \n%@ : %@", NSLocalizedString(@"board_info_name", @"board_info_name"),snsNm, NSLocalizedString(@"board_info_desc", @"board_info_desc"),snsDesc, NSLocalizedString(@"board_create_owner", @"board_create_owner"),snsLeader, NSLocalizedString(@"board_info_visible_type", @"board_info_visible_type"),snsType, NSLocalizedString(@"board_info_need_allow", @"board_info_need_allow"),snsAllow, NSLocalizedString(@"board_info_member_count", @"board_info_member_count"),snsMemCnt, NSLocalizedString(@"board_info_create_date", @"board_info_create_date"),snsCreateDate];
      
      NSMutableAttributedString *atrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSParagraphStyleAttributeName:paraStyle,NSFontAttributeName:[UIFont systemFontOfSize:15.0]}];
      [alert setValue:atrStr forKey:@"attributedMessage"];
      
      
      UIAlertAction* closeButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"close", @"close") style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                          }];
      
      [alert addAction:closeButton];
      
      if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
         UIAlertAction* joinButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"invite_done", @"invite_done") style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                               [self callJoinSns:snsNo];
                                                            }];
         [alert addAction:joinButton];
      }
      [self presentViewController:alert animated:YES completion:nil];
      
   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}
- (void)tapJoinButton:(UIButton *)sender{
   @try {
      NSInteger tag = sender.tag;
      NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:tag];
      NSString *content = [msgDict objectForKey:@"CONTENT"];
      
      NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
      NSError *error;
      NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
      
      NSString *snsNo = [dict objectForKey:@"SNS_NO"];
      NSString *snsNm = [dict objectForKey:@"SNS_NM"];
      
      joinSnsName = snsNm;
      
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast0", @"join_sns_toast0"), snsNm] message:nil preferredStyle:UIAlertControllerStyleAlert];
      
      UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                              
                                                           }];
      UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                                          [self callJoinSns:snsNo];
                                                       }];
      [alert addAction:cancelButton];
      [alert addAction:okButton];
      [self presentViewController:alert animated:YES completion:nil];
      
   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}
- (void)tapChatMoreButton:(UIButton *)sender{
   NSInteger chatNo = sender.tag;
   
   UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
   LongChatViewController *destination = (LongChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LongChatViewController"];
   
   destination.roomNo = self.roomNo;
   destination.chatNo = [NSString stringWithFormat:@"%lu", chatNo];
   
   UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
   navController.modalTransitionStyle = UIModalPresentationNone;
   navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
   [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Long Tap Event Handler
-(void)txtLongTapDetected:(UILongPressGestureRecognizer *)gesture{
   CGPoint p = [gesture locationInView:self.tableView];
   
   NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
   if (indexPath == nil) {
   } else if (gesture.state == UIGestureRecognizerStateBegan) {
      UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
      
      UIAlertAction *copyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"copy", @"copy")
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action){
                                                                   [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                   
                                                                   NSString *content = [[self.msgData.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT"];
                                                                   UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                                   NSString *decodeString = [NSString urlDecodeString:content];
                                                                   pasteboard.string = decodeString;
                                                                }];
      
      UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"share", @"share")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action){
//                                                             NSLog(@"SHARE MSG DATA : %@", [self.msgData.chatArray objectAtIndex:indexPath.row]);
                                                             [actionSheet dismissViewControllerAnimated:YES completion:nil];
         
                                                             NSString *content = [[self.msgData.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT"];
                                                             
                                                             NSMutableArray *arr = [NSMutableArray array];
                                                             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                                             
                                                             [dict setObject:@"TEXT" forKey:@"TYPE"];
                                                             [dict setObject:content forKey:@"VALUE"];
                                                             [dict setObject:@"true" forKey:@"IS_SHARE"];
                                                             [arr addObject:dict];
                                                             
                                                             [appDelegate.appPrefs setObject:arr forKey:@"SHARE_ITEM_FROM_CHAT"];
                                                             [appDelegate.appPrefs synchronize];
                                                             
                                                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                            ShareSelectViewController *destination = (ShareSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareSelectViewController"];
                                                            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                                                            destination.fromSegue = @"SHARE_FROM_CHAT_MODAL";
         destination.currNo = self.roomNo;
                                                            navController.modalTransitionStyle = UIModalPresentationNone;
                                                            navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                            [self presentViewController:navController animated:YES completion:nil];
                                                             
                                                          }];
      
      UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action){
                                                            
                                                            @try{
                                                               [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                               
                                                               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_select_msg_delete", @"chat_select_msg_delete") preferredStyle:UIAlertControllerStyleAlert];
                                                               UIAlertAction *deleteMsg = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done")
                                                                            style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction * action){
                                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                                               
                                                                               @try{
                                                                                  NSString *chatNo = [[self.msgData.chatArray objectAtIndex:indexPath.row]objectForKey:@"CHAT_NO"];
                                                                                  
                                                                                  NSString *sqlString = [appDelegate.dbHelper deleteChat:self.roomNo chatNo:chatNo];
                                                                                  [appDelegate.dbHelper crudStatement:sqlString];
                                                                                  
                                                                                  [self.msgData.chatArray removeObjectAtIndex:indexPath.row];
                                                                                  [self.tableView reloadData];
                                                                                  
                                                                               } @catch (NSException *exception) {
                                                                                  NSLog(@"Exception : %@", exception);
                                                                               }
                                                                            }];
                                                               [alert addAction:deleteMsg];
                                                               [self presentViewController:alert animated:YES completion:nil];
                                                               
                                                            } @catch (NSException *exception) {
                                                               NSLog(@"Exception : %@", exception);
                                                            }
                                                         }];
      
      [actionSheet addAction:copyAction];
      [actionSheet addAction:shareAction];
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
//                                                             NSLog(@"SHARE MSG DATA : %@", [self.msgData.chatArray objectAtIndex:indexPath.row]);
                                                             [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                             NSString *content = [[self.msgData.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT"];
                                                             content = [content stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                                                             NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:content]];
                                                             
                                                             NSMutableArray *arr = [NSMutableArray array];
                                                             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                                             
                                                             [dict setObject:@"IMG" forKey:@"TYPE"];
                                                             [dict setObject:imgData forKey:@"VALUE"];
                                                             [dict setObject:content forKey:@"URL"];
                                                             [dict setObject:@"true" forKey:@"IS_SHARE"];
                                                             [arr addObject:dict];
                                                             
                                                             [appDelegate.appPrefs setObject:arr forKey:@"SHARE_ITEM_FROM_CHAT"];
                                                             [appDelegate.appPrefs synchronize];
                                                             
                                                             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                             ShareSelectViewController *destination = (ShareSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareSelectViewController"];
                                                             UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                                                             destination.fromSegue = @"SHARE_FROM_CHAT_MODAL";
                                                             navController.modalTransitionStyle = UIModalPresentationNone;
                                                             navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                             [self presentViewController:navController animated:YES completion:nil];
                                                             
                                                          }];
      
      UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
        style:UIAlertActionStyleDestructive
      handler:^(UIAlertAction * action){
         @try{
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_select_msg_delete", @"chat_select_msg_delete") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *deleteMsg = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            
                            @try{
                               NSString *chatNo = [[self.msgData.chatArray objectAtIndex:indexPath.row]objectForKey:@"CHAT_NO"];
                               
                               NSString *sqlString = [appDelegate.dbHelper deleteChat:self.roomNo chatNo:chatNo];
                               [appDelegate.dbHelper crudStatement:sqlString];
                               
                               [self.msgData.chatArray removeObjectAtIndex:indexPath.row];
                               [self.tableView reloadData];
                               
                            } @catch (NSException *exception) {
                               NSLog(@"Exception : %@", exception);
                            }
                         }];
            [alert addAction:deleteMsg];
            [self presentViewController:alert animated:YES completion:nil];
            
         } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
         }
      }];
      
      [actionSheet addAction:shareAction];
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
//                                                             NSLog(@"SHARE VIDEO MSG DATA : %@", [self.msgData.chatArray objectAtIndex:indexPath.row]);
                                                             [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                             NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                                                             NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
                                                             
                                                             NSDate *today = [NSDate date];
                                                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                             [dateFormatter setDateFormat:@"yyyyMMdd"];
                                                             NSString *currentTime = [dateFormatter stringFromDate:today];
                                                             
//                                                             NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Video/%@", self.roomNo, currentTime];
                                                             NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Video/%@/thumb/", self.roomNo, currentTime];
                                                             
                                                             NSFileManager *fileManager = [NSFileManager defaultManager];
                                                             BOOL issue = [fileManager isReadableFileAtPath:saveThumbPath];
                                                             if (issue) {
                                                                
                                                             }else{
                                                                 NSLog(@"Chat RoomNo directory can't read...Create Folder");
                                                                [fileManager createDirectoryAtPath:saveThumbPath withIntermediateDirectories:YES attributes:nil error:nil];
                                                             }
                                                             
                                                             //썸네일이미지
                                                             NSString *imagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[[self.msgData.chatArray objectAtIndex:indexPath.row] objectForKey:@"FILE_NM"]]];
                                                             imagePath = [imagePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                                                             NSData *thumbData = [NSData dataWithContentsOfFile:imagePath];
                                                             
                                                             NSString *content = [[self.msgData.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT"];
                                                             
                                                             NSMutableArray *arr = [NSMutableArray array];
                                                             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                                             [dict setObject:@"VIDEO" forKey:@"TYPE"];
                                                             [dict setObject:thumbData forKey:@"VIDEO_THUMB"];
                                                             [dict setObject:@"" forKey:@"VIDEO_DATA"];
                                                             [dict setObject:content forKey:@"URL"];
                                                             [dict setObject:@"true" forKey:@"IS_SHARE"];
                                                             [arr addObject:dict];
                                                             
                                                             [appDelegate.appPrefs setObject:arr forKey:@"SHARE_ITEM_FROM_CHAT"];
                                                             [appDelegate.appPrefs synchronize];
                                                             
                                                             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                             ShareSelectViewController *destination = (ShareSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareSelectViewController"];
                                                             UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                                                             destination.fromSegue = @"SHARE_FROM_CHAT_MODAL";
                                                             navController.modalTransitionStyle = UIModalPresentationNone;
                                                             navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                             [self presentViewController:navController animated:YES completion:nil];
                                                             
                                                          }];
      
      UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
        style:UIAlertActionStyleDestructive
      handler:^(UIAlertAction * action){
         @try{
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_select_msg_delete", @"chat_select_msg_delete") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *deleteMsg = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            
                            @try{
                               NSString *chatNo = [[self.msgData.chatArray objectAtIndex:indexPath.row]objectForKey:@"CHAT_NO"];
                               
                               NSString *sqlString = [appDelegate.dbHelper deleteChat:self.roomNo chatNo:chatNo];
                               [appDelegate.dbHelper crudStatement:sqlString];
                               
                               [self.msgData.chatArray removeObjectAtIndex:indexPath.row];
                               [self.tableView reloadData];
                               
                            } @catch (NSException *exception) {
                               NSLog(@"Exception : %@", exception);
                            }
                         }];
            [alert addAction:deleteMsg];
            [self presentViewController:alert animated:YES completion:nil];
            
         } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
         }
      }];
      
      [actionSheet addAction:shareAction];
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
//                                                             NSLog(@"SHARE FILE MSG DATA : %@", [self.msgData.chatArray objectAtIndex:indexPath.row]);
                                                             [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                             NSString *content = [[self.msgData.chatArray objectAtIndex:indexPath.row] objectForKey:@"CONTENT"];

                                                             NSMutableArray *arr = [NSMutableArray array];
                                                             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                                             [dict setObject:@"FILE" forKey:@"TYPE"];
                                                             [dict setObject:content forKey:@"VALUE"];
                                                             [dict setObject:@"true" forKey:@"IS_SHARE"];
                                                             [arr addObject:dict];

                                                             [appDelegate.appPrefs setObject:arr forKey:@"SHARE_ITEM_FROM_CHAT"];
                                                             [appDelegate.appPrefs synchronize];

                                                             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                             ShareSelectViewController *destination = (ShareSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ShareSelectViewController"];
                                                             UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
                                                             destination.fromSegue = @"SHARE_FROM_CHAT_MODAL";
                                                             navController.modalTransitionStyle = UIModalPresentationNone;
                                                            navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                                                             [self presentViewController:navController animated:YES completion:nil];
                                                             
                                                          }];
      
      UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
        style:UIAlertActionStyleDestructive
      handler:^(UIAlertAction * action){
         @try{
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_select_msg_delete", @"chat_select_msg_delete") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *deleteMsg = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            
                            @try{
                               NSString *chatNo = [[self.msgData.chatArray objectAtIndex:indexPath.row]objectForKey:@"CHAT_NO"];
                               
                               NSString *sqlString = [appDelegate.dbHelper deleteChat:self.roomNo chatNo:chatNo];
                               [appDelegate.dbHelper crudStatement:sqlString];
                               
                               [self.msgData.chatArray removeObjectAtIndex:indexPath.row];
                               [self.tableView reloadData];
                               
                            } @catch (NSException *exception) {
                               NSLog(@"Exception : %@", exception);
                            }
                         }];
            [alert addAction:deleteMsg];
            [self presentViewController:alert animated:YES completion:nil];
            
         } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
         }
      }];
      
      [actionSheet addAction:shareAction];
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
}
-(void)inviteLongTapDetected:(UILongPressGestureRecognizer *)gesture{
   CGPoint p = [gesture locationInView:self.tableView];
   
   NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
   if (indexPath == nil) {
      
   } else if (gesture.state == UIGestureRecognizerStateBegan) {
      UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
      
      UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
        style:UIAlertActionStyleDestructive
      handler:^(UIAlertAction * action){
         @try{
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_select_msg_delete", @"chat_select_msg_delete") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *deleteMsg = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            
                            @try{
                               NSString *chatNo = [[self.msgData.chatArray objectAtIndex:indexPath.row]objectForKey:@"CHAT_NO"];
                               
                               NSString *sqlString = [appDelegate.dbHelper deleteChat:self.roomNo chatNo:chatNo];
                               [appDelegate.dbHelper crudStatement:sqlString];
                               
                               [self.msgData.chatArray removeObjectAtIndex:indexPath.row];
                               [self.tableView reloadData];
                               
                            } @catch (NSException *exception) {
                               NSLog(@"Exception : %@", exception);
                            }
                         }];
            [alert addAction:deleteMsg];
            [self presentViewController:alert animated:YES completion:nil];
            
         } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
         }
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
}
-(void)largeTxtLongTapDetected:(UILongPressGestureRecognizer *)gesture{
   CGPoint p = [gesture locationInView:self.tableView];
   
   NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
   if (indexPath == nil) {
      
   } else if (gesture.state == UIGestureRecognizerStateBegan) {
      UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
      
      UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"delete", @"delete")
        style:UIAlertActionStyleDestructive
      handler:^(UIAlertAction * action){
         @try{
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_select_msg_delete", @"chat_select_msg_delete") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *deleteMsg = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            
                            @try{
                               NSString *chatNo = [[self.msgData.chatArray objectAtIndex:indexPath.row]objectForKey:@"CHAT_NO"];
                               
                               NSString *sqlString = [appDelegate.dbHelper deleteChat:self.roomNo chatNo:chatNo];
                               [appDelegate.dbHelper crudStatement:sqlString];
                               
                               [self.msgData.chatArray removeObjectAtIndex:indexPath.row];
                               [self.tableView reloadData];
                               
                            } @catch (NSException *exception) {
                               NSLog(@"Exception : %@", exception);
                            }
                         }];
            [alert addAction:deleteMsg];
            [self presentViewController:alert animated:YES completion:nil];
            
         } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
         }
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
}


#pragma mark - MediaButton events
-(void)changeMediaButton:(BOOL)isItem{
   @try{
      if(_isFlag){ //미디어버튼
         UIImage *accessoryImage = [UIImage imageNamed:@"btn_add.png"];
         UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
         [_mediaButton setImage:normalImage forState:UIControlStateNormal];

         _mediaButton.contentMode = UIViewContentModeScaleAspectFit;
         _mediaButton.backgroundColor = [UIColor clearColor];

         self.inputToolbar.contentView.textView.inputView = nil;
         
         if(!isItem) [self.inputToolbar.contentView.textView reloadInputViews];

         _isFlag = false;
      }
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)cameraButtonPressed:(id)sender{
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
   
   //   if([AccessAuthCheck cameraAccessCheck]){
   //      dispatch_async(dispatch_get_main_queue(), ^{
   //         UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
   //         self.attachView.picker = [[UIImagePickerController alloc] init];
   //         self.attachView.picker.delegate = self;
   //         self.attachView.picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
   //         self.attachView.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
   //         self.attachView.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
   //         self.attachView.picker.videoMaximumDuration = 60.0f; //최대촬영시간설정
   //
   //         self.attachView.picker.modalPresentationStyle = UIModalPresentationFullScreen;
   //         [top presentViewController:self.attachView.picker animated:YES completion:NULL];
   //
   ////         [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_SelectMedia" object:nil];
   //      });
   //   }
   [self changeMediaButton:YES];
}

- (void)photoButtonPressed:(id)sender{
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
               if(status==YES) [self performSegueWithIdentifier:@"CHAT_PHLIB_MODAL" sender:@"PHOTO"];
            });
         }];
      }];
      [alert addAction:okButton];
      [self presentViewController:alert animated:YES completion:nil];
      
   } else {
      [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
         dispatch_async(dispatch_get_main_queue(), ^{
            if(status==YES) [self performSegueWithIdentifier:@"CHAT_PHLIB_MODAL" sender:@"PHOTO"];
         });
      }];
   }
   
//   if([AccessAuthCheck photoAccessCheck]){
//      [self performSegueWithIdentifier:@"CHAT_PHLIB_MODAL" sender:@"PHOTO"];
//   }
   [self changeMediaButton:YES];
}

- (void)videoButtonPressed:(id)sender {
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
               if(status==YES) [self performSegueWithIdentifier:@"CHAT_PHLIB_MODAL" sender:@"VIDEO"];
            });
         }];
         
      }];
      [alert addAction:okButton];
      [self presentViewController:alert animated:YES completion:nil];
      
   } else {
      [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
         dispatch_async(dispatch_get_main_queue(), ^{
            if(status==YES) [self performSegueWithIdentifier:@"CHAT_PHLIB_MODAL" sender:@"VIDEO"];
         });
      }];
   }
//   if([AccessAuthCheck photoAccessCheck]){
//      [self performSegueWithIdentifier:@"CHAT_PHLIB_MODAL" sender:@"VIDEO"];
//   }
   [self changeMediaButton:YES];
}

#pragma mark - pushNotification
- (void)noti_applicationDidBecomeActive:(NSNotification *)notification {
   appDelegate.isChatViewing = YES;
}

- (void)noti_applicationDidEnterBackground:(NSNotification *)notification {
   appDelegate.isChatViewing = NO;
}

- (void)noti_ChatDetailView:(NSNotification *)notification{
   NSLog();
   
   @try{
      NSArray *dataSet = [notification.userInfo objectForKey:@"DATASET"];
      NSString *roomNo = [[dataSet objectAtIndex:0] objectForKey:@"ROOM_NO"];
      if([[NSString stringWithFormat:@"%@", roomNo] isEqualToString:[NSString stringWithFormat:@"%@", self.roomNo]]){
         //[[NSNotificationCenter defaultCenter] postNotificationName:@"noti_Flag" object:nil userInfo:nil];
      } else {
         [self.navigationController popViewControllerAnimated:YES];
      }
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)noti_Chat:(NSNotification *)notification {
   NSLog(@"========================================================");
   NSLog(@"1.푸시수신");

   NSDictionary *userInfo = notification.userInfo;
   @try{
      NSLog(@"userInfo : %@", userInfo);
   
      NSArray *dataSet = [userInfo objectForKey:@"DATASET"];
      NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
      
      NSLog(@"### userNo : %@ / myUserNo : %@", userNo, _myUserNo);
      
      if([[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", _myUserNo]]){
         [self receiveMyChatPush:userInfo];
      } else {
         [self receiveYourChatPush:userInfo];
      }
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)noti_APNS_ChatReadPush:(NSNotification *)notification {
   NSLog(@"userInfo : %@", notification.userInfo);

   NSUInteger msgDataCnt = self.msgData.chatArray.count;
   
   @try{
      NSString *roomNo = [notification.userInfo objectForKey:@"ROOM_NO"];
      NSArray *dataSet = [notification.userInfo objectForKey:@"DATASET"];
      
      for(int i=0; i<dataSet.count; i++){
         NSString *chatNoList = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CHAT_NO_LIST"]];
         NSNumber *unreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"UNREAD_COUNT"];
         
         NSMutableArray *chatNoArr = [NSMutableArray array];
         if([chatNoList rangeOfString:@","].location != NSNotFound){
            chatNoArr = [[chatNoList componentsSeparatedByString:@","] mutableCopy];
         } else {
            [chatNoArr addObject:chatNoList];
         }
         
         if([[NSString stringWithFormat:@"%@", roomNo] isEqualToString:[NSString stringWithFormat:@"%@", self.roomNo]]){
            for(int i=0; i<msgDataCnt; i++){
               NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:i];
               NSString *chatNo = [msgDict objectForKey:@"CHAT_NO"];
               
               for(int j=0; j<chatNoArr.count; j++){
                  NSString *chatNo2 = [chatNoArr objectAtIndex:j];
                  if([chatNo integerValue] == [chatNo2 integerValue]){
                     [msgDict setValue:unreadCnt forKey:@"UNREAD_COUNT"];
                     
                     NSIndexPath *replaceCell = [NSIndexPath indexPathForItem:i inSection:0];
                     [self.tableView beginUpdates];
                     [self.tableView reloadRowsAtIndexPaths:@[replaceCell] withRowAnimation:UITableViewRowAnimationNone];
                     [self.tableView endUpdates];
                  }
               }
            }
         }
      }
      [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_APNS_ChatReadPush" object:nil];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)noti_ChatReadPush:(NSNotification *)notification {
   NSLog();
   NSUInteger msgDataCnt = self.msgData.chatArray.count;
   
   @try{
      NSString *roomNo = [notification.userInfo objectForKey:@"ROOM_NO"];
      NSArray *dataSet = [notification.userInfo objectForKey:@"DATASET"];
      
      for(int i=0; i<dataSet.count; i++){
         NSString *chatNoList = [NSString urlDecodeString:[[dataSet objectAtIndex:i] objectForKey:@"CHAT_NO_LIST"]];
         NSNumber *unreadCnt = [[dataSet objectAtIndex:i] objectForKey:@"UNREAD_COUNT"];
         
         NSMutableArray *chatNoArr = [NSMutableArray array];
         if([chatNoList rangeOfString:@","].location != NSNotFound){
            chatNoArr = [[chatNoList componentsSeparatedByString:@","] mutableCopy];
         } else {
            [chatNoArr addObject:chatNoList];
         }
         
         if([[NSString stringWithFormat:@"%@", roomNo] isEqualToString:[NSString stringWithFormat:@"%@", self.roomNo]]){
            for(int i=0; i<msgDataCnt; i++){
               NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:i];
               NSString *chatNo = [msgDict objectForKey:@"CHAT_NO"];
               
               for(int j=0; j<chatNoArr.count; j++){
                  NSString *chatNo2 = [chatNoArr objectAtIndex:j];
                  if([chatNo integerValue] == [chatNo2 integerValue]){
                     [msgDict setValue:unreadCnt forKey:@"UNREAD_COUNT"];
                     
                     NSIndexPath *replaceCell = [NSIndexPath indexPathForItem:i inSection:0];
                     [self.tableView beginUpdates];
                     [self.tableView reloadRowsAtIndexPaths:@[replaceCell] withRowAnimation:UITableViewRowAnimationNone];
                     [self.tableView endUpdates];
                  }
               }
            }
//            여기서 호출이 안되서..
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeChatBadge" object:nil userInfo:nil];
         }
      }
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

- (void)noti_ChatExit:(NSNotification *)notification {
   [self.navigationController popViewControllerAnimated:YES];
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

-(void)noti_ShareChatUpdate:(NSNotification *)notification{
   NSLog(@"%s",__FUNCTION__);
   
   //채팅/게시판->채팅 공유
   NSArray *shareArr = [NSArray array];
   shareArr = [appDelegate.appPrefs objectForKey:@"SHARE_ITEM_FROM_CHAT"];
   resultArr = [NSMutableArray array];

   for(int i=0; i<shareArr.count; i++){
      NSString *type = [[shareArr objectAtIndex:i] objectForKey:@"TYPE"];
      if([type isEqualToString:@"TEXT"]){
         NSString *content = [[shareArr objectAtIndex:i] objectForKey:@"VALUE"];
         [self sendMessage:content];

      } else if([type isEqualToString:@"IMG"]){
         NSData *value = [[shareArr objectAtIndex:i] objectForKey:@"VALUE"];
         
         UIImage *originImg = [MFUtil getResizeImageRatio:[UIImage imageWithData:value]]; //원본이지만 화질 설정에 맞춘 것.
         UIImage *thumbImg = [MFUtil getScaledLowImage:originImg scaledToMaxWidth:180.0f];

         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         [dict setObject:@"IMG" forKey:@"TYPE"];
         [dict setObject:thumbImg forKey:@"THUMB"];
         [dict setObject:originImg forKey:@"ORIGIN"];

         if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
            [dict setObject:@"true" forKey:@"IS_SHARE"];
            [dict setObject:[[shareArr objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
         }
         [resultArr addObject:dict];

      } else if([type isEqualToString:@"VIDEO"]){
         NSData *videoData = [[shareArr objectAtIndex:i] objectForKey:@"VIDEO_DATA"];
         NSData *data = [[shareArr objectAtIndex:i] objectForKey:@"VIDEO_THUMB"];
         
         UIImage *originImg = [MFUtil getResizeImageRatio:[UIImage imageWithData:data]]; //원본이지만 화질 설정에 맞춘 것.
         UIImage *thumbImg = [MFUtil getScaledLowImage:[UIImage imageWithData:data] scaledToMaxWidth:180.0f];

         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         [dict setObject:@"VIDEO" forKey:@"TYPE"];
         [dict setObject:thumbImg forKey:@"VIDEO_THUMB"];
         [dict setObject:videoData forKey:@"VIDEO_DATA"];
         [dict setObject:originImg forKey:@"ORIGIN"];

         if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
            [dict setObject:@"true" forKey:@"IS_SHARE"];
            [dict setObject:[[shareArr objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
         }
         [resultArr addObject:dict];

      } else if([type isEqualToString:@"FILE"]){
         NSString *value = [[shareArr objectAtIndex:i] objectForKey:@"VALUE"];
         value = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
         NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:value]];

         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         [dict setObject:@"FILE" forKey:@"TYPE"];
         [dict setObject:value forKey:@"VALUE"];
         [dict setObject:data forKey:@"FILE_DATA"];
         [dict setObject:[value lastPathComponent] forKey:@"FILE_NM"];

         if([[shareArr objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
            [dict setObject:@"true" forKey:@"IS_SHARE"];
         }
         [resultArr addObject:dict];
      }
   }
   
   if(resultArr.count>0) {
      [self addThumbnailImage:resultArr];
   }
}

#pragma mark Album Photo/Video
- (void)getImageNotification:(NSNotification *)notification {
   @try {
      self.assetArray = [notification.userInfo objectForKey:@"ASSET_LIST"];
      
      NSArray *imageArray = [[NSArray alloc] initWithObjects:notification.userInfo, nil];
      NSArray *imgList = [[imageArray objectAtIndex:0] objectForKey:@"IMG_LIST"];
      if(imgList.count==1&&[mediaType isEqualToString:@"IMG"]){
         self.croppingStyle = TOCropViewCroppingStyleDefault;
         TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:[imgList objectAtIndex:0]];
         cropController.delegate = self;
         self.image = [imgList objectAtIndex:0];
         [self presentViewController:cropController animated:YES completion:nil];

      } else {
         [self setChatData:imageArray :mediaType :YES];
      }
      [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getImageNotification" object:nil];
     
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
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
   [self setChatData:fileArray :mediaType :NO];
   
}
-(void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
   NSLog();
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
   [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
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

#pragma mark RealTime Video
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
      [self setChatData:videoArray :mediaType :NO];
   }
}

#pragma mark RealTime Image
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
   if (error) {
      NSLog(@"error: %@", [error localizedDescription]);

   } else {
      mediaType = @"IMG";
      
      appDelegate.isChatViewing = YES;
      
      UIImage *rotateImg = nil;
      if(image.size.width>image.size.height){
         rotateImg = [MFUtil rotateImage:image byOrientationFlag:image.imageOrientation];
      } else {
         rotateImg = [MFUtil rotateImage90:image];
      }
      
      self.croppingStyle = TOCropViewCroppingStyleDefault;
      TOCropViewController *cropController = [[TOCropViewController alloc] initWithCroppingStyle:self.croppingStyle image:image];
      cropController.delegate = self;
      self.image = image;
      [self presentViewController:cropController animated:YES completion:nil];
   }
}

-(void)setChatData:(NSArray *)mediaArr :(NSString *)mediaType :(BOOL)isAlbum{
   NSLog();
   @try{
      if([mediaType isEqualToString:@"IMG"]){
         [self sendImageMessage:mediaArr isAlbum:isAlbum];
         
      } else if([mediaType isEqualToString:@"VIDEO"]){
         [self sendVideoMessage:mediaArr isAlbum:isAlbum];
      
      } else if([mediaType isEqualToString:@"FILE"]){
         [self sendFileMessage:mediaArr isAlbum:nil];
      }
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

#pragma mark - Cropper Delegate
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
   self.croppedFrame = cropRect;
   self.angle = angle;
   [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToCircularImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
   self.croppedFrame = cropRect;
   self.angle = angle;
   [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}
- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(TOCropViewController *)cropViewController {
   if (image!=nil) {
      if (cropViewController.croppingStyle != TOCropViewCroppingStyleCircular) {
         [cropViewController dismissAnimatedFromParentViewController:self
                                                    withCroppedImage:image
                                                              toView:nil
                                                             toFrame:CGRectZero
                                                               setup:^{}
                                                          completion:^{
                                                             //mediaArr 형태로 만들어 주기 위해
                                                             NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:image, nil];
                                                             NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:arr, @"IMG_LIST", nil];
                                                             NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:dic, nil];
                                                             
                                                             [self sendImageMessage:array isAlbum:YES];
                                                          }];
      }
   }
}

#pragma mark - Chat Util
-(NSString *)createFileName :(NSString *)filetype{
   @try{
      NSString *fileExt = @"";
      if([filetype isEqualToString:@"IMG"]||[filetype isEqualToString:@"VIDEO_THUMB"]) fileExt = @"png";
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

-(void)videoSizeCheck{
   resultArr = [NSMutableArray array];
   self.firstAddMsg = [NSMutableDictionary dictionary];
   
   UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"upload_fail_title", @"upload_fail_title") message:NSLocalizedString(@"upload_fail_size_limit", @"upload_fail_size_limit") preferredStyle:UIAlertControllerStyleAlert];
   UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                    }];
   [alert addAction:okButton];
   [self presentViewController:alert animated:YES completion:nil];
}
-(NSString *)creatLocalChatFolder :(NSString *)type roomNo:(NSString *)roomNo chatDate:(NSString *)date{
   NSString *localPath = @"";
   
   NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
   NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
   
   NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
   [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
   NSDate *dfDate = [dateFormat dateFromString:date];
   
   NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
   [dateFormat2 setDateFormat:@"yyyyMMdd"];
   NSString *currentTime = [dateFormat2 stringFromDate:dfDate];
   
   if(![type isEqualToString:@"TEXT"]){
      localPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@/thumb/", roomNo, [MFUtil getFolderName:type], currentTime];
      
      NSFileManager *fileManager = [NSFileManager defaultManager];
      BOOL issue = [fileManager isReadableFileAtPath:localPath];
      if (issue) {
         
      }else{
         NSLog(@"[%@] directory can't read...Create Folder", localPath);
         [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
      }
   }
   
   return localPath;
}
-(BOOL)checkExpireChatImg :(NSString *)chatDate{
   BOOL isExpire = NO;
   
   //오늘날짜
   NSDate *today = [NSDate date];
   NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
   formatter.dateFormat = @"yyyy-MM-dd";
   
   NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
   [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
   NSDate *dfDate = [dateFormat dateFromString:chatDate];

   NSString *currentTime = [formatter stringFromDate:dfDate];

   //1.채팅 이미지 전송 날짜
   NSDate *startDate = [formatter dateFromString:currentTime];
   
   //2.채팅 이미지 전송 날짜로부터 90일
   NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
   dayComponent.day = 90;
   NSCalendar *theCalendar = [NSCalendar currentCalendar];
   NSDate *endDate = [theCalendar dateByAddingComponents:dayComponent toDate:startDate options:0];
   
   //3.채팅 이미지 전송 날짜와 오늘 날짜 비교
   NSCalendar *sysCalendar = [NSCalendar currentCalendar];
   unsigned int unitFlags = NSCalendarUnitDay;
   NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:today toDate:endDate options:0];//날짜 비교해서 차이값 추출
   NSInteger date = dateComp.day;
   if(date>=0){
      //유효
      isExpire = NO;
   } else {
      //만료
      isExpire = YES;
   }
   //return isExpire; //기능 추후에 사용
   return NO;
}

-(int)getMissedChatCount{
   int count = 0;
   NSString *missedStr = [appDelegate.dbHelper getMissedChat:self.roomNo];
   NSMutableArray *missedArr = [appDelegate.dbHelper selectMutableArray:missedStr];
//   NSLog(@"missedArr.count : %d, tmpMissedCnt : %d", (int)missedArr.count, tmpMissedCnt);
   count = (int)(missedArr.count + tmpMissedCnt);
   return count;
}

#pragma mark - Search Chat Content
- (void)searchChatContent:(NSString *)text{
   int searchCnt=0;
   NSUInteger msgDataCnt = self.msgData.chatArray.count;
   
   if(text!=nil && ![text isEqualToString:@""]){
      self.searchText = text;
      
      for(int i=0; i<msgDataCnt; i++){
         NSString *content = [NSString urlDecodeString:[[self.msgData.chatArray objectAtIndex:i] objectForKey:@"CONTENT"]];
         if([content rangeOfString:[NSString stringWithFormat:@"%@", text]].location != NSNotFound){
            searchCnt++;
         }
      }
      
      if(searchCnt<1){
         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"검색결과가 없습니다." preferredStyle:UIAlertControllerStyleAlert];
         UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             [self resignFirstResponder];
                                                          }];
         [alert addAction:okButton];
         [self presentViewController:alert animated:YES completion:nil];
      }
      [self.tableView reloadData];
   }
}

-(NSMutableAttributedString *)textGetRanges:(NSString *)text keyword:(NSString *)keyword {
   NSDictionary *attrs = @{ NSBackgroundColorAttributeName : [UIColor redColor], NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:13] };
   NSMutableAttributedString *rangeStr = [[NSMutableAttributedString alloc] initWithString:text];
   
   NSRange searchRange = NSMakeRange(0,text.length);
   NSRange foundRange;
   
   while (searchRange.location < text.length) {
      searchRange.length = text.length-searchRange.location;
      foundRange = [text rangeOfString:keyword options:NSCaseInsensitiveSearch range:searchRange];
      if (foundRange.location != NSNotFound) {
         searchRange.location = foundRange.location+foundRange.length;
         [rangeStr addAttributes:attrs range:foundRange];
      } else {
         break;
      }
   }
   return rangeStr;
}

- (void)closeSearchChat{
   if(self.searchText!=nil && ![self.searchText isEqualToString:@""]){
      self.searchText = nil;
      [self.tableView reloadData];
   }
}

#pragma mark - Keyboard events
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
   
   if(kbSize.height==199) kbSize.height = 257; //아이폰X에서만 키보드 이슈가 생겨서
   
   if([self.fromSegue isEqualToString:@"SIDE_MENU_SEARCH"]) self.inputToolbar.hidden = YES;
   else self.inputToolbar.hidden = NO;

   if ([notification name]==UIKeyboardWillShowNotification) {
      self.keyboardHeight.constant = kbSize.height;
      
      if(msgDataCnt>0){
         if((int)self.tableView.contentOffset.y >= (int)tableBottom){
            //아래코드는 스크롤이 하단일 경우에만 사용, 스크롤 중간일때는 화면 내리지 않음
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               NSInteger row = [self.tableView numberOfRowsInSection:0];
               NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
               [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            });
         }
      }
      [self.view layoutIfNeeded];
      
   } else if([notification name]==UIKeyboardWillHideNotification){
      self.keyboardHeight.constant = 0;
      
      if(msgDataCnt>0){
         if(self.tableView.contentOffset.y > tableBottom){
            //아래코드는 스크롤이 하단일 경우에만 사용, 스크롤 중간일때는 화면 내리지 않음
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               NSInteger row = [self.tableView numberOfRowsInSection:0];
               NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
               [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            });
         }
      }
      [self.view layoutIfNeeded];
   }
   [UIView commitAnimations];
   self.fromSegue=nil;
}

#pragma mark - UIScrollView Delegate
- (void)scrollToBottomAnimated:(BOOL)animated {
   @try{
      if(self.msgData.chatArray.count > 0){
         NSInteger row = [self.tableView numberOfRowsInSection:0];
         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
         [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
         
      } else {
         return;
      }
   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}
- (NSMutableArray *) loadMessage{
   rowCnt += CHAT_LOAD_COUNT;
   return [self.msgData readFromDatabase:rowCnt];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
   @try{
      CGRect screen = [[UIScreen mainScreen]bounds];
      CGFloat screenWidth = screen.size.width;
      CGFloat screenHeight = screen.size.height;
      if ([MFUtil retinaDisplayCapable]) {
         screenHeight = screenHeight*2;
         screenWidth = screenWidth*2;
      }
      
      if (scrollView.contentSize.height-scrollView.contentOffset.y<self.tableView.frame.size.height) {
         for(UIView *subview in [self.view subviews]) {
            if([subview isKindOfClass:[self.toastView class]]) {
               [subview removeFromSuperview];
            }
         }
      }
   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   @try{
      CGFloat scrollOffsetY = scrollView.contentOffset.y;
      
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
      CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
      CGRect rectOfCellInSuperview = [self.tableView convertRect:rectOfCellInTableView toView: self.tableView.superview];
      int loadPosition = (int)rectOfCellInSuperview.origin.y;

      beforeRowCnt = afterRowCnt;
      
      if(isScroll){
         if((int)scrollOffsetY == loadPosition){
            isScroll = NO;
            
            if(rowCnt<loadMsgCnt+CHAT_LOAD_COUNT){
               [self syncChat];
            }
         }
      }
   } @catch(NSException *exception){
      NSLog(@"Exception : %@", exception);
   }
}
-(void)tabledraw{
   if(rowCnt<loadMsgCnt+CHAT_LOAD_COUNT){
      loadMsgCnt = (int)[self loadMessage].count;
      
      afterRowCnt = loadMsgCnt;
      
      NSLog(@"beforeRowCnt : %d / afterRowCnt : %d", beforeRowCnt, afterRowCnt);
      
      if(beforeRowCnt!=afterRowCnt){
         //메시지로드 후 데이터사이즈에 맞게 스크롤위치 조정
         CGSize beforeContentSize;
         CGSize afterContentSize;
         
         beforeContentSize = self.tableView.contentSize;
         [self.tableView reloadData];
         afterContentSize = self.tableView.contentSize;

         if(beforeContentSize.height < afterContentSize.height){
            CGPoint afterContentOffset = self.tableView.contentOffset;
            CGPoint newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height);
            self.tableView.contentOffset = newContentOffset;
            
         } else{
            //로딩한 메시지 높이의 합이 보여지는 뷰보다 작을때는 스크롤을 제일 상단으로 올린다.
            //아니면 화면 새로고침해서 밑에서부터 주르륵 올라감.
            int tmp = loadMsgCnt - CHAT_LOAD_COUNT;
            if(tmp>0&&tmp<=CHAT_LOAD_COUNT){
               NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tmp-1 inSection:0];
               [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            } else if(tmp>CHAT_LOAD_COUNT) {
               NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tmp-CHAT_LOAD_COUNT inSection:0];
               [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
         }
         isScroll = YES;
      } 
   }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(getImageNotification:)
                                                name:@"getImageNotification"
                                              object:nil];
   
   if ([[segue identifier] isEqualToString:@"CHAT_PHLIB_MODAL"]) {
      UINavigationController *destination = segue.destinationViewController;
      PHLibListViewController *vc = [[destination childViewControllers] objectAtIndex:0];
      vc.fromSegue = segue.identifier;
      vc.listType = sender;
      destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
      
   }
}

#pragma mark - HandyViewer Delegate
- (void)handyViewerOpen:(NSString *)filePath{
   @try{
      filePath = [filePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
      
      NSString *platform = [[UIDevice currentDevice] modelName];
      NSRange range = NSMakeRange(7, 1);
      NSString *platformNumber = [platform substringWithRange:range];
      if([platformNumber isEqualToString:@"X"]){
         [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
      } else {
         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
      }
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"HideImageViewer" object: nil];
      
      if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
         imageViewer = [[HISImageViewer alloc] initWithNibName:@"HISImageViewer" bundle:nil];
      } else {
         imageViewer = [[HISImageViewer alloc] initWithNibName:@"HISImageViewer_IPad" bundle:nil];
      }
      
      NSString *path = [NSString stringWithFormat:@"toiphoneapp://callDocumentFunction?fileName=%@&filePath=%@", [filePath lastPathComponent], filePath];
      if(imageViewer == nil) {
         NSLog(@"imageViewer is nil");
      }
      
      NSString *BASE_URL = @"https://touch1.hhi.co.kr/";
      [imageViewer setBaseUrl:BASE_URL];
      [imageViewer setParamInformation:path];
      
      [[[UIApplication sharedApplication] keyWindow] addSubview:imageViewer.view];
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}
- (void) receiveTestNotification:(NSNotification *)notification {
   if([[notification name] isEqualToString:@"HideImageViewer"]) {
      NSLog();
      [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
      // 만일 이미지 뷰어가 종료되었을 때 이벤트를 받아서 처리할게 있다면 이곳에서 처리 한다.
      [imageViewer dismissViewControllerAnimated:YES completion:nil];
   }
}

#pragma mark - TTTAttributedLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
   [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
      
   }];
}
-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneNumber]] options:@{} completionHandler:nil];
}

@end


