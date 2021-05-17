//
//  MFDBHelper.h
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 22..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MFSingleton.h"

//#import "AppDelegate.h"
//#import "SVProgressHUD.h"

@interface MFDBHelper : NSObject {
    sqlite3 *db;
}

@property (nonatomic, strong) NSString *userId;

- (instancetype)init:(NSString *)call userId:(NSString *)userId;

-(NSString *)testQurey;

- (void)restoreInsertDB;
- (void)clearDataBase;

- (void)crudStatement:(NSString *)crudStmt;
- (void)crudStatement:(NSString *)crudStmt completion:(void (^)())completion;
- (NSString *)selectString:(NSString *)selectStmt;
- (NSString *)selectString:(NSString *)selectStmt :(NSString *)param1;

- (NSMutableArray *)selectRoomList;

- (NSMutableArray *)selectValueMutableArray:(NSString *)query;
- (NSMutableArray *)selectArray:(NSString *)query;
- (NSMutableArray *)selectMutableArray:(NSString *)query;
- (NSMutableArray *)selectMutableArray:(NSString *)query :(NSMutableArray *)paramArr;
- (NSMutableDictionary *)selectMutableDictionary:(NSString *)query :(NSMutableArray *)paramArr;
- (void)createLocalFolder;

//query
-(NSString *)getAllSnsList;
-(NSString *)getSnsList:(NSString *)snsKind;
-(NSString *)getSnsNo:(NSString *)snsNo;
-(NSString *)getSnsName:(NSString *)snsName;
-(NSString *)getSnsUserList:(NSString *)userList;
-(NSString *)getPostNoti:(NSString *)snsNo;
-(NSString *)getCommentNoti:(NSString *)snsNo;

-(NSString *)getRoomList;
-(NSString *)getRoomList:(NSString*)param;
-(NSString *)getNotOfTypeRoomList:(NSString *)roomType;
-(NSString *)getRoomName:(NSString *)roomNo;
-(NSString *)getRoomNoti:(NSString *)roomNo;
-(NSString *)getRoomType:(NSString *)roomNo;
-(NSString *)getRoomInfo:(NSString *)roomNo;
-(NSString *)getRoomImg:(NSString *)roomNo;
-(NSString *)getUpdateRoomList:(NSString *)myUserNo roomNo:(NSString *)roomNo;
-(NSString *)getRoomNo:(NSString *)userNo;
-(NSString *)getCustomRoomName:(NSString *)roomNo;
//-(NSString *)getCurrRoomAndChat;
-(NSString *)getChatRoomNo;

-(NSString *)getUserNoAndUserImg:(NSString *)roomNo;
-(NSString *)getUserInfo:(NSString *)userNo;
-(NSString *)getSnsUserType:(NSString *)userNo;
-(NSString *)getRoomUserInfo:(NSString *)roomNo;
-(NSString *)getRoomUserNo:(NSString *)roomNo;
-(NSString *)getRoomUserCount:(NSString *)roomNo;

-(NSString *)getUnreadChatNoRange:(NSString *)roomNo;
-(NSString *)getUnreadChatNoRange:(NSString *)roomNo myUserNo:(NSString *)userNo;
-(NSString *)getMyUnreadChatNoRange:(NSString *)roomNo myUserNo:(NSString *)userNo;
-(NSString *)getLastInsertRowID;
-(NSString *)getContentLongChat:(NSString *)chatNo;
-(NSString *)getChatList:(NSString *)roomNo rowCount:(int)rowCnt;
-(NSString *)getChatInfo;
-(NSString *)getMissedChat:(NSString *)roomNo;
-(NSString *)getCheckMissedChatDate:(NSString *)roomNo type:(NSString *)type content:(NSString *)content;

-(NSString *)getChatLastNo:(NSString *)roomNo;
-(NSString *)getChatRoomInfo:(NSString *)roomNo;

//INSERT
-(NSString *)insertOrUpdateSns:(NSString *)snsNo snsName:(NSString *)snsName snsType:(NSString *)snsType needAllow:(NSString *)needAllow snsDesc:(NSString *)snsDesc coverImg:(NSString *)coverImg createUserNo:(NSString *)createUserNo createUserNm:(NSString *)createUserNm createDate:(NSString *)createDate compNo:(NSString *)compNo snsKind:(NSString *)snsKind;

-(NSString *)insertOrUpdateUsers:(NSString *)userNo userId:(NSString *)userId userName:(NSString *)userName userImg:(NSString *)userImg userMsg:(NSString *)userMsg phoneNo:(NSString *)phoneNo deptNo:(NSString *)deptNo userBgImg:(NSString *)userBgImg deptName:(NSString *)deptName levelNo:(NSString *)levelNo levelName:(NSString *)levelName dutyNo:(NSString *)dutyNo dutyName:(NSString *)dutyName jobGrpName:(NSString *)jobGrpName exCompNo:(NSString *)exCompNo exCompName:(NSString *)exCompName userType:(NSString *)userType;
-(NSString *)insertChatUsers:(NSString *)roomNo userNo:(NSString *)userNo;

