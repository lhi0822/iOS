//
//  UploadProcessViewController.m
//  mFinity
//
//  Created by hilee on 30/11/2018.
//  Copyright © 2018 Jun hyeong Park. All rights reserved.
//

#import "UploadProcessViewController.h"
#import "MFinityAppDelegate.h"

#define BOUNDARY @"---------------------------14737809831466499882746641449"

@interface UploadProcessViewController (){
    int uploadCount;
    NSURLConnection *urlCon;
    MFinityAppDelegate *appDelegate;
    NSMutableArray *returnArray;
}

@end

@implementation UploadProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    uploadCount = 0;
    //self.uploadUrl = @"http://eqmnew.e-hshi.co.kr/Weblogic/PhotoSave";
    returnArray = [NSMutableArray array];
    
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *fileName = [[_uploadFilePathArray objectAtIndex:0] lastPathComponent];
    NSLog(@"filePath : %@",[_uploadFilePathArray objectAtIndex:0]);
    NSLog(@"fileName : %@",fileName);
    NSData *fileData = [[NSData alloc]initWithContentsOfFile:[_uploadFilePathArray objectAtIndex:0]];
    NSString *upLoadUrl = [_uploadUrlArray objectAtIndex:0];
    
    //NSLog(@"fileData : %@", fileData);
    
    self.headerView.backgroundColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
    self.titleLabel.text = @"Upload";
    self.fileNameLabel.text = fileName;
    //self.countLabel.text = [NSString stringWithFormat:@"0/%lu", (unsigned long)_uploadFilePathArray.count];
    self.countLabel.hidden = YES;
    
    [self.cancelButton setTitle:@"Close" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [self.refreshButton addTarget:self action:@selector(refreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelButton.hidden = YES;
    self.refreshButton.hidden = YES;
    
    [self startUpload:fileData :fileName :upLoadUrl];
}

-(void)startUpload: (NSData *)data :(NSString *)fileName :(NSString *)upLoadUrl{
    NSURL *url = [NSURL URLWithString:upLoadUrl];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDARY];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1.0f];
    [request setHTTPMethod:@"POST"];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *postbody = [NSMutableData data];
    
    //[postbody appendData:[[NSString stringWithFormat:@"--\%@--\r\n",BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:data]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postbody];
    
    urlCon = [NSURLConnection connectionWithRequest:request delegate:self];
    if (urlCon) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }else{
        NSLog(@"connection error");
    }
}

-(void)cancelButtonClick{
    [self.delegate UploadProcessViewReturn:@"FAILED" :nil];
}
-(void)refreshButtonClick{
    NSString *fileName = [[_uploadFilePathArray objectAtIndex:uploadCount] lastPathComponent];
    NSData *fileData = [[NSData alloc]initWithContentsOfFile:[_uploadFilePathArray objectAtIndex:uploadCount]];
    NSString *upLoadUrl = [_uploadUrlArray objectAtIndex:uploadCount];
    
    [self startUpload:fileData :fileName :upLoadUrl];
}

#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    
    float num = totalBytesWritten;
    float total = totalBytesExpectedToWrite;
    float percentf = num/total*100;
    
    self.percentLabel.text = [NSString stringWithFormat:@"%d %%",(int)percentf];
    self.progressView.progress = percentf;
}
//파일 업로드 완료 되었을 때
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"returnString : %@",returnString);  // 리턴값이 있다면 확인해 볼 수 있다.
    NSError *error=nil;
    
    if (error==nil) {
        if([returnString isEqualToString:@"uploadFailed"]){
            self.cancelButton.hidden = NO;
            self.refreshButton.hidden = NO;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"업로드 실패" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            if(_deleteFlag){
                //삭제플래그 true이면 업로드 후 로컬에서 파일 삭제
                //            NSFileManager *manager =[NSFileManager defaultManager];
                //            NSString *filePath = [_uploadFilePathArray objectAtIndex:progressTag];
                //            NSLog(@"deleteFilePath : %@", filePath);
                //            [manager removeItemAtPath:filePath error:&error];
            }
            
            //if(_uploadFilePathArray.count-1 == progressTag) [self.delegate returnArray:returnArray WithError:error.localizedDescription];
            
            NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
            [returnDic setObject:@"FILE" forKey:@"TYPE"];
            [returnDic setObject:[self.uploadFilePathArray objectAtIndex:uploadCount] forKey:@"FILEPATH"];
            [returnDic setObject:@"SUCCEED" forKey:@"RESULT"];
            [returnDic setObject:@"" forKey:@"VALUE"];
            
            uploadCount++;
            [returnArray addObject:returnDic];
            
            NSLog(@"uploadCount : %d", uploadCount);
            
            if(uploadCount<self.uploadFilePathArray.count){
                NSString *fileName = [[_uploadFilePathArray objectAtIndex:uploadCount] lastPathComponent];
                NSData *fileData = [[NSData alloc]initWithContentsOfFile:[_uploadFilePathArray objectAtIndex:uploadCount]];
                NSString *upLoadUrl = [_uploadUrlArray objectAtIndex:uploadCount];
                
                NSLog(@"fileName: %@", fileName);
                self.fileNameLabel.text = fileName;
                [self startUpload:fileData :fileName :upLoadUrl];
                
            } else if(uploadCount==self.uploadFilePathArray.count){
                NSString *fileName = [[_uploadFilePathArray objectAtIndex:uploadCount-1] lastPathComponent];
                self.fileNameLabel.text = fileName;
            }
        }
        
        
    }else{
        NSLog(@"error : %@",error);
        
        self.cancelButton.hidden = NO;
        self.refreshButton.hidden = NO;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"업로드 실패" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


//끝나면 프로그레스바가 있는 Alert을 닫아준다.
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"%s", __func__);
    self.countLabel.text = [NSString stringWithFormat:@"%d/%lu", uploadCount, (unsigned long)self.uploadFilePathArray.count];

    NSDictionary *returnDic = [[NSDictionary alloc] initWithObjectsAndKeys:returnArray, @"RETURN", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageUploadReturn" object:self userInfo:returnDic];
    
//    if(uploadCount==self.uploadFilePathArray.count){
//        uploadCount = 0;
//        //[self.delegate UploadProcessViewReturn:@"SUCCEED" :returnArray];
//
//        NSDictionary *returnDic = [[NSDictionary alloc] initWithObjectsAndKeys:returnArray, @"RETURN", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageUploadReturn" object:self userInfo:returnDic];
//    }
}

//파일 업로드 중 실패하였을 경우
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alertView show];
    
    self.cancelButton.hidden = NO;
    self.refreshButton.hidden = NO;
}

@end
