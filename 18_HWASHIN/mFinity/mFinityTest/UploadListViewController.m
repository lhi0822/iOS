//
//  UploadListViewController.m
//  mFinity
//
//  Created by Park on 2014. 10. 8..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import "UploadListViewController.h"
#import "SubMenuViewCell.h"
#import "ZipArchive.h"
#import "MFinityAppDelegate.h"
#import "UIViewController+MJPopupViewController.h"
#define labelTag 1000

@interface UploadListViewController (){
    MFinityAppDelegate *appDelegate;
    NSMutableArray *progressList;
    NSMutableArray *percentList;
    NSMutableData *fileData;
    NSNumber *totalFileSize;
    NSMutableArray *checkList;
    NSString *percentString;
    NSString *mode;
    NSString *viewerURL;
    int count;
    int progressTag;
    IBOutlet UIImageView *_imageView;
    IBOutlet UITableView *_tableView;
    
    NSURLConnection *urlCon;
    
    int uploadCount;
    NSMutableArray *returnArray;
}
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation UploadListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    uploadCount = 0;
    returnArray = [NSMutableArray array];
    
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = @"Upload";
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
    }
    self.navigationItem.titleView = label;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSData *imageData;
    if ([manager isReadableFileAtPath:appDelegate.subBgImagePath]) {
        NSLog(@"subBg : %@",appDelegate.subBgImagePath);
        imageData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    }else{
        
    }
    UIImage *bgImage = [UIImage imageWithData:imageData];
    _imageView.image = bgImage;
    _tableView.delegate = self;
    _tableView.separatorColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    // Do any additional setup after loading the view from its nib.
    [self startUpload];
}

- (void)startUpload{
    [_tableView reloadData];
    _tableView.scrollEnabled = NO;
    
    checkList = [NSMutableArray array];
    for (int i=0; i<_uploadUrlArray.count; i++) {
        [checkList addObject:@"NO"];
    }
    progressTag = 0;
    percentList = [[NSMutableArray alloc]init];
    progressList = [[NSMutableArray alloc]init];
    
    NSString *urlString = [_uploadUrlArray objectAtIndex:progressTag];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *_fileName = [[_uploadFilePathArray objectAtIndex:progressTag] lastPathComponent];
    NSLog(@"filePath : %@",[_uploadFilePathArray objectAtIndex:progressTag]);
    NSLog(@"_fileName : %@",_fileName);
    NSData *_fileData = [[NSData alloc]initWithContentsOfFile:[_uploadFilePathArray objectAtIndex:progressTag]];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSLog(@"is File : %@",[manager isReadableFileAtPath:[_uploadFilePathArray objectAtIndex:progressTag]]?@"YES":@"NO");
    NSLog(@"filedata : %@", _fileData);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];

    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filename\"; filename=\"%@\"\r\n",_fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:_fileData]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"postbody : %@",[[NSString alloc]initWithData:postbody encoding:NSUTF8StringEncoding]);
    [request setHTTPBody:postbody];
    
    urlCon = [NSURLConnection connectionWithRequest:request delegate:self];
    if (urlCon) {
        fileData =[[NSMutableData alloc] init];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }else{
        NSLog(@"connection error");
    }
}
- (void)endUpload{
    NSLog(@"endUpload");
    _tableView.scrollEnabled = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClick)];
}
-(void)leftButtonClick{
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(leftButtonClicked:)]) {
        [self.delegate leftButtonClicked2:self :returnArray];
//    }
}
-(void)cancelButtonClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonClicked:)]) {
        [urlCon cancel];
        [fileData setLength:0];
        [self.delegate cancelButtonClicked2:self];
    }
}
-(void)errorButtonClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(errorButtonClicked:)]) {
        [self.delegate errorButtonClicked2:self];
    }
}
-(void)rightButtonClick{
    [self startUpload];
}
#pragma mark
#pragma mark UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_uploadUrlArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SubMenuViewCell";
    
    SubMenuViewCell *cell = (SubMenuViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"SubMenuViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[SubMenuViewCell class]]) {
                cell = (SubMenuViewCell *) currentObject;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 275, 44)];
    label.tag = labelTag;
    label.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    
    label.text = [NSString urlDecodeString:[[_uploadFilePathArray objectAtIndex:indexPath.row] lastPathComponent]];
    [cell.contentView addSubview:label];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(220, 55, 70, 30)];
    label2.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    label2.textAlignment = NSTextAlignmentRight;
    
    [cell.contentView addSubview:label2];
    
    UIProgressView *webAppProgressBar = [[UIProgressView alloc]initWithFrame:CGRectMake(15, 50, 275, 3)];
    webAppProgressBar.progressViewStyle = UIProgressViewStyleDefault;
    webAppProgressBar.progressTintColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    webAppProgressBar.tag = indexPath.row+1000;
    if ([[checkList objectAtIndex:indexPath.row]isEqualToString:@"YES"]) {
        webAppProgressBar.progress = 100.0f;
        label2.text = @"100 %";
    }else{
        label2.text = @"0 %";
        webAppProgressBar.progress = 0.0f;
    }
    [percentList addObject:label2];
    [progressList addObject:webAppProgressBar];
    [cell.contentView addSubview:webAppProgressBar];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
