//
//  ShareViewController.m
//  ShareEx
//
//  Created by hilee on 24/10/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "ShareViewController.h"

//디비밸리 테스트
//callScheme = @"com.dbvalley.mfinity.sns";
//appGroup = @"group.sns.share";
#define SHARE_GRP_NAME @"group.hhi.sns.share"
#define CALL_SCHEME @"hhi.mobile.ios.sns"

@interface ShareViewController (){
    int setCount;
    UIActivityIndicatorView *indicator;
}
@end

@implementation ShareViewController

-(void)viewDidLoad{
    NSLog(@"%s", __func__);
    
    indicator = [[UIActivityIndicatorView alloc] init];
    [indicator setFrame:CGRectMake(0, 0, 50, 50)];
    [indicator setCenter:self.view.center];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    if([[MFSingleton sharedInstance] workTimeLimit]){
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH"];
        NSString *dateString = [dateFormatter stringFromDate:date];
//        NSLog(@"current time is : %@",dateString);
        
        int currTime = [dateString intValue];
        
//        if(8<=currTime && currTime<10){
        if(8<=currTime && currTime<18){
            [self dataConvert];
            
        } else {
            NSString *msg = @"주52시간 근로시간 준수를 위해 근무시간 외 글쓰기 기능이 제한이 제한됩니다. \n(※ 글쓰기 가능시간 : 오전8시~오후6시)";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        
    } else {
        [self dataConvert];
    }
    
}

- (NSString *)stringFromDeviceToken:(NSData *)deviceToken {
    NSUInteger length = deviceToken.length;
    if (length == 0) {
        return nil;
    }
    const unsigned char *buffer = deviceToken.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(length * 2)];
    for (int i = 0; i < length; ++i) {
        [hexString appendFormat:@"%02x", buffer[i]];
    }
    return [hexString copy];
}

-(void)dataConvert{
    setCount = 0;
    NSMutableArray *arr = [NSMutableArray array];
    NSUserDefaults *shareDefaults = [[NSUserDefaults alloc] initWithSuiteName:SHARE_GRP_NAME];
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        NSUInteger *count = item.attachments.count;
        NSLog(@"count : %lu", count);
        
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                    NSString *str = [NSString stringWithFormat:@"%@",(NSURL*)item];
//                    NSLog(@"str : %@", str);
                    
                    NSData *imgData = [[NSData alloc] initWithContentsOfURL:(NSURL*)item];
                    float dataSize = ((CGFloat)imgData.length)/1024/1024;
                    NSLog(@"img dataSize : %f", dataSize);
                    
                    if(dataSize<=20){
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [dict setObject:@"IMG" forKey:@"TYPE"];
                        [dict setObject:imgData forKey:@"VALUE"];

                        [arr addObject:dict];

                        [shareDefaults setObject:arr forKey:@"SHARE_ITEM"];
                        [shareDefaults synchronize];
                        
                        NSLog(@"SHARE_ITEM.. : %@", [shareDefaults objectForKey:@"SHARE_ITEM"]);

                        setCount++;
                        if(setCount==count) [self dataConvertFinished];

                    } else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"share_item_size_over", @"share_item_size_over") preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                                                                         }];
                        [alert addAction:okButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }];
           
            } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeMovie options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                    NSString *str = [NSString stringWithFormat:@"%@",(NSURL*)item];
                    NSData * videoData = [[NSData alloc] initWithContentsOfURL:(NSURL*)item];
                    float dataSize = ((CGFloat)videoData.length)/1024/1024;
                    NSLog(@"video dataSize : %f", dataSize);
                    
                    if(dataSize<=80){
                        AVURLAsset *asset = [AVURLAsset assetWithURL:(NSURL*)item];
                        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                        imageGenerator.appliesPreferredTrackTransform = YES;
                        CMTime time = CMTimeMake(1, 1);
                        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                        CGImageRelease(imageRef);
                        
                        NSData *thumbData = UIImageJPEGRepresentation(thumbnail,0.1);
                        
                        NSString *fileName = @"";
                        [self compressVideoWithInputVideoUrl:asset.URL asset:asset fileName:fileName completion:^(NSData *data) {
                            NSLog(@"[ConvertChatDataSet] 변환된 데이터 : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);

                            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                            [dict setObject:@"VIDEO" forKey:@"TYPE"];
                            [dict setObject:thumbData forKey:@"VIDEO_THUMB"];
                            [dict setObject:data forKey:@"VIDEO_DATA"];
                            [dict setObject:@"false" forKey:@"IS_SHARE"];
                            [arr addObject:dict];

                            [shareDefaults setObject:arr forKey:@"SHARE_ITEM"];
                            [shareDefaults synchronize];

                            setCount++;
                            if(setCount==count) [self dataConvertFinished];
                        }];
                        
                    } else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"share_video_size_limit", @"share_video_size_limit") preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                                                                         }];
                        [alert addAction:okButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }];
            }
        }
    }
}

