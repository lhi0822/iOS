//
//  SyncChatInfo.h
//  mfinity_sns
//
//  Created by hilee on 2020/08/18.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFSingleton.h"
#import "AppDelegate.h"


@interface SyncChatInfo : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate> {
    NSUInteger taskId;
}

@property (strong, nonatomic) NSString *wsName;
@property (strong, nonatomic) NSString *paramString;
@property (strong, nonatomic) NSMutableData *returnData;
@property (strong, nonatomic) NSDictionary *returnDictionary;

-(void)syncChatRoom;

@end

