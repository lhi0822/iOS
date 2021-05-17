
#import "VersionCheck.h"
#define BOUNDARY @"---------------------------14737809831466499882746641449"

@implementation VersionCheck

-(void)currentVersionCheck:(NSString *)url param:(NSString *)param{
    //버전체크 웹서비스 호출
//    NSString *urlString = @"https://touch1.hhi.co.kr/dataservice41/ezLogin3";
//    NSString *paramString = @"id=rEziypCOw2B1PIcdICjy8Q%3D%3D&pwd=efftucyfrdz0IoWtomcsUA%3D%3D&dvcid=B2C088E3-FBC5-4EF5-9CE4-9DA65A0A61A7&dvcgubn=P&tel_corp=KT&os_ver=13.3.1&extra_ram=N&extra_total_volume=0&extra_usable_volume=0&usable_volume=48606040064&push_1=d5a73e9901841184d6cc9db05368a39e4d6df258def170ae0a9810564c8341d7&push_2=-&rooting=N&dvcOS=iOS&RES_VER=2552&MF_VER=5.1.7&returnType=JSON&encType=AES256";
    
    [self URL:[NSURL URLWithString:url] parameter:param];
}

#pragma mark - MFURLSession delegate
- (void)URL:(NSURL *)url parameter:(NSString *)paramString {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    [request setHTTPMethod:@"POST"];

    @try {
        if (paramString != nil) {
            NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
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
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSInteger code = [(NSHTTPURLResponse *) response statusCode];
    if(code >= 200 && code < 300) {
        completionHandler (NSURLSessionResponseAllow);
    } else {
        NSLog(@"error code : %ld", (long)code);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.returnData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(!error){
        NSString *encReturnDataString = [[NSString alloc]initWithData:self.returnData encoding:NSUTF8StringEncoding];
        self.returnDataString = encReturnDataString;
//        NSLog(@"[MFURLSession] returnDataString : %@", self.returnDataString);

        NSError *dicError;
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
        self.returnDictionary = dataDic;
//        NSLog(@"dic : %@",self.returnDictionary);
        
        [self.delegate returnDataWithObject:self error:nil];
        
    } else {
        NSLog(@"error : %@",error);
    }
}

@end
