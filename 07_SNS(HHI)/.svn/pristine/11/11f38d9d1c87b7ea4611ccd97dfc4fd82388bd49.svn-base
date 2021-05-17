//
//  SendChatHandler.m
//  mfinity_sns
//
//  Created by hilee on 30/10/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import "SendChatHandler.h"


@interface SendChatHandler() {
    NSMutableArray *mediaFileArr;
    int setCount;
    NSString *videoThumbName;
    int tmpImgIdx;
}

@end

@implementation SendChatHandler {
    AppDelegate *appDelegate;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    }
    return self;
}


-(void)sendTextData:(NSString *)content msgData:(NSMutableArray *)msgData missedCnt:(int)missedCnt completion:(void(^)(NSMutableDictionary*))completion{
    @try{
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
       
        NSString *trimContent = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        trimContent = [MFUtil replaceEncodeToChar:trimContent];

        NSUInteger textByte = [trimContent lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

        if(![trimContent isEqualToString:@""] && trimContent != nil){
            self.tmpMsgIdx++;
            NSUInteger msgDataCnt = msgData.count;

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *date = [dateFormatter stringFromDate:[NSDate date]];
            NSString *dvcID = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]];//[MFUtil getUUID];

            self.firstAddMsg = [[NSMutableDictionary alloc]init];
            [self.firstAddMsg setObject:self.myUserNo forKey:@"USER_NO"];
            [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];

            [self.firstAddMsg setObject:date forKey:@"DATE"];

            if(textByte>1000) {
                NSData *contentData = [trimContent dataUsingEncoding:NSASCIIStringEncoding];
                contentData = [contentData subdataWithRange:NSMakeRange(0, 1000)];
                NSString *prevStr = [[NSString alloc] initWithBytes:[contentData bytes] length:[contentData length] encoding:NSASCIIStringEncoding];

                [self.firstAddMsg setObject:@"LONG_TEXT" forKey:@"CONTENT_TY"];
                [self.firstAddMsg setObject:@"" forKey:@"CONTENT"];
                [self.firstAddMsg setObject:prevStr forKey:@"CONTENT_PREV"];

            } else {
                [self.firstAddMsg setObject:@"TEXT" forKey:@"CONTENT_TY"];
                [self.firstAddMsg setObject:trimContent forKey:@"CONTENT"];
                [self.firstAddMsg setObject:@"" forKey:@"CONTENT_PREV"];
            }

            [self.firstAddMsg setObject:@"" forKey:@"FILE_NM"];

            self.editInfoDic = [NSMutableDictionary dictionary];
            NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(msgDataCnt-missedCnt) inSection:0];
            [self.editInfoDic setObject:@"SENDING" forKey:@"TYPE"];
            //[self.editInfoDic setObject:[NSNumber numberWithInteger:self.tmpMsgIdx] forKey:@"TMP_NO"];
            [self.editInfoDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
            [self.editInfoDic setObject:dvcID forKey:@"DEVICE_ID"];
            [self.editInfoDic setObject:@"" forKey:@"LOCAL_CONTENT"];

            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.editInfoDic options:0 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

            [self.firstAddMsg setObject:jsonString forKey:@"ADIT_INFO"];
            
            if(msgDataCnt > 0){
               //메시지가 있는 채팅방일 경우
               [msgData insertObject:self.firstAddMsg atIndex:msgDataCnt-missedCnt];
               
            } else {
               //메시지가 없는 새로운 채팅방일 경우
               [msgData addObject:self.firstAddMsg];
               
            }
            
            [resultDic setObject:@(msgData.count) forKey:@"MSG_COUNT"];
            [resultDic setObject:self.firstAddMsg forKey:@"SEND_DATA"];
            [resultDic setObject:self.editInfoDic forKey:@"EDIT_INFO"];
            [resultDic setObject:trimContent forKey:@"CONTENT"];

            completion(resultDic);


        } else {

        }
    } @catch (NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}

-(void)setImageData:(NSArray *)mediaArr isAlbum:(BOOL)isAlbum msgData:(NSMutableArray *)msgData missedCnt:(int)missedCnt completion:(void(^)(NSMutableDictionary*))completion{
    NSLog(@"%s", __func__);
    
    mediaFileArr = [NSMutableArray array];
    CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
   
    @try{
        if(isAlbum){
            NSArray *imgList = [[mediaArr objectAtIndex:0] objectForKey:@"IMG_LIST"];
            for(int i=0; i<imgList.count; i++){
                UIImage *image = [MFUtil getScaledImage:[imgList objectAtIndex:i] scaledToMaxWidth:screenWidth-20];

                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"IMG" forKey:@"TYPE"];
                [dict setObject:image forKey:@"VALUE"];
                [dict setObject:[imgList objectAtIndex:i] forKey:@"ORIGIN"];
                [mediaFileArr addObject:dict];
            }
            //[self contvertDataSet:mediaFileArr];
         
        } else {
         
        }
       
    } @catch (NSException *exception) {
      NSLog(@"%s Exception : %@", __func__, exception);
    }
}

