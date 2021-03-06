//
//  MFLineDrawView.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 19..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "MFLineDrawView.h"

@implementation MFLineDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _pathArray=[[NSMutableArray alloc]init];
        bufferArray=[[NSMutableArray alloc]init];
        
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    [[UIColor blackColor] setStroke];
    for (UIBezierPath *_path in _pathArray)
        [_path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    
    
}

#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    _myPath=[[UIBezierPath alloc]init];
    _myPath.lineWidth=5;
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [_myPath moveToPoint:[mytouch locationInView:self]];
    [_pathArray addObject:_myPath];
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [_myPath addLineToPoint:[mytouch locationInView:self]];
    [self setNeedsDisplay];
    
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
