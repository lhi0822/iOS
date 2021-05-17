//
//  MFSyncURLSession.h
//  mfinity_sns
//
//  Created by hilee on 2018. 2. 14..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MFSyncURLSessionDelegate;

@interface MFSyncURLSession : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>

- (void)URL:(NSURL *)url parameter:(NSString *)paramString :(NSDictionary *)paramDic;

@property (strong, nonatomic) NSMutableData *returnData;
@property (strong, nonatomic) NSDictionary *returnDictionary;
@property (assign, nonatomic) NSString *errorMessage;
@property (strong, nonatomic) NSString *returnDataString;
@property (strong, nonatomic) NSString *paramString;
@property (strong, nonatomic) NSString *requestMethod;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *wsName;
@property (strong, nonatomic) NSDictionary *paramDictonary;


@property (weak, nonatomic) id <MFSyncURLSessionDelegate> delegate;
@end

@protocol MFSyncURLSessionDelegate <NSObject>
@required
-(void)syncReturnDataWithObject:(MFSyncURLSession *)session error:(NSString *)error;
@optional
-(void)syncReturnDataWithDictionary:(NSDictionary *)dictionary error:(NSString *)error;
-(void)syncReturnError:(MFSyncURLSession *)session error:(NSError *)error;

@end
