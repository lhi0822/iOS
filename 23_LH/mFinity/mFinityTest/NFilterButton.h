//
//  NFButton.h
//  toolbar
//
//  Created by 김기원 on 2015. 10. 23..
//  Copyright © 2015년 kwkim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "nFilterTypes.h"


typedef NS_ENUM (NSInteger, NFilterAlignment)
{
    NFilterAlignmentLeft    ,
    NFilterAlignmentRight
};



@interface NFilterButton : UIButton

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NFilterButtonType nFilterbuttonType;
@property (nonatomic, assign) NFilterAlignment alignment;
@property (nonatomic, assign) NFilterMargin margin;



@end
