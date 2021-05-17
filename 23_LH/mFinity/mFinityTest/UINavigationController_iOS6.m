//
//  UINavigationController_iOS6.m
//  NFilterSample
//
//  Created by bhchae on 2016. 7. 18..
//  Copyright © 2016년 bhchae. All rights reserved.
//

#import "UINavigationController_iOS6.h"

@implementation UINavigationController(Rotate_iOS6)

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}
@end
