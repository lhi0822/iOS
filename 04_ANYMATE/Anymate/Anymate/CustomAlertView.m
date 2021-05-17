//
//  CustomAlertView.m
//  Anymate
//
//  Created by Kyeong In Park on 12. 12. 27..
//  Copyright (c) 2012년 Kyeong In Park. All rights reserved.
//

#import "CustomAlertView.h"

@implementation CustomAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id) initWithTitle:(NSString *)title
			 message:(NSString *)message
			delegate:(id)delegate
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION{
	
	self = [super initWithTitle:title
						message:@"\n\n\n\n\n\n"
					   delegate:delegate
              cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:otherButtonTitles,nil];

	return self;
}

- (void)dealloc {
    [super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
