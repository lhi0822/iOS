//
//  AccessAuthCheck.h
//  mfinity_sns
//
//  Created by hilee on 2020/05/08.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>
#import "MFSingleton.h"

@interface AccessAuthCheck : NSObject

//+(BOOL)cameraAccessCheck;
//+(BOOL)photoAccessCheck;
//
//+(BOOL)cameraAccessCheckNotAuth;
//+(BOOL)photoAccessCheckNotAuth;

+ (void)cameraAccessCheck:(void (^)(BOOL status))completion;
+ (void)photoAccessCheck:(void (^)(BOOL status))completion;

+ (void)cameraAccessCheckNotAuth:(void (^)(BOOL status))completion;
+ (void)photoAccessCheckNotAuth:(void (^)(BOOL status))completion;

@end

