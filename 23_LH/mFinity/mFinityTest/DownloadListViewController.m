//
//  DownloadListViewController.m
//  downloadTest
//
//  Created by Park on 2014. 6. 25..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import "DownloadListViewController.h"
#import "SubMenuViewCell.h"
#import "ZipArchive.h"
#import "MFinityAppDelegate.h"
#import "UIViewController+MJPopupViewController.h"

#define labelTag 1000

@interface DownloadListViewController (){
    MFinityAppDelegate *appDelegate;
    NSMutableArray *progressList;
    NSMutableArray *percentList;
    NSMutableData *fileData;
    NSNumber *totalFileSize;
    NSMutableArray *checkList;
    NSString *percentString;
    int count;
    int progressTag;
    IBOutlet UIImageView *_imageView;
    IBOutlet UITableView *_tableView;
    BOOL connError;
}
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation DownloadListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.cNaviFontColor]; //[appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.cNaviColor]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.cNaviColor]]; //[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    
    label.textColor = [appDelegate myRGBfromHex:appDelegate.cNaviFontColor]; //[appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = @"Download";
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
    }
    self.navigationItem.titleView = label;
    _imageView.backgroundColor = [appDelegate myRGBfromHex:appDelegate.cBgColor];
    _tableView.delegate = self;
//    _tableView.separatorColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    
    [self startDownload];
}
- (void)startDownload{
    [_tableView reloadData];
    _tableView.scrollEnabled = NO;
    
    checkList = [NSMutableArray array];
    NSLog(@"_downloadUrlArray : %@",_downloadUrlArray);
    NSLog(@"checkList : %@",checkList);
    for (int i=0; i<_downloadUrlArray.count; i++) {
        [checkList addObject:@"NO"];
    }
    progressTag = 0;
    percentList = [[NSMutableArray alloc]init];
    progressList = [[NSMutableArray alloc]init];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_downloadUrlArray objectAtIndex:progressTag]]];
    [urlRequest setHTTPMethod:@"POST"];
    NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if (urlCon) {
        fileData =[[NSMutableData alloc] init];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}
