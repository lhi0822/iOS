//
//  WebViewAdditions.m
//  Anymate
//
//  Created by Kyeong In Park on 13. 1. 22..
//  Copyright (c) 2013년 Kyeong In Park. All rights reserved.
//
#import "WebViewAdditions.h"

@implementation UIWebView(WebViewAdditions)

- (CGSize)windowSize
{
    CGSize size;
    size.width = [[self stringByEvaluatingJavaScriptFromString:@"window.innerWidth"] integerValue];
    size.height = [[self stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] integerValue];
    return size;
}

- (CGPoint)scrollOffset
{
    CGPoint pt;
    pt.x = [[self stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] integerValue];
    pt.y = [[self stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
    return pt;
}
@end

