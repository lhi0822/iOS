//
//  NFilterHandler.h
//  mFinity
//
//  Created by hilee on 2021/05/11.
//  Copyright © 2021 Jun hyeong Park. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NFilterNum.h"
#import "NFilterChar.h"

#import "SampleUtils.h"

//@protocol NFilterHandlerDelegate;

@interface NFilterHandler : UIViewController <NFilterCharDelegate, NFilterNumDelegate, NFilterToolbar2Delegate>

@property NFilterNum *numPad;
@property NFilterChar *charPad;

@property UIViewController *lg;

@property BOOL isCustomKeypad;
@property BOOL isSupportLandscape;
@property BOOL isCloseKeypad;
@property BOOL isCustomKeypadToolbar;

- (void)showCharKeyForViewMode;
- (void)showCharKeyForFullMode;

//@property (weak, nonatomic) id <NFilterHandlerDelegate> delegate;

@end


//@protocol NFilterHandlerDelegate <NSObject>
//@optional
//-(void)returnKeyPad:(NFilterChar *)charPad;
//
//@end
