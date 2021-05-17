//
//  IntroViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 19..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ixShieldSystemCheck.h"

@interface IntroViewController : UIViewController{
	IBOutlet UIImageView	*imageView;
	int count;
	
}

@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *myIndicator;

@end
