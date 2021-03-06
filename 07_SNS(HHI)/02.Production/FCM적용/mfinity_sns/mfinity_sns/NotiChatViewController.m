//
//  NotiChatViewController.m
//  mfinity_sns
//
//  Created by hilee on 10/05/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "NotiChatViewController.h"
#import "MFUtil.h"
#import "UIImageView+WebCache.m"

#import "NotiChatViewCell.h"
#import "NotiInviteViewCell.h"
#import "NotiFileViewCell.h"
#import "NotiLongChatViewCell.h"

#import "LongChatViewController.h"
#import "CustomHeaderViewController.h"
#import "ImgDownloadViewController.h"

#import "HDNotificationView.h"


#define CHAT_LOAD_COUNT 50
#define REFRESH_TABLEVIEW_DEFAULT_ROW               64.f
#define REFRESH_HEADER_DEFAULT_HEIGHT               64.f

@interface NotiChatViewController () {
    AppDelegate *appDelegate;
    NSUInteger msgDataCnt;
    SDImageCache *imgCache;
    ChatConnectSocket *socket;
    
    UIImage *imgRecvMsg;
    NSString *myUserNo;
    NSNumber *unReadCnt;
    
    BOOL isScroll;
    
    BOOL socketFail;
    int alreadyFail;
    
    int loadMsgCnt;
    int beforeRowCnt;
    int afterRowCnt;
    
    float tableBottom;
    
    NSString *network;
    
    NSString *joinSnsName;
    
    int pChatSize;
    NSString *stChatSeq;
}

@end

@implementation NotiChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @try{
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
//        socketFail = NO;
//        [self connectSocket];
        socket = [[ChatConnectSocket alloc] init];
        socket.delegate = self;
        [socket connectSocket];
        
        self.tableView.estimatedRowHeight = 50;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        self.tableView.backgroundColor = [MFUtil myRGBfromHex:@"ABC0D0"]; //카톡배경색(현대중공업)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        tableBottom = self.tableView.contentOffset.y;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NoticeChat:) name:@"noti_NoticeChat" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChatReadPush:) name:@"noti_ChatReadPush" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_APNS_ChatReadPush:) name:@"noti_APNS_ChatReadPush" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_applicationDidBecomeActive:) name:@"noti_applicationDidBecomeActive" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_applicationDidEnterBackground:) name:@"noti_applicationDidEnterBackground" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTable:)];
        [self.tableView addGestureRecognizer:tap];
        
        imgCache = [SDImageCache sharedImageCache];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        [imgCache makeDiskCachePath:cachePath];
        
        self.msgData = [[ChatMessageData alloc] initwithRoomNo:_roomNo];
        
        self.inputToolbar.delegate = self;
        self.inputToolbar.contentView.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [self.inputToolbar.contentView.textView setShowsVerticalScrollIndicator:NO];
        
        self.inputToolbar.contentView.textView.layer.borderWidth = 0.5f;
        self.inputToolbar.contentView.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"readonly_chatroom_input_msg", @"readonly_chatroom_input_msg");
        self.inputToolbar.contentView.textView.editable = NO;
        
        self.inputToolbar.contentView.textView.autocorrectionType = UITextAutocorrectionTypeNo; //자동완성끄기
        
        beforeRowCnt=0;
        afterRowCnt=0;
        alreadyFail=0;
        rowCnt = 0;
        loadMsgCnt = 0;
        msgDataCnt = 0;
        msgDataCnt = self.msgData.chatArray.count;
        
        joinSnsName = @"";
        
        stChatSeq = @"1";
        isScroll = NO;
        pChatSize = 30;
        
        myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
        //채팅웹서비스 호출
        [self syncChat];
        
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
        
//        [self callSyncChatUser];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChatDetailView:) name:@"noti_ChatDetailView" object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    @try{
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(self.tableView.contentSize.height>self.tableView.frame.size.height){
        NSString *sqlString = [appDelegate.dbHelper updateChatRoomScrolled:1 roomNo:self.roomNo];
        [appDelegate.dbHelper crudStatement:sqlString];
        
    } else {
        NSString *sqlString = [appDelegate.dbHelper updateChatRoomScrolled:0 roomNo:self.roomNo];
        [appDelegate.dbHelper crudStatement:sqlString];
    }
    
    self.navigationController.navigationBar.translucent = YES;
    appDelegate.isChatViewing = NO;
    
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        appDelegate.currChatRoomNo = nil;
    }
}

#pragma mark
#pragma mark - Socket
/*
- (void)connectSocket{
    
    NSLog(@"Connect Socket...");
    
    int usrNo = [[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]] intValue];
    
    socket.delegate = nil;
    socket = nil;
    
    NSString *socketUrl;
    int lastNum = usrNo % 2;
    if (lastNum == 0) socketUrl = [[MFSingleton sharedInstance] socketUrl1];
    else socketUrl = [[MFSingleton sharedInstance] socketUrl2];
    
    SRWebSocket *newWebSocket  = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:socketUrl]];
    newWebSocket.delegate = self;
    [newWebSocket open];
}
- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    NSLog();
    
    socket = newWebSocket;
    socketFail = NO;
    
    alreadyFail=0;
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"error : %@", error);
    
    if(webSocket!=nil) [webSocket close];
    //socket = nil;
    socketFail = YES;
    
    alreadyFail++;
    if(alreadyFail==1){
        //소켓연결 실패 시 반대 서버에 붙어야함
        int usrNo = [[appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]] intValue];
        NSString *socketUrl;
        int lastNum = usrNo % 2;
        if (lastNum == 0) socketUrl = [[MFSingleton sharedInstance] socketUrl2];
        else socketUrl = [[MFSingleton sharedInstance] socketUrl1];
        
        SRWebSocket *newWebSocket  = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:socketUrl]];
        newWebSocket.delegate = self;
        [newWebSocket open];
    }
    
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog();
    
    if(socket!=nil) [webSocket close];
    socket = nil;
    socketFail = YES;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Socket Receive : %@", message);
}

-(void)socketCheck:(NSString *)type :(NSString *)message :(NSDictionary *)dict{
    //채팅방 입장 시 웹소켓연결->채팅전송시 웹소켓 연결 되있는지 안되있는지 확인
    //소켓연결 되있으면 소켓전송, 안되어있으면 소켓연결 후 소켓전송
    if(socket==nil) {
        [self connectSocket];
        
        if(socketFail) {
            //소켓연결 실패 시 바로 sendSocket 호출하여 http연결
            NSLog(@"소켓연결 실패 시 바로 sendSocket 호출하여 http연결");
            [self sendSocket:type :message :dict];
            
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //소켓연결 성공 시 약간의 텀이 있으므로 0.3초 뒤에 sendSocket 호출
                NSLog(@"소켓연결 성공 시 약간의 텀이 있으므로 0.3초 뒤에 sendSocket 호출");
                [self sendSocket:type :message :dict];
            });
        }
    } else {
        [self sendSocket:type :message :dict];
    }
}

-(void)sendSocket:(NSString *)type :(NSString *)message :(NSDictionary *)dict{
    NSMutableDictionary *socketDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    @try{
        if([type isEqualToString:@"CHAT_READ_STATUS"]){
            NSString *sqlString = [appDelegate.dbHelper getUnreadChatNoRange:self.roomNo myUserNo:myUserNo];
            NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:sqlString];
            
            NSNumber *firstChat = [[selectArr objectAtIndex:0] objectForKey:@"FIRST_CHAT"];
            NSNumber *lastChat = [[selectArr objectAtIndex:0] objectForKey:@"LAST_CHAT"];
            
            if(![[NSString stringWithFormat:@"%@", firstChat] isEqualToString:@"-1"] && ![[NSString stringWithFormat:@"%@", lastChat] isEqualToString:@"-1"]){
                NSString *userNo = [MFUtil paramEncryptAndEncode:[NSString stringWithFormat:@"%@",myUserNo]];
                NSString *roomNo = [MFUtil paramEncryptAndEncode:[NSString stringWithFormat:@"%@",self.roomNo]];
                NSString *firstStr = [MFUtil paramEncryptAndEncode:[NSString stringWithFormat:@"%@",firstChat]];
                NSString *lastStr = [MFUtil paramEncryptAndEncode:[NSString stringWithFormat:@"%@",lastChat]];
                
                [paramDict setObject:userNo forKey:@"usrNo"];
                [paramDict setObject:roomNo forKey:@"roomNo"];
                [paramDict setObject:firstStr forKey:@"firstChatNo"];
                [paramDict setObject:lastStr forKey:@"lastChatNo"];
            }
            
            if(paramDict.count<=0){
                appDelegate.currChatRoomNo = self.roomNo;
                
                NSString *sqlString2 = [appDelegate.dbHelper updateChatReadStatus:self.roomNo];
                [appDelegate.dbHelper crudStatement:sqlString2];
            }
            
            [socketDict setObject:@"saveChatReadStatus" forKey:@"request"];
        }
        [socketDict setObject:paramDict forKey:@"request_value"];
        
        if(paramDict.count>0){
            NSData *socketData = [NSJSONSerialization dataWithJSONObject:socketDict options:0 error:nil];
            NSString *socketJson = [[NSString alloc] initWithData:socketData encoding:NSUTF8StringEncoding];
            
            //메시지 소켓전송 성공이면 끝. 실패면 웹서비스 전송
            @try {
                NSError *error;
                if([socket sendString:socketJson error:&error]){
                    if([type isEqualToString:@"CHAT_READ_STATUS"]){
                        appDelegate.currChatRoomNo = self.roomNo;
                        
                        NSString *sqlString2 = [appDelegate.dbHelper updateChatReadStatus:self.roomNo];
                        [appDelegate.dbHelper crudStatement:sqlString2];
                    }
                } else {
                    NSLog(@"http전송");
                    if([type isEqualToString:@"CHAT_READ_STATUS"]){
                        [self callChatReadStatus];
                    }
                }
            }
            @catch (NSException *exception) {
                [socket close];
                socket = nil;
                NSLog(@"Socket Error !");
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
}
*/

