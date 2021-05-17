//
//  PointData.m
//  mFinity
//
//  Created by hilee on 07/01/2019.
//  Copyright © 2019 Jun hyeong Park. All rights reserved.
//

#import "PointData.h"

@implementation PointData
@synthesize points;

- (id)init{
    if (self = [super init]){
        points = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addPoint:(CGPoint)point{
    [points addObject:[NSValue valueWithCGPoint:point]];
}

@end
