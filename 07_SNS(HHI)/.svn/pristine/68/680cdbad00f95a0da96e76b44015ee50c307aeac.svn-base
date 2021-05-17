//
//  MFSyncURLSession.m
//  mfinity_sns
//
//  Created by hilee on 2018. 2. 14..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "MFSyncURLSession.h"
#import "AppDelegate.h"

@implementation MFSyncURLSession{
    AppDelegate *appDelegate;
}

+(MFSyncURLSession *)sharedInstance{
    static MFSyncURLSession *shared = nil;
    
    if(shared==nil){
        shared = [[MFSyncURLSession alloc] init];
    }
    return shared;
}

- (void)URL:(NSURL *)url parameter:(NSString *)paramString :(NSDictionary *)paramDic{
    @try{
        self.url = url;
        self.paramString = paramString;
        if(self.requestMethod==nil) self.requestMethod = @"POST";
        NSLog(@"url : %@",self.url);
        NSLog(@"parameter : %@",self.paramString);
        self.wsName = [[self.url absoluteString] lastPathComponent];
        
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if(![[NSString stringWithFormat:@"%@",url] isEqualToString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish"]){
            NSLog(@"paramString : %@", paramString);
            self.paramString = [MFUtil webServiceParamEncrypt:paramString];
        }
        
        self.paramDictonary = [NSDictionary dictionary];
        self.paramDictonary = paramDic;
        
        //NSLog(@"paramDictonary : %@",[self requestSynchronousDataWithURLString]);
        //NSLog(@"returnDictionary : %@", self.returnDictionary);
        
        [self requestSynchronousDataWithURLString];
        
    } @catch(NSException *exception){
        NSLog(@"error : %@",exception);
    }
}

- (void)requestSynchronousDataWithURLString
{
    NSLog(@"%s", __func__);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    [request setHTTPMethod:self.requestMethod];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",self.url];
    if([urlStr isEqualToString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish"]){
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"Basic YWRtaW46ZmVlbDEwMDE=" forHTTPHeaderField:@"Authorization"];
    }
    
    if (self.paramString != nil) {
        NSData *paramData = [self.paramString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:paramData];
    }
    
    [self startTask:request];
}

- (void)startTask:(NSMutableURLRequest *)request{
    @try {
        NSLog(@"%s", __func__);
        
        __block NSData *data = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
            data = taskData;
            if (!data) {
                NSLog(@"%@", error);
            }
            
            self.returnData = [[NSMutableData alloc] init];
            [self.returnData appendData:data];
            NSString *encReturnDataString = [[NSString alloc]initWithData:self.returnData encoding:NSUTF8StringEncoding];
            
            if(![[NSString stringWithFormat:@"%@",self.url] isEqualToString:@"http://mfps2.hhi.co.kr:15672/api/exchanges/snsHost/mfps.dlq.function/publish"]){
                if([self.wsName isEqualToString:@"changePublicPushId"]||[self.wsName isEqualToString:@"getUserQueueInfo"]){
                    
                } else {
                    if(appDelegate.wsEncrypt){
                        encReturnDataString = [encReturnDataString AES256DecryptWithKeyString:appDelegate.AES256Key];
                    }
                }
            }
            
            self.returnDataString = encReturnDataString;
            NSLog(@"[MFSyncURLSession_%@] returnDataString : %@", self.wsName, self.returnDataString);
            
            NSError *dicError;
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
            self.returnDictionary = dataDic;
            [self.delegate syncReturnDataWithObject:self error:nil];
            
            dispatch_semaphore_signal(semaphore);
        }];
        
        [task resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    @catch (NSException *exception) {
        NSLog(@"error : %@",exception);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"networkErrorNotification" object:nil];
        
    }
}

@end
