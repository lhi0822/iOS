//
//  StringUtil.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 6..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "StringUtil.h"

@implementation StringUtil
+ (void) sortedByNick:(NSMutableArray *)_source {
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"nickname" ascending:YES selector:@selector(localizedCompare:)];
    [_source sortUsingDescriptors:[NSArray arrayWithObjects:nameSort, nil]];
 
}

+ (NSMutableArray *) createSectionList:(NSMutableArray *)_source {
    NSMutableArray* sortedArray = [[NSMutableArray alloc] init];
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < [_SECTION_INDEX length]+1; i++) {
        NSMutableArray* temp = [[NSMutableArray alloc] init];
        [sortedArray addObject:temp];
    }
    
    for(NSMutableArray* array in sortedArray) {
        if([array count] > 0) {
            [resultArray addObject:array];
        }
    }
    
    return resultArray;
}

+ (NSMutableArray *) createSectionListForFavor:(NSMutableArray *)_source {
    NSMutableArray* sortedArray = [[NSMutableArray alloc] init];
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < [_SECTION_INDEX length]+2; i++) {
        NSMutableArray* temp = [[NSMutableArray alloc] init];
        [sortedArray addObject:temp];
    }
    
    
    for(NSMutableArray* array in sortedArray) {
        if([array count] > 0) {
            [resultArray addObject:array];
        }
    }
    
    return resultArray;
}

+ (NSMutableArray *) createSectionListForRealname:(NSMutableArray *)_source {
    NSMutableArray* sortedArray = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < [_SECTION_INDEX length]+1; i++) {
        NSMutableArray* temp = [[NSMutableArray alloc] init];
        [sortedArray addObject:temp];
    }
    
    
    return sortedArray;
}

+ (NSMutableArray *) createSectionListForCompared:(NSMutableArray *)_source {
    NSMutableArray* sortedArray = [[NSMutableArray alloc] init];
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < [_SECTION_INDEX length]+2; i++) {
        NSMutableArray* temp = [[NSMutableArray alloc] init];
        [sortedArray addObject:temp];
    }
    
    
    
    for(NSMutableArray* array in sortedArray) {
        if([array count] > 0) {
            [resultArray addObject:array];
        }
    }
    
    return resultArray;
}

+ (NSMutableArray *) createSectionListForManage:(NSMutableArray *)_source {
    NSMutableArray* sortedArray = [[NSMutableArray alloc] init];
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < 3; i++) {
        NSMutableArray* temp = [[NSMutableArray alloc] init];
        [sortedArray addObject:temp];
    }
    
    
    for(NSMutableArray* array in sortedArray) {
        if([array count] > 0) {
            [resultArray addObject:array];
        }
    }
    
    return resultArray;
}


