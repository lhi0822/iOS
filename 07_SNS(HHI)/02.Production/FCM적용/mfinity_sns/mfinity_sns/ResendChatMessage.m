//
//  ResendChatMessage.m
//  mfinity_sns
//
//  Created by hilee on 2020/12/07.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import "ResendChatMessage.h"

@implementation ResendChatMessage {
    NSMutableDictionary *resultDict;
}

- (NSDictionary *)resendMessage:(NSDictionary *)dictionary roomNo:(NSString *)roomNo{
    NSLog(@"Resend Dict : %@", dictionary);
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    
    NSMutableArray *resendArr = [NSMutableArray array];
    
    @try{
        NSMutableDictionary *thumbDict = [NSMutableDictionary dictionary];
        NSString *chatNo = [dictionary objectForKey:@"CHAT_NO"];
        NSString *contentType = [dictionary objectForKey:@"CONTENT_TY"];
        NSString *content = [dictionary objectForKey:@"CONTENT"];
        NSString *fileName = [dictionary objectForKey:@"FILE_NM"];
        
        NSError *error;
        NSString *editInfo = [dictionary objectForKey:@"ADIT_INFO"];
        NSData *editInfoData = [editInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *editDic = [NSJSONSerialization JSONObjectWithData:editInfoData options:0 error:&error];
        NSString *tmpIdx = [editDic objectForKey:@"TMP_IDX"];
        NSString *localContent = [editDic objectForKey:@"LOCAL_CONTENT"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *date = [dateFormatter stringFromDate:[NSDate date]];
        
        self.editInfoDic = [NSMutableDictionary dictionary];
        [self.editInfoDic setObject:@"SENDING" forKey:@"TYPE"];
        [self.editInfoDic setObject:tmpIdx forKey:@"TMP_IDX"];
        [self.editInfoDic setObject:localContent forKey:@"LOCAL_CONTENT"];
        
        NSData* editData = [NSJSONSerialization dataWithJSONObject:self.editInfoDic options:0 error:nil];
        NSString* editJsonData = [[NSString alloc] initWithData:editData encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *msgResendDict = [NSMutableDictionary dictionary];
        [msgResendDict setObject:editJsonData forKey:@"ADIT_INFO"];
        [msgResendDict setObject:date forKey:@"DATE"];
        [msgResendDict setObject:myUserNo forKey:@"USER_NO"]; //MISSED 일 때 USER_NO가 10으로 들어옴.
        
        [resultDict setObject:msgResendDict forKey:@"MSG_RESEND_DICT"];
        
        NSString *sqlString = [appDelegate.dbHelper deleteMissedChat:roomNo chatNo:chatNo];
        [appDelegate.dbHelper crudStatement:sqlString];
        
        if([contentType isEqualToString:@"TEXT"]||[contentType isEqualToString:@"LONG_TEXT"]){
    
            
        } else if([contentType isEqualToString:@"IMG"]){
            NSRange range = [fileName rangeOfString:@"-" options:0];
            NSString *fileDate = [fileName substringToIndex:range.location];
            
            //로컬경로에 저장되어있는 이미지 재업로드
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
            
            NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Image/%@/", roomNo, fileDate];
            NSString *imagePath =[saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
            
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            
            //mediaArr 형태로 만들어 주기 위해
            UIImage *image = [[UIImage alloc] initWithData:data];
            NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:image, nil];
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:arr, @"IMG_LIST", nil];
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:dic, nil];
            
            [resultDict setObject:array forKey:@"IMG_ARRAY"];
            
        } else if([contentType isEqualToString:@"VIDEO"]){
            //썸네일이랑 비디오 데이터를(로컬에서 가져와서) 어레이에 넣고 썸네일 먼저 업로드 후 비디오 업로드..
            NSRange range = [fileName rangeOfString:@"-" options:0];
            NSString *fileDate = [fileName substringToIndex:range.location];
            
            //로컬경로에 저장되어있는 이미지 재업로드
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            NSString *documentFolder = [NSString stringWithFormat:@"/%@/%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
            
            //local thumb path
            NSString *saveThumbPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Video/%@/thumb/", roomNo, fileDate];
            NSString *thumbPath =[saveThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",fileName]];
            NSData *thumbData = [NSData dataWithContentsOfFile:thumbPath];
            UIImage *thumbImage = [UIImage imageWithData:thumbData];
            
            NSString *saveOrginPath = [documentFolder stringByAppendingFormat:@"/Chat/%@/Video/%@/", roomNo, fileDate];
            NSRange range2 = [fileName rangeOfString:@"." options:NSBackwardsSearch];
            NSString *videoName = [NSString stringWithFormat:@"%@.mp4",[fileName substringToIndex:range2.location]];
            NSString *videoPath = [saveOrginPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",videoName]];
            NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:videoPath]){
                //NSLog(@"재전송 동영상 데이터 삭제");
                [[NSFileManager defaultManager]removeItemAtPath:videoPath error:nil];
            }
            
            [thumbDict setObject:fileName forKey:@"FILE_NM"];
            [thumbDict setObject:thumbImage forKey:@"ORIGIN"];
            [thumbDict setObject:@"VIDEO_THUMB" forKey:@"TYPE"];
            [resendArr addObject:thumbDict];
            
            NSMutableDictionary *originDict = [NSMutableDictionary dictionary];
            [originDict setObject:editJsonData forKey:@"ADIT_INFO"];
            [originDict setObject:videoName forKey:@"FILE_NM"];
            [originDict setObject:videoData forKey:@"ORIGIN"];
            [originDict setObject:contentType forKey:@"TYPE"];
            [resendArr addObject:originDict];
            
            [resultDict setObject:resendArr forKey:@"VIDEO_ARRAY"];
        }
        
        return resultDict;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}



@end
