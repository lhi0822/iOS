//
//  MFURLSessionUpload.m
//  MFINITY_SNS
//
//  Created by Jun HyungPark on 2016. 9. 5..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFURLSessionUpload.h"
#define BOUNDARY @"---------------------------14737809831466499882746641449"
@implementation MFURLSessionUpload
- (id)initWithURL:(NSURL *)url option:(NSDictionary *)dictionary WithData:(NSData *)sendData AndFileName:(NSString *)fileName{
    self = [super init];
    if (self) {
        [self URL:url parameter:dictionary WithData:sendData AndFileName:fileName];
    }
    
    return self;
}
- (void)URL:(NSURL *)url parameter:(NSDictionary *)dictionary WithData:(NSData *)sendData AndFileName:(NSString *)fileName{
    self.url = url;
    self.paramDictionary = dictionary;
    self.sendData = sendData;
    self.sendFileName = fileName;
    NSLog(@"url : %@",self.url);
    NSLog(@"param : %@",dictionary);
    NSLog(@"fileName : %@",fileName);
}
- (NSData *)createParamData{
    
    if (self.paramDictionary!=nil) {
        NSMutableData *returnData = [NSMutableData data];
        NSArray *keys = self.paramDictionary.allKeys;
        
        for(NSString *key in keys){
            NSLog(@"%s %@",__FUNCTION__,[self.paramDictionary objectForKey:key]);
            [returnData appendData:[[NSString stringWithFormat:@"--%@\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
            [returnData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
            [returnData appendData:[[NSString stringWithFormat:@"%@",[self.paramDictionary objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
            [returnData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        return returnData;
    }else{
        return nil;
    }
    
}
- (BOOL)start{
    
    //NSString *_fileName = [self.paramDictionary objectForKey:@"FILE_NAME"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",BOUNDARY];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *postbody = [NSMutableData data];
    
    //1.parameter
    [postbody appendData:[self createParamData]];
    
    //2.file
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",self.sendFileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:self.sendData]];
    
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    @try {
        
        //[request setHTTPBody:postbody];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
               fromData:postbody completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   
                   if ([response respondsToSelector:@selector(statusCode)]) {
                       if ([(NSHTTPURLResponse *) response statusCode] == 401) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               //NSLog(@"response : %@",response);
                               //NSLog(@"error : %@",error);
                               //-(void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error
                               [self.delegate returnResponse:response WithError:error.localizedDescription];
                               
                               return;
                           });
                       }
                   }
                   
                   if (!error) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                      
                           NSString *encReturnDataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                           self.returnDataString = [NSString urlDecodeString:encReturnDataString];
                           NSLog(@"encReturnDataString : %@",encReturnDataString);
                           NSLog(@"self.returnDataString : %@",self.returnDataString);
                           NSError *dicError;
                           NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[self.returnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
                           
                           self.returnDictionary = dataDic;
                           
                           [self.delegate returnDictionary:dataDic WithError:nil];
                           //[self.delegate returnDataWithObject:self error:nil];
                           
                       
                       });
                       
                   } else {
                       [self.delegate returnResponse:response WithError:error.localizedDescription];
                   }
               }];


        [uploadTask resume];
        
    }
    @catch (NSException *exception) {
        [self.delegate receiveError:exception.description];
        
        return NO;
        
    }
    return YES;
    
}
@end
