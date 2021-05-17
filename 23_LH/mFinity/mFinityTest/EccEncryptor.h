//
//  EccEncryptor.h
//  nFilterModuleBasic
//
//  Created by 발팀 개 on 10. 3. 11..
//  Copyright 2010 NSHC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NFilterAESCrypt.h"
#import "NFilterRSAEncryptor.h"

@interface EccEncryptor : NSObject {
	
	NSData *_publicKeyOfMine;
	NSData *_privateKeyOfMine;
	NSData *_sharedKey;     //서버로 보낼 데이터 암호화
	NSData *_sharedKey2;	//AES 암복호화, 연동모드가 아닐 경우
	NSMutableData *_rcvPublicKeyDataFromServer;
    NFilterAESCrypt *nFilterAESCrypt;
    NFilterRSAEncryptor *nFilterRSAEncryptor;
    
	NSArray *_arrKeyNum;
	NSArray *_arrKeyNum2;
    NSString *_encryptedAESKey;
}

+ (EccEncryptor *)sharedInstance;

- (NSArray *)makeGapWithKeypads:(NSInteger)pSeed
					   gapCount:(NSInteger)pGapCount widthPixel:(NSInteger)pWidthPixel;

- (void)setServerPublickeyURL:(NSString *)pXmlURL;
- (void)setServerPublickey:(NSString *)pServerPublickey;
- (void)setRSAPublicKey:(NSString *)pRSAPublicKey;
- (void)makeSharedKey;

- (NSString *)makeEncWithPadding:(NSData *)pPlainText padding:(BOOL)isNOPadding;
- (NSString *)makeEncWithPadding2:(NSMutableArray *)pPlainText padding:(BOOL)isNOPadding;
- (NSString *)makeEncWithPadding3:(NSMutableArray *)pPlainText padding:(BOOL)isNOPadding;
- (NSString *)makeEncNoPadding:(NSData *)pPlainText;
- (NSString *)makeEncNoPadding2:(NSMutableArray *)pPlainText;
- (NSString *)makeEncPadding:(NSData *)pPlainText;
- (NSString *)makeEncPadding2:(NSMutableArray *)pPlainText;
- (NSString *)makeDecNoPadWithSeedkey:(NSString *)pPlainText __attribute__((deprecated("Replaced by makeDecNoPadWithSeedkey:decryptString:decryptLength:")));
- (BOOL)makeDecNoPadWithSeedkey:(NSString *)pPlainText output:(char **)output outlen:(int *)outlen;
- (NSString *)makeEncNoPadWithSeedkey2:(NSMutableArray *)pPlainText;
- (NSString *)makeEncNoPadWithSeedkey3:(NSMutableArray *)pPlainText;

- (NSArray *)getKeypadArray;
- (NSArray *)getKeypadArray2;
- (NSArray *)getKeypadArray:(NSData *)pSeedKey;
- (NSArray *)Permutation:(int)maxsize;

- (void)getSeedKeyNClientPublickeyWithServerPublickey:(NSString *)pServerPublicKey
                                      ClientPublickey:(NSString **)vClientPublickey SeedKey:(NSData **)vSeedKey;
- (void)getSeedKeyNClientPublickeyWithServerPublickeyURL:(NSString *)pServerPublicKeyURL
                                         ClientPublickey:(NSString **)vClientPublickey SeedKey:(NSData **)vSeedKey;

- (NSString *)makeEncNoPadWithSeedkey:(NSData *)pPlainText;
- (NSString *)makeEncNoPadWithSeedkey:(NSData *)pPlainText seedKey:(NSData *)pSeedKey;
- (NSString *)makeEncPadWithSeedKey:(NSData *)pPlainText seedKey:(NSData *)pSeedKey;

- (NSInteger)getRandNum:(NSData *)pSeedKey;
- (NSInteger)getRandNum;

- (NSData *) encyptWithAES:(NSData *)pPlainText pubkey:(NSString*)pPubkey;
- (NSData *) encyptWithAES2:(NSMutableArray *)pPlainText pubkey:(NSString*)pPubkey;
- (NSData *) encyptWithAES3:(NSMutableArray *)pPlainText pubkey:(NSString*)pPubkey;
- (NSString *)genKey:(NSString *)pubKey;
- (NSString *) getIV:(NSString*)val;
- (NSString *) getEncryptedAESKey;

- (NSString *)getLocalEncdata:(NSData *)pPlainText mode:(NSString *)isMode;

+ (BOOL) decryptAES256WithKey:(NSData *)data Key:(NSString *)key iv:(NSString*)iv AESMode:(NFilterAESMode)AESMode output:(unsigned char **)output outlen:(int *)outlen ;

@property (nonatomic, assign) BOOL useInitialVector;
@property (nonatomic, assign) NFilterAESMode AESMode;
@property (nonatomic, assign) NSString *coworkerCode;
@property (nonatomic, assign) NSString *RSAPublicKey;
@property (nonatomic, assign) BOOL isUseRSA;

- (NSString *) getDecryptedAESKey:(NSString *)key privateKey:(NSString *)privateKey;
    
@end