-(void)callSyncChatUser{
   NSString *sqlString = [appDelegate.dbHelper getRoomUserNo:self.roomNo];
   NSMutableArray *selectArr = [appDelegate.dbHelper selectValueMutableArray:sqlString];
   NSString *usrLists = [[selectArr valueForKey:@"description"] componentsJoinedByString:@","];
   
   NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
   NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"syncChatUsers"]];

   NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&usrLists=%@", myUserNo, self.roomNo, usrLists];
   MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
   session.delegate = self;
   [session start];
}

-(void)syncChat{
   NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
   NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getChatList"]];
//   NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&stSeq=%@&pSize=%d", _myUserNo, self.roomNo,stChatSeq, pChatSize];
   NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&stSeq=%@&pSize=%d&stDate=%@", myUserNo, self.roomNo,stChatSeq, pChatSize, [appDelegate.appPrefs objectForKey:@"INSTALL_DATE"]];

   MFURLSession *session = [[MFURLSession alloc] initWithURL:url option:paramString];
   session.delegate = self;
   [session start];
}

#pragma mark - Message Send
- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
    
}
- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgData.chatArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotiChatViewCell *notiCell = (NotiChatViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NotiChatViewCell"];
    NotiInviteViewCell *inviteCell = (NotiInviteViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NotiInviteViewCell"];
    NotiFileViewCell *fileCell = (NotiFileViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NotiFileViewCell"];
    NotiLongChatViewCell *longCell = (NotiLongChatViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NotiLongChatViewCell"];
    
    if(self.msgData.chatArray!=nil){
        @try{
            NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:indexPath.row];
            NSString *contentType = [msgDict objectForKey:@"CONTENT_TY"];
            
            if([contentType isEqualToString:@"FILE"]){
                if(fileCell == nil) {
                    NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NotiFileViewCell" owner:self options:nil];
                    
                    for(id currentObject in topLevelObject) {
                        if([currentObject isKindOfClass:[NotiFileViewCell class]]){
                            fileCell = (NotiFileViewCell *) currentObject;
                            [fileCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        }
                    }
                }
                
                [self setNotiFileCell:fileCell atIndexPath:indexPath];
                fileCell.backgroundColor = [MFUtil myRGBfromHex:@"ABC0D0"];
                
                return fileCell;
                
                
            } else if([contentType isEqualToString:@"INVITE"]){
                if(inviteCell == nil) {
                    NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NotiInviteViewCell" owner:self options:nil];
                    
                    for(id currentObject in topLevelObject) {
                        if([currentObject isKindOfClass:[NotiInviteViewCell class]]){
                            inviteCell = (NotiInviteViewCell *) currentObject;
                            [inviteCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        }
                    }
                }
                
                inviteCell.coverImg.image = nil;
                
                [self setNotiInviteCell:inviteCell atIndexPath:indexPath];
                inviteCell.backgroundColor = [MFUtil myRGBfromHex:@"ABC0D0"];
                
                return inviteCell;
                
            } else if([contentType isEqualToString:@"LONG_TEXT"]){
                if(longCell == nil) {
                    NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NotiLongChatViewCell" owner:self options:nil];
                    
                    for(id currentObject in topLevelObject) {
                        if([currentObject isKindOfClass:[NotiLongChatViewCell class]]){
                            longCell = (NotiLongChatViewCell *) currentObject;
                            [longCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        }
                    }
                }
                
                [self setNotiLongCell:longCell atIndexPath:indexPath];
                longCell.backgroundColor = [MFUtil myRGBfromHex:@"ABC0D0"];
                
                return longCell;
                
            } else {
                if(notiCell == nil) {
                    NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NotiChatViewCell" owner:self options:nil];
                    
                    for(id currentObject in topLevelObject) {
                        if([currentObject isKindOfClass:[NotiChatViewCell class]]){
                            notiCell = (NotiChatViewCell *) currentObject;
                            [notiCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        }
                    }
                }
                
                notiCell.notiImgView.image = nil;
                notiCell.notiContent.text = @"";
                notiCell.notiDate.text = @"";
                //notiCell.notiViewTrailing.constant = 0;
                
                notiCell.notiContent.enabledTextCheckingTypes = NSTextCheckingTypeLink|NSTextCheckingTypeAddress|NSTextCheckingTypePhoneNumber;
                notiCell.notiContent.userInteractionEnabled = YES;
                notiCell.notiContent.tttdelegate = self;
                
                [self setNotiRecvCell:notiCell atIndexPath:indexPath];
                notiCell.backgroundColor = [MFUtil myRGBfromHex:@"ABC0D0"];
                
                return notiCell;
            }
            
            
        } @catch(NSException *exception){
            NSLog(@"Exception : %@", exception);
        }
    }
}

- (void)setNotiRecvCell:(NotiChatViewCell *)notiCell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.row];
        
        NSString *chatDate = [NSString urlDecodeString:[currentDic objectForKey:@"DATE"]];
        NSString *userImg = [NSString urlDecodeString:[currentDic objectForKey:@"USER_IMG"]];
        NSString *userName = [NSString urlDecodeString:[currentDic objectForKey:@"USER_NM"]];
        NSString *contentType = [currentDic objectForKey:@"CONTENT_TY"];
        NSString *content = [NSString urlDecodeString:[currentDic objectForKey:@"CONTENT"]];
        content = [MFUtil replaceEncodeToChar:content];
        NSString *fileName = [NSString urlDecodeString:[currentDic objectForKey:@"FILE_NM"]];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *nsDate = [dateFormat dateFromString:chatDate];
        
        NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
        [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
        NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
        
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
        NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
        NSString *decodeTime = [NSString urlDecodeString:timeStr];
        
        if([userImg isEqualToString:@""]) {
            UIImage *defaultImg = [UIImage imageNamed:@"profile_default.png"];
            notiCell.notiUserImg.image = defaultImg;
            
        } else {
            [notiCell.notiUserImg sd_setImageWithURL:[NSURL URLWithString:userImg] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                image = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :image];
                notiCell.notiUserImg.image = image;
            }];
        }
        
        notiCell.notiTitleView.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        [notiCell.titleBtn.titleLabel setTextColor:[UIColor whiteColor]];
        [notiCell.titleBtn setTitle:NSLocalizedString(@"notify_chat_title", @"notify_chat_title") forState:UIControlStateNormal];
        
        notiCell.notiUserNm.text = userName;
        notiCell.notiTime.text = decodeTime;
        
        NSString *loacalThumbPath = [self creatLocalChatFolder:contentType roomNo:self.roomNo chatDate:chatDate];
        
        if([contentType isEqualToString:@"IMG"]){
            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
            
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            UIImage *image = [UIImage imageWithData:data];
            
            if(image){
                if(image.size.height > image.size.width*2) {
                    UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : image];
                    image = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
                } else {
                    image = [MFUtil getScaledLowImage:image scaledToMaxWidth:180.0f];
                }
                imgRecvMsg = image;
                
            } else {
                if([self checkExpireChatImg:chatDate]){
                    UIImage *expireImg = [UIImage imageNamed:@""];
                    imgRecvMsg = expireImg;
                    
                } else {
                    imgRecvMsg = nil;
                }
            }
            
        } else if([contentType isEqualToString:@"VIDEO"]){
            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
            
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            UIImage *image = [UIImage imageWithData:data];
            
            if(image){
                if(image.size.height > image.size.width*2) {
                    UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) : image];
                    image = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
                } else {
                    image = [MFUtil getScaledLowImage:image scaledToMaxWidth:180.0f];
                }
                imgRecvMsg = image;
                
            } else {
                if([self checkExpireChatImg:chatDate]){
                    UIImage *expireImg = [UIImage imageNamed:@""];
                    imgRecvMsg = expireImg;
                    
                } else {
                    imgRecvMsg = nil;
                }
            }
        }
        
        if (indexPath.row == 0) {
            notiCell.notiDate.text = dateStr;
            notiCell.notiDate.hidden = NO;
            notiCell.notiDateConstraint.constant=25;
            
            if([contentType isEqualToString:@"TEXT"]){
                notiCell.notiImgView.hidden = YES;
                notiCell.notiContent.hidden = NO;
                notiCell.videoContainer.hidden = YES;
                
                //notiCell.notiContent.text = content;
                [notiCell.notiContent setText:content];
                
                //채팅내용 검색결과
                if(self.searchText.length>0){
                    if([content rangeOfString:[NSString stringWithFormat:@"%@", self.searchText]].location != NSNotFound){
                        notiCell.notiContent.attributedText = [self textGetRanges:content keyword:self.searchText];
                    }
                }

            } else if([contentType isEqualToString:@"IMG"]){
                notiCell.notiImgView.hidden = NO;
                notiCell.notiContent.hidden = YES;
                notiCell.videoContainer.hidden = YES;
                
                if(imgRecvMsg==nil){
                    [notiCell.notiImgView sd_setImageWithURL:[NSURL URLWithString:content]
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
                                                            notiCell.notiImgView.image = urlImg;
                                                            
                                                            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[content lastPathComponent]]];
                                                            
                                                            if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
                                                                //실패이미지를 위해 이미지 저장
                                                                NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
                                                                [imageThumbData writeToFile:imagePath atomically:YES];
//                                                                NSLog(@"받은 이미지 실패이미지를 위해 이미지 저장(이미지없음) : %@", imagePath);
                                                            }
                                                        }];
                } else {
                    notiCell.notiImgView.image = imgRecvMsg;
                }
                
            } else if([contentType isEqualToString:@"VIDEO"]){
                notiCell.notiImgView.hidden = NO;
                notiCell.notiContent.hidden = YES;
                notiCell.videoContainer.hidden = NO;
                notiCell.playButton.tag = indexPath.row;
                
                if(imgRecvMsg==nil){
//                    NSRange range = [content rangeOfString:@"/" options:NSBackwardsSearch];
//                    NSString *filePath = [content substringToIndex:range.location+1];
//                    NSString *filePath2 = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb/%@",fileName]];
//
//                    [notiCell.notiImgView sd_setImageWithURL:[NSURL URLWithString:filePath2]
//                                                 placeholderImage:[UIImage imageNamed:@"chat_trans.png"]
//                                                          options:0
//                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                                            //큰이미지 사이즈조절
//                                                            UIImage *urlImg = image;
//                                                            if(urlImg.size.height > urlImg.size.width*2) {
//                                                                UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) :urlImg];
//                                                                urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
//                                                            } else {
//                                                                urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
//                                                            }
//                                                            notiCell.notiImgView.image = urlImg;
//
//                                                            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[content lastPathComponent]]];
//
//                                                            if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
//                                                                //실패이미지를 위해 이미지 저장
//                                                                NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
//                                                                [imageThumbData writeToFile:imagePath atomically:YES];
//                                                                NSLog(@"받은 비디오 실패이미지를 위해 이미지 저장(이미지없음) : %@", imagePath);
//                                                            }
//                                                        }];
                    
                    notiCell.notiImgView.image = [UIImage imageNamed:@"chat_thumb_null.png"];
                    //notiCell.notiViewTrailing.constant = -(notiCell.notiUserNm.frame.origin.x+notiCell.notiUserNm.frame.size.width-notiCell.notiImgView.image.size.width-20);
                    
                } else {
                    notiCell.notiImgView.image = imgRecvMsg;
                }
                
            }
        }
        
        if (indexPath.row > 0) {
            NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.row - 1];
            NSString *previousDate = [previousDic objectForKey:@"DATE"];
            NSString *currentDate = [currentDic objectForKey:@"DATE"];
            
            NSDate *pDate = [dateFormat dateFromString:previousDate];
            NSDate *cDate = [dateFormat dateFromString:currentDate];
            
            NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
            [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
            NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
            NSString *cDateStr = [dateFormat4 stringFromDate:cDate];
            
            if([contentType isEqualToString:@"TEXT"]){
                notiCell.notiImgView.hidden = YES;
                notiCell.notiContent.hidden = NO;
                notiCell.videoContainer.hidden = YES;
                
                //notiCell.notiContent.text = content;
                [notiCell.notiContent setText:content];
                
                //채팅내용 검색결과
                if(self.searchText.length>0){
                    if([content rangeOfString:[NSString stringWithFormat:@"%@", self.searchText]].location != NSNotFound){
                        notiCell.notiContent.attributedText = [self textGetRanges:content keyword:self.searchText];
                    }
                }
                
//                NSDictionary *attributes = @{NSFontAttributeName: [sendCell.msgLabel font]};
//                CGSize textSize = [[sendCell.msgLabel text] sizeWithAttributes:attributes];
//                CGFloat strikeWidth = textSize.width;
//
//                if(strikeWidth < 23.0f){
//                    sendCell.msgContentWidth.constant = 30;
//                    sendCell.msgLabel.textAlignment = NSTextAlignmentCenter;
//                } else if(strikeWidth >= self.tableView.frame.size.width - 160){
//                    sendCell.msgContentWidth.constant = self.tableView.frame.size.width - 160;
//                    sendCell.msgLabel.textAlignment = NSTextAlignmentLeft;
//                } else {
//                    if(strikeWidth+15 >= self.tableView.frame.size.width - 160) sendCell.msgContentWidth.constant = self.tableView.frame.size.width - 160;
//                    else sendCell.msgContentWidth.constant = strikeWidth+10;
//
//                    sendCell.msgLabel.textAlignment = NSTextAlignmentLeft;
//                }

            } else if([contentType isEqualToString:@"IMG"]){
                notiCell.notiImgView.hidden = NO;
                notiCell.notiContent.hidden = YES;
                notiCell.videoContainer.hidden = YES;
                
                if(imgRecvMsg==nil){
                    [notiCell.notiImgView sd_setImageWithURL:[NSURL URLWithString:content]
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
                                                            notiCell.notiImgView.image = urlImg;
                                                            
                                                            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[content lastPathComponent]]];
                                                            
                                                            if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
                                                                //실패이미지를 위해 이미지 저장
                                                                NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
                                                                [imageThumbData writeToFile:imagePath atomically:YES];
//                                                                NSLog(@"2 받은 이미지 실패이미지를 위해 이미지 저장(이미지없음) : %@", imagePath);
                                                            }
                                                        }];
                } else {
                    notiCell.notiImgView.image = imgRecvMsg;
                }
            
            } else if([contentType isEqualToString:@"VIDEO"]){
                notiCell.notiImgView.hidden = NO;
                notiCell.notiContent.hidden = YES;
                notiCell.videoContainer.hidden = NO;
                notiCell.playButton.tag = indexPath.row;
                
                if(imgRecvMsg==nil){
//                    NSRange range = [content rangeOfString:@"/" options:NSBackwardsSearch];
//                    NSString *filePath = [content substringToIndex:range.location+1];
//                    NSString *filePath2 = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb/%@",fileName]];
//
//                    [notiCell.notiImgView sd_setImageWithURL:[NSURL URLWithString:filePath2]
//                                                 placeholderImage:[UIImage imageNamed:@"chat_trans.png"]
//                                                          options:0
//                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                                            //큰이미지 사이즈조절
//                                                            UIImage *urlImg = image;
//                                                            if(urlImg.size.height > urlImg.size.width*2) {
//                                                                UIImage *image2 = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(180,300) :urlImg];
//                                                                urlImg = [MFUtil getScaledImage:image2 scaledToMaxWidth:180 maxHeight:300];
//                                                            } else {
//                                                                urlImg = [MFUtil getScaledLowImage:urlImg scaledToMaxWidth:180.0f];
//                                                            }
//                                                            notiCell.notiImgView.image = urlImg;
//
//                                                            NSString *imagePath = [loacalThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[content lastPathComponent]]];
//
//                                                            if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]){
//                                                                //실패이미지를 위해 이미지 저장
//                                                                NSData *imageThumbData = UIImagePNGRepresentation(urlImg);
//                                                                [imageThumbData writeToFile:imagePath atomically:YES];
//                                                                NSLog(@"2받은 비디오 실패이미지를 위해 이미지 저장(이미지없음) : %@", imagePath);
//                                                            }
//                                                        }];
                    
                    notiCell.notiImgView.image = [UIImage imageNamed:@"chat_thumb_null.png"];
                    //notiCell.notiViewTrailing.constant = -(notiCell.notiUserNm.frame.origin.x+notiCell.notiUserNm.frame.size.width-notiCell.notiImgView.image.size.width-20);
                    
                } else {
                    notiCell.notiImgView.image = imgRecvMsg;
                }
                
            }
            
            if (![pDateStr isEqualToString:cDateStr]) {
                notiCell.notiDate.text = dateStr;
                notiCell.notiDate.hidden = NO;
                notiCell.notiDateConstraint.constant=25;
                
            } else {
                notiCell.notiDate.text = @"";
                notiCell.notiDate.hidden = YES;
                notiCell.notiDateConstraint.constant=5;
            }
        }
        
        [notiCell.playButton addTarget:self action:@selector(chatVideoTapGesture:) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *revcImgGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatImgTapGesture:)];
        notiCell.notiImgView.tag = indexPath.row;
        [notiCell.notiImgView setUserInteractionEnabled:YES];
        [notiCell.notiImgView addGestureRecognizer:revcImgGesture];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileOnTable:)];
        notiCell.notiUserImg.tag = indexPath.row;
        [notiCell.notiUserImg setUserInteractionEnabled:YES];
        [notiCell.notiUserImg addGestureRecognizer:tap];
        
        UITapGestureRecognizer *recvVideoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chatVideoTapGesture:)];
        notiCell.videoContainer.tag = indexPath.row;
        [notiCell.videoContainer setUserInteractionEnabled:YES];
        [notiCell.videoContainer addGestureRecognizer:recvVideoGesture];
        
        UILongPressGestureRecognizer *txtLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(txtLongTapDetected:)];
        txtLongPress.minimumPressDuration = 0.5;
        txtLongPress.delegate = self;
        [notiCell.notiContent addGestureRecognizer:txtLongPress];
        
        UILongPressGestureRecognizer *imgLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imgLongTapDetected:)];
        imgLongPress.minimumPressDuration = 0.5;
        imgLongPress.delegate = self;
        [notiCell.notiImgView addGestureRecognizer:imgLongPress];
        
        UILongPressGestureRecognizer *videoLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(videoLongTapDetected:)];
        videoLongPress.minimumPressDuration = 0.5;
        videoLongPress.delegate = self;
        [notiCell.videoContainer addGestureRecognizer:videoLongPress];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)setNotiInviteCell:(NotiInviteViewCell *)inviteCell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.row];

        NSString *chatDate = [NSString urlDecodeString:[currentDic objectForKey:@"DATE"]];
        NSString *userImg = [NSString urlDecodeString:[currentDic objectForKey:@"USER_IMG"]];
        NSString *userName = [NSString urlDecodeString:[currentDic objectForKey:@"USER_NM"]];
        NSString *content = [NSString urlDecodeString:[currentDic objectForKey:@"CONTENT"]];
        
        NSError *error;
        NSData *jsonData = [[NSString urlDecodeString:content] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        
        NSString *snsNm = [dict objectForKey:@"SNS_NM"];
        NSString *snsDesc = [dict objectForKey:@"SNS_DESC"];
        NSString *snsCoverImage = [dict objectForKey:@"SNS_COVER_IMG"];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *nsDate = [dateFormat dateFromString:chatDate];
        
        NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
        [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
        NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
        
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
        NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
        NSString *decodeTime = [NSString urlDecodeString:timeStr];
        
        if([userImg isEqualToString:@""]) {
            UIImage *defaultImg = [UIImage imageNamed:@"profile_default.png"];
            inviteCell.inviteUserImg.image = defaultImg;
            
        } else {
            [inviteCell.inviteUserImg sd_setImageWithURL:[NSURL URLWithString:userImg] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                image = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :image];
                inviteCell.inviteUserImg.image = image;
            }];
        }
        
        inviteCell.inviteNotiTitleView.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        [inviteCell.titleBtn.titleLabel setTextColor:[UIColor whiteColor]];
        [inviteCell.titleBtn setTitle:NSLocalizedString(@"notify_chat_title", @"notify_chat_title") forState:UIControlStateNormal];
        
        inviteCell.inviteUserNm.text = userName;
        inviteCell.timeLabel.text = decodeTime;
        
        inviteCell.coverImg.layer.cornerRadius = inviteCell.coverImg.frame.size.width/10;
        inviteCell.coverImg.clipsToBounds = YES;
        
        if(![snsCoverImage isEqualToString:@""]&&![snsCoverImage isEqualToString:@"null"]&&snsCoverImage!=nil){
            UIImage *image = [MFUtil saveThumbImage:@"Cover" path:snsCoverImage num:nil];
            if(image!=nil){
                UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(125, 105) :image];
                inviteCell.coverImg.image = postCover;
            } else {
                UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(125, 105) :[UIImage imageNamed:@"cover3-2.png"]];
                inviteCell.coverImg.image = postCover;
            }
        } else {
            UIImage *postCover = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(125, 105) :[UIImage imageNamed:@"cover3-2.png"]];
            inviteCell.coverImg.image = postCover;
        }
        
        inviteCell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"invite_title", @"invite_title"), snsNm];
        inviteCell.contentLabel.text = snsDesc;
        
        [inviteCell.moreButton setImage:[MFUtil getScaledLowImage:[UIImage imageNamed:@"icon_popup.png"] scaledToMaxWidth:10.0f] forState:UIControlStateNormal];
        [inviteCell.moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
        [inviteCell.moreButton setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
        [inviteCell.moreButton setTitle:NSLocalizedString(@"invite_more", @"invite_more") forState:UIControlStateNormal];
        inviteCell.moreButton.tag = indexPath.row;
        [inviteCell.moreButton addTarget:self action:@selector(tapMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [inviteCell.joinButton setTitle:NSLocalizedString(@"invite_done", @"invite_done") forState:UIControlStateNormal];
        inviteCell.joinButton.tag = indexPath.row;
        [inviteCell.joinButton addTarget:self action:@selector(tapJoinButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (indexPath.row == 0) {
            inviteCell.inviteDate.text = dateStr;
            inviteCell.inviteDate.hidden = NO;
            inviteCell.inviteDateConstraint.constant=25;
        }

        if (indexPath.row > 0) {
            NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.row - 1];
            NSString *previousDate = [previousDic objectForKey:@"DATE"];
            NSString *currentDate = [currentDic objectForKey:@"DATE"];

            NSDate *pDate = [dateFormat dateFromString:previousDate];
            NSDate *cDate = [dateFormat dateFromString:currentDate];

            NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
            [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
            NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
            NSString *cDateStr = [dateFormat4 stringFromDate:cDate];

            if (![pDateStr isEqualToString:cDateStr]) {
                inviteCell.inviteDate.text = dateStr;
                inviteCell.inviteDate.hidden = NO;
                inviteCell.inviteDateConstraint.constant=25;

            } else {
                inviteCell.inviteDate.text = @"";
                inviteCell.inviteDate.hidden = YES;
                inviteCell.inviteDateConstraint.constant=5;
            }
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileOnTable:)];
        inviteCell.inviteUserImg.tag = indexPath.row;
        [inviteCell.inviteUserImg setUserInteractionEnabled:YES];
        [inviteCell.inviteUserImg addGestureRecognizer:tap];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)setNotiFileCell:(NotiFileViewCell *)fileCell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.row];
        
        NSString *chatDate = [NSString urlDecodeString:[currentDic objectForKey:@"DATE"]];
        NSString *userImg = [NSString urlDecodeString:[currentDic objectForKey:@"USER_IMG"]];
        NSString *userName = [NSString urlDecodeString:[currentDic objectForKey:@"USER_NM"]];
        NSString *content = [NSString urlDecodeString:[currentDic objectForKey:@"CONTENT"]];
        content = [MFUtil replaceEncodeToChar:content];
       
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *nsDate = [dateFormat dateFromString:chatDate];
        
        NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
        [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
        NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
        
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
        NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
        NSString *decodeTime = [NSString urlDecodeString:timeStr];
        
        if([userImg isEqualToString:@""]) {
            UIImage *defaultImg = [UIImage imageNamed:@"profile_default.png"];
            fileCell.fileUserImg.image = defaultImg;
            
        } else {
            [fileCell.fileUserImg sd_setImageWithURL:[NSURL URLWithString:userImg] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                image = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :image];
                fileCell.fileUserImg.image = image;
            }];
        }
        
        fileCell.notiFileTitleView.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        [fileCell.fileTitleBtn.titleLabel setTextColor:[UIColor whiteColor]];
        [fileCell.fileTitleBtn setTitle:NSLocalizedString(@"notify_chat_title", @"notify_chat_title") forState:UIControlStateNormal];
        
        fileCell.fileUserNm.text = userName;
        fileCell.timeLabel.text = decodeTime;
        
        NSString *file = @"";
        @try{
            file = [content lastPathComponent];
            
        } @catch (NSException *exception) {
            file = content;
            NSLog(@"Exception : %@", exception);
        }
        fileCell.fileName.text = file;
        
        NSRange range = [file rangeOfString:@"." options:NSBackwardsSearch];
        NSString *fileExt = [[file substringFromIndex:range.location+1] lowercaseString];
        
        if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_img.png"];
            
        } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_movie.png"];
            
        } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_music.png"];
            
        } else if([fileExt isEqualToString:@"psd"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_psd.png"];
            
        } else if([fileExt isEqualToString:@"ai"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_ai.png"];
            
        } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_word.png"];
            
        } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_ppt.png"];
            
        } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_excel.png"];
            
        } else if([fileExt isEqualToString:@"pdf"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_pdf.png"];
            
        } else if([fileExt isEqualToString:@"txt"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_txt.png"];
            
        } else if([fileExt isEqualToString:@"hwp"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_hwp.png"];
            
        } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_zip.png"];
            
        } else {
            fileCell.fileIcon.image = [UIImage imageNamed:@"file_document.png"];
        }
    
        if (indexPath.row == 0) {
            fileCell.fileDate.text = dateStr;
            fileCell.fileDate.hidden = NO;
            fileCell.fileDateConstraint.constant=25;
        }

        if (indexPath.row > 0) {
            NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.row - 1];
            NSString *previousDate = [previousDic objectForKey:@"DATE"];
            NSString *currentDate = [currentDic objectForKey:@"DATE"];

            NSDate *pDate = [dateFormat dateFromString:previousDate];
            NSDate *cDate = [dateFormat dateFromString:currentDate];

            NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
            [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
            NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
            NSString *cDateStr = [dateFormat4 stringFromDate:cDate];

            if (![pDateStr isEqualToString:cDateStr]) {
                fileCell.fileDate.text = dateStr;
                fileCell.fileDate.hidden = NO;
                fileCell.fileDateConstraint.constant=25;

            } else {
                fileCell.fileDate.text = @"";
                fileCell.fileDate.hidden = YES;
                fileCell.fileDateConstraint.constant=5;
            }
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileOnTable:)];
        fileCell.fileUserImg.tag = indexPath.row;
        [fileCell.fileUserImg setUserInteractionEnabled:YES];
        [fileCell.fileUserImg addGestureRecognizer:tap];
        
        UITapGestureRecognizer *fileTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFileOnTable:)];
        fileCell.fileName.tag = indexPath.row;
        [fileCell.fileName setUserInteractionEnabled:YES];
        [fileCell.fileName addGestureRecognizer:fileTap];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)setNotiLongCell:(NotiLongChatViewCell *)longCell atIndexPath:(NSIndexPath *)indexPath {
    @try{
        NSDictionary *currentDic = [self.msgData.chatArray objectAtIndex:indexPath.row];
        
        NSString *chatDate = [NSString urlDecodeString:[currentDic objectForKey:@"DATE"]];
        NSString *userImg = [NSString urlDecodeString:[currentDic objectForKey:@"USER_IMG"]];
        NSString *userName = [NSString urlDecodeString:[currentDic objectForKey:@"USER_NM"]];
        NSString *content = [NSString urlDecodeString:[currentDic objectForKey:@"CONTENT"]];
        content = [MFUtil replaceEncodeToChar:content];
        NSString *chatNo = [currentDic objectForKey:@"CHAT_NO"];
        NSString *contentPrev = [NSString urlDecodeString:[currentDic objectForKey:@"CONTENT_PREV"]];
        contentPrev = [MFUtil replaceEncodeToChar:contentPrev];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *nsDate = [dateFormat dateFromString:chatDate];
        
        NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
        [dateFormat2 setDateFormat:NSLocalizedString(@"date14", @"date14")];
        NSString *dateStr = [dateFormat2 stringFromDate:nsDate];
        
        NSDateFormatter *dateFormat3 = [[NSDateFormatter alloc] init];
        [dateFormat3 setDateFormat:NSLocalizedString(@"date3", @"date3")];
        NSString *timeStr = [dateFormat3 stringFromDate:nsDate];
        NSString *decodeTime = [NSString urlDecodeString:timeStr];
        
        if([userImg isEqualToString:@""]) {
            UIImage *defaultImg = [UIImage imageNamed:@"profile_default.png"];
            longCell.longUserImg.image = defaultImg;
            
        } else {
            [longCell.longUserImg sd_setImageWithURL:[NSURL URLWithString:userImg] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                image = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :image];
                longCell.longUserImg.image = image;
            }];
        }
        
        longCell.longNotiTitleView.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        [longCell.titleBtn.titleLabel setTextColor:[UIColor whiteColor]];
        [longCell.titleBtn setTitle:NSLocalizedString(@"notify_chat_title", @"notify_chat_title") forState:UIControlStateNormal];
        
        longCell.longUserNm.text = userName;
        longCell.timeLabel.text = decodeTime;
        
        longCell.contentLbl.text = contentPrev;
        
        [longCell.moreBtn setImage:[MFUtil getScaledLowImage:[UIImage imageNamed:@"icon_popup.png"] scaledToMaxWidth:10.0f] forState:UIControlStateNormal];
        [longCell.moreBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
        [longCell.moreBtn setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
        [longCell.moreBtn setTitle:NSLocalizedString(@"chat_long_text_view_all", @"chat_long_text_view_all") forState:UIControlStateNormal];
        longCell.moreBtn.tag = [chatNo integerValue];
        [longCell.moreBtn addTarget:self action:@selector(tapChatMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (indexPath.row == 0) {
            longCell.longDate.text = dateStr;
            longCell.longDate.hidden = NO;
            longCell.longDateConstraint.constant=25;
        }

        if (indexPath.row > 0) {
            NSDictionary *previousDic = [self.msgData.chatArray objectAtIndex:indexPath.row - 1];
            NSString *previousDate = [previousDic objectForKey:@"DATE"];
            NSString *currentDate = [currentDic objectForKey:@"DATE"];

            NSDate *pDate = [dateFormat dateFromString:previousDate];
            NSDate *cDate = [dateFormat dateFromString:currentDate];

            NSDateFormatter *dateFormat4 = [[NSDateFormatter alloc] init];
            [dateFormat4 setDateFormat:@"yyyy-MM-dd"];
            NSString *pDateStr = [dateFormat4 stringFromDate:pDate];
            NSString *cDateStr = [dateFormat4 stringFromDate:cDate];

            if (![pDateStr isEqualToString:cDateStr]) {
                longCell.longDate.text = dateStr;
                longCell.longDate.hidden = NO;
                longCell.longDateConstraint.constant=25;

            } else {
                longCell.longDate.text = @"";
                longCell.longDate.hidden = YES;
                longCell.longDateConstraint.constant=5;
            }
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileOnTable:)];
        longCell.longUserImg.tag = indexPath.row;
        [longCell.longUserImg setUserInteractionEnabled:YES];
        [longCell.longUserImg addGestureRecognizer:tap];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - TAP Event
- (void)tapOnTable:(UITapGestureRecognizer*)tap{
    @try{
        [self.inputToolbar.contentView.textView resignFirstResponder];
        
        for(UIView *subview in [self.view subviews]) {
            if([subview isKindOfClass:[self.toastView class]]) {
                [self.toastView setFrame:CGRectMake(0, self.inputToolbar.frame.origin.y-60, self.tableView.frame.size.width, 60)];
                break;
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)tapProfileOnTable:(id)sender{
    UITapGestureRecognizer *gesture = sender;
    UIImageView *imageView = (UIImageView *)gesture.view;
    
    @try{
        NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:(long)imageView.tag];
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
        NSString *content = [NSString urlDecodeString:[msgDict objectForKey:@"CONTENT"]];
        NSString *userName = [NSString urlDecodeString:[msgDict objectForKey:@"USER_NM"]];
        NSString *date = [msgDict objectForKey:@"DATE"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ImgDownloadViewController *destination = (ImgDownloadViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ImgDownloadViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        
        destination.imgPath = content;
        destination.writer = userName;
        destination.writeDate = date;
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
        NSString *content = [NSString urlDecodeString:[msgDict objectForKey:@"CONTENT"]];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WebViewController *destination = (WebViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        
        destination.fileUrl = content;
        
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
- (void)tapFileOnTable:(id)sender{
    UITapGestureRecognizer *gesture = sender;
    UIImageView *imageView = (UIImageView *)gesture.view;
    
    @try {
        NSDictionary *msgDict = [self.msgData.chatArray objectAtIndex:(long)imageView.tag];
        
        NSString *fileUrl = [msgDict objectForKey:@"CONTENT"];
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *fileOpenAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"file_open", @"file_open")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action){
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

- (void)tapMoreButton:(UIButton *)sender{
    NSInteger tag = sender.tag;
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
        
        if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
            UIAlertAction* joinButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"invite_done", @"invite_done") style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                                                   [self callJoinSns:snsNo];
                                                                   
//                                                                   UIAlertController *alert2 = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"join_sns_toast0", @"join_sns_toast0"), snsNm] message:nil preferredStyle:UIAlertControllerStyleAlert];
//
//                                                                   UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
//                                                                                                                        handler:^(UIAlertAction * action) {
//                                                                                                                            [alert2 dismissViewControllerAnimated:YES completion:nil];
//
//                                                                                                                        }];
//                                                                   UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
//                                                                                                                    handler:^(UIAlertAction * action) {
//                                                                                                                        [alert2 dismissViewControllerAnimated:YES completion:nil];
//                                                                                                                        [self callJoinSns:snsNo];
//                                                                                                                    }];
//                                                                   [alert2 addAction:cancelButton];
//                                                                   [alert2 addAction:okButton];
//                                                                   [self presentViewController:alert2 animated:YES completion:nil];
                                                                   
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

- (void)callJoinSns:(NSString *)snsNo{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"joinSNS"]];
    
    //aditInfo : 메시지번호 등의 추가정보
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&dvcId=%@", myUserNo, snsNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    [session start];
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
//            NSLog(@"SHARE MSG DATA : %@", [self.msgData.chatArray objectAtIndex:indexPath.row]);
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            
            if([MFUtil isWorkingTime]){
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
                navController.modalTransitionStyle = UIModalPresentationNone;
                navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [self presentViewController:navController animated:YES completion:nil];
            }
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
//            NSLog(@"SHARE MSG DATA : %@", [self.msgData.chatArray objectAtIndex:indexPath.row]);
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            
            if([MFUtil isWorkingTime]){
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
            }
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
//            NSLog(@"SHARE VIDEO MSG DATA : %@", [self.msgData.chatArray objectAtIndex:indexPath.row]);
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            
            if([MFUtil isWorkingTime]){
                NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
                
                NSDate *today = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *currentTime = [dateFormatter stringFromDate:today];
                
//                NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Video/%@", self.roomNo, currentTime];
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
                //NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:content]];
                
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
            }
            
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
//            NSLog(@"SHARE FILE MSG DATA : %@", [self.msgData.chatArray objectAtIndex:indexPath.row]);
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
            
            if([MFUtil isWorkingTime]){
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
            }
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

#pragma mark - Call Webservice
- (void)callChatReadStatus {
    NSString *sqlString = [appDelegate.dbHelper getUnreadChatNoRange:self.roomNo myUserNo:myUserNo];
    NSMutableArray *selectArr = [appDelegate.dbHelper selectMutableArray:sqlString];
    
    @try{
        NSNumber *firstChat = [[selectArr objectAtIndex:0] objectForKey:@"FIRST_CHAT"];
        NSNumber *lastChat = [[selectArr objectAtIndex:0] objectForKey:@"LAST_CHAT"];
        
        if(![[NSString stringWithFormat:@"%@", firstChat] isEqualToString:@"-1"] && ![[NSString stringWithFormat:@"%@", lastChat] isEqualToString:@"-1"]){
            
            NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
            NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveChatReadStatus"]];
            NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&firstChatNo=%@&lastChatNo=%@&dvcId=%@", myUserNo, self.roomNo, firstChat, lastChat, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
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

#pragma mark - MFURLSession delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    if (error != nil) {
        //실패테이블에 저장
        @try{
            
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
        
    } else {
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
                                
                                unReadCnt = unreadCnt;
                            }
                            
                            if([[NSString stringWithFormat:@"%@", roomNo] isEqualToString:[NSString stringWithFormat:@"%@", self.roomNo]]){
                                
                            } else {
                                
                            }
                        }
                        
                    } else if([wsName isEqualToString:@"joinSNS"]){
                        NSMutableArray *dataSet = [session.returnDictionary objectForKey:@"DATASET"];
                        NSString *affected = [[dataSet objectAtIndex:0] objectForKey:@"AFFECTED"];
                        NSString *needAllow = [[dataSet objectAtIndex:0] objectForKey:@"NEED_ALLOW"];
                        NSString *snsName = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"SNS_NM"]];
                        
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
                        
                        NSLog(@"USER SYNC AND DATA LOAD.");
                        self.msgData = [[ChatMessageData alloc] initwithRoomNo:_roomNo];
                        [self tabledraw];
                        
                    } else if([wsName isEqualToString:@"getChatList"]){
                        NSDictionary *dic = session.returnDictionary;
                        NSLog(@"getChatList : %@", dic);
                        
                        NSArray *dataSet = [dic objectForKey:@"DATASET"];
                        NSUInteger count = dataSet.count;
                        
                        if(count > 0){
                            NSString *seq = [[NSString alloc]init];
                            
                            NSMutableArray *indexPaths = [NSMutableArray array];
                            for(int i=1; i<=count; i++){
                                seq = [NSString stringWithFormat:@"%d", [stChatSeq intValue]+i];
                                [indexPaths addObject:[NSIndexPath indexPathForRow:i-1 inSection:0]];
                            }
                            //                        stChatSeq = seq;
                            //                        isScroll = YES;
                            
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
                                    if([[NSString stringWithFormat:@"%@", chatCount] isEqualToString:@"0"]){
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
                                            //NSLog(@"여기??");
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
                    if([wsName isEqualToString:@"joinSNS"]){
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
        }
    }
}

- (void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error code : %ld", (long)error.code);

    [SVProgressHUD dismiss];
    if(error.code == -1009){
        //Code=-1009 : 인터넷연결 꺼져있을경우?
        //실패테이블에 저장
        @try{
            
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
        
    } else if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
    }
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
- (void)closeSearchChat{
    if(self.searchText!=nil && ![self.searchText isEqualToString:@""]){
        self.searchText = nil;
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


#pragma mark - UIScrollView Delegate
- (NSMutableArray *) loadMessage{
    rowCnt += CHAT_LOAD_COUNT;
    return [self.msgData readFromDatabase:rowCnt];
}

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
            
        } else {
            
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
    //               [self tabledraw]; //200830 기존
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
                if(tmp>0&&tmp<CHAT_LOAD_COUNT){
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tmp-1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            }
            isScroll = YES;
        }
    }
}

// 테이블뷰를 드래깅 할 때 호출
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}

#pragma mark - Notification
- (void)noti_NoticeChat:(NSNotification *)notification {
    NSLog(@"========================================================");
    NSLog(@"1.알림톡 푸시수신");

    NSDictionary *userInfo = notification.userInfo;
    NSUInteger msgDataCnt = self.msgData.chatArray.count;
    
    @try{
        NSLog(@"userInfo : %@", userInfo);
        
        NSArray *dataSet = [userInfo objectForKey:@"DATASET"];
        NSDictionary *aditInfoDic = [[dataSet objectAtIndex:0] objectForKey:@"ADITINFO"];
        NSString *chatNo = [[dataSet objectAtIndex:0] objectForKey:@"CHAT_NO"];
        NSString *userNo = [[dataSet objectAtIndex:0] objectForKey:@"CUSER_NO"];
        NSString *pushType = [userInfo objectForKey:@"TYPE"];
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
        if([[NSString stringWithFormat:@"%@", roomNo] isEqualToString:[NSString stringWithFormat:@"%@", _roomNo]]){
            [HDNotificationView hideNotificationView];
            
            if(![contentType isEqualToString:@"SYS"]){
                if([contentType isEqualToString:@"LONG_TEXT"]){
                    [userInfoDic setObject:@"" forKey:@"CONTENT"];
                    [userInfoDic setObject:content forKey:@"CONTENT_PREV"];
                } else {
                    [userInfoDic setObject:content forKey:@"CONTENT"];
                    [userInfoDic setObject:@"" forKey:@"CONTENT_PREV"];
                }
                
                if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
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
            
            //받은 메시지
            if([contentType isEqualToString:@"LONG_TEXT"]){
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:chatDate fileName:fileName aditInfo:fileThumb unReadCnt:unRead contentPrev:content];
                
                [appDelegate.dbHelper crudStatement:sqlString];
                
            } else {
                NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:content localContent:@"" chatDate:chatDate fileName:fileName aditInfo:fileThumb unReadCnt:unRead contentPrev:@""];
                
                [appDelegate.dbHelper crudStatement:sqlString];
            }
            
            NSLog(@"2.알림톡 메시지 DB저장 : %@ / %@", content, chatDate);
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditInfoDic options:0 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [userInfoDic setObject:jsonString forKey:@"ADIT_INFO"];
            
            [self.msgData.chatArray insertObject:userInfoDic atIndex:msgDataCnt];
            NSLog(@"3.알림톡 메시지 데이터 추가 (%lu) : %@ ", (unsigned long)msgDataCnt, userInfoDic);

            NSIndexPath *lastCell = [NSIndexPath indexPathForItem:msgDataCnt inSection:0];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[lastCell] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
      
            NSLog(@"4.알림톡 메시지 테이블 갱신");
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
                NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ChatToastView" owner:self options:nil];
                self.toastView = [subviewArray objectAtIndex:0];
                [self.toastView setFrame:CGRectMake(0, self.inputToolbar.frame.origin.y-60, self.tableView.frame.size.width, 60)];
                
                UIImage *image = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(50, 50) :[MFUtil saveThumbImage:@"Profile" path:profileImg num:userNo]];
                
                self.toastView.imgView.image = image;
                if([contentType isEqualToString:@"TEXT"]||[contentType isEqualToString:@"LONG_TEXT"]){
                    self.toastView.contentLabel.text = content;
                } else if([contentType isEqualToString:@"IMG"]){
//                    NSRange range = [content rangeOfString:@"." options:NSBackwardsSearch];
//                    NSString *fileExt = [[content substringFromIndex:range.location+1] lowercaseString];
//
//                    if([fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"jpg"] || [fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"heic"]){
                        self.toastView.contentLabel.text = NSLocalizedString(@"chat_receive_image", @"chat_receive_image");
//                    }
                    
                } else if([contentType isEqualToString:@"VIDEO"]){
                    self.toastView.contentLabel.text = NSLocalizedString(@"chat_receive_video", @"chat_receive_video");
                    
                }  else if([contentType isEqualToString:@"FILE"]){
                    self.toastView.contentLabel.text = NSLocalizedString(@"chat_receive_file", @"chat_receive_file");
                    
                } else if([contentType isEqualToString:@"INVITE"]){
                    self.toastView.contentLabel.text = NSLocalizedString(@"chat_receive_invite", @"chat_receive_invite");
                } else {
                    self.toastView.contentLabel.text = content;
                }
                
                self.toastView.userLabel.text = userName;
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnToastView:)];
                [self.toastView addGestureRecognizer:tap];
                [self.toastView setUserInteractionEnabled:YES];
                
                for(UIView *subview in [self.view subviews]) {
                    if([subview isKindOfClass:[self.toastView class]]) {
                        [subview removeFromSuperview];
                    }
                }
                [self.view addSubview:self.toastView];
                
            } else {
                NSIndexPath *lastCell2 = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:0]-1) inSection:0];
                [self.tableView scrollToRowAtIndexPath:lastCell2 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            
        } else {
            NSLog(@"다른방메시지도착");
            if(![[NSString stringWithFormat:@"%@", userNo] isEqualToString:[NSString stringWithFormat:@"%@", myUserNo]]){
                if([contentType isEqualToString:@"LONG_TEXT"]){
                    NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:chatDate fileName:fileName aditInfo:fileThumb isRead:@"0" unReadCnt:unRead contentPrev:content];
                    [appDelegate.dbHelper crudStatement:sqlString];
                    
                } else {
                    NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:content localContent:@"" chatDate:chatDate fileName:fileName aditInfo:fileThumb isRead:@"0" unReadCnt:unRead contentPrev:@""];
                    [appDelegate.dbHelper crudStatement:sqlString];
                }
                
                if(![contentType isEqualToString:@"SYS"]){
                    NSString *sqlString2 = [appDelegate.dbHelper updateRoomNewChat:1 roomNo:roomNo];
                    [appDelegate.dbHelper crudStatement:sqlString2];
                }
            } else {
                if([contentType isEqualToString:@"LONG_TEXT"]){
                    NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:@"" localContent:@"" chatDate:chatDate fileName:fileName aditInfo:fileThumb isRead:@"1" unReadCnt:unRead contentPrev:content];
                    [appDelegate.dbHelper crudStatement:sqlString];
                    
                } else {
                    NSString *sqlString = [appDelegate.dbHelper insertOrUpdateChats2:chatNo roomNo:roomNo userNo:userNo contentType:contentType content:content localContent:@"" chatDate:chatDate fileName:fileName aditInfo:fileThumb isRead:@"1" unReadCnt:unRead contentPrev:@""];
                    [appDelegate.dbHelper crudStatement:sqlString];
                }
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_ChatReadPush:(NSNotification *)notification {
    NSUInteger msgDataCnt = self.msgData.chatArray.count;
    
    @try{
        NSString *roomNo = [notification.userInfo objectForKey:@"ROOM_NO"];
        NSArray *dataSet = [notification.userInfo objectForKey:@"DATASET"];
        self.roomNo = roomNo;
        
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
                            
                            //NSLog(@"unRead msgDict : %@", msgDict);
                            NSIndexPath *replaceCell = [NSIndexPath indexPathForItem:i inSection:0];
                            [self.tableView beginUpdates];
                            [self.tableView reloadRowsAtIndexPaths:@[replaceCell] withRowAnimation:UITableViewRowAnimationNone];
                            [self.tableView endUpdates];
                        }
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeChatBadge" object:nil userInfo:nil];
            }
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
        self.roomNo = roomNo;
        
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

- (void)noti_applicationDidBecomeActive:(NSNotification *)notification {
    appDelegate.isChatViewing = YES;
}

- (void)noti_applicationDidEnterBackground:(NSNotification *)notification {
    appDelegate.isChatViewing = NO;
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
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
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

#pragma mark - Utility
    
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
    //   NSLog(@"endDate: %@", endDate);
    
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

#pragma mark - TTTAttributedLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        
    }];
}
-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneNumber]] options:@{} completionHandler:nil];
}

@end