#pragma mark
#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        [self endUpload];
        if ([alertView.title isEqualToString:@"Upload Failed"]) {
            NSDictionary *returnDic = [[NSDictionary alloc] initWithObjectsAndKeys:returnArray, @"RETURN", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"executeFileUploadReturn" object:self userInfo:returnDic];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick)];
            
        } else if([alertView.title isEqualToString:@"Error"]){
            NSDictionary *returnDic = [[NSDictionary alloc] initWithObjectsAndKeys:returnArray, @"RETURN", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"executeFileUploadReturn" object:self userInfo:returnDic];
            
        }/*else if ([alertView.title isEqualToString:@"Upload"]){
          [self.delegate leftButtonClicked2:self :returnArray];
          }*/
    }
}
#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    @try {
        float num = totalBytesWritten;
        float total = totalBytesExpectedToWrite;
        float percentf = num/total*100;
        
        UIProgressView *progressView=[progressList objectAtIndex:progressTag];
        UILabel *percentView = [percentList objectAtIndex:progressTag];
        
        percentView.text = [NSString stringWithFormat:@"%d %%",(int)percentf];
        progressView.progress = percentf;
        
    } @catch (NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}
//파일 업로드 완료 되었을 때
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"returnString : %@",returnString);  // 리턴값이 있다면 확인해 볼 수 있다.
    
    NSError *error=nil;
    //NSData *login_data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
    //NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:login_data options:kNilOptions error:&error];
    
    @try {
        if (error==nil) {
            if(_deleteFlag){
                //삭제플래그 true이면 업로드 후 로컬에서 파일 삭제
                NSFileManager *manager =[NSFileManager defaultManager];
                NSString *filePath = [_uploadFilePathArray objectAtIndex:progressTag];
                NSLog(@"deleteFilePath : %@", filePath);
                [manager removeItemAtPath:filePath error:&error];
            }
            
            NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
            [returnDic setObject:@"FILE" forKey:@"TYPE"];
            [returnDic setObject:[self.uploadFilePathArray objectAtIndex:uploadCount] forKey:@"FILEPATH"];
            [returnDic setObject:@"SUCCEED" forKey:@"RESULT"];
            [returnDic setObject:returnString forKey:@"VALUE"];
            
            uploadCount++;
            [returnArray addObject:returnDic];
            NSLog(@"returnArray : %@", returnArray);
            
        }else{
            NSLog(@"error : %@",error);
            
            NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
            [returnDic setObject:@"FILE" forKey:@"TYPE"];
            [returnDic setObject:[self.uploadFilePathArray objectAtIndex:uploadCount] forKey:@"FILEPATH"];
            [returnDic setObject:@"FAILED" forKey:@"RESULT"];
            [returnDic setObject:error.localizedDescription forKey:@"VALUE"];
            
            [returnArray addObject:returnDic];
            
            UIAlertView *alertView;
            alertView = [[UIAlertView alloc]initWithTitle:@"Upload Failed" message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
            [alertView show];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
        
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        [returnDic setObject:@"FILE" forKey:@"TYPE"];
        [returnDic setObject:[self.uploadFilePathArray objectAtIndex:uploadCount] forKey:@"FILEPATH"];
        [returnDic setObject:@"FAILED" forKey:@"RESULT"];
        [returnDic setObject:exception.reason forKey:@"VALUE"];
        
        [returnArray addObject:returnDic];
        
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc]initWithTitle:@"Upload Failed" message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
        [alertView show];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    NSLog(@"statusCode : %ld", (long)statusCode);
    
    if(statusCode == 403 || statusCode == 404 || statusCode == 500){
        //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        //[connection cancel];
    }
}

//끝나면 프로그레스바가 있는 Alert을 닫아준다.
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"%s",__FUNCTION__);
    
    @try {
        UILabel *percentView = [percentList objectAtIndex:progressTag];
        percentView.text = @"100 %";
        UIProgressView *progressView=[progressList objectAtIndex:progressTag];
        progressView.progress = 100.f;
        [checkList replaceObjectAtIndex:progressTag withObject:@"YES"];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error;
        [manager removeItemAtPath:[_uploadFilePathArray objectAtIndex:progressTag] error:&error];
        
        if (progressTag < _uploadUrlArray.count-1) {
            progressTag++;
            count=0;
            NSIndexPath* ipath = [NSIndexPath indexPathForRow:progressTag-1 inSection: 0];
            [_tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
            NSLog(@"progressTag : %d",progressTag);
            [self startTimer];
        }else{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            [self endUpload];
            //[self.delegate leftButtonClicked2:self :returnArray];
            
            //2018-12-21 delegate호출 시 웹뷰를 새로그려 초기화되는 이슈로 인해 notificaion호출로 변경
            NSDictionary *returnDic = [[NSDictionary alloc] initWithObjectsAndKeys:returnArray, @"RETURN", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"executeFileUploadReturn" object:self userInfo:returnDic];
            
            //UIAlertView *alertView;
            //alertView = [[UIAlertView alloc]initWithTitle:@"Upload" message:@"Completed" delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
            //[alertView show];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
        
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        [returnDic setObject:@"FILE" forKey:@"TYPE"];
        [returnDic setObject:[self.uploadFilePathArray objectAtIndex:uploadCount-1] forKey:@"FILEPATH"];
        [returnDic setObject:@"FAILED" forKey:@"RESULT"];
        [returnDic setObject:exception.reason forKey:@"VALUE"];
        
        [returnArray addObject:returnDic];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:exception.reason delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
    }
}

//파일 업로드 중 실패하였을 경우
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"uploadCount : %d", uploadCount);
    NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
    [returnDic setObject:@"FILE" forKey:@"TYPE"];
    [returnDic setObject:[self.uploadFilePathArray objectAtIndex:uploadCount-1] forKey:@"FILEPATH"];
    [returnDic setObject:@"FAILED" forKey:@"RESULT"];
    [returnDic setObject:error.localizedDescription forKey:@"VALUE"];
    [returnArray addObject:returnDic];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
    [alertView show];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick)];
    [self endUpload];
}
#pragma mark
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString *) startTimer{
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                              target:self
                                            selector:@selector(handleTimer:)
                                            userInfo:nil
                                             repeats:YES];
    return @"YES";
}
-(void) handleTimer:(NSTimer *)timer {
    count++;
    if (count==1) {
        
        NSString *urlString = [_uploadUrlArray objectAtIndex:progressTag];
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *_fileName = [[_uploadFilePathArray objectAtIndex:progressTag] lastPathComponent];
        NSLog(@"filePath : %@",[_uploadFilePathArray objectAtIndex:progressTag]);
        NSLog(@"_fileName : %@",_fileName);
        NSData *_fileData = [[NSData alloc]initWithContentsOfFile:[_uploadFilePathArray objectAtIndex:progressTag]];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSLog(@"is File : %@",[manager isReadableFileAtPath:[_uploadFilePathArray objectAtIndex:progressTag]]?@"YES":@"NO");

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [request setHTTPMethod:@"POST"];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *postbody = [NSMutableData data];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filename\"; filename=\"%@\"\r\n",_fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[NSData dataWithData:_fileData]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        NSLog(@"postbody : %@",[[NSString alloc]initWithData:postbody encoding:NSUTF8StringEncoding]);
        NSLog(@"postbody : %@",postbody);
        [request setHTTPBody:postbody];

        urlCon = [NSURLConnection connectionWithRequest:request delegate:self];
        if (urlCon) {
            fileData =[[NSMutableData alloc] init];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }else{
            NSLog(@"connection error");
        }
        
    }
}

//- (NSData *)createParamData{
//    if (self.paramDictionary!=nil) {
//        NSMutableData *returnData = [NSMutableData data];
//        NSArray *keys = self.paramDictionary.allKeys;
//        //NSLog(@"keys : %@", keys);
//        //NSLog(@"paramDictionary : %@", self.paramDictionary);
//
//        for(NSString *key in keys){
//            [returnData appendData:[[NSString stringWithFormat:@"--%@\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
//            [returnData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
//            [returnData appendData:[[NSString stringWithFormat:@"%@",[self.paramDictionary objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
//            [returnData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        }
//        return returnData;
//    } else{
//        return nil;
//    }
//}
@end
