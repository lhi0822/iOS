//
//  NSLocale+ios8.m
//  OMaid
//
//  Created by 최형준 on 2014. 12. 22..
//  Copyright (c) 2014년 maino2. All rights reserved.
//

#import "NSLocale+ios8.h"
#import <objc/runtime.h>

@implementation NSLocale (iOS8)

+ (void)load
{
    Method originalMethod = class_getClassMethod(self, @selector(currentLocale));
    Method swizzledMethod = class_getClassMethod(self, @selector(swizzled_currentLocale));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (NSLocale*)swizzled_currentLocale
{
    return [NSLocale localeWithLocaleIdentifier:@"ko_KR"];
}

@end
