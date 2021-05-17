//
//  NFilterToolbar.h
//  ToolbarTest
//
//  Created by bhchae on 2016. 7. 14..
//  Copyright © 2016년 bhchae. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFilterButton2.h"

@interface NFilterToolbar2 : UIView

@property (nonatomic, assign) id <NFilterToolbar2Delegate> delegate;
@property (nonatomic, assign) NFilterToolbarAlign align;
@property (nonatomic, strong) NFView *container;

- (void) addToolbarButton:(NFView *) toolbarButton;
@end
