//
//  CustomSegmentedControl.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 27..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSegmentedControl : UISegmentedControl {
	UIColor *offColor;	//off시 배경색
	UIColor *onColor;	//on시 배경색
	UIColor *onTextColor;	//off시 글자색
	UIColor *offTextColor;	//on시 글자색
	int fontSize;	//글자의 크기
}

-(id)initWithItems:(NSArray*)items
		  offColor:(UIColor*)offcolor
           onColor:(UIColor*)oncolor
	  offTextColor:(UIColor*)offtextcolor
       onTextColor:(UIColor*)ontextcolor
		  fontSize:(int)fontsize;

@end
