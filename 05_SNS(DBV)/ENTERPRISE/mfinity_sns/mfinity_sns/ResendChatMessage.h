//
//  ResendChatMessage.h
//  mfinity_sns
//
//  Created by hilee on 2020/12/07.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ResendChatMessage : NSObject

@property (nonatomic,strong) NSMutableDictionary *editInfoDic;
- (NSDictionary *)resendMessage:(NSDictionary *)dictionary roomNo:(NSString *)roomNo;

@end

NS_ASSUME_NONNULL_END
