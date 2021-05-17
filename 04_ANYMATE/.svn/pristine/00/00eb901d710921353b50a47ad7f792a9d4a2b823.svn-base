//
//  SessionHTTP.h
//  mFinity_test
//
//  Created by Park Jun Hyeong on 2016. 4. 28..
//  Copyright © 2016년 Park Jun Hyeong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SessionHTTPDelegate;

@interface SessionHTTP : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>

-(BOOL)URL:(NSURL *)url parameter:(NSString *)paramString;
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler;
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

@property (assign, nonatomic) id <SessionHTTPDelegate> delegate;
@property (strong, nonatomic) NSMutableData *returnData;
@property (strong, nonatomic) NSDictionary *returnDictionary;
@property (strong, nonatomic) NSString *strCode;
@property (assign, nonatomic) NSString *errorMessage;
@property (strong, nonatomic) NSString *dataStr;
@property (strong, nonatomic) NSURL *url;

@end

@protocol SessionHTTPDelegate <NSObject>
@optional
-(void)returnData:(SessionHTTP *)session;
-(void)returnData:(SessionHTTP *)SessionHTTP withErrorMessage:(NSString *)errorMessage error:(NSError *)error;

@end
