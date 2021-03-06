//
//  SessionHTTP.h
//  mFinity_test
//
//  Created by Park Jun Hyeong on 2016. 4. 28..
//  Copyright © 2016년 Park Jun Hyeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFUtil.h"
@protocol MFURLSessionDelegate;

@interface MFURLSession : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>{
}
- (id)initWithURL:(NSURL *)url option:(NSString *)paramString;
- (BOOL)start;
- (void)URL:(NSURL *)url parameter:(NSString *)paramString;

@property (strong, nonatomic) NSMutableData *returnData;
@property (strong, nonatomic) NSDictionary *returnDictionary;
@property (assign, nonatomic) NSString *errorMessage;
@property (strong, nonatomic) NSString *returnDataString;
@property (strong, nonatomic) NSString *paramString;
@property (strong, nonatomic) NSString *requestMethod;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSError *error;

@property (assign, nonatomic) id <MFURLSessionDelegate> delegate;
@end

@protocol MFURLSessionDelegate <NSObject>
@required
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error;
@optional
-(void)returnDataWithDictionary:(NSDictionary *)dictionary error:(NSString *)error;

@end
