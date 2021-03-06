//
//  SetMediaDataHandler.m
//  mfinity_sns
//
//  Created by hilee on 14/01/2020.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "SetMediaDataHandler.h"
#import "AppDelegate.h"

@implementation SetMediaDataHandler{
    AppDelegate *appDelegate;
    NSString *myUserNo;
    
    NSMutableArray *resultArr;
    int setCount;
    
    int uploadCnt;
    NSString *vThumb;
    
    NSMutableDictionary *firstAddMsg;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    }
    return self;
}

/*
 채팅뷰에서 메시지 전송 시 먼저 로컬에 저장 및 선등록 후 핸들러 호출하여 업로드
 */
-(void)convertChatDataSet:(NSMutableArray *)array{
    @try{
        setCount = 0;
        resultArr = [array mutableCopy];
        NSLog(@"resultArr : %@", resultArr);
        
        NSUInteger count = resultArr.count;
        for(int i=0; i<(int)count; i++){
            NSString *type = [[array objectAtIndex:i] objectForKey:@"TYPE"];
            if([type isEqualToString:@"IMG"]){
                setCount++;
                if(setCount==count)[self dataConvertFinished:resultArr];
                
            } else if([type isEqualToString:@"VIDEO"]){
                if([[array objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
                    [self dataConvertFinished:resultArr];
                    
                } else {
                    AVURLAsset *value;
                    NSString *fileName = [[resultArr objectAtIndex:i] objectForKey:@"FILE_NM"];
                    if([[resultArr objectAtIndex:i] objectForKey:@"VIDEO_VALUE"]!=nil){
                        //앨범에서 가져온 비디오
                        value = [[resultArr objectAtIndex:i] objectForKey:@"VIDEO_VALUE"];
                        
                    } else if([[resultArr objectAtIndex:i] objectForKey:@"RECORD_VALUE"]!=nil){
                        //촬영한 비디오
                        value = [[resultArr objectAtIndex:i] objectForKey:@"RECORD_VALUE"];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSURL *URL = [(AVURLAsset *)value URL];
                        [MFFileCompress compressVideoWithInputVideoUrl:URL asset:value num:0 mode:@"CHAT" fileName:fileName paramNo:self.roomNo completion:^(NSData *data) {
                            NSLog(@"변환된 데이터 : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);

                            if([self.mode isEqualToString:@"CHAT"]){
                                [[resultArr objectAtIndex:i] setObject:data forKey:@"ORIGIN"]; //압축한 데이터로 변경

                                setCount++;
                                [self dataConvertFinished:resultArr];
                            }
                        }];
                        
//                        [self compressVideoWithInputVideoUrl:URL asset:value fileName:fileName completion:^(NSData *data) {
//                            NSLog(@"[ConvertChatDataSet] 변환된 데이터 : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);
//
//                            if([self.mode isEqualToString:@"CHAT"]){
//                                [[resultArr objectAtIndex:i] setObject:data forKey:@"ORIGIN"]; //압축한 데이터로 변경
//
//                                setCount++;
//                                [self dataConvertFinished:resultArr];
//                            }
//                        }];
                    });
                }
                
            } else if([type isEqualToString:@"FILE"]){
                setCount++;
                if(setCount==count) [self dataConvertFinished:resultArr];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)dataConvertFinished:(NSMutableArray *)array{
    NSLog(@"[uploadCnt : %d] array : %@", uploadCnt, array);
    @try{
        NSString *type = [[array objectAtIndex:uploadCnt] objectForKey:@"TYPE"];
        
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
        urlString = [urlString stringByAppendingPathComponent:@"saveAttachedFile"];
        
        NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
        
        NSData *data;
        NSString *infoStr = @"";
        NSString *isThumb = @"";
        NSString *isShare = @"";
        NSString *srcFileUrl = @"";
        NSString *fileName = @"";
        
        if([type isEqualToString:@"VIDEO_THUMB"]) isThumb = @"true";
        else isThumb = @"false";
        
        if([type isEqualToString:@"IMG"]){
            UIImage *image = [[array objectAtIndex:uploadCnt] objectForKey:@"ORIGIN"];
            data = UIImageJPEGRepresentation(image, 1.0);
            NSLog(@"IMG size : %.2f MB",(float)data.length/1024.0f/1024.0f);
            
            infoStr = [[array objectAtIndex:uploadCnt] objectForKey:@"ADIT_INFO"];
            [sendFileParam setObject:infoStr forKey:@"aditInfo"];
            
        } else if([type isEqualToString:@"VIDEO_THUMB"]){
            UIImage *image = [[array objectAtIndex:uploadCnt] objectForKey:@"ORIGIN"];
            data = UIImageJPEGRepresentation(image, 1.0);
            NSLog(@"VIDEO_THUMB size : %.2f MB",(float)data.length/1024.0f/1024.0f);
            
            NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
            [aditDic setObject:type forKey:@"DATA_TYPE"];
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:&error];
            infoStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [sendFileParam setObject:infoStr forKey:@"aditInfo"];
            
        } else if([type isEqualToString:@"VIDEO"]){
            if([[array objectAtIndex:uploadCnt] objectForKey:@"IS_SHARE"]!=nil&&[[[array objectAtIndex:uploadCnt] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
                
            } else {
                data = [[array objectAtIndex:uploadCnt] objectForKey:@"ORIGIN"];
                NSLog(@"VIDEO size : %.2f MB",(float)data.length/1024.0f/1024.0f);
            }
            
            infoStr = [[array objectAtIndex:uploadCnt] objectForKey:@"ADIT_INFO"];
            [sendFileParam setObject:infoStr forKey:@"aditInfo"];
            [sendFileParam setObject:vThumb forKey:@"thumbName"];
            
        } else if([type isEqualToString:@"FILE"]){
            data = [[array objectAtIndex:uploadCnt] objectForKey:@"FILE_DATA"];
            infoStr = [[array objectAtIndex:uploadCnt] objectForKey:@"ADIT_INFO"];
            [sendFileParam setObject:infoStr forKey:@"aditInfo"];
        }
        
        fileName = [[array objectAtIndex:uploadCnt] objectForKey:@"FILE_NM"];
        
        if([[array objectAtIndex:uploadCnt] objectForKey:@"IS_SHARE"]!=nil&&[[[array objectAtIndex:uploadCnt] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
            isShare = @"true";
            srcFileUrl = [[array objectAtIndex:uploadCnt] objectForKey:@"URL"];
            data = nil;
            fileName = nil;
            
        } else {
            isShare = @"false";
            srcFileUrl = @"";
        }
        
        [sendFileParam setObject:self.roomNo forKey:@"roomNo"];
        [sendFileParam setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
        [sendFileParam setObject:myUserNo forKey:@"usrNo"];
        [sendFileParam setObject:@"3" forKey:@"refTy"];
        [sendFileParam setObject:self.roomNo forKey:@"refNo"];
        [sendFileParam setObject:isThumb forKey:@"isThumb"];
        [sendFileParam setObject:isShare forKey:@"isShared"];
        [sendFileParam setObject:srcFileUrl forKey:@"srcFileUrl"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            MFURLSessionUpload *sessionUpload = [[MFURLSessionUpload alloc] initWithURL:[NSURL URLWithString:urlString] option:sendFileParam WithData:data AndFileName:fileName];
            sessionUpload.delegate = self;
            [sessionUpload start:^(int count) {
                NSLog(@"업로드 카운트 : %d , arrCnt : %lu", count, (unsigned long)array.count);
                if(count < array.count){
                    [self dataConvertFinished:array];
                } else {
                    uploadCnt = 0;
                }
            }];
        });
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)dataConvertFailed{
   [SVProgressHUD dismiss];
}

#pragma mark - MFURLSessionUpload Delegate
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error completion:(void (^)(int count))completion{
   if (error != nil) {
      NSLog(@"파일 전송 실패 !");
      
   } else{
      if(dictionary != nil){
         NSLog(@"dictionary : %@", dictionary);

         @try{
            uploadCnt++;
            vThumb = @"";

            NSDictionary *editDic = [dictionary objectForKey:@"ADITINFO"];
            NSString *dataType = [editDic objectForKey:@"DATA_TYPE"];
            if([dataType isEqualToString:@"VIDEO_THUMB"]){
               vThumb = [[dictionary objectForKey:@"FILE_URL"] lastPathComponent];

            } else if([dataType isEqualToString:@"VIDEO"]){
                firstAddMsg = [[NSMutableDictionary alloc]init];
            }
             
            completion(uploadCnt);
            
         } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
         }
         
      } else {
         NSLog(@"인터넷 연결이 오프라인으로 나타납니다.");
      }
   }
}

- (void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error{
    NSLog(@"ERROR resultArr : %@", resultArr);
    
    firstAddMsg = [[NSMutableDictionary alloc]init];
    
    @try{
        NSString *type = [[resultArr objectAtIndex:uploadCnt] objectForKey:@"TYPE"];
        if([type isEqualToString:@"VIDEO_THUMB"]){
            NSString *type = [[resultArr objectAtIndex:uploadCnt+1] objectForKey:@"TYPE"];
            if([type isEqualToString:@"VIDEO"]){
                NSData *data = [[resultArr objectAtIndex:uploadCnt+1] objectForKey:@"ORIGIN"];
                NSLog(@"비디오 size : %.2f MB",(float)data.length/1024.0f/1024.0f);
                NSLog(@"firstAddMsg : %@", firstAddMsg);

                NSString *thumbName = [[resultArr objectAtIndex:uploadCnt+1] objectForKey:@"FILE_NM"];

                NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];

                NSDate *today = [NSDate date];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyyMMdd"];
                NSString *currentTime = [dateFormat stringFromDate:today];

                NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@/", self.roomNo, [MFUtil getFolderName:type], currentTime];
                NSString *videoPath = [saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", thumbName]];
                NSLog(@"실패 저장된 비디오 경로 : %@", videoPath);
                [data writeToFile:videoPath atomically:YES];
            }
        }
        [self.delegate failedChatData:nil];
        
    } @catch (NSException *exception) {
       NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - Util
-(NSString *)createFileName :(NSString *)filetype{
   @try{
       NSString *fileExt = @"";
       if([filetype isEqualToString:@"IMG"]||[filetype isEqualToString:@"VIDEO_THUMB"]) fileExt = @"png";
       else if([filetype isEqualToString:@"VIDEO"]) fileExt = @"mp4";
      
       NSString *fileName = nil;
       NSDate *today = [NSDate date];
       NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
       [dateFormatter setDateFormat:@"yyyyMMdd-HHmmssSSS"];
       NSString *currentTime = [dateFormatter stringFromDate:today];
       fileName = [NSString stringWithFormat:@"%@.%@",currentTime,fileExt];
       return fileName;
      
   } @catch (NSException *exception) {
      NSLog(@"Exception : %@", exception);
   }
}

/*
-(void)makeThumbImgFromVideo:(AVURLAsset *)asset completion:(void (^)(UIImage *))completion{
    @try {
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

- (void)compressVideoWithInputVideoUrl:(NSURL *)inputVideoUrl asset:(AVAsset*)asset fileName:(NSString *)fileName completion:(void (^)(NSData *))completion{
    @try{
        NSLog(@"비디오 압축 시작 ?");
        //폴더생성
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];

        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSString *currentTime = [dateFormatter stringFromDate:today];

        NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/%@/%@/Video/%@/", [MFUtil getFolderName:self.mode], self.roomNo, currentTime];
        NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/%@/%@/Video/%@/thumb/", [MFUtil getFolderName:self.mode], self.roomNo, currentTime];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL issue = [fileManager isReadableFileAtPath:saveThumbPath];
        if (issue) {
        } else {
          [fileManager createDirectoryAtPath:saveThumbPath withIntermediateDirectories:YES attributes:nil error:nil];
        }

        NSString *finalVideoURLString = [saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
        // 파일이 이미 있는지 확인한 다음 이전 파일을 제거합니다.
        if ([[NSFileManager defaultManager]fileExistsAtPath:finalVideoURLString]){
            NSLog(@"데이터변환 후 삭제");
            [[NSFileManager defaultManager]removeItemAtPath:finalVideoURLString error:nil];
        }
        
        NSURL *outputVideoUrl = ([[NSURL URLWithString:finalVideoURLString] isFileURL] == 1)?([NSURL URLWithString:finalVideoURLString]):([NSURL fileURLWithPath:finalVideoURLString]);
        NSLog(@"outputVideoUrl : %@", [outputVideoUrl absoluteURL]);

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
           
           if ([[NSFileManager defaultManager]fileExistsAtPath:finalVideoURLString]){
              NSLog(@"데이터변환 후 삭제 ***");
              [[NSFileManager defaultManager]removeItemAtPath:finalVideoURLString error:nil];
           }
        }];
        
    } @catch (NSException *exception) {
       NSLog(@"Exception : %@", exception);
    }
}
*/

-(void)videoCompessToPercent:(float)progress{
    @try{
        [self.delegate videoCompessing:progress];
    } @catch (NSException *exception) {
       NSLog(@"Exception : %@", exception);
    }
}

@end
