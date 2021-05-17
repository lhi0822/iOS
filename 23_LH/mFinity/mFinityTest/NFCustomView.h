//
//  NFCustomView.h
//  NFUI
//
//  Created by bhchae on 2015. 12. 7..
//  Copyright © 2015년 bhchae. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NFCustomViewDelegate <NSObject>
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)drawRect:(CGRect)rect;
@end

@interface NFCustomView : UIView

@property (nonatomic, weak, nullable) id <NFCustomViewDelegate> delegate;

@end
