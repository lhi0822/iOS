//
//  NFView.h
//  NFUI
//
//  Created by bhchae on 2015. 12. 7..
//  Copyright © 2015년 bhchae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NFCustomView.h"

typedef enum NFBackgroundImageLayout
{
    BackgroundImageLayoutNone,
    BackgroundImageLayoutCenter,
    BackgroundImageLayoutTile,
    BackgroundImageLayoutStretch
} NFBackgroundImageLayout;

typedef enum NFDockType
{
    NFDockTypeNone,
    NFDockTypeLeft,
    NFDockTypeTop,
    NFDockTypeRight,
    NFDockTypeBottom,
    NFDockTypeFill
} NFDockType;

typedef struct NFMargins{
    CGFloat left;
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
} NFMargins;

CG_INLINE NFMargins NFMarginsMake(NSInteger left, NSInteger top, NSInteger right, NSInteger bottom)
{
    NFMargins NFilterMargin;
    NFilterMargin.left = left;
    NFilterMargin.top = top;
    NFilterMargin.right = right;
    NFilterMargin.bottom = bottom;
    return NFilterMargin;
}

typedef struct NFPadding{
    CGFloat left;
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
} NFPadding;

@interface NFView : NSObject

@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) CGSize  size;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, readonly, copy) NSArray<__kindof NFView *> *subviews;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NFView *superView;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign) NFBackgroundImageLayout backgroundImageLayout;
@property (nonatomic, assign) NFDockType dock;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) BOOL alignWithMargins;
@property (nonatomic, assign) NFMargins margins;
@property (nonatomic, assign) NFPadding padding;
@property (nonatomic, strong) NFCustomView *view;

- (instancetype)initWithSuperView:(UIView *)superView;
- (instancetype)initWithFrame:(CGRect)rect;
- (void)addSubView:(NFView *)view;
- (void)removeFromSuperView;

@end
