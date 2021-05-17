//
//  NSData+AESCrypt.h
//
//  AES Encrypt/Decrypt
//  Created by Jim Dovey and 'Jean'
//  See http://iphonedevelopment.blogspot.com/2009/02/strong-encryption-for-cocoa-cocoa-touch.html
//
//  BASE64 Encoding/Decoding
//  Copyright (c) 2001 Kyle Hammond. All rights reserved.
//  Original development by Dave Winer.
//
//  Put together by Michael Sedlaczek, Gone Coding on 2011-02-22
//

#import <Foundation/Foundation.h>
#import "NFilterCommon.h"

@interface NSData (AESCrypt)

- (NSData *)NF_AES256DecryptWithKey:(NSString *)key iv:(NSString*)iv AESMode:(NFilterAESMode)AESMode;
- (NSData *)NF_AES256EncryptWithKey:(NSString *)key iv:(NSString*)iv AESMode:(NFilterAESMode)AESMode;

+ (NSData *)NF_dataWithBase64EncodedString:(NSString *)string;
- (id)NF_initWithBase64EncodedString:(NSString *)string;

- (NSString *)NF_base64Encoding;
- (NSString *)NF_base64EncodingWithLineLength:(NSUInteger)lineLength;

- (BOOL)NF_hasPrefixBytes:(const void *)prefix length:(NSUInteger)length;
- (BOOL)NF_hasSuffixBytes:(const void *)suffix length:(NSUInteger)length;

- (NSString*) NF_stringWithHexBytes1;
@end