+ (NSString *)GetUTF8String:(NSString *)str {
    NSArray *cho = [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@" ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];
    NSArray *jung = [[NSArray alloc] initWithObjects:@"ㅏ",@"ㅐ",@"ㅑ",@"ㅒ",@"ㅓ",@"ㅔ",@"ㅕ",@"ㅖ",@"ㅗ",@"ㅘ",@" ㅙ",@"ㅚ",@"ㅛ",@"ㅜ",@"ㅝ",@"ㅞ",@"ㅟ",@"ㅠ",@"ㅡ",@"ㅢ",@"ㅣ",nil];
    NSArray *jong = [[NSArray alloc] initWithObjects:@"",@"ㄱ",@"ㄲ",@"ㄳ",@"ㄴ",@"ㄵ",@"ㄶ",@"ㄷ",@"ㄹ",@"ㄺ",@"ㄻ",@" ㄼ",@"ㄽ",@"ㄾ",@"ㄿ",@"ㅀ",@"ㅁ",@"ㅂ",@"ㅄ",@"ㅅ",@"ㅆ",@"ㅇ",@"ㅈ",@"ㅊ",@"ㅋ",@" ㅌ",@"ㅍ",@"ㅎ",nil];
    NSString *returnText = @"";
    for (int i=0;i<[str length];i++) {
        NSInteger code = [str characterAtIndex:i];
        if (code >= 44032 && code <= 55203) { // 한글영역에 대해서만 처리
            NSInteger UniCode = code - 44032; // 한글 시작영역을 제거
            NSInteger choIndex = UniCode/21/28; // 초성
            NSInteger jungIndex = UniCode%(21*28)/28; // 중성
            NSInteger jongIndex = UniCode%28; // 종성
            returnText = [NSString stringWithFormat:@"%@%@%@%@", returnText, [cho objectAtIndex:choIndex], [jung objectAtIndex:jungIndex], [jong objectAtIndex:jongIndex]];
        }
    }
    return returnText;
}

+ (NSString *) get1stChars:(NSString *)str {
    NSArray *cho = [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@" ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];
    NSString *returnText = @"";
    for (int i=0;i<[str length];i++) {
        NSInteger code = [str characterAtIndex:i];
        if (code >= 44032 && code <= 55203) { // 한글영역에 대해서만 처리
            NSInteger UniCode = code - 44032; // 한글 시작영역을 제거
            NSInteger choIndex = UniCode/21/28; // 초성
            returnText = [NSString stringWithFormat:@"%@%@", returnText, [cho objectAtIndex:choIndex]];
        }
    }
    return returnText;
}
+ (NSString *) get1stChars:(NSString *)str charNumber:(int)index{
    NSString *returnText = @"";
    NSArray *cho = [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@" ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];
    for (int i=0;i<[str length];i++) {
        NSInteger code = [str characterAtIndex:i];
        
        if (code >= 44032 && code <= 55203) { // 한글영역에 대해서만 처리
            NSInteger UniCode = code - 44032; // 한글 시작영역을 제거
            NSInteger choIndex = UniCode/21/28; // 초성
            returnText = [NSString stringWithFormat:@"%@%@", returnText, [cho objectAtIndex:choIndex]];
        }
    }
    return returnText;
}

+ (NSString *) get1stChar:(NSString *)str {
    NSArray *cho = [[NSArray alloc] initWithObjects:@"ㄱ",@"ㄲ",@"ㄴ",@"ㄷ",@"ㄸ",@"ㄹ",@"ㅁ",@"ㅂ",@"ㅃ",@"ㅅ",@" ㅆ",@"ㅇ",@"ㅈ",@"ㅉ",@"ㅊ",@"ㅋ",@"ㅌ",@"ㅍ",@"ㅎ",nil];
    NSString *returnText = @"";
    for (int i=0;i<[str length];i++) {
        NSInteger code = [str characterAtIndex:i];
        if (code >= 44032 && code <= 55203) { // 한글영역에 대해서만 처리
            NSInteger UniCode = code - 44032; // 한글 시작영역을 제거
            NSInteger choIndex = UniCode/21/28; // 초성
            returnText = [NSString stringWithString:[cho objectAtIndex:choIndex]];
            break;
        } else {
            NSInteger firstChar = [str characterAtIndex:0];
            NSInteger choChar = 0;
            for(int i = 0; i < [cho count]; i++) {
                choChar = [[cho objectAtIndex:i] characterAtIndex:0];
                if(firstChar == choChar) {
                    returnText = [cho objectAtIndex:i];
                }
            }
        }
    }
    
    if([returnText length] == 0) {
        returnText = @"기타";
    }
    
    return returnText;
}

+ (NSString *) callback:(NSString *)url parameter:(NSString *)param {
    if(param == nil || [param length] == 0) {
        return nil;
    }
    NSRange index = [url rangeOfString:param];
    
    if(index.location == NSNotFound) {
        return nil;
    }
    
    NSInteger loc = index.location;
    NSInteger len = index.length;
    
    NSString* value = nil;
    if(loc+len+1 <= [url length]) {
        value = [url substringFromIndex:loc+len+1];
    } else {
        value = @"";
    }
    
    NSRange endIdx = [value rangeOfString:@"&"];
    ////NSLog(@"endIdx : %d", endIdx.location);
    
    if(endIdx.location == NSNotFound) {
    } else {
        value = [value substringToIndex:endIdx.location];
    }
    return value;
}



+ (NSString *) urlEscapeEncodingForMe2day:(NSString *)url {
    NSString*   encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:-2147481280];
    
    return encodedUrl;
}

+ (NSString *) urlEscapeEncodingWithEUCKR:(NSString *)url {
    NSString*   encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:0x80000003];
    
    return encodedUrl;
}

+ (NSString *) urlEscapeEncoding:(NSString *)url {
    NSString*   encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return encodedUrl;
}

+ (NSString *) urlEncoding:(NSString *)_url {
    NSString*   encodedUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)_url, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    
    return encodedUrl;
}

+ (NSString *) urlEscapeDecoding:(NSString *)url {
    NSString*   decodedUrl = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return decodedUrl;
}

+ (BOOL) needUpdateWithTargetVersion:(NSString *)_sourceVersion target:(NSString *)_targetVersion {
    //NSInteger sourceVersion = [_sourceVersion longLongValue];
    //NSInteger targetVersion = [_targetVersion longLongValue];
    
    if([_sourceVersion longLongValue] < [_targetVersion longLongValue]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *) removceChars:(NSString *)_source target:(NSString *)_target {
    NSString*   result = nil;
    result = [_source stringByReplacingOccurrencesOfString:@"<" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@">" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@" " withString:@""];
    return result;
}
@end
