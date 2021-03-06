//
//  MFFileCompress.m
//  mfinity_sns
//
//  Created by hilee on 2020/04/27.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "MFFileCompress.h"

@implementation MFFileCompress

//동영상 썸네일 이미지 생성
+(void)makeThumbImgFromVideo:(AVURLAsset *)asset completion:(void (^)(UIImage *))completion{
   @try{
      AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
      imageGenerator.appliesPreferredTrackTransform = YES;
      CMTime time = CMTimeMake(1, 1);
      CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
      UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
      CGImageRelease(imageRef);
      
      completion(thumbnail);
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

+ (void)compressVideoWithInputVideoUrl:(NSURL *)inputVideoUrl asset:(AVAsset*)asset num:(int)num mode:(NSString*)mode fileName:(NSString*)fileName paramNo:(NSString*)paramNo completion:(void (^)(NSData *data))completion{
    //채팅으로 비디오 전송 시 사용되는 파라미터 : mode, fileName, paramNo(roomNo)

    NSString *finalVideoURLString = @"";
    
    if([mode isEqualToString:@"CHAT"]){
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        //폴더생성
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];

        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSString *currentTime = [dateFormatter stringFromDate:today];

        NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/%@/%@/Video/%@/", [MFUtil getFolderName:mode], paramNo, currentTime];
        NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/%@/%@/Video/%@/thumb/", [MFUtil getFolderName:mode], paramNo, currentTime];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL issue = [fileManager isReadableFileAtPath:saveThumbPath];
        if (issue) {
        } else {
          [fileManager createDirectoryAtPath:saveThumbPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        finalVideoURLString = [saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];

    } else {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        finalVideoURLString = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"VIDEO_%d.mp4",num]];
    }

    // 파일이 이미 있는지 확인한 다음 이전 파일을 제거합니다.
    if ([[NSFileManager defaultManager]fileExistsAtPath:finalVideoURLString]){
       NSLog(@"데이터변환 후 삭제");
       [[NSFileManager defaultManager]removeItemAtPath:finalVideoURLString error:nil];
    }

    NSURL *outputVideoUrl = ([[NSURL URLWithString:finalVideoURLString] isFileURL] == 1)?([NSURL URLWithString:finalVideoURLString]):([NSURL fileURLWithPath:finalVideoURLString]);

    SDAVAssetExportSession *compressionEncoder = [SDAVAssetExportSession.alloc initWithAsset:[AVAsset assetWithURL:inputVideoUrl]]; // provide inputVideo Url Here
    compressionEncoder.delegate = self;
    compressionEncoder.outputFileType = AVFileTypeMPEG4;
    compressionEncoder.outputURL = outputVideoUrl;
    compressionEncoder.shouldOptimizeForNetworkUse = YES;

    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    CGSize newSize = [MFUtil getResizeVideoRatio:dimensions];
    NSLog(@"newSize w : %f, h : %f", newSize.width, newSize.height);

    float frameRate = [track nominalFrameRate];
    float bps = [track estimatedDataRate];
    NSLog(@"Frame rate == %f",frameRate);
    NSLog(@"bps rate == %f",bps);

    float defaultBps = 2300000;
    float newBps = (newSize.width * newSize.height * 20 * 0.15);
    if(newBps > defaultBps) newBps = defaultBps;
    NSLog(@"newBps : %f", newBps);

    compressionEncoder.videoSettings = @
    {
      AVVideoCodecKey: AVVideoCodecH264,
      AVVideoWidthKey: @(newSize.width),
      AVVideoHeightKey: @(newSize.height),
      AVVideoCompressionPropertiesKey: @
      {
         //        AVVideoAverageBitRateKey: @2300000,
         AVVideoAverageBitRateKey:@(newBps),
         AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
      },
    };

    compressionEncoder.audioSettings = @
    {
      AVFormatIDKey: @(kAudioFormatMPEG4AAC),
      AVNumberOfChannelsKey: @2,
      AVSampleRateKey: @44100,
      AVEncoderBitRateKey: @128000,
    };

    [compressionEncoder exportAsynchronouslyWithCompletionHandler:^{
        if (compressionEncoder.status == AVAssetExportSessionStatusCompleted){
            NSData *data = [NSData dataWithContentsOfURL:outputVideoUrl];
            completion(data);

        } else if(compressionEncoder.status == AVAssetExportSessionStatusFailed){
            NSLog (@"세션 내보내기 실패");
        //       [self dataConvertFailed];

        } else if(compressionEncoder.status == AVAssetExportSessionStatusCancelled){
            NSLog (@"Export canceled");

        } else if(compressionEncoder.status == AVAssetExportSessionStatusExporting){
            NSLog(@"video conversion exporting");

        } else if(compressionEncoder.status == AVAssetExportSessionStatusWaiting){
            NSLog(@"video conversion is waiting");

        } else if(compressionEncoder.status == AVAssetExportSessionStatusUnknown){
            NSLog(@"video converstion status unknown");
        }

        if ([[NSFileManager defaultManager]fileExistsAtPath:finalVideoURLString]){
           NSLog(@"데이터변환 후 삭제 ***");
           [[NSFileManager defaultManager]removeItemAtPath:finalVideoURLString error:nil];
        }
    }];
}

+(void)videoCompessToPercent:(float)progress{
    @try{
        
    } @catch (NSException *exception) {
       NSLog(@"Exception : %@", exception);
    }
}

@end
