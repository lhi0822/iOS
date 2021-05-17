//
//  NFilterRSAEncryptor.h
//  nFilter
//
//  Created by jechoi-mac on 17/09/2020.
//  Copyright © 2020 bhchae. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NFilterRSAEncryptor : NSObject {
}

static NSString *NF_RSA_base64_encode_data_RSA(NSData *data);
static NSData *NF_RSA_base64_decode_RSA(NSString *str);

+ (NSString *)NF_RSA_encryptString:(NSString *)str publicKey:(NSString *)pubKey; // return base64 encoded string
+ (NSData *)NF_RSA_encryptData:(NSData *)data publicKey:(NSString *)pubKey; // return raw data
+ (NSString *)NF_RSA_decryptString:(NSString *)str publicKey:(NSString *)pubKey; // // decrypt base64 encoded string, convert result to string(not base64 encoded)
+ (NSData *)NF_RSA_decryptData:(NSData *)data publicKey:(NSString *)pubKey;
+ (NSString *)NF_RSA_decryptString:(NSString *)str privateKey:(NSString *)privKey;
+ (NSData *)NF_RSA_decryptData:(NSData *)data privateKey:(NSString *)privKey;

@end

NS_ASSUME_NONNULL_END
