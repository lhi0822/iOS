//
//  NFilterAESCrypt.h
//

#import <Foundation/Foundation.h>
#include "NFilterCommon.h"

@interface NFilterAESCrypt : NSObject {
    
}

- (NSData *)NF_AES256EncryptWithData:(NSData *)data Key:(NSString *)key iv:(NSString*)iv AESMode:(NFilterAESMode)AESMode;
- (NSData *)NF_AES256DecryptWithData:(NSData *)data Key:(NSString *)key iv:(NSString*)iv AESMode:(NFilterAESMode)AESMode;

- (id)NF_initWithBase64EncodedString:(NSString *)string;
+ (NSData *)NF_dataWithBase64EncodedString:(NSString *)string;

- (NSString *)NF_base64EncodingWithData:(NSData *)data;
- (NSString *)NF_base64EncodingWithData:(NSData *)data LineLength:(NSUInteger)lineLength;

- (NSString *) NF_stringWithHexBytesWithData:(NSData *)data;
@end