- (void)errorDownload{
    _tableView.scrollEnabled = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(errorButtonClick)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
}
- (void)endDownload{
    _tableView.scrollEnabled = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonClick)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
}
-(void)leftButtonClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonClicked:)]) {
        [self.delegate cancelButtonClicked:self];
    }
}
-(void)errorButtonClick{
    [self.delegate errorButtonClicked:self];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(errorButtonClicked:)]) {
        [self.delegate errorButtonClicked:self];
    }
}
-(void)rightButtonClick{
    [self startDownload];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_downloadUrlArray count];
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
    label.textColor = [appDelegate myRGBfromHex:appDelegate.cFontColor]; //[appDelegate myRGBfromHex:appDelegate.subFontColor];
    label.text = [NSString urlDecodeString:[_downloadMenuTitleList objectAtIndex:indexPath.row]];
    [cell.contentView addSubview:label];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(15, 55, 275, 30)];
    label2.textColor = [appDelegate myRGBfromHex:appDelegate.cFontColor]; //[appDelegate myRGBfromHex:appDelegate.subFontColor];
    label2.textAlignment = NSTextAlignmentRight;
    
    [cell.contentView addSubview:label2];
    
    UIProgressView *webAppProgressBar = [[UIProgressView alloc]initWithFrame:CGRectMake(15, 50, 275, 3)];
    webAppProgressBar.progressViewStyle = UIProgressViewStyleDefault;
    webAppProgressBar.progressTintColor = [appDelegate myRGBfromHex:appDelegate.cFontColor]; //[appDelegate myRGBfromHex:appDelegate.subFontColor];
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
    NSLog(@"clickedButtonAtIndex");
    if ([alertView.title isEqualToString:@"Download"]) {
        if (connError) {
            [self errorDownload];
        }else{
            if ([_downloadUrlArray count]<2) {
                [self.delegate cancelButtonClicked:self];
            }else{
                [self endDownload];
            }
            
        }
        
    }
}
#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError : %@",error);
    connError = YES;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"")  otherButtonTitles: nil];
    [alertView show];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    [self errorDownload];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    NSLog(@"statusCode : %ld",(long)statusCode);
    if(statusCode == 404 || statusCode == 500){
        connError = YES;
        [connection cancel];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick)];
        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
        [self errorDownload];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"%d Error \n %@",statusCode,NSLocalizedString(@"message12", @"")] delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
        
    }else{
        connError = NO;
        [fileData setLength:0];
        totalFileSize = [NSNumber numberWithLongLong:[response expectedContentLength]];
        NSLog(@"totalFileSize : %@", totalFileSize);
        if ([totalFileSize isEqualToNumber:[[NSNumber alloc]initWithDouble:-1]]) {
            totalFileSize = [[NSNumber alloc]initWithDouble:1];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [fileData appendData:data];
    NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[fileData length]];
//    NSLog(@"resourceLength : %@", resourceLength);
    NSNumber *progress = [NSNumber numberWithFloat:([resourceLength floatValue] / [totalFileSize floatValue] )];
    NSNumber *percent = [NSNumber numberWithInt:([resourceLength floatValue] / [totalFileSize floatValue])*100];
//    NSLog(@"progress : %@ / percent : %@", progress, percent);
    
    UIProgressView *progressView=[progressList objectAtIndex:progressTag];
    UILabel *percentView = [percentList objectAtIndex:progressTag];

    percentView.text = [NSString stringWithFormat:@"%d %%",[percent intValue]];
    progressView.progress = [progress floatValue];
    
}
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
//    NSLog(@"totalBytesWritten : %ld", (long)totalBytesWritten);
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSString *lastPath = [urlStr lastPathComponent];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *save = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    save = [save stringByAppendingFormat:@"/%@/webapp/%@",appDelegate.comp_no,[_downloadNoArray objectAtIndex:progressTag]];
    save = [save stringByAppendingString:@".zip"];
    
    NSString *unZipFolder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingFormat:@"/%@/webapp/%@",appDelegate.comp_no,[[save lastPathComponent] stringByDeletingPathExtension]];
    [fileData writeToFile:save atomically:YES];
    
    ZipArchive *zip = [[ZipArchive alloc]init];
    if ([zip UnzipOpenFile:save]) {
        [zip UnzipFileTo:unZipFolder overWrite:YES];
    }
    [zip UnzipCloseFile];
    NSFileManager *manager =[NSFileManager defaultManager];
    NSError *error;
    [manager removeItemAtPath:save error:&error];
    NSPropertyListFormat format;
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];
    NSMutableDictionary *dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
    if (dic==nil) {
        dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[_downloadVerArray objectAtIndex:progressTag],[_downloadNoArray objectAtIndex:progressTag],nil];
    }else{
        [dic setObject:[_downloadVerArray objectAtIndex:progressTag] forKey:[_downloadNoArray objectAtIndex:progressTag]];
    }
    [dic writeToFile:filePath atomically:YES];
    UILabel *percentView = [percentList objectAtIndex:progressTag];
    percentView.text = @"100 %";
    UIProgressView *progressView=[progressList objectAtIndex:progressTag];
    progressView.progress = 100.f;
    [checkList replaceObjectAtIndex:progressTag withObject:@"YES"];
    if (progressTag < _downloadUrlArray.count-1) {
        progressTag++;
        count=0;
        NSIndexPath* ipath = [NSIndexPath indexPathForRow:progressTag-1 inSection: 0];
        [_tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        [self startTimer];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Download" message:NSLocalizedString(@"message164", @"완료되었습니다.") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"확인") otherButtonTitles: nil];
        [alertView show];
    }
}
#pragma mark
#pragma mark delay

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
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_downloadUrlArray objectAtIndex:progressTag]]];
        [urlRequest setHTTPMethod:@"POST"];
        NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        if (urlCon) {
            fileData =[[NSMutableData alloc] init];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [_timer invalidate];
            _timer=nil;
        }
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
