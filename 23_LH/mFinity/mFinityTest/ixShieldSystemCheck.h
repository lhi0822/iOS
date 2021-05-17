//
//  ixShieldSystemCheck.h
//  mFinity
//
//  Created by hilee on 2021/03/31.
//  Copyright © 2021 Jun hyeong Park. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iX.h"

@protocol ixShieldSystemCheckDelegate;

@interface ixShieldSystemCheck : NSObject

@property (weak, nonatomic) id <ixShieldSystemCheckDelegate> delegate;

@end


@protocol ixShieldSystemCheckDelegate <NSObject>
@optional
-(void)systemCheckReturn;
@end