-(void)setVideoData:(NSArray *)mediaArr isAlbum:(BOOL)isAlbum msgData:(NSMutableArray *)msgData missedCnt:(int)missedCnt completion:(void(^)(NSMutableDictionary*data))completion{
//-(void)setVideoData:(NSArray *)mediaArr :(BOOL)isAlbum{
    NSLog(@"%s", __func__);
    mediaFileArr = [NSMutableArray array];
    
    @try{
       if(isAlbum){
          NSArray *assetList = [[mediaArr objectAtIndex:0] objectForKey:@"ASSET_LIST"];
          PHAsset *asset = [assetList objectAtIndex:0];
          
          NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
          [dict2 setObject:@"VIDEO" forKey:@"TYPE"];
          [dict2 setObject:asset forKey:@"VIDEO_VALUE"];
          [mediaFileArr addObject:dict2];
           
          //[self contvertDataSet:mediaFileArr];
           [self contvertDataSet:mediaFileArr msgData:msgData missedCnt:missedCnt completion:completion];
          
       } else {
          NSString *videoPath = [mediaArr objectAtIndex:0];
          
          AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath] options:nil];
          
          NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
          [dict2 setObject:@"VIDEO" forKey:@"TYPE"];
          [dict2 setObject:asset forKey:@"RECORD_VALUE"];
          [mediaFileArr addObject:dict2];
          
          //[self contvertDataSet:mediaFileArr];
       }
        
    } @catch (NSException *exception) {
       NSLog(@"%s Exception : %@", __func__, exception);
    }
}

