//
//  PointData.h
//  mFinity
//
//  Created by hilee on 22/05/2019.
//  Copyright © 2019 Jun hyeong Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    PEN = 0,
    ERASE = 1
} TYPES;

@interface PointData : NSObject

@property (readonly, nonatomic) NSMutableArray *points;
@property (strong, nonatomic) UIColor* pColor;   // 현재 색상
@property float pWidth;                          // 현재 선의 두께
@property TYPES pType;                           // 현재 드로잉 타입(PEN, ERASE)

- (void)addPoint:(CGPoint)point;

@end
