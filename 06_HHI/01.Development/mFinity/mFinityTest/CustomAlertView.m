    //
//  CustomAlertView.m
//  EzSmart
//
//  Created by mac on 11. 7. 20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomAlertView.h"


@implementation CustomAlertView
- (id) initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    self = [super initWithTitle:title
						message:@"\n\n\n\n\n\n\n\n\n\n\n"
					   delegate:delegate
              cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:otherButtonTitles,nil];
	
	return self;
}


@end
