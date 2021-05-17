//
//  ActivityAlertView.m
//  ezSmart
//
//  Created by mac on 10. 9. 30..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ActivityAlertView.h"


@implementation ActivityAlertView

@synthesize activityView;

-(id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
		[self addSubview:activityView];
		activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[activityView startAnimating];
	}
	
	return self;
}

-(void) close {
	[self dismissWithClickedButtonIndex:0 animated:YES];
}

@end
