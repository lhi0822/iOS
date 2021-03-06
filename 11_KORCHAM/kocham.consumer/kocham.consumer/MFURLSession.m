//
//  SessionHTTP.m
//  mFinity_test
//
//  Created by Park Jun Hyeong on 2016. 4. 28..
//  Copyright © 2016년 Park Jun Hyeong. All rights reserved.
//

#import "MFURLSession.h"



@implementation MFURLSession

- (id)initWithURL:(NSURL *)url option:(NSString *)paramString{
    self = [super init];
    if (self) {
        [self URL:url parameter:paramString];
    }
    
    return self;
}
- (void)URL:(NSURL *)url parameter:(NSString *)paramString {
    self.url = url;
    self.paramString = paramString;
    if(self.requestMethod==nil) self.requestMethod = @"POST";
    NSLog(@"url : %@",self.url);
    NSLog(@"parameter : %@",self.paramString);
}
- (BOOL)start{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    [request setHTTPMethod:self.requestMethod];
    
    @try {
        if (self.paramString != nil) {
            NSData *paramData = [self.paramString dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:paramData];
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        self.returnData = [[NSMutableData alloc] init];
        [task resume];
        
    }
    @catch (NSException *exception) {
        NSLog(@"error : %@",exception);
        return NO;
        
    }
    return YES;
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    //NSLog(@"%s",__func__);
    //NSLog(@"response : %@",response);
    
    NSInteger code = [(NSHTTPURLResponse *) response statusCode];
    NSString *errMsg = [[NSString alloc]initWithString:NSLocalizedString(@"MFURLSession_Error_Title", @"")];
    
    if(code >= 200 && code < 300){
        completionHandler (NSURLSessionResponseAllow);
    }else if(code == 404){
        [self.delegate returnDataWithObject:self error:NSLocalizedString(@"MFURLSession_Error_404", @"")];
    }else if(code == 500){
        [self.delegate returnDataWithObject:self error:NSLocalizedString(@"MFURLSession_Error_500", @"")];
    }else{
        [self.delegate returnDataWithObject:self error:[NSString stringWithFormat:@"%@ %ld",errMsg,(long)code]];
    }
    
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.returnData appendData:data];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"%s",__FUNCTION__);
    @try {
        if(!error){
            NSString *encReturnDataString = [[NSString alloc]initWithData:self.returnData encoding:NSUTF8StringEncoding];
            self.returnDataString = encReturnDataString;
            //NSLog(@"encReturnDataString : %@",encReturnDataString);
            //self.returnDataString = [NSString urlDecodeString:encReturnDataString];
            //NSLog(@"self.returnDataString : %@",self.returnDataString);
            NSError *dicError;
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
            self.returnDictionary = dataDic;
            [self.delegate returnDataWithObject:self error:nil];
        }else{
            NSLog(@"error : %@",error);
            self.error = error;
            [self.delegate returnDataWithObject:self error:error.localizedDescription];
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"didCompleteWithError : %@",exception);
        NSLog(@"return Data : %@",self.returnDataString);
        [self.delegate returnDataWithObject:self error:exception.description];
    }
}

@end