#pragma mark Media Data Convert
-(void)contvertDataSet:(NSMutableArray *)array msgData:(NSMutableArray *)msgData missedCnt:(int)missedCnt completion:(void(^)(NSMutableDictionary *resultDic))completion{
//-(void)contvertDataSet:(NSMutableArray *)array{
   NSLog(@"%s", __func__);
   @try{
      setCount = 0;
      NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
      
      NSUInteger count = array.count;
      
      for(int i=0; i<(int)count; i++){
         NSMutableDictionary *obj = [NSMutableDictionary dictionary];
         
         NSString *type = [[array objectAtIndex:i] objectForKey:@"TYPE"];
         if([type isEqualToString:@"IMG"]){
            [obj setObject:@"IMG" forKey:@"TYPE"];
            [obj setObject:[[array objectAtIndex:i] objectForKey:@"ORIGIN"] forKey:@"VALUE"];
            
            if([[array objectAtIndex:i] objectForKey:@"IS_SHARE"]!=nil){
               [obj setObject:@"true" forKey:@"IS_SHARE"];
               [obj setObject:[[array objectAtIndex:i] objectForKey:@"URL"] forKey:@"URL"];
            }
            
            [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
            
            setCount++;
            //if(setCount==count) [self dataConvertFinished:tmpDict];
            
         } else if([type isEqualToString:@"VIDEO"]){
            if([[array objectAtIndex:i] objectForKey:@"VIDEO_VALUE"]!=nil){
               //앨범에서 가져온 비디오
               PHAsset *value = [[array objectAtIndex:i] objectForKey:@"VIDEO_VALUE"];
               
               PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
               options.version = PHVideoRequestOptionsVersionOriginal;
               options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
               options.networkAccessAllowed = YES;
             
               //동영상 변환
               [[PHImageManager defaultManager] requestAVAssetForVideo:value options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                     
                     NSURL *URL = [(AVURLAsset *)avAsset URL];
                     
                     // 비디오 파일로 애셋 URL 만들기
                     AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
                     
                     [self compressVideoWithInputVideoUrl:URL asset:avAsset completion:^(NSData *data) {
                        NSLog(@"2 이거 변환된 데이터? : %@",[NSString stringWithFormat:@"%.2lf MB", (float)data.length/1024.0f/1024.0f]);

                      AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
                      imageGenerator.appliesPreferredTrackTransform = YES;
                      CMTime time = CMTimeMake(1, 1);
                      CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                      UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                      CGImageRelease(imageRef);

                      [obj setObject:@"VIDEO" forKey:@"TYPE"];
                      [obj setObject:data forKey:@"VALUE"];
                      if(thumbnail!=nil) [obj setObject:thumbnail forKey:@"THUMB"];
                      [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];

                      setCount++;
                      //if(setCount==count) [self dataConvertFinished:tmpDict];
                        
                         if(setCount==count) [self dataConvertFinished:tmpDict msgData:msgData missedCnt:missedCnt completion:completion];

                     }];
                     
                  });
               }];
               
            } else {
                /*
               //촬영한 비디오
#ifdef DEBUG
               NSLog(@"이건 촬영한 비디오 i=%d", i);
#endif
               AVURLAsset *avAsset = [[array objectAtIndex:i] objectForKey:@"RECORD_VALUE"];
               
               NSArray * compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
               // 비디오가 변환을 지원하는지 확인하십시오.
               if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]){
                  // 내보내기 세션 만들기
                  AVAssetExportSession *exportSession = nil;
                  if (@available(iOS 11.0, *)) exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHEVCHighestQuality];
                  else exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
                  
                  // 변환 된 비디오를 저장하기위한 임시 경로 만들기
                  NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                  NSString *myDocumentPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"CHAT_VIDEO_%d.mp4",i]];
                  NSURL *url = [[NSURL alloc] initFileURLWithPath:myDocumentPath];
                  
                  // 파일이 이미 있는지 확인한 다음 이전 파일을 제거합니다.
                  if ([[NSFileManager defaultManager]fileExistsAtPath:myDocumentPath]){
                     [[NSFileManager defaultManager]removeItemAtPath:myDocumentPath error:nil];
                  }
                  exportSession.outputURL = url;
                  // 다른 파일 형식 (예 : .3gp)으로 만들려면 출력 파일 형식을 설정합니다.
                  exportSession.outputFileType = AVFileTypeMPEG4 ;
                  exportSession.shouldOptimizeForNetworkUse = YES ;
                  
                  [exportSession exportAsynchronouslyWithCompletionHandler : ^ {
                     switch ([exportSession status ])
                     {
                        case AVAssetExportSessionStatusFailed:
                           NSLog (@"세션 내보내기 실패");
                           [self dataConvertFailed];
                           break ;
                        case AVAssetExportSessionStatusCancelled:
                           NSLog (@"Export canceled");
                           break ;
                        case AVAssetExportSessionStatusExporting:
                           NSLog(@"video conversion exporting");
                           break;
                        case AVAssetExportSessionStatusWaiting:
                           NSLog(@"video conversion is waiting");
                           break;
                        case AVAssetExportSessionStatusUnknown:
                           NSLog(@"video converstion status unknown");
                           break;
                        case AVAssetExportSessionStatusCompleted:
                        {
                           // 비디오 변환 완료
#ifdef DEBUG
                           NSLog (@"촬영 변환 성공! i=%d", i);
#endif
                           NSData *data = [NSData dataWithContentsOfURL:url];
                           
                           AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:avAsset];
                           imageGenerator.appliesPreferredTrackTransform = YES;
                           CMTime time = CMTimeMake(1, 1);
                           CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                           UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
                           CGImageRelease(imageRef);
                           
                           // 파일이 이미 있는지 확인한 다음 이전 파일을 제거합니다.
                           if ([[NSFileManager defaultManager]fileExistsAtPath:myDocumentPath]){
#ifdef DEBUG
                              NSLog(@"데이터변환 후 삭제");
#endif
                              [[NSFileManager defaultManager]removeItemAtPath:myDocumentPath error:nil];
                           }
                           
                           [obj setObject:@"VIDEO" forKey:@"TYPE"];
                           [obj setObject:data forKey:@"VALUE"];
                           if(thumbnail!=nil) [obj setObject:thumbnail forKey:@"THUMB"];
                           [tmpDict setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
                           
                           setCount++;
                           if(setCount==count) [self dataConvertFinished:tmpDict];
                        }
                           break ;
                        default :
                           break ;
                     }
                  }];
               }
               else {
#ifdef DEBUG
                  NSLog (@"지원되지 않는 비디오 파일!");
#endif
               }
                 */
            }
         }
      }
   } @catch (NSException *exception) {
      NSLog(@"%s Exception : %@", __func__, exception);
   }
}

