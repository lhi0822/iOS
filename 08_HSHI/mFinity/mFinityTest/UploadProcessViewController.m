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
    
    UIImage *image = [[self.dataArr objectAtIndex:0] objectForKey:@"UPLOAD_VALUE"];
    NSString *fileName = [[self.dataArr objectAtIndex:0] objectForKey:@"NAME"];
    NSData * data = UIImageJPEGRepresentation(image, 0.1);
    
    self.headerView.backgroundColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
    self.titleLabel.text = @"사진 업로드";
    self.fileNameLabel.text = fileName;
    self.countLabel.text = [NSString stringWithFormat:@"0/%lu", (unsigned long)self.dataArr.count];
    
    [self.cancelButton setTitle:@"취소" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.cancelButton setTitle:@"재전송" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(refreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelButton.hidden = YES;
    self.refreshButton.hidden = YES;
    
    [self startUpload:data :fileName];
}

-(void)startUpload: (NSData *)data :(NSString *)fileName{
    NSURL *url = [NSURL URLWithString:self.uploadUrl];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDARY];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    [request setHTTPMethod:@"POST"];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *postbody = [NSMutableData data];
    
    [postbody appendData:[[NSString stringWithFormat:@"--\%@--\r\n",BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
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
    UIImage *image = [[self.dataArr objectAtIndex:uploadCount-1] objectForKey:@"UPLOAD_VALUE"];
    NSString *fileName = [[self.dataArr objectAtIndex:uploadCount-1] objectForKey:@"NAME"];
    NSData * data = UIImageJPEGRepresentation(image, 0.1);
    [self startUpload:data :fileName];
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
            
            uploadCount++;
            [returnArray addObject:returnString];
            
            NSLog(@"uploadCount : %d", uploadCount);
            
            if(uploadCount<self.dataArr.count){
                UIImage *image = [[self.dataArr objectAtIndex:uploadCount] objectForKey:@"UPLOAD_VALUE"];
                NSString *fileName = [[self.dataArr objectAtIndex:uploadCount] objectForKey:@"NAME"];
                NSData * data = UIImageJPEGRepresentation(image, 0.1);
                
                NSLog(@"fileName: %@", fileName);
                self.fileNameLabel.text = fileName;
                [self startUpload:data :fileName];
                
            } else if(uploadCount==self.dataArr.count){
                NSString *fileName = [[self.dataArr objectAtIndex:uploadCount-1] objectForKey:@"NAME"];
                self.fileNameLabel.text = fileName;
            }
        }
        
        
    }else{
        NSLog(@"error : %@",error);
        
        self.cancelButton.hidden = NO;
        self.refreshButton.hidden = NO;
    }
}


//끝나면 프로그레스바가 있는 Alert을 닫아준다.
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"%s", __func__);
    self.countLabel.text = [NSString stringWithFormat:@"%d/%lu", uploadCount, (unsigned long)self.dataArr.count];

    if(uploadCount==self.dataArr.count){
        uploadCount = 0;
        [self.delegate UploadProcessViewReturn:@"SUCCEED" :returnArray];
    }
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