- (void)compressVideoWithInputVideoUrl:(NSURL *)inputVideoUrl asset:(AVAsset*)asset fileName:(NSString *)fileName completion:(void (^)(NSData *))completion{
    NSLog(@"공유 비디오 압축 시작");
    // 변환 된 비디오를 저장하기위한 임시 경로 만들기
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myDocumentPath = [documentsDirectory stringByAppendingPathComponent:@"SHARE_VIDEO.mp4"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:myDocumentPath];

    // 파일이 이미 있는지 확인한 다음 이전 파일을 제거합니다.
    if ([[NSFileManager defaultManager]fileExistsAtPath:myDocumentPath]){
        [[NSFileManager defaultManager]removeItemAtPath:myDocumentPath error:nil];
    }
    
//    NSLog(@"finalVideoURLString : %@", myDocumentPath);
   
    NSURL *outputVideoUrl = ([[NSURL URLWithString:myDocumentPath] isFileURL] == 1)?([NSURL URLWithString:myDocumentPath]):([NSURL fileURLWithPath:myDocumentPath]);
    NSLog(@"outputVideoUrl : %@", [outputVideoUrl absoluteURL]);

    SDAVAssetExportSession *compressionEncoder = [SDAVAssetExportSession.alloc initWithAsset:[AVAsset assetWithURL:inputVideoUrl]]; // provide inputVideo Url Here
    compressionEncoder.delegate = self;
    compressionEncoder.outputFileType = AVFileTypeMPEG4;
    compressionEncoder.outputURL = outputVideoUrl;
    compressionEncoder.shouldOptimizeForNetworkUse = YES;

    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    CGSize newSize = [self getResizeVideoRatio:dimensions];
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
//            AVVideoAverageBitRateKey: @2300000,
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
          NSLog(@"세션 내보내기 성공");
         NSData *data = [NSData dataWithContentsOfURL:outputVideoUrl];
         completion(data);

      } else if(compressionEncoder.status == AVAssetExportSessionStatusFailed){
       NSLog (@"세션 내보내기 실패");
       [self dataConvertFailed];

      } else if(compressionEncoder.status == AVAssetExportSessionStatusCancelled){
       NSLog (@"Export canceled");

      } else if(compressionEncoder.status == AVAssetExportSessionStatusExporting){
       NSLog(@"video conversion exporting");

      } else if(compressionEncoder.status == AVAssetExportSessionStatusWaiting){
       NSLog(@"video conversion is waiting");

      } else if(compressionEncoder.status == AVAssetExportSessionStatusUnknown){
       NSLog(@"video converstion status unknown");
      }
       
       if ([[NSFileManager defaultManager]fileExistsAtPath:myDocumentPath]){
          NSLog(@"데이터변환 후 삭제 ***");
          [[NSFileManager defaultManager]removeItemAtPath:myDocumentPath error:nil];
       }
   }];
}

- (void)videoCompessToPercent:(float)progress{
    
}

-(void)dataConvertFinished{
    NSLog(@"%s", __func__);
    [indicator stopAnimating];
    
    NSString *sendUrl = [NSString stringWithFormat:@"%@.ShareEx", CALL_SCHEME];
    NSString *callUrl = [NSString stringWithFormat:@"%@://?call=%@", CALL_SCHEME, sendUrl];
    NSLog(@"callUrl : %@", callUrl);
    
    NSURL *destinationURL = [NSURL URLWithString:callUrl];
    
    NSString *className = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x55, 0x49, 0x41, 0x70, 0x70, 0x6C, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6F, 0x6E} length:13] encoding:NSASCIIStringEncoding];
    NSLog(@"className : %@", className);
    if (NSClassFromString(className)) {
        id object = [NSClassFromString(className) performSelector:@selector(sharedApplication)];
        NSLog(@"object : %@", object);

        NSLog(@"ShareView Call openURL");
        [object performSelector:@selector(openURL:) withObject:destinationURL];
    }
    
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

-(void)dataConvertFailed{
    [indicator stopAnimating];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"파일 변환에 실패하였습니다. \n다시 시도 해주세요.", @"")] message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
                                                     }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (CGSize)getResizeVideoRatio:(CGSize)videoSize{
    NSString *videoQuality = [[MFSingleton sharedInstance] vdoQuality];
    int normalSize = 480; //720;
    int highSize = 1080; //1980;
    
    CGFloat oldWidth = fabs(videoSize.width);
    CGFloat oldHeight = fabs(videoSize.height);
    
    CGFloat scaleFactor=1;
    
//    긴쪽기준
//    float longSide = 0;
//    if(oldWidth > oldHeight) longSide = oldWidth;
//    if(oldWidth <= oldHeight) longSide = oldHeight;
//
//    if([videoQuality isEqualToString:@"NORMAL"]){
//        if(longSide >= 1000) {
//            scaleFactor = normalSize / longSide;
//        }
//
//    } else if([videoQuality isEqualToString:@"HIGH"]){
//        if(longSide >= 2000) {
//            scaleFactor = highSize / longSide;
//        }
//    }
    
//    짧은쪽기준
    float shortSide = 0;
    if(oldWidth > oldHeight) shortSide = oldHeight;
    if(oldWidth <= oldHeight) shortSide = oldWidth;
    
    if([videoQuality isEqualToString:@"NORMAL"]){
        if(shortSide > normalSize) {
            scaleFactor = normalSize / shortSide;
        }
        
    } else if([videoQuality isEqualToString:@"HIGH"]){
        if(shortSide > highSize) {
            scaleFactor = highSize / shortSide;
        }
    }

    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return newSize;
}

@end
