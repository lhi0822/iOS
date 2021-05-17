//
//  CustomSegmentedControl.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 27..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "CustomSegmentedControl.h"


@implementation CustomSegmentedControl

//UISegment계열 폰트의 색과 크기를 조절시켜준다. 재귀적으로 찾아가는 것을 눈여겨 보자.
- (void)_changeUISegmentFont:(UIView*) aView
					fontSize:(int)fontsize
                   textColor:(UIColor*)textcolor
{
	NSString *typeName = NSStringFromClass([aView class]);
	if([typeName compare:@"UISegmentLabel" options:NSLiteralSearch] == NSOrderedSame) {
		UILabel *label = (UILabel*)aView;
		UIFont *font = [UIFont boldSystemFontOfSize:fontsize];
		[label setFont:font]; //글자크기 지정
		[label setTextColor:textcolor]; //글자색 지정
		//글자크기에 따라 위치/크기 보정
		//CGSize size = [label.text sizeWithFont:font forWidth:320 lineBreakMode:UILineBreakModeClip];
		//[label setFrame:CGRectMake(0, 0, size.width, size.height)];
		//[label setCenter:CGPointMake(label.superview.frame.size.width/2, label.superview.frame.size.height/2)];
	}
	NSArray *subs = [aView subviews];
	NSEnumerator* iter = [subs objectEnumerator];
	UIView *subView;
	while (subView = [iter nextObject]) {
		[self _changeUISegmentFont:subView fontSize:fontsize textColor:textcolor];
	}
}

//색이 바뀔때마다 Segment의 배경색과 폰트색을 바꿔준다.
-(void)_setToggleHiliteColors {
	////NSLog(@"%d",self.selectedSegmentIndex);
	int index = self.selectedSegmentIndex;
	int numSegments = [self.subviews count];
	id subview;
	
	//리셋 및 선택 처리
	//   깜박임이 존재하는 것은 UISegmentedControl 내부적으로 폰트 및 색을 그렸다가
	//   여기서 또 강제로 다시한번 지정하기 때문에 그렇다.
	//   어찌할 방법을 찾지는 못했지만 그럭저럭 쓸만함
	for (int i=0; i<numSegments; i++) {
		subview = [self viewWithTag:i];
		if (i==index) { //선택
			[subview setTintColor:nil];
			[subview setTintColor:onColor];
			[self _changeUISegmentFont:subview fontSize:fontSize textColor:onTextColor];
		} else { //리셋
			[subview setTintColor:nil];
			[subview setTintColor:offColor];
			[self _changeUISegmentFont:subview fontSize:fontSize textColor:offTextColor];
			
		}
	}
}

//초기화 함수
-(id)initWithItems:(NSArray*)items
		  offColor:(UIColor*)offcolor
           onColor:(UIColor*)oncolor
	  offTextColor:(UIColor*)offtextcolor
       onTextColor:(UIColor*)ontextcolor
		  fontSize:(int)fontsize
{
	if (self = [super initWithItems:items]) {
		//색 및 폰트크기 지정
		offColor = offcolor;
		onColor = oncolor;
		offTextColor = offtextcolor;
		onTextColor = ontextcolor;
		fontSize = fontsize;
		
		//스타일 고정
		[self setBackgroundColor:[UIColor clearColor]];
		[self setSegmentedControlStyle:UISegmentedControlStyleBar];
		
		//루프를 돌면서 태그를 달아줌
		id subview;
		for (int i=0; i<[self.subviews count]; i++) {
			subview = [self.subviews objectAtIndex:i];
			[subview setTag:i];
		}
		
		//listen for updates
		[self addTarget:self action:@selector(_setToggleHiliteColors) forControlEvents:UIControlEventValueChanged];
		
		//비동기적으로 한번 호출해준다. 글자크기/배경색 적용을 위해...
		[self performSelector:@selector(_setToggleHiliteColors) withObject:nil afterDelay:0.1];
	}
	return self;
}


@end
