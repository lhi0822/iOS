//
//  Toolbar.h
//  toolbar
//
//  Created by 김기원 on 2015. 10. 23..
//  Copyright © 2015년 kwkim. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "nFilterTypes.h"

@protocol NFilterToolbarDelegate <NSObject>

- (void) NFilterButtonClick:(id)sender;

@end

CG_INLINE NFilterMargin NFilterMarginMake(NSInteger left, NSInteger top, NSInteger right, NSInteger bottom)
{
    NFilterMargin NFilterMargin;
    NFilterMargin.left = left;
    NFilterMargin.top = top;
    NFilterMargin.right = right;
    NFilterMargin.bottom = bottom;
    return NFilterMargin;
}

@interface NFilterToolbar : UIView {
    
}

@property (nonatomic, strong) NSArray * buttons;
@property (nonatomic, weak) id<NFilterToolbarDelegate> delegate;
@property (nonatomic, assign) NFilterToolbarAlign align;
@property (nonatomic, assign) NSInteger height;

- (void) OrientationChanged:(BOOL)isLandscape;
@end
