//
//  SplashViewController.h
//  iTennis
//
//  Created by Brandon Trebitowski on 3/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface SplashViewController : UIViewController <NSURLSessionDelegate, NSURLSessionDataDelegate>{
	NSTimer *timer;
	UIImageView *splashImageView;

}
@property(nonatomic,retain) NSTimer *timer;
@property(nonatomic,retain) UIImageView *splashImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *splashImageView;

@property (strong, nonatomic) NSMutableData *returnData;

@end
