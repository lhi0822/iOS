//
//  MIURLSession.m
//  MyIG
//
//  Created by hilee on 2020/04/21.
//  Copyright © 2020 hilee. All rights reserved.
//

#import "MIURLSession.h"
#import "AppDelegate.h"
#define BOUNDARY @"---------------------------14737809831466499882746641449"


@implementation MIURLSession{
    AppDelegate *appDelegate;
}
- (id)initWithURL:(NSURL *)url option:(NSString *)paramString{
    self = [super init];
    if (self) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [self URL:url parameter:paramString];
    }
    return self;
}

- (void)URL:(NSURL *)url parameter:(NSString *)paramString {
    self.url = url;
    self.paramString = paramString;
    if(self.requestMethod==nil) self.requestMethod = @"POST";

    NSLog(@"MFURLSession url : %@", self.url);

    self.wsName = [[self.url absoluteString] lastPathComponent];
}

- (BOOL)start{

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    [request setHTTPMethod:self.requestMethod];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }];
    
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
        NSLog(@"###11 encReturnDataString : %@", encReturnDataString);
        
        self.returnDataString = encReturnDataString;
        NSError *dicError;
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
        self.returnDictionary = dataDic;
        [self.delegate returnDataWithObject:self error:nil];
        
    } else {
        //NSLog(@"error : %@",error);
        //[self.delegate returnDataWithObject:self error:[NSString stringWithFormat:@"%@",error]];
        [self.delegate returnError:self error:error];
    }
    
    self.wsName = nil;
}

@end