-(void)dataConvertFinished:(NSMutableDictionary *)dict msgData:(NSMutableArray *)msgData missedCnt:(int)missedCnt completion:(void(^)(NSMutableDictionary * resultDic))completion{
//-(void)dataConvertFinished:(NSMutableDictionary *)dict{
   NSLog(@"Convert Data Finished : %@", dict);

   self.resultArr = [NSMutableArray array];
    
   @try{
      for(int i=0; i<dict.count; i++){
         NSMutableDictionary *reDict = [NSMutableDictionary dictionary];
         
         NSDictionary *dataDict = [dict objectForKey:[NSString stringWithFormat:@"%d",i]];
         
         NSString *type = [dataDict objectForKey:@"TYPE"];
         if([type isEqualToString:@"IMG"]){
            [reDict setObject:@"IMG" forKey:@"TYPE"];
            [reDict setObject:[dataDict objectForKey:@"VALUE"] forKey:@"VALUE"]; //UIImage
            [self.resultArr addObject:reDict];
            
         } else if([type isEqualToString:@"VIDEO"]){
            NSMutableDictionary *thumbDict = [NSMutableDictionary dictionary];
            if([dataDict objectForKey:@"THUMB"]!=nil){
               [thumbDict setObject:@"VIDEO_THUMB" forKey:@"TYPE"];
               [thumbDict setObject:[dataDict objectForKey:@"THUMB"] forKey:@"VALUE"]; //UIImage
               [self.resultArr addObject:thumbDict];
            }
            
            [reDict setObject:@"VIDEO" forKey:@"TYPE"];
            [reDict setObject:[dataDict objectForKey:@"VALUE"] forKey:@"VALUE"]; //NSData
            
            [self.resultArr addObject:reDict];
         }
      }
      //[self saveMediaFiles];
       [self saveMediaFiles:msgData missedCnt:missedCnt completion:completion];
      
   } @catch (NSException *exception) {
      NSLog(@"%s Exception : %@", __func__, exception);
   }
}

