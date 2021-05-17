//
//  MIURLSession.h
//  MyIG
//
//  Created by hilee on 2020/04/21.
//  Copyright © 2020 hilee. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MIURLSessionDelegate;

@interface MIURLSession : NSObject<NSURLSessionDelegate, NSURLSessionDataDelegate>{
}
- (id)initWithURL:(NSURL *)dnjurl option:(NSString *)paramString;
- (BOOL)start;
- (void)URL:(NSURL *)url parameter:(NSString *)paramString;

@property (strong, nonatomic) NSMutableData *returnData;
@property (strong, nonatomic) NSDictionary *returnDictionary;
@property (assign, nonatomic) NSString *errorMessage;
@property (strong, nonatomic) NSString *returnDataString;
@property (strong, nonatomic) NSString *paramString;
@property (strong, nonatomic) NSString *requestMethod;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *wsName;


@property (weak, nonatomic) id <MIURLSessionDelegate> delegate;
@end

@protocol MIURLSessionDelegate <NSObject>
@required
-(void)returnDataWithObject:(MIURLSession *)session error:(NSString *)error;
@optional
-(void)returnDataWithDictionary:(NSDictionary *)dictionary error:(NSString *)error;
-(void)returnError:(MIURLSession *)session error:(NSError *)error;

@end


