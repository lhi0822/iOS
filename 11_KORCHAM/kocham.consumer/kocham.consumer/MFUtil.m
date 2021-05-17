//
//  MFUtil.m
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 8..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFUtil.h"

@implementation MFUtil

+ (NSString *)getMainURL{
    //개발
//    return @"http://devmapp.korcham.net";
    //운영
    return @"https://mapp.korcham.net";
}
+ (BOOL)isRooted{
    //NSString *isRooting = @"-";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: @"/Applications/Cydia.app"]||
        [fileManager fileExistsAtPath: @"/Applications/RockApp.app"]||
        [fileManager fileExistsAtPath: @"/Applications/Icy.app"]||
        [fileManager fileExistsAtPath: @"/Applications/FakeCrrier.app"]||
        [fileManager fileExistsAtPath: @"/Applications/WinterBoard.app"]||
        [fileManager fileExistsAtPath: @"/Applications/SBSettings.app"]||
        [fileManager fileExistsAtPath: @"/Applications/MxTube.app"]||
        [fileManager fileExistsAtPath: @"/Applications/InteliScreen.app"]||
        [fileManager fileExistsAtPath: @"/Applications/blackra1n.app"]||
        [fileManager fileExistsAtPath: @"/Applications/.app"]||
        [fileManager fileExistsAtPath: @"/usr/sbin/sshd"]||
        [fileManager fileExistsAtPath: @"/usr/bin/sshd"]||
        [fileManager fileExistsAtPath: @"/usr/libexec/sftp-server"]||
        [fileManager fileExistsAtPath: @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist"]||
        [fileManager fileExistsAtPath: @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist"]||
        [fileManager fileExistsAtPath: @"/private/var/lib/apt"]||
        [fileManager fileExistsAtPath: @"/private/var/stash"]||
        [fileManager fileExistsAtPath: @"/private/var/mobile/Library/SBSettings/Themes"]||
        [fileManager fileExistsAtPath: @"/System/Library/LaunchDaemons/com.ikey.bbot.plist"]||
        [fileManager fileExistsAtPath: @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist"]||
        [fileManager fileExistsAtPath: @"/private/var/tmp/cydia.log"]||
        [fileManager fileExistsAtPath: @"/private/var/lib/cydia"]) {
        
        //isRooting = @"Y";
        return YES;
    }else{
        return NO;
        //isRooting = @"N";
    }
}
+ (NSString *) getUUID
{
    // initialize keychaing item for saving UUID.
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    
    NSString *uuid = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    
    if( uuid == nil || uuid.length == 0)
    {
        // if there is not UUID in keychain, make UUID and save it.
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        uuid = [NSString stringWithString:(__bridge NSString *) uuidStringRef];
        CFRelease(uuidStringRef);
        
        // save UUID in keychain
        [wrapper setObject:uuid forKey:(__bridge id)(kSecAttrAccount)];
    }
    
    return uuid;
}
+ (UIColor *) myRGBfromHex: (NSString *) code{
    NSString *str = [[code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([str length] < 6)  // 일단 6자 이하면 말이 안되니까 검은색을 리턴해주자.
        return [UIColor blackColor];
    
    // 0x로 시작하면 0x를 지워준다.
    if ([str hasPrefix:@"0X"])
        str = [str substringFromIndex:2];
    
    // #으로 시작해도 #을 지워준다.
    
    if ([str hasPrefix:@"#"])
        str = [str substringFromIndex:1];
    if ([str length] != 6) //그랫는데도 6자 이하면 이것도 이상하니 그냥 검은색을 리턴해주자.
        return [UIColor blackColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rcolorString = [str substringWithRange:range];
    range.location = 2;
    NSString *gcolorString = [str substringWithRange:range];
    range.location = 4;
    NSString *bcolorString = [str substringWithRange:range];
    unsigned int red, green, blue;
    [[NSScanner scannerWithString: rcolorString] scanHexInt:&red];
    [[NSScanner scannerWithString: gcolorString] scanHexInt:&green];
    [[NSScanner scannerWithString: bcolorString] scanHexInt:&blue];
    
    
    return [UIColor colorWithRed:((float) red / 255.0f)
                           green:((float) green / 255.0f)
                            blue:((float) blue / 255.0f)
                           alpha:1.0f];
    
}

+ (NSString *)getCompNo{
    return @"10";
}
+ (NSString *)getAES256Key{
    return @"E3Z2S1M5A9R8T1F3E2E4L31504081532";
}
+ (NSString*)getJsonStringByDictionary:(NSDictionary*)dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
+ (NSDictionary *)getParametersByString:(NSString *)query{
    NSArray *params = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    for (int i=0; i<[params count]; i++) {
        NSArray *tmpArr = [[params objectAtIndex:i] componentsSeparatedByString:@"="];
        NSString *keyString = [NSString urlDecodeString:[tmpArr objectAtIndex:0]];
        NSString *valueString = [NSString urlDecodeString:[tmpArr objectAtIndex:1]];
        [returnDic setObject:valueString forKey:keyString];
    }
    
    return returnDic;
    
}
@end
@implementation NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding)));
}
+ (NSString *)urlDecodeString:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                             (CFStringRef)temp,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8));
    return result;
}
- (NSString *)AES256EncryptWithKeyString:(NSString *)key
{
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [plainData AES256EncryptWithKey:key];
    
    NSString *encryptedString = [encryptedData base64Encoding];
    
    return encryptedString;
}

- (NSString *)AES256DecryptWithKeyString:(NSString *)key
{
    NSData *encryptedData = [NSData dataWithBase64EncodedString:self];
    NSData *plainData = [encryptedData AES256DecryptWithKey:key];
    
    NSString *plainString = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
    
    return plainString;
}

@end
@implementation NSData (NSData_AES256)
- (NSData *)AES256EncryptWithKey:(NSString *)key
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}
@end
