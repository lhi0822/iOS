//
//  MainDrawView.h
//  mFinity
//
//  Created by hilee on 07/01/2019.
//  Copyright © 2019 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointData.h"

@interface MainDrawView : UIView {
    NSMutableArray *pPointArry;     // 모든 좌표 저장
    UIColor *pCurColor;             // 선의 색깔
    float    pCurWidth;             // 선의 두께
    TYPES    pCurType;              // 드로잉 타입
    
}

@property (nonatomic, retain) PointData *curPointData;

- (void)drawScreen:(PointData *)pData inContext:(CGContextRef)context;
- (void)drawPen:(PointData *)pData inContext:(CGContextRef)context;
- (void)drawErase:(PointData *)pData inContext:(CGContextRef)context;

- (void) initCurPointData;

- (void)setCurType:(TYPES)type;
- (void)setCurColor:(UIColor * )color;
- (void)setCurWidth:(float)width;

-(void)canvasClear;


@end
