//
//  MFUtil.h
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 7. 8..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import "KeychainItemWrapper.h"
#import "SecurityManager.h"
@interface MFUtil : NSObject
+ (BOOL)isRooted;
+ (NSString *)getMainURL;
+ (NSString *)getCompNo;
+ (NSString *) getUUID;
+ (UIColor *) myRGBfromHex: (NSString *) code;
+ (NSString *)getAES256Key;
+ (NSDictionary *)getParametersByString:(NSString *)query;
+ (NSString*)getJsonStringByDictionary:(NSDictionary*)dictionary;
@end
@interface NSString(URLEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
+ (NSString *)urlDecodeString:(NSString *)str;
- (NSString *)AES256EncryptWithKeyString:(NSString *)key;
- (NSString *)AES256DecryptWithKeyString:(NSString *)key;
@end
@interface NSData (NSData_AES256)
- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;
@end