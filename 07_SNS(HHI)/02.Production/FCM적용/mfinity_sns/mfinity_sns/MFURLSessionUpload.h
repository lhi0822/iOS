//
//  MFURLSessionUpload.h
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 9. 5..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFUtil.h"
#import "SVProgressHUD.h"

@protocol MFURLSessionUploadDelegate;

@interface MFURLSessionUpload : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (strong, nonatomic) NSData *sendData;
@property (strong, nonatomic) NSString *sendFileName;
@property (strong, nonatomic) NSMutableData *returnData;
@property (strong, nonatomic) NSDictionary *returnDictionary;
@property (assign, nonatomic) NSString *errorMessage;
@property (strong, nonatomic) NSString *returnDataString;
@property (strong, nonatomic) NSDictionary *paramDictionary;
@property (strong, nonatomic) NSURL *url;
@property (assign, nonatomic) id <MFURLSessionUploadDelegate> delegate;
@property (strong, nonatomic) NSString *wsName;

- (id)initWithURL:(NSURL *)url option:(NSDictionary *)dictionary WithData:(NSData *)sendData AndFileName:(NSString *)fileName;
- (void)URL:(NSURL *)url parameter:(NSDictionary *)dictionary WithData:(NSData *)sendData AndFileName:(NSString *)fileName;

- (BOOL)start;
- (BOOL)start:(void (^)(int count))completion;

@end


@protocol MFURLSessionUploadDelegate <NSObject>
@optional
-(void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error;
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error;
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error completion:(void (^)(int count))completion;
@end
