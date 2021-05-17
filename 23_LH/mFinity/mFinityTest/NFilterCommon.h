//
//  NFilterCommon.h
//  nFileterForiPhone
//
//  Created by 김기원 on 2016. 2. 16..
//
//
#import <UIKit/UIKit.h>

@import Foundation;

#define NF_versionInfo @"nFilter iOS 6.0.0"

typedef NS_ENUM (NSInteger, NFilterMasking)
{
    NFilterMaskingDefault,
    NFilterMaskingAll,
    NFilterMaskingNon
};

typedef NS_ENUM (NSInteger, NFilterAttachType)
{
    NFilterAttachView,
    NFilterAttachViewController
};

typedef NS_ENUM (NSInteger, NFilterAESMode)
{
    NFilterAESModeCBC,
    NFilterAESModeECB
};

@interface NFilterCommon : NSObject
{
    
}

+ (void)soundPlay:(NSString*)pSoundFile;
+ (BOOL)isIPhoneX;
@end
