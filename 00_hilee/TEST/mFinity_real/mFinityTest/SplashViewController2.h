//
//  SplashViewController2.h
//  sample
//
//  Created by hilee on 17/03/2020.
//  Copyright © 2020 hilee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VersionCheck.h"

NS_ASSUME_NONNULL_BEGIN

@interface SplashViewController2 : UIViewController <VersionCheckDelegate>{
    NSTimer *timer;
    UIImageView *splashImageView;

}
@property(nonatomic,retain) NSTimer *timer;
@property(nonatomic,retain) UIImageView *splashImageView;

@end

NS_ASSUME_NONNULL_END
