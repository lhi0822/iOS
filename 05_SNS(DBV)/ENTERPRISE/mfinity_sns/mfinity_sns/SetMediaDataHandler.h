//
//  SetMediaDataHandler.h
//  mfinity_sns
//
//  Created by hilee on 14/01/2020.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFUtil.h"
#import "MFURLSessionUpload.h"
//#import "MFFileCompress.h"

@protocol SetMediaDataDelegate;

@interface SetMediaDataHandler : NSObject<MFURLSessionUploadDelegate>

@property (strong, nonatomic) NSString *mode;
@property (strong, nonatomic) NSString *roomNo;

-(void)convertChatDataSet:(NSMutableArray *)array;
-(void)dataConvertFinished:(NSMutableArray *)array;

@property (weak, nonatomic) id <SetMediaDataDelegate> delegate;

@end

@protocol SetMediaDataDelegate <NSObject>
@optional
-(void)failedChatData:(NSDictionary *)dict;
-(void)videoCompessing:(float)progress;


@end
