//
//  ChatMessageData.h
//  mfinity_sns
//
//  Created by hilee on 2017. 4. 21..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@interface ChatMessageData : NSObject {
    int _rowCnt;
}

@property (strong, nonatomic) NSMutableArray *chatArray;
@property (nonatomic, strong) NSString *roomNum;
@property (weak, nonatomic) NSString *myUserNo;

- (instancetype)initwithRoomNo:(NSString *)roomNo;
- (NSMutableArray *)readFromDatabase: (int)rowCnt;

@end