-(NSString *)insertChatRooms:(NSString *)roomNo roomName:(NSString *)roomName roomType:(NSString *)roomType;
//-(NSString *)insertMissedChat:(NSString *)roomNo contentType:(NSString *)contentType content:(NSString *)content fileName:(NSString *)fileName aditInfo:(NSString *)aditInfo;
-(NSString *)insertMissedChat:(NSString *)roomNo contentType:(NSString *)contentType content:(NSString *)content fileName:(NSString *)fileName contentThumb:(NSString *)contentThumb  aditInfo:(NSString *)aditInfo;
-(NSString *)insertOrUpdateChats:(NSString *)chatNo roomNo:(NSString *)roomNo userNo:(NSString *)userNo contentType:(NSString *)contentType content:(NSString *)content localContent:(NSString *)localContent chatDate:(NSString *)date fileName:(NSString *)fileName aditInfo:(NSString *)aditInfo unReadCnt:(NSString *)unReadCnt contentPrev:(NSString *)contentPrev;
-(NSString *)insertOrUpdateChats2:(NSString *)chatNo roomNo:(NSString *)roomNo userNo:(NSString *)userNo contentType:(NSString *)contentType content:(NSString *)content localContent:(NSString *)localContent chatDate:(NSString *)date fileName:(NSString *)fileName aditInfo:(NSString *)aditInfo isRead:(NSString *)isRead unReadCnt:(NSString *)unReadCnt contentPrev:(NSString *)contentPrev;
-(NSString *)insertChats:(NSString *)chatNo roomNo:(NSString *)roomNo userNo:(NSString *)userNo contentType:(NSString *)contentType content:(NSString *)content localContent:(NSString *)localContent chatDate:(NSString *)date fileName:(NSString *)fileName aditInfo:(NSString *)aditInfo isRead:(NSString *)isRead unReadCnt:(NSString *)unReadCnt contentPrev:(NSString *)contentPrev;

-(NSString *)insertRoomImages:(NSString *)roomNo roomImg:(NSString *)roomImg refNo1:(NSString *)refNo1;
-(NSString *)insertRoomImages:(NSString *)resultKey roomNo:(NSString *)roomNo roomImg:(NSString *)roomImg resultVal:(NSString *)resultVal;

-(NSString *)insertSnsUser:(NSString *)snsNo userNo:(NSString *)userNo;

-(NSString *)insertChatRoomInfo:(NSString *)roomNo roomType:(NSString *)roomType lastChatNo:(NSString *)lastChatNo exitFlag:(NSString *)exitFlag;

//UPDATE
-(NSString *)updateSnsInfo:(NSString *)snsName snsType:(NSString *)snsType needAllow:(NSString *)needAllow snsDesc:(NSString *)snsDesc coverImg:(NSString *)coverImg snsNo:(NSString *)snsNo;
-(NSString *)updateSnsMemberInfo:(NSString *)createUserNo createUserNm:(NSString *)createUserNm snsNo:(NSString *)snsNo;

-(NSString *)updatePostNoti:(NSString *)postNoti snsNo:(NSString *)snsNo;
-(NSString *)updateCommentNoti:(NSString *)commNoti snsNo:(NSString *)snsNo;

-(NSString *)updateRoomNewChat:(int)newChat roomNo:(NSString *)roomNo;
-(NSString *)updateChatReadStatus:(NSString *)roomNo;
-(NSString *)updateChatRoomScrolled:(int)isScroll roomNo:(NSString *)roomNo;
-(NSString *)updateChatUnReadCount:(NSNumber *)unReadCnt roomNo:(NSString *)roomNo chatNoList:(NSString *)chatNoList;
-(NSString *)updateRoomNoti:(int)noti roomNo:(NSString *)roomNo;
-(NSString *)updateChatContent:(NSString *)longContent chatNo:(NSString *)chatNo;
-(NSString *)updateRoomName:(NSString *)roomName roomNo:(NSString *)roomNo;
-(NSString *)updateCustomRoomName:(NSString *)roomName roomNo:(NSString *)roomNo;
-(NSString *)updateRoomImage:(NSString *)roomImage roomNo:(NSString *)roomNo;

//DELETE
-(NSString *)deleteMissedChat:(NSString *)roomNo;
-(NSString *)deleteMissedChat:(NSString *)roomNo chatNo:(NSString *)chatNo;
-(NSString *)deleteChats:(NSString *)roomNo;
-(NSString *)deleteChat:(NSString *)roomNo chatNo:(NSString *)chatNo;
-(NSString *)deleteChatUsers:(NSString *)roomNo;
-(NSString *)deleteChatUsers:(NSString *)roomNo userNo:(NSString *)userNo;
-(NSString *)deleteChatRooms:(NSString *)roomNo;
-(NSString *)deleteRoomImage:(NSString *)roomNo;
-(NSString *)deleteSns:(NSString *)snsNo;

@end
