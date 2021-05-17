//
//  ActivityAlertView.h
//  ezSmart
//
//  Created by mac on 10. 9. 30..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ActivityAlertView : UIAlertView {
	UIActivityIndicatorView *activityView;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityView;

-(void) close;

@end
