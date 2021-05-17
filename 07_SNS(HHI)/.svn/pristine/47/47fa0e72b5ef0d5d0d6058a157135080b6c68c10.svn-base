//
//  ChatMessageData.m
//  mfinity_sns
//
//  Created by hilee on 2017. 4. 21..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ChatMessageData.h"
#import <sqlite3.h>
#import "AppDelegate.h"
#import "MFDBHelper.h"

@implementation ChatMessageData {
    AppDelegate *appDelegate;
    MFDBHelper *dbHelper;
}

- (instancetype)initwithRoomNo:(NSString *)roomNo{
    _roomNum = roomNo;
    return [self init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        dbHelper = [[MFDBHelper alloc] init:@"1" userId:nil];
        
        self.chatArray = [NSMutableArray array];
        
        _myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
        [self readFromDatabase:0];
    }
    return self;
}

- (NSMutableArray *)readFromDatabase :(int)rowCnt{
//    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    _rowCnt = rowCnt;
    NSString *sqlString = [[NSString alloc] initWithString:[dbHelper getChatList:_roomNum rowCount:_rowCnt]];
    return [dbHelper selectMutableArray:sqlString :self.chatArray];
}

@end
