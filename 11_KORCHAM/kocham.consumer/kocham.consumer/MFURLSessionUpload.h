//
//  MFURLSessionUpload.h
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 9. 5..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFUtil.h"
@protocol MFURLSessionUploadDelegate;

@interface MFURLSessionUpload : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>
@property (strong, nonatomic) NSData *sendData;
@property (strong, nonatomic) NSString *sendFileName;
@property (strong, nonatomic) NSMutableData *returnData;
@property (strong, nonatomic) NSDictionary *returnDictionary;
@property (assign, nonatomic) NSString *errorMessage;
@property (strong, nonatomic) NSString *returnDataString;
@property (strong, nonatomic) NSDictionary *paramDictionary;
@property (strong, nonatomic) NSURL *url;
@property (assign, nonatomic) id <MFURLSessionUploadDelegate> delegate;

- (id)initWithURL:(NSURL *)url option:(NSDictionary *)dictionary WithData:(NSData *)sendData AndFileName:(NSString *)fileName;
- (void)URL:(NSURL *)url parameter:(NSDictionary *)dictionary WithData:(NSData *)sendData AndFileName:(NSString *)fileName;
- (BOOL)start;

@end


@protocol MFURLSessionUploadDelegate <NSObject>
@required
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error;
@optional
-(void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error;
-(void)receiveError:(NSString *)error;
@end
