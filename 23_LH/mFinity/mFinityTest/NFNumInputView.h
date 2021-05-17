//
//  NFNumInputView.h
//  streatchTest
//
//  Created by Han Dae Kwon on 2017. 3. 9..
//  Copyright © 2017년 Han Dae Kwon. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM (NSInteger, NFInputType)
{
    NFInputType4,
    NFInputType6
};

typedef NS_ENUM (NSInteger, NFInputMaskingType)
{
    NFInputTypeNON,    // 안함
    NFInputTypeALL,    // 전부
    NFInputTypeDefault // 마지막 한글자
};

@interface NFNumInputView : UIView

@property (nonatomic, assign) NFInputMaskingType maskingType;
@property (nonatomic, assign) float fontSize;
@property (nonatomic, assign) float dotSize;

- (id) initWithFrame:(CGRect)frame inputType:(NFInputType)inputType;
- (void) changeRotation:(CGSize) size;
- (void) setText:(NSString *)text;
- (void) clearField;

@end
