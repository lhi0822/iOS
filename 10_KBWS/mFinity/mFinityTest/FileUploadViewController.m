//
//  FileUploadViewController.m
//  mFinity
//
//  Created by Park on 2014. 2. 3..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import "FileUploadViewController.h"
#import "MFinityAppDelegate.h"
#import "CustomSegmentedControl.h"

#define kLabelIndentedRect	CGRectMake(100.0, 12.0, 275.0, 20.0)
#define kLabelRect			CGRectMake(65.0, 12.0, 275.0, 20.0)

#define kCellPictureViewTag	1000
#define kCellImageViewTag	1001
#define kCellLabelTag		1002
@interface FileUploadViewController (){
    int selectTag;
}

@end

@implementation FileUploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    // Do any additional setup after loading the view from its nib.
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    _label.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    _label.text = @"File Upload";
    _label.font = [UIFont boldSystemFontOfSize:18.0];
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.subIsShadow isEqualToString:@"Y"]) {
        _label.shadowOffset = CGSizeMake([appDelegate.subShadowOffset floatValue], [appDelegate.subShadowOffset floatValue]);
        _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.subShadowColor];
    }
    
    CustomSegmentedControl *button;
    button= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Cancel",nil]
                                                offColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                                 onColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]
                                            offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                             onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                fontSize:12];
    button.momentary = YES;
    [button addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=left;
    self.navigationItem.titleView = _label;
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
	   
}
-(void)cancelButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark
#pragma mark TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat{
	return 70;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_uploadInfo count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SubMenuViewCell";
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UILabel *label = [[UILabel alloc] initWithFrame:kLabelRect];
		label.tag = kCellLabelTag;
		[cell.contentView addSubview:label];
        
        NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
        documentFolder = [documentFolder stringByAppendingFormat:@"/photo"];
        
		NSMutableString *filePath = [NSMutableString stringWithString:documentFolder];
		[filePath appendString:@"/"];
		NSString *temp = [filePath lastPathComponent];
		NSArray *arr = [temp componentsSeparatedByString:@"."];
		NSString *thumFileName = [arr objectAtIndex:0];
		thumFileName = [thumFileName stringByAppendingString:@".thum"];
		NSMutableString *filePath2 = [NSMutableString stringWithString:documentFolder];
		[filePath2 appendString:@"/"];
		[filePath2 appendString:thumFileName];
        NSData *descryptData = [NSData dataWithContentsOfFile:filePath2];
		UIImage *image = [UIImage imageWithData:descryptData ];
		UIImageView *pictureView = [[UIImageView alloc] initWithImage:image];
		pictureView.frame = CGRectMake(5.0, 10.0, 50.0, 50.0);
		[cell.contentView addSubview:pictureView];
		pictureView.tag = kCellPictureViewTag;
        
    }
    NSLog(@"indexPath.row : %d",indexPath.row);
    NSUInteger row =indexPath.row;
    UIProgressView *progress = [[UIProgressView alloc]initWithFrame:CGRectMake(65,45, 225, 10)];
    progress.tag = 10000+indexPath.row;
    progress.progressTintColor = [UIColor yellowColor];
    [cell.contentView addSubview:progress];
    
    UIButton *playButton = [[UIButton alloc]initWithFrame:CGRectMake(250, 10, 24, 24)];
    playButton.tag = 20000+indexPath.row;
    //playButton.tag = indexPath.row;
    [playButton setBackgroundImage:[UIImage imageNamed:@"play-3-icon-24.png"] forState:UIControlStateNormal];
    [playButton setBackgroundImage:[UIImage imageNamed:@"play-3-icon-24 (1).png"] forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:playButton];
    
    
    
    NSDictionary *dic = [_uploadInfo objectForKey:[NSString stringWithFormat:@"%d",row]];
    NSString *fileName = [dic objectForKey:@"fileName"];
    
	NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    documentFolder = [documentFolder stringByAppendingFormat:@"/photo"];
   
    NSMutableString *filePath = [NSMutableString stringWithString:documentFolder];
	[filePath appendString:@"/"];
    NSArray *tmpArr = [fileName componentsSeparatedByString:@"."];
	[filePath appendString:[tmpArr objectAtIndex:0]];
	NSString *temp = [filePath lastPathComponent];
	NSArray *arr = [temp componentsSeparatedByString:@"."];
	NSString *thumFileName = [arr objectAtIndex:0];
	thumFileName = [thumFileName stringByAppendingString:@".thum"];
	NSMutableString *filePath2 = [NSMutableString stringWithString:documentFolder];
	[filePath2 appendString:@"/"];
	[filePath2 appendString:thumFileName];
    NSData *descryptData = [NSData dataWithContentsOfFile:filePath2];
    UIImage *image = [UIImage imageWithData:descryptData];

	UIImageView *picture = (UIImageView *)[cell.contentView viewWithTag:kCellPictureViewTag];
	picture.image = image;
	picture.hidden = NO;
	
	UILabel *label = (UILabel *)[cell.contentView viewWithTag:kCellLabelTag];
    label.text = fileName;
	label.opaque = NO;
    
    //[UIView commitAnimations];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath : %d",indexPath.row);
}
#pragma mark
#pragma mark FileUpload
-(void) buttonTouched:(id)sender{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    UIButton *_btn = (UIButton *)sender;
    NSLog(@"sender : %d",[sender tag]);
    selectTag = [sender tag]-10000;
    _btn.alpha = 0.5;
    [_btn setEnabled:NO];
    NSDictionary *dic = [_uploadInfo objectForKey:[NSString stringWithFormat:@"%d",[sender tag]-20000]];
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
    documentFolder = [documentFolder stringByAppendingFormat:@"/photo"];
    NSString *fileName = [documentFolder stringByAppendingPathComponent:[dic objectForKey:@"fileName"]];
    [self fileUpload:fileName :[dic objectForKey:@"upLoadPath"]];
}
-(void)fileUpload:(NSString *)fileName :(NSString *)uploadPath{
    
    NSString *_fileName = [fileName lastPathComponent];
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:fileName]];
    
	NSData *imageData = UIImageJPEGRepresentation(image,90);
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
	NSURL *url = [NSURL URLWithString:uploadPath];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"%@\"\r\n",_fileName] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        progressView = (UIProgressView *)[self.view viewWithTag:selectTag];
        [progressView setProgressViewStyle:UIProgressViewStyleBar];
    }else{
        NSLog(@"connection error");
    }

}
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    
    float num = totalBytesWritten;
    float total = totalBytesExpectedToWrite;
    float percent = num/total;
    progressView.progress = percent;
}
//파일 업로드 완료 되었을 때
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",returnString);  // 리턴값이 있다면 확인해 볼 수 있다.
    NSError *error=nil;
    NSData *login_data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:login_data options:kNilOptions error:&error];
    if (error==nil) {
        NSLog(@"Upload Success : %@",dic);
        
    }else{
        NSLog(@"error : %@",error);
    }
    
}


//끝나면 프로그레스바가 있는 Alert을 닫아준다.
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"upload end : %d",selectTag);
    //[_uploadInfo removeObjectForKey:[NSString stringWithFormat:@"%d",selectTag-10000]];
    //[_tableView reloadData];
}

//파일 업로드 중 실패하였을 경우
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message82", @"")
                                                    message:NSLocalizedString(@"message83", @"")
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"")
                                          otherButtonTitles:nil];
    
    [alert show];
    
}
#pragma mark
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
