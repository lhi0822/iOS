//
//  SessionHTTP.m
//  mFinity_test
//
//  Created by Park Jun Hyeong on 2016. 4. 28..
//  Copyright © 2016년 Park Jun Hyeong. All rights reserved.
//

#import "MFURLSession.h"
#import "AppDelegate.h"

@implementation MFURLSession{
    AppDelegate *appDelegate;
}

- (id)initWithURL:(NSURL *)url option:(NSString *)paramString{
    self = [super init];
    if (self) {
//        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
//        if(![[NSString stringWithFormat:@"%@",url] isEqualToString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish"] ){
        if([[NSString stringWithFormat:@"%@", url] rangeOfString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps"].location == NSNotFound){
            NSLog(@"[%@] paramString : %@", [[url absoluteString] lastPathComponent], paramString);
            self.decParamStr = paramString;
            
            paramString = [MFUtil webServiceParamEncrypt:paramString];
        }
        [self URL:url parameter:paramString];
    }
    return self;
}

- (void)URL:(NSURL *)url parameter:(NSString *)paramString {
    self.url = url;
    self.paramString = paramString;
    if(self.requestMethod==nil) self.requestMethod = @"POST";

    NSLog(@"url : %@", self.url);
//    NSLog(@"MFURLSession paramString : %@", self.paramString);

    self.wsName = [[self.url absoluteString] lastPathComponent];
}

- (BOOL)start{
//    NSLog(@"MFURLSession wsName : %@", self.wsName);
    
    if([self.wsName isEqualToString:@"chkUsrLogin"]||[self.wsName isEqualToString:@"saveChat"]||[self.wsName isEqualToString:@"saveNotification"]||[self.wsName isEqualToString:@"getRoomInfo"]||[self.wsName isEqualToString:@"saveChatReadStatus"]){
        
    } else {
        //[SVProgressHUD show];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    [request setHTTPMethod:self.requestMethod];
    
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];

//http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.topic/publish
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",self.url];
    if([urlStr rangeOfString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps"].location != NSNotFound){
//    if([urlStr isEqualToString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish"]){
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"Basic YWRtaW46ZmVlbDEwMDE=" forHTTPHeaderField:@"Authorization"];
    }
    
    //NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    }];
    
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotification" object:nil];
        
        return YES;
        
    }
    return YES;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSInteger code = [(NSHTTPURLResponse *) response statusCode];
    NSString *errMsg = [[NSString alloc]initWithString:NSLocalizedString(@"MFURLSession_Error_Title", @"")];
    
    if(code >= 200 && code < 300) {
        completionHandler (NSURLSessionResponseAllow);
    } else if(code == 404) {
        [self.delegate returnDataWithObject:self error:NSLocalizedString(@"MFURLSession_Error_404", @"")];
    } else if(code == 500) {
        [self.delegate returnDataWithObject:self error:NSLocalizedString(@"MFURLSession_Error_500", @"")];
    } else {
        [self.delegate returnDataWithObject:self error:[NSString stringWithFormat:@"%@ %ld",errMsg,(long)code]];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.returnData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(!error){
        NSString *encReturnDataString = [[NSString alloc]initWithData:self.returnData encoding:NSUTF8StringEncoding];
//        NSLog(@"###11 encReturnDataString : %@", encReturnDataString);
        
        if([[NSString stringWithFormat:@"%@", _url] rangeOfString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps"].location == NSNotFound){
//        if(![[NSString stringWithFormat:@"%@",self.url] isEqualToString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish"]){
            if([self.wsName isEqualToString:@"changePublicPushId"]||[self.wsName isEqualToString:@"getUserQueueInfo"]){
                
            } else {
                if([[MFSingleton sharedInstance] wsEncrypt]){
                    encReturnDataString = [encReturnDataString AES256DecryptWithKeyString:[[MFSingleton sharedInstance] aes256key]];
                }
            }
            
            self.returnDataString = encReturnDataString;

            NSLog(@"[%@] returnDataString : %@", self.wsName, self.returnDataString);

            @try{
                NSError *dicError;
                NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
//                NSLog(@"dataDict : %@", dataDic);
                
                self.returnDictionary = dataDic;
                
            } @catch (NSException *exception) {
                NSLog(@"error : %@",exception);
            }
            [self.delegate returnDataWithObject:self error:nil];
        }
        
        
    } else {
        NSLog(@"Error : %@",error);
        //[self.delegate returnDataWithObject:self error:[NSString stringWithFormat:@"%@",error]];
        [self.delegate returnError:self error:error];
    }
    
    self.wsName = nil;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog();
}

@end

