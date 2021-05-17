//
//  IntroViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 19..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController<UIAlertViewDelegate>{
    
	IBOutlet UIImageView	*imageView;
	int count;
	IBOutlet UIActivityIndicatorView *myIndicator;
}

@end
