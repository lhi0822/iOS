//
//  MFFileCompress.h
//  mfinity_sns
//
//  Created by hilee on 2020/04/27.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SDAVAssetExportSession.h"
#import "AppDelegate.h"
#import "MFUtil.h"

@interface MFFileCompress : NSObject <SDAVAssetExportSessionDelegate>

+ (void)compressVideoWithInputVideoUrl:(NSURL *)inputVideoUrl asset:(AVAsset*)asset num:(int)num mode:(NSString*)mode fileName:(NSString*)fileName paramNo:(NSString*)paramNo completion:(void (^)(NSData *data))completion;
+(void)makeThumbImgFromVideo:(AVURLAsset *)asset completion:(void (^)(UIImage *))completion;
+(void)videoCompessToPercent:(float)progress;

@end