#pragma mark - File Upload
-(void)saveMediaFiles:(NSMutableArray *)msgData missedCnt:(int)missedCnt completion:(void(^)(NSMutableDictionary *resultDic))completion{
//-(void)saveMediaFiles{
NSLog(@"%s", __func__);
   @try{
      self.uploadCnt=0;
      
       NSLog(@"resultArr : %@", self.resultArr);
      NSString *type = [[self.resultArr objectAtIndex:0] objectForKey:@"TYPE"];
//       NSString *type = [[resultArr objectAtIndex:1] objectForKey:@"TYPE"];
      
      if([type isEqualToString:@"IMG"]){
         if([[self.resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]!=nil&&[[[self.resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
            [self shareMediaFiles:nil mediaType:type isThumbImg:[[self.resultArr objectAtIndex:0] objectForKey:@"VALUE"] isFile:nil isShared:@"true" srcFileUrl:[[self.resultArr objectAtIndex:0] objectForKey:@"URL"]];
            
         } else {
            UIImage *value = [[self.resultArr objectAtIndex:0] objectForKey:@"VALUE"];
            value = [MFUtil getResizeImageRatio:value];
            
            NSData *data = UIImageJPEGRepresentation(value, 0.7);
            NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
//            [self saveMediaFiles:data mediaType:type];
         }
         
      } else if([type isEqualToString:@"VIDEO"]){
         if([[self.resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]!=nil&&[[[self.resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
            [self shareMediaFiles:nil mediaType:type isThumbImg:[[self.resultArr objectAtIndex:0] objectForKey:@"VALUE"] isFile:nil isShared:@"true" srcFileUrl:[[self.resultArr objectAtIndex:0] objectForKey:@"URL"]];
         
         } else {
            NSData *data = [[self.resultArr objectAtIndex:0] objectForKey:@"VALUE"];
//             NSData *data = [[resultArr objectAtIndex:1] objectForKey:@"VALUE"];
            
//            if((float)data.length/1024.0f/1024.0f>20){
//               //[self videoSizeCheck];
//            } else {
//               [self saveMediaFiles:data mediaType:type];
                [self saveMediaFiles:data mediaType:type msgData:msgData missedCnt:missedCnt completion:completion];
//            }
         }
          
      } else if([type isEqualToString:@"VIDEO_THUMB"]){
         UIImage *value = [[self.resultArr objectAtIndex:0] objectForKey:@"VALUE"];
         value = [MFUtil getResizeImageRatio:value];
         NSData *data = UIImageJPEGRepresentation(value, 0.7);
//         [self saveMediaFiles:data mediaType:type];
          [self saveMediaFiles:data mediaType:type msgData:msgData missedCnt:missedCnt completion:completion];
         
      } else if([type isEqualToString:@"FILE"]){
         if([[self.resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]!=nil&&[[[self.resultArr objectAtIndex:0] objectForKey:@"IS_SHARE"]isEqualToString:@"true"]){
            [self shareMediaFiles:nil mediaType:type isThumbImg:nil isFile:[[self.resultArr objectAtIndex:0] objectForKey:@"FILE_NM"] isShared:@"true" srcFileUrl:[[self.resultArr objectAtIndex:0] objectForKey:@"VALUE"]];
         } else {
            NSData *data = [[self.resultArr objectAtIndex:0] objectForKey:@"FILE_DATA"];
//            [self saveMediaFiles:data mediaType:type];
         }
      }
      
   } @catch (NSException *exception) {
      NSLog(@"%s Exception : %@", __func__, exception);
   }
}

-(void)saveMediaFiles:(NSData *)data mediaType:(NSString *)type msgData:(NSMutableArray *)msgData missedCnt:(int)missedCnt completion:(void(^)(NSMutableDictionary *resultDic))completion{
//-(void)saveMediaFiles:(NSData *)data mediaType:(NSString *)type{
    NSLog(@"%s", __func__);
    
    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];

    @try {
        NSString *dvcID = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]];
      
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *date = [dateFormatter stringFromDate:[NSDate date]];
        
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"yyyyMMdd"];
        NSString *currentTime = [dateFormatter2 stringFromDate:today];

        NSUInteger msgDataCnt = msgData.count;
        tmpImgIdx++;
      
        if([type isEqualToString:@"IMG"]){
          /*
         UIImage *image = [UIImage imageWithData:data];
         
         NSString *orientation;
         if(image.size.width > image.size.height) orientation = @"HORIZONTAL";
         else orientation = @"VERTICAL";
         
         self.firstAddMsg = [[NSMutableDictionary alloc]init];
         [self.firstAddMsg setObject:self.myUserNo forKey:@"USER_NO"];
         [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];
         [self.firstAddMsg setObject:@"" forKey:@"CONTENT"];
         [self.firstAddMsg setObject:@"IMG" forKey:@"CONTENT_TY"];
         [self.firstAddMsg setObject:date forKey:@"DATE"];
         [self.firstAddMsg setObject:orientation forKey:@"ORIENTATION"];
         
         NSString *fileName = [self createFileName:@"IMG"];
         [self.firstAddMsg setObject:fileName forKey:@"FILE_NM"];
         
         NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
         
         //로컬tmp경로 ADIT_INFO에 추가
         NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
         NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
         
         NSDate *today = [NSDate date];
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setDateFormat:@"yyyyMMdd"];
         NSString *currentTime = [dateFormatter stringFromDate:today];
         
         NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Image/%@", self.roomNo, currentTime];
         NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Image/.thumb/%@", self.roomNo, currentTime];
         
         NSFileManager *fileManager = [NSFileManager defaultManager];
         BOOL issue = [fileManager isReadableFileAtPath:saveThumbPath];
         if (issue) {
            
         }else{
            [fileManager createDirectoryAtPath:saveThumbPath withIntermediateDirectories:YES attributes:nil error:nil];
         }
         
         NSString *imagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
         
         //썸네일이미지 로컬경로에 저장
         NSData *thumbData = UIImagePNGRepresentation([MFUtil getScaledLowImage:image scaledToMaxWidth:180.0f]);
         NSString *thumbImgPath =[saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
         [thumbData writeToFile:thumbImgPath atomically:YES];
         
         image = [MFUtil getResizeImageRatio:image];
         NSData *originData = UIImageJPEGRepresentation(image, 1.0);
         NSString *originImgPath =[saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
         [originData writeToFile:originImgPath atomically:YES];
         
         int count = missedCnt + tmpMissedCnt;
         
         NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(self.msgData.chatArray.count-count) inSection:0];
         
         [aditDic setObject:@"SENDING" forKey:@"TYPE"];
         [aditDic setObject:[NSNumber numberWithInteger:tmpImgIdx] forKey:@"TMP_NO"];
         [aditDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
         [aditDic setObject:imagePath forKey:@"LOCAL_CONTENT"];
         
         NSError *error;
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:&error];
         NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         
         [self.firstAddMsg setObject:jsonString forKey:@"ADIT_INFO"];
         
         if(msgDataCnt > 0){
            //메시지가 있는 채팅방일 경우
            [self.msgData.chatArray insertObject:self.firstAddMsg atIndex:self.msgData.chatArray.count-count];
            
         } else {
            //메시지가 없는 새로운 채팅방일 경우
            [self.msgData.chatArray addObject:self.firstAddMsg];
         }
         
         [self.sendingMsgArr addObject:self.firstAddMsg];
         
         NSMutableDictionary *param = [NSMutableDictionary dictionary];
         [param setObject:self.roomNo forKey:@"roomNo"];
         [param setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
         [param setObject:self.myUserNo forKey:@"usrNo"];
         [param setObject:@"3" forKey:@"refTy"];
         [param setObject:self.roomNo forKey:@"refNo"];
         [param setObject:jsonString forKey:@"aditInfo"];
         [param setObject:@"false" forKey:@"isThumb"];
         [param setObject:@"false" forKey:@"isShared"];
         [param setObject:@"" forKey:@"srcFileUrl"];
         */
         
        } else if([type isEqualToString:@"VIDEO_THUMB"]){
            UIImage *image = [UIImage imageWithData:data];
            NSString *fileName = [self createFileName:@"IMG"];

            NSString *orientation;
            if(image.size.width > image.size.height) orientation = @"HORIZONTAL";
            else orientation = @"VERTICAL";

            self.firstAddMsg = [[NSMutableDictionary alloc]init];
            [self.firstAddMsg setObject:self.myUserNo forKey:@"USER_NO"];
            [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];
            [self.firstAddMsg setObject:@"" forKey:@"CONTENT"];
            [self.firstAddMsg setObject:@"VIDEO" forKey:@"CONTENT_TY"];
            [self.firstAddMsg setObject:date forKey:@"DATE"];
            [self.firstAddMsg setObject:orientation forKey:@"ORIENTATION"];
            [self.firstAddMsg setObject:fileName forKey:@"FILE_NM"];

            //썸네일이미지 로컬경로에 저장
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];

            NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Video/.thumb/%@", self.roomNo, currentTime];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL issue = [fileManager isReadableFileAtPath:saveThumbPath];
            if (issue) { }
            else{
                [fileManager createDirectoryAtPath:saveThumbPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *imagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
            NSData *thumbData = UIImagePNGRepresentation([MFUtil getScaledLowImage:image scaledToMaxWidth:180.0f]);
            NSString *thumbImgPath =[saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
            [thumbData writeToFile:thumbImgPath atomically:YES];

            //로컬tmp경로 ADIT_INFO에 추가
            NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
            NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(msgDataCnt-missedCnt) inSection:0];
            [aditDic setObject:@"SENDING" forKey:@"TYPE"];
            [aditDic setObject:[NSNumber numberWithInteger:tmpImgIdx] forKey:@"TMP_NO"];
            [aditDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
            [aditDic setObject:imagePath forKey:@"LOCAL_CONTENT"];

            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

            [self.firstAddMsg setObject:jsonString forKey:@"ADIT_INFO"];

            if(msgDataCnt > 0){
                //메시지가 있는 채팅방일 경우
                [msgData insertObject:self.firstAddMsg atIndex:msgDataCnt-missedCnt];
            } else {
                //메시지가 없는 새로운 채팅방일 경우
                [msgData addObject:self.firstAddMsg];
            }

            //[self.sendingMsgArr addObject:self.firstAddMsg];

            NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
            [sendFileParam setObject:self.roomNo forKey:@"roomNo"];
            [sendFileParam setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
            [sendFileParam setObject:self.myUserNo forKey:@"usrNo"];
            [sendFileParam setObject:@"3" forKey:@"refTy"];
            [sendFileParam setObject:self.roomNo forKey:@"refNo"];
            [sendFileParam setObject:jsonString forKey:@"aditInfo"];
            [sendFileParam setObject:@"true" forKey:@"isThumb"];
            [sendFileParam setObject:@"false" forKey:@"isShared"];
            [sendFileParam setObject:@"" forKey:@"srcFileUrl"];
            
            [resultDic setObject:@"VIDEO_THUMB" forKey:@"TYPE"];
            [resultDic setObject:@(msgData.count) forKey:@"MSG_COUNT"];
            [resultDic setObject:self.firstAddMsg forKey:@"SEND_DATA"];
            [resultDic setObject:sendFileParam forKey:@"SEND_PARAM"];
            [resultDic setObject:data forKey:@"FILE_DATA"];
            [resultDic setObject:fileName forKey:@"FILE_NAME"];
            
            completion(resultDic);
            
        } else if([type isEqualToString:@"VIDEO"]){
//            NSData *jsonData = [[self.firstAddMsg objectForKey:@"ADIT_INFO"] dataUsingEncoding:NSUTF8StringEncoding];
//            NSError *e;
//            NSDictionary *editDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
//
//            NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
//            [aditDic setObject:[editDic objectForKey:@"TMP_NO"] forKey:@"TMP_NO"];
//            [aditDic setObject:[editDic objectForKey:@"TMP_IDX"] forKey:@"TMP_IDX"];
//            [aditDic setObject:[editDic objectForKey:@"LOCAL_CONTENT"] forKey:@"LOCAL_CONTENT"];
//            [aditDic setObject:[editDic objectForKey:@"TYPE"] forKey:@"TYPE"];
//            [aditDic setObject:dvcID forKey:@"DEVICE_ID"];
//            [aditDic setObject:[self.firstAddMsg objectForKey:@"ORIENTATION"] forKey:@"ORIENTATION"];
//
//            NSData* aditData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:nil];
//            NSString* aditJsonData = [[NSString alloc] initWithData:aditData encoding:NSUTF8StringEncoding];

            NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
            [sendFileParam setObject:self.roomNo forKey:@"roomNo"];
            [sendFileParam setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
            [sendFileParam setObject:self.myUserNo forKey:@"usrNo"];
            [sendFileParam setObject:@"3" forKey:@"refTy"];
            [sendFileParam setObject:self.roomNo forKey:@"refNo"];
//            [sendFileParam setObject:aditJsonData forKey:@"aditInfo"];
            [sendFileParam setObject:@"false" forKey:@"isThumb"];
//            [sendFileParam setObject:videoThumbName forKey:@"thumbName"];
            [sendFileParam setObject:@"false" forKey:@"isShared"];
            [sendFileParam setObject:@"" forKey:@"srcFileUrl"];
         
            NSString *fileName = [self createFileName:@"VIDEO"];
         
            [resultDic setObject:@"VIDEO" forKey:@"TYPE"];
            [resultDic setObject:@(msgData.count) forKey:@"MSG_COUNT"];
            [resultDic setObject:self.firstAddMsg forKey:@"SEND_DATA"];
            [resultDic setObject:sendFileParam forKey:@"SEND_PARAM"];
            [resultDic setObject:data forKey:@"FILE_DATA"];
            [resultDic setObject:fileName forKey:@"FILE_NAME"];

            completion(resultDic);
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}

-(void)shareMediaFiles:(NSData *)data mediaType:(NSString *)type isThumbImg:(UIImage *)image isFile:(NSString *)fileNm isShared:(NSString *)isShare srcFileUrl:(NSString *)fileUrl{
   /*
    @try{
      NSString *urlString = appDelegate.main_url;
      urlString = [urlString stringByAppendingPathComponent:@"saveAttachedFile"];
      
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      NSString *date = [dateFormatter stringFromDate:[NSDate date]];
      
      tmpImgIdx++;
      
      UIImage *image = [UIImage imageWithData:data];
         
      NSString *orientation;
      if(image.size.width > image.size.height) orientation = @"HORIZONTAL";
      else orientation = @"VERTICAL";
      
      self.firstAddMsg = [[NSMutableDictionary alloc]init];
      [self.firstAddMsg setObject:self.myUserNo forKey:@"USER_NO"];
      [self.firstAddMsg setObject:self.roomNo forKey:@"ROOM_NO"];
      [self.firstAddMsg setObject:@"" forKey:@"CONTENT"];
      [self.firstAddMsg setObject:type forKey:@"CONTENT_TY"];
      [self.firstAddMsg setObject:date forKey:@"DATE"];
      [self.firstAddMsg setObject:orientation forKey:@"ORIENTATION"];
      
      NSString *fileName;
      if([type isEqualToString:@"FILE"]) fileName = fileNm;
      else fileName = [fileUrl lastPathComponent];
      
      [self.firstAddMsg setObject:fileName forKey:@"FILE_NM"];
      
      NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
      
      //로컬tmp경로 ADIT_INFO에 추가
      NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
      NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
      
      NSDate *today = [NSDate date];
      NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
      [dateFormatter2 setDateFormat:@"yyyyMMdd"];
      NSString *currentTime = [dateFormatter2 stringFromDate:today];
      
      NSString *folder = @"";
      if([type isEqualToString:@"IMG"]) folder = @"Image";
      else if([type isEqualToString:@"VIDEO"]) folder = @"Video";
      else if([type isEqualToString:@"FILE"]) folder = @"File";
      
      NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/%@", self.roomNo, folder, currentTime];
      NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/%@/.thumb/%@", self.roomNo, folder, currentTime];
      
      NSFileManager *fileManager = [NSFileManager defaultManager];
      BOOL issue = [fileManager isReadableFileAtPath:saveThumbPath];
      if (issue) {
         
      }else{
         [fileManager createDirectoryAtPath:saveThumbPath withIntermediateDirectories:YES attributes:nil error:nil];
      }
      
      NSString *imagePath = [saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
      
      //썸네일이미지 로컬경로에 저장
      NSData *thumbData = UIImagePNGRepresentation([MFUtil getScaledLowImage:image scaledToMaxWidth:180.0f]);
      NSString *thumbImgPath =[saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
      [thumbData writeToFile:thumbImgPath atomically:YES];
      
      image = [MFUtil getResizeImageRatio:image];
      NSData *originData = UIImageJPEGRepresentation(image, 1.0);
      NSString *originImgPath =[saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
      [originData writeToFile:originImgPath atomically:YES];
      
      int count = missedCnt + tmpMissedCnt;
      
      NSIndexPath *rowNo = [NSIndexPath indexPathForItem:(self.msgData.chatArray.count-count) inSection:0];
      
      [aditDic setObject:@"SENDING" forKey:@"TYPE"];
      [aditDic setObject:[NSNumber numberWithInteger:tmpImgIdx] forKey:@"TMP_NO"];
      [aditDic setObject:[NSNumber numberWithInteger:rowNo.row] forKey:@"TMP_IDX"];
      [aditDic setObject:imagePath forKey:@"LOCAL_CONTENT"];
      
      NSError *error;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:&error];
      NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      
      [self.firstAddMsg setObject:jsonString forKey:@"ADIT_INFO"];
      
      if(msgDataCnt > 0){
         //메시지가 있는 채팅방일 경우
         [self.msgData.chatArray insertObject:self.firstAddMsg atIndex:self.msgData.chatArray.count-count];
         
      } else {
         //메시지가 없는 새로운 채팅방일 경우
         [self.msgData.chatArray addObject:self.firstAddMsg];
      }
      
      [self.sendingMsgArr addObject:self.firstAddMsg];
      
      NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
      [sendFileParam setObject:self.roomNo forKey:@"roomNo"];
      [sendFileParam setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
      [sendFileParam setObject:self.myUserNo forKey:@"usrNo"];
      [sendFileParam setObject:@"3" forKey:@"refTy"];
      [sendFileParam setObject:self.roomNo forKey:@"refNo"];
      [sendFileParam setObject:jsonString forKey:@"aditInfo"];
      [sendFileParam setObject:@"false" forKey:@"isThumb"];
      [sendFileParam setObject:isShare forKey:@"isShared"];
      [sendFileParam setObject:fileUrl forKey:@"srcFileUrl"];
      
      
   } @catch (NSException *exception) {
      NSLog(@"%s Exception : %@", __func__, exception);
   }
    */
}

-(NSString *)createFileName :(NSString *)filetype{
   @try{
      NSString *fileExt = @"";
      if([filetype isEqualToString:@"IMG"]) fileExt = @"png";
      else if([filetype isEqualToString:@"VIDEO"]) fileExt = @"mp4";
      
      NSString *fileName = nil;
      NSDate *today = [NSDate date];
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"yyyyMMdd-HHmmssSSS"];
      NSString *currentTime = [dateFormatter stringFromDate:today];
      fileName = [NSString stringWithFormat:@"%@.%@",currentTime,fileExt];
      return fileName;
      
   } @catch (NSException *exception) {
      NSLog(@"%s Exception : %@", __func__, exception);
   }
}

#pragma mark - Video Compression
- (void)compressVideoWithInputVideoUrl:(NSURL *)inputVideoUrl asset:(AVAsset*)asset completion:(void (^)(NSData *))completion{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *finalVideoURLString = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"CHAT_VIDEO_%d.mp4",0]];
    // 파일이 이미 있는지 확인한 다음 이전 파일을 제거합니다.
    if ([[NSFileManager defaultManager]fileExistsAtPath:finalVideoURLString]){
      NSLog(@"데이터변환 후 삭제");
      [[NSFileManager defaultManager]removeItemAtPath:finalVideoURLString error:nil];
    }

    NSURL *outputVideoUrl = ([[NSURL URLWithString:finalVideoURLString] isFileURL] == 1)?([NSURL URLWithString:finalVideoURLString]):([NSURL fileURLWithPath:finalVideoURLString]);

    SDAVAssetExportSession *compressionEncoder = [SDAVAssetExportSession.alloc initWithAsset:[AVAsset assetWithURL:inputVideoUrl]]; // provide inputVideo Url Here
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
       float newBps = (newSize.width * newSize.height * 25 * 0.15);
       if(newBps > defaultBps) newBps = defaultBps;
       NSLog(@"newBps : %f", newBps);
       
        compressionEncoder.videoSettings = @
        {
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: @(newSize.width),
        AVVideoHeightKey: @(newSize.height),
        AVVideoCompressionPropertiesKey: @
            {
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
        if (compressionEncoder.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"Compression Export Completed Successfully");
            NSData *data = [NSData dataWithContentsOfURL:outputVideoUrl];
            completion(data);
         
        } else if (compressionEncoder.status == AVAssetExportSessionStatusCancelled) {
             NSLog(@"Compression Export Canceled");
            
        } else {
            NSLog(@"Compression Failed");
        }
     }];
}


@end
