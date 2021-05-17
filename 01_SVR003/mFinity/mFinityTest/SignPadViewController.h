//
//  SignPadViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 19..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
//#import "MFLineDrawView.h"
#import "MainDrawView.h"

@interface SignPadViewController : UIViewController{
//    MFLineDrawView *drawScreen;
//    IBOutlet UINavigationBar *naviBar;
}
@property (nonatomic, strong)NSString *userSpecific;
@property (nonatomic, strong)NSString *callbackFunc;

@property (strong, nonatomic) IBOutlet MainDrawView *canvasView;


@end
