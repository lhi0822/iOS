//
//  NSData+AESCrypt.m
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

#import "NSData+AESCrypt.h"
#import <CommonCrypto/CommonCryptor.h>

#include "aes_mod.h"
#include "ns_api.h"

static char encodingTable[64] =
{
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
};

@implementation NSData (AESCrypt)

- (NSData *)NF_AES256EncryptWithKey:(NSString *)key iv:(NSString*)iv AESMode:(NFilterAESMode)AESMode
{
    if (key == nil)
        return nil;
    
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero( keyPtr, sizeof( keyPtr ) ); // fill with zeroes (for padding)
    memcpy(keyPtr, [key UTF8String], sizeof(keyPtr)-1);
    
    const char *ivPtr = [iv UTF8String];
    unsigned char *output = NULL;
    int outlen = 0;
    
    int ivLen = 0;
    if (ivPtr != NULL)
        ivLen = (int)strlen(ivPtr);
    
    unsigned opmode = NSO_CTX_AES_CBC;
    if (AESMode == NFilterAESModeECB)
        opmode = NSO_CTX_AES_ECB;
    
    int ret = NF_encryptAESData(opmode,  (unsigned char *)keyPtr, sizeof(keyPtr)-1, (unsigned char *)[self bytes], (int)[self length],
                                (unsigned char *)ivPtr, ivLen, &output, &outlen);
    if (ret != 0) {
        return nil;
    }
    
    NSData *data = [NSData dataWithBytesNoCopy:output length:outlen];
    return data;
}

- (NSData *)NF_AES256DecryptWithKey:(NSString *)key iv:(NSString*)iv AESMode:(NFilterAESMode)AESMode
{
    if (key == nil)
        return nil;

    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero( keyPtr, sizeof( keyPtr ) ); // fill with zeroes (for padding)
    memcpy(keyPtr, [key UTF8String], sizeof(keyPtr)-1);
    
    const char *ivPtr = [iv UTF8String];
    unsigned char *output = NULL;
    int outlen = 0;
    
    int ivLen = 0;
    if (ivPtr != NULL)
        ivLen = (int)strlen(ivPtr);
    
    unsigned opmode = NSO_CTX_AES_CBC;
    if (AESMode == NFilterAESModeECB)
        opmode = NSO_CTX_AES_ECB;

    int ret = NF_decryptAESData(opmode, (unsigned char *)keyPtr, sizeof(keyPtr)-1, (unsigned char *)[self bytes], (int)[self length],
                                (unsigned char *)ivPtr, ivLen, &output, &outlen);
    if (ret != 0) {
        return nil;
    }
    
    NSData *data = [NSData dataWithBytesNoCopy:output length:outlen];
    return data;
}

#pragma mark -

+ (NSData *)NF_dataWithBase64EncodedString:(NSString *)string
{
    return [[NSData allocWithZone:nil] NF_initWithBase64EncodedString:string];
}

- (id)NF_initWithBase64EncodedString:(NSString *)string
{
    NSMutableData *mutableData = nil;
    
    if( string )
    {
        unsigned long ixtext = 0;
        unsigned long lentext = 0;
        unsigned char ch = 0;
        unsigned char inbuf[4] = {};
        unsigned char outbuf[3];
        short i = 0, ixinbuf = 0;
        BOOL flignore = NO;
        BOOL flendtext = NO;
        NSData *base64Data = nil;
        const unsigned char *base64Bytes = nil;
        
        // Convert the string to ASCII data.
        base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
        base64Bytes = (const unsigned char *)[base64Data bytes];
        mutableData = [NSMutableData dataWithCapacity:base64Data.length];
        lentext = base64Data.length;
        
        while( YES )
        {
            if( ixtext >= lentext ) break;
            ch = base64Bytes[ixtext++];
            flignore = NO;
            
            if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
            else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
            else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
            else if( ch == '+' ) ch = 62;
            else if( ch == '=' ) flendtext = YES;
            else if( ch == '/' ) ch = 63;
            else flignore = YES;
            
            if( ! flignore )
            {
                short ctcharsinbuf = 3;
                BOOL flbreak = NO;
                
                if( flendtext )
                {
                    if( ! ixinbuf ) break;
                    if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
                    else ctcharsinbuf = 2;
                    ixinbuf = 3;
                    flbreak = YES;
                }
                
                inbuf [ixinbuf++] = ch;
                
                if( ixinbuf == 4 ) {
                    ixinbuf = 0;
                    outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
                    outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
                    outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );
                    
                    for( i = 0; i < ctcharsinbuf; i++ )
                        [mutableData appendBytes:&outbuf[i] length:1];
                }
                
                if( flbreak )  break;
            }
        }
    }
    
    return [self initWithData:mutableData];
}

#pragma mark -

- (NSString *) NF_base64Encoding
{
    return [self NF_base64EncodingWithLineLength:0];
}

- (NSString *) NF_base64EncodingWithLineLength:(NSUInteger)lineLength
{
    const unsigned char   *bytes = (const unsigned char *)[self bytes];
    NSMutableString *result = [NSMutableString stringWithCapacity:self.length];
    unsigned long ixtext = 0;
    unsigned long lentext = self.length;
    long ctremaining = 0;
    unsigned char inbuf[3], outbuf[4];
    unsigned short i = 0;
    unsigned short charsonline = 0, ctcopy = 0;
    unsigned long ix = 0;
    
    while( YES )
    {
        ctremaining = lentext - ixtext;
        if( ctremaining <= 0 ) break;
        
        for( i = 0; i < 3; i++ )
        {
            ix = ixtext + i;
            if( ix < lentext ) inbuf[i] = bytes[ix];
            else inbuf [i] = 0;
        }
        
        outbuf [0] = (inbuf [0] & 0xFC) >> 2;
        outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
        outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
        outbuf [3] = inbuf [2] & 0x3F;
        ctcopy = 4;
        
        switch( ctremaining )
        {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for( i = 0; i < ctcopy; i++ )
            [result appendFormat:@"%c", encodingTable[outbuf[i]]];
        
        for( i = ctcopy; i < 4; i++ )
            [result appendString:@"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if( lineLength > 0 )
        {
            if( charsonline >= lineLength )
            {
                charsonline = 0;
                [result appendString:@"\n"];
            }
        }
    }
    
    return [NSString stringWithString:result];
}

#pragma mark -

- (BOOL) NF_hasPrefixBytes:(const void *)prefix length:(NSUInteger)length
{
    if( ! prefix || ! length || self.length < length ) return NO;
    return ( memcmp( [self bytes], prefix, length ) == 0 );
}

- (BOOL) NF_hasSuffixBytes:(const void *)suffix length:(NSUInteger)length
{
    if( ! suffix || ! length || self.length < length ) return NO;
    return ( memcmp( ((const char *)[self bytes] + (self.length - length)), suffix, length ) == 0 );
}

#pragma mark -

- (NSString*) NF_stringWithHexBytes1 {
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    int i;
    for (i = 0; i < [self length]; ++i) {
        [stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }
    return [stringBuffer copy];
}

+ (NSString*) NF_stringWithHexBytesWithData:(NSData *)data {
    
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([data length] * 2)];
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    int i;
    for (i = 0; i < [data length]; ++i) {
        [stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }
    
    return [stringBuffer copy];
}

@end
