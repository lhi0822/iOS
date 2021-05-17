//
//  StringUtil.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 6..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#define _SECTION_INDEX  @"ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎ"
@interface StringUtil : NSObject

+ (NSString *) callback:(NSString *)url parameter:(NSString *)param;

+ (NSString *) urlEscapeEncodingForMe2day:(NSString *)url;
+ (NSString *) urlEscapeEncodingWithEUCKR:(NSString *)url;
+ (NSString *) urlEscapeEncoding:(NSString *)url;
+ (NSString *) urlEscapeDecoding:(NSString *)url;
+ (NSString *) urlEncoding:(NSString *)url;

+ (BOOL) needUpdateWithTargetVersion:(NSString *)_sourceVersion target:(NSString *)_targetVersion;

+ (NSString *) removceChars:(NSString *)_source target:(NSString *)_target;

+ (void) sortedByNick:(NSMutableArray *)_source;

+ (NSMutableArray *) createSectionList:(NSMutableArray *)_source;
+ (NSMutableArray *) createSectionListForRealname:(NSMutableArray *)_source;
+ (NSMutableArray *) createSectionListForFavor:(NSMutableArray *)_source;
+ (NSMutableArray *) createSectionListForCompared:(NSMutableArray *)_source;
+ (NSMutableArray *) createSectionListForManage:(NSMutableArray *)_source;

+ (NSString *) GetUTF8String:(NSString *)str;
+ (NSString *) get1stChars:(NSString *)str;
+ (NSString *) get1stChar:(NSString *)str;
@end
