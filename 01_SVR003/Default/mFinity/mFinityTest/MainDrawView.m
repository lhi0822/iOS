//
//  MainDrawView.m
//  mFinity
//
//  Created by hilee on 07/01/2019.
//  Copyright © 2019 Jun hyeong Park. All rights reserved.
//

#import "MainDrawView.h"

@implementation MainDrawView
@synthesize curPointData;

- (id)initWithCoder:(NSCoder*)decoder {
    if (self = [super initWithCoder:decoder]){
        pPointArry = [[NSMutableArray alloc] init];
        pCurColor = [UIColor redColor];    //디폴트 색상을 설정
        pCurWidth = 2;                     //디폴트 선의 두께를 설정
        pCurType = PEN;                    //디폴트 트로잉 Type를 설정
        [self initCurPointData];
    }
    return self; // return this object
}

-(void)canvasClear{
    pPointArry = [[NSMutableArray alloc] init];
    [self setNeedsDisplay];
}

- (void) initCurPointData {
    curPointData = [[PointData alloc] init];
    [curPointData setPColor:pCurColor];
    [curPointData setPWidth:pCurWidth];
    [curPointData setPType:pCurType];
}

- (void)setCurType:(TYPES)type //드로잉 타입 설정
{
    pCurType = type;
    [curPointData setPType:type];
}

- (void)setCurColor:(UIColor *)color //선의 색상 설정
{
    pCurColor = color;
    [curPointData setPColor:color];
}

- (void)setCurWidth:(float)width //선의 굵기 설정
{
    pCurWidth = width;
    [curPointData setPWidth:width];
}

- (void) addPointArry{
    [pPointArry addObject:curPointData];
    [self initCurPointData];
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (PointData *pPoint in pPointArry) {
        [self drawScreen:pPoint inContext:context];
    }
    [self drawScreen:curPointData inContext:context];
}

- (void)drawScreen:(PointData *)pData inContext:(CGContextRef)context{
    switch (pData.pType) {
        case PEN:
            [self drawPen:pData inContext:context];
            break;
        case ERASE:
            [self drawErase:pData inContext:context];
            break;
        default:
            break;
    }
}

- (void)drawPen:(PointData *)pData inContext:(CGContextRef)context{
    CGColorRef colorRef = [pData.pColor CGColor];
    CGContextSetStrokeColorWithColor(context, colorRef);
    
    //선의 굵기 설정
    CGContextSetLineWidth(context, pData.pWidth);
    
    NSMutableArray *points = [pData points];
    
    if(points.count == 0) return;
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGPoint firstPoint; // declare a CGPoint
    [[points objectAtIndex:0] getValue:&firstPoint];
    
    //시작점 설정
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    
    for (int i = 1; i < [points count]; i++){
        NSValue *value = [points objectAtIndex:i];
        CGPoint point;
        [value getValue:&point];
        
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);
}

- (void)drawErase:(PointData *)pData inContext:(CGContextRef)context{
    //선의 굵기 설정
    CGContextSetLineWidth(context, 10);
    
    NSMutableArray *points = [pData points];
    
    if(points.count == 0) return;
    
    CGPoint firstPoint; // declare a CGPoint
    [[points objectAtIndex:0] getValue:&firstPoint];
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    //시작점 설정
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    
    for (int i = 1; i < [points count]; i++){
        NSValue *value = [points objectAtIndex:i];
        CGPoint point;
        [value getValue:&point];
        
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *array = [touches allObjects];
    
    for (UITouch *touch in array)
        [curPointData addPoint:[touch locationInView:self]];
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *array = [touches allObjects];
    
    for (UITouch *touch in array)
        [curPointData addPoint:[touch locationInView:self]];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *array = [touches allObjects];
    
    for (UITouch *touch in array)
        [curPointData addPoint:[touch locationInView:self]];
    
    [self addPointArry];
    [self setNeedsDisplay];
}


@end
