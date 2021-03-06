//
//  SessionHTTP.m
//  mFinity_test
//
//  Created by Park Jun Hyeong on 2016. 4. 28..
//  Copyright © 2016년 Park Jun Hyeong. All rights reserved.
//

#import "SessionHTTP.h"
#import "SecurityManager.h"
#import "NSData+AES256.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "FBEncryptorAES.h"
#import "BeaconManager_Reco.h"

@implementation SessionHTTP
@synthesize returnData, strCode;

-(BOOL)URL:(NSURL *)url parameter:(NSString *)paramString {
    self.url = url;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    [request setHTTPMethod:@"POST"];
    
    @try {
        NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:paramData];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];

        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        returnData = [[NSMutableData alloc] init];
        [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"%s error : %@",__FUNCTION__,exception);
    }

    return YES;
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    //NSLog(@"%s",__func__);
    //NSLog(@"response : %@",response);

    NSInteger code = [(NSHTTPURLResponse *) response statusCode];
    NSString *errMsg = [[NSString alloc]initWithString:NSLocalizedString(@"msg3", @"")];
    
    if(code >= 200 && code < 300){
        completionHandler (NSURLSessionResponseAllow);
    }else if(code == 404){
        //NSLog(@"%@",strCode);
        [self.delegate returnData:self withErrorMessage:NSLocalizedString(@"msg1", @"") error:nil];
    }else if(code == 500){
       [self.delegate returnData:self withErrorMessage:NSLocalizedString(@"msg2", @"") error:nil];
    }else{
        [self.delegate returnData:self withErrorMessage:[NSString stringWithFormat:@"%@ %ld",errMsg,(long)code] error:nil];
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    //NSLog(@"%s",__func__);
    [self.returnData appendData:data];
    //NSLog(@"returnData : %@", self.returnData);

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    //NSLog(@"%s",__func__);
    NSString *errorMessage = error.localizedDescription;

    @try {
        if(error){
            //NSLog(@"error : %@",errorMessage);
            [self.delegate returnData:self withErrorMessage:errorMessage error:error];
            
        }else{
            _dataStr = [[NSString alloc]initWithData:self.returnData encoding:NSUTF8StringEncoding];
            //NSLog(@"dataStr : %@",_dataStr);
            
            NSError *dicError;
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[_dataStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
            //NSLog(@"dataDic : %@",dataDic);
            
            _returnDictionary = dataDic;
            [self.delegate returnData:self];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"didCompleteWithError : %@",exception);
    }
}

@end
