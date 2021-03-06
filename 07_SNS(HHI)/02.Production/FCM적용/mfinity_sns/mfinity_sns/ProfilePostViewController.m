//
//  ProfilePostViewController.m
//  ARSegmentPager
//
//  Created by August on 15/3/28.
//  Copyright (c) 2015年 August. All rights reserved.
//

#import "ProfilePostViewController.h"
#import "MFDBHelper.h"
#import "PostDetailViewController.h"
#import "SDImageCache.h"

@interface ProfilePostViewController () {
    AppDelegate *appDelegate;
    SDImageCache *imgCache;
}

@end

@implementation ProfilePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_SetUserData:) name:@"noti_SetUserData" object:nil];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    NSLog(@"USERNO~~ : %@", self.userNo);
    
    imgCache = [SDImageCache sharedImageCache];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    [imgCache makeDiskCachePath:cachePath];
    
    self.lastPostNo = @"1";
    [self callGetPostList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)segmentTitle
{
    return NSLocalizedString(@"profile_post", @"profile_post");
}

-(UIScrollView *)streachScrollView
{
    return self.tableView;
}

- (void)noti_SetUserData:(NSNotification *)notification {
    NSLog(@"userNm : %@, userImgPath : %@", self.userNm, self.userImgPath);
    
    /*CustomHeaderViewController에서 넘어온 사용자 데이터가 없을 때 쿼리로 데이터 조회*/
    if(self.userNm==nil || self.userImgPath==nil){
        NSMutableArray *selectUser = [appDelegate.dbHelper selectMutableArray:[appDelegate.dbHelper getUserInfo:self.userNo]];
        if(selectUser.count>0){
            self.userNm = [[selectUser objectAtIndex:0]objectForKey:@"USER_NM"];
            self.userImgPath = [[selectUser objectAtIndex:0]objectForKey:@"USER_IMG"];
        }
    }
    [self.tableView reloadData];
}

- (void)callGetPostList{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&compNo=%@&refTy=1&stPostSeq=%@&target_usrNo=%@&dvcId=%@", myUserNo, compNo, self.lastPostNo, self.userNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"getWriteLists"]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

#pragma mark - MFURLSessionDelegate
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    
    if (error!=nil || [error isEqualToString:@"(null)"]) {
        if ([error isEqualToString:@"The request timed out."]) {
            [self callGetPostList];
        }else{
            NSLog(@"Error Message : %@",error);
        }
        
    }else{
        @try{
            NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
            NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
//            NSLog(@"dataSets : %@", dataSets);
            
            NSMutableArray *postArr = [NSMutableArray array];
            
            NSString *seq = [[NSString alloc]init];
            for(int i=1; i<=dataSets.count; i++){
                seq = [NSString stringWithFormat:@"%d", [self.lastPostNo intValue]+i];
                
                NSString *dataType = [[dataSets objectAtIndex:i-1] objectForKey:@"DATA_TYPE"];
                if([dataType isEqualToString:@"POST_TYPE"]){
                    [postArr addObject:[dataSets objectAtIndex:i-1]];
                }
            }
            
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([self.lastPostNo intValue]==1) {
                    self.lastPostNo = seq;
                    self.dataSetArray = [NSMutableArray arrayWithArray:postArr];
                }else{
                    if (dataSets.count>0){
                        self.lastPostNo = seq;
                        [self.dataSetArray addObjectsFromArray:postArr]; //deep copy
                    }
                }
                [self.tableView reloadData];
                
            } else{
                NSLog(@"Error Message : %@",[session.returnDictionary objectForKey:@"MESSAGE"]);
            }
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
        
    }
}
-(void)postImgCaching:(NSArray *)contents{
    @try{
        NSUInteger count = contents.count;
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
        
        for(int i=0; i<(int)count; i++){
            NSString *type = [[contents objectAtIndex:i] objectForKey:@"TYPE"];
            if([type isEqualToString:@"IMG"]){
                NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                
                //썸네일을 로컬에 저장
                NSString *thumbImgPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[thumbImg lastPathComponent]]];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:thumbImgPath];
                if(!fileExists){
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbImg]];
                    [data writeToFile:thumbImgPath atomically:YES];
                }
                
                
            } else if([type isEqualToString:@"VIDEO"]) {
                NSDictionary *valueDic = [[contents objectAtIndex:i] objectForKey:@"VALUE"];
                //NSString *originImg = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                NSString *thumbImg = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                
                //썸네일을 로컬에 저장
                NSString *thumbImgPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",[thumbImg lastPathComponent]]];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:thumbImgPath];
                if(!fileExists){
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbImg]];
                    [data writeToFile:thumbImgPath atomically:YES];
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
}

#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataSetArray.count > 0){
        return self.dataSetArray.count;
        
    } else {
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsFeedViewCell"];
    if (cell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NewsFeedViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[NewsFeedViewCell class]]) {
                cell = (NewsFeedViewCell *) currentObject;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    
    cell.descriptionLabel.text = nil;
    cell.contentImageView.image = nil;
    cell.fileName.text = nil;
    cell.fileViewHeight.constant = 0;
    cell.playButton.hidden = YES;
    
    cell.descriptionLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink|NSTextCheckingTypeAddress|NSTextCheckingTypePhoneNumber;
    cell.descriptionLabel.userInteractionEnabled = YES;
    cell.descriptionLabel.tttdelegate = self;
    
    @try{
        if(cell!=nil && self.dataSetArray.count>0){
            NSDictionary *dataSetItem = [self.dataSetArray objectAtIndex:indexPath.item];
            
            NSString *dataContent = [NSString urlDecodeString:[dataSetItem objectForKey:@"DATA_CONTENT"]];
            NSString *dataDate = [NSString urlDecodeString:[dataSetItem objectForKey:@"DATA_DATE"]];
            //NSString *dataNo = [dataSetItem objectForKey:@"DATA_NO"];
            //NSString *dataType = [NSString urlDecodeString:[dataSetItem objectForKey:@"DATA_TYPE"]];
            NSString *ref1 = [NSString urlDecodeString:[dataSetItem objectForKey:@"REF_01"]];
            NSString *ref2 = [NSString urlDecodeString:[dataSetItem objectForKey:@"REF_02"]];
            //NSString *ref3 = [dataSetItem objectForKey:@"REF_03"];
            
            NSError *error;
            NSArray *contentArr = [NSArray array];
            NSData *jsonData = [dataContent dataUsingEncoding:NSUTF8StringEncoding];
            contentArr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            
            NSDictionary *ref1Dict = [NSDictionary dictionary];
            NSData *jsonData1 = [ref1 dataUsingEncoding:NSUTF8StringEncoding];
            ref1Dict = [NSJSONSerialization JSONObjectWithData:jsonData1 options:kNilOptions error:&error];
            
            NSDictionary *ref2Dict = [NSDictionary dictionary];
            NSData *jsonData2 = [ref2 dataUsingEncoding:NSUTF8StringEncoding];
            ref2Dict = [NSJSONSerialization JSONObjectWithData:jsonData2 options:NSJSONReadingAllowFragments error:&error];

            NSDate *currentDate = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            NSString *tmp = [dataDate substringToIndex:dataDate.length-3];
            NSDate *regiDate = [formatter dateFromString:tmp];
            
            NSCalendar *sysCalendar = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSCalendarUnitDay;
            NSDateComponents *dateComp = [sysCalendar components:unitFlags fromDate:regiDate toDate:currentDate options:0];//날짜 비교해서 차이값 추출
            NSInteger date = dateComp.day;
            
            NSString *postDateString = [[NSString alloc]init];
            if(date > 0){
                NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
                formatter2.dateFormat = NSLocalizedString(@"date13", @"date13");
                postDateString = [formatter2 stringFromDate:regiDate];
            } else{
                postDateString = [MFUtil getTimeIntervalFromDate:regiDate ToDate:currentDate];
            }
            
            if(![self.userImgPath isEqualToString:@""]&&self.userImgPath!=nil){
                UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[MFUtil saveThumbImage:@"Profile" path:self.userImgPath num:self.userNo]];
                [cell.userImageButton setImage:userImg forState:UIControlStateNormal];
            } else {
                UIImage *userImg = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(120, 120) :[UIImage imageNamed:@"profile_default.png"]];
                [cell.userImageButton setImage:userImg forState:UIControlStateNormal];
            }
            
            cell.userNameLabel.text = self.userNm;
            cell.dateLabel.text = postDateString;
            cell.teamNameLabel.text = [NSString urlDecodeString:[ref1Dict objectForKey:@"SNS_NM"]];
            
            cell.commCntLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"comment", @"comment"), [ref2Dict objectForKey:@"POST_COMMENT_COUNT"]];
            cell.viewCntLabel.text = [NSString stringWithFormat:@"%@", [ref2Dict objectForKey:@"POST_READ_COUNT"]];
            
            //읽음카운트 20이상 줄바꿈 현상 수정
            NSDictionary *attributes = @{NSFontAttributeName: [cell.viewCntLabel font]};
            CGSize textSize = [[cell.viewCntLabel text] sizeWithAttributes:attributes];
            CGFloat strikeWidth = textSize.width;
            
            if(strikeWidth < 14.0f){
                cell.viewCntConstraint.constant = 15;
            } else {
                cell.viewCntConstraint.constant = strikeWidth+5;
            }
            cell.viewCntLabel.textAlignment = NSTextAlignmentRight;
            
            NSString *description = @"";
            NSString *thumbImagePath =  @"";
            NSString *originImagePath =  @"";
            NSString *filePath =  @"";
            
            NSInteger count = [contentArr count]-1;
            
            for (int i=(int)count; i>=0; i--) {
                NSDictionary *content = [contentArr objectAtIndex:i];
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"TEXT"]) {
                    cell.playButton.hidden = YES;
                    
                    description = [NSString urlDecodeString:[content objectForKey:@"VALUE"]];
                    
                    NSString *newString = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if(![newString isEqualToString:@""]){
                        //cell.descriptionLabel.text = newString;
                        [cell.descriptionLabel setText:newString];
                        [cell.descriptionLabel setNumberOfLines:5];
                    }
                }
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"IMG"]) {
                    cell.playButton.hidden = YES;
                    
                    NSDictionary *value = [content objectForKey:@"VALUE"];
                    thumbImagePath = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                    originImagePath = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
                    
                    if (originImagePath!=nil && ![originImagePath isEqualToString:@""]) {
                        cell.contentImageView.hidden = NO;
                        
                        [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:originImagePath]
                                                 placeholderImage:nil
                                                          options:SDWebImageProgressiveDownload
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                            if(image.size.width>self.tableView.frame.size.width){
                                                                image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                                                cell.contentImageView.image = image;
                                                            }
                                                            
                                                            [self.tableView beginUpdates];
                                                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                            [self.tableView endUpdates];
                                                        }];
                        
                        
                    } else{
                        cell.contentImageView.hidden = YES;
                    }
                }
                if([[content objectForKey:@"TYPE"] isEqualToString:@"VIDEO"]){
                    cell.contentImageView.hidden = NO;
                    cell.playButton.hidden = NO;
                    cell.contentImageView.image = nil;
                    cell.videoTmpView.gestureRecognizers = nil;
                    cell.videoTmpView.tag = indexPath.row;
                    cell.playButton.tag = indexPath.row;
                    
                    NSDictionary *value = [content objectForKey:@"VALUE"];
                    
                    //서버 리턴 썸네일 있을 때
                    NSString *thumbPath = [NSString urlDecodeString:[value objectForKey:@"THUMB"]];
                    
                    [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:thumbPath]
                                             placeholderImage:nil
                                                      options:SDWebImageProgressiveDownload
                                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                        if(image.size.width>self.tableView.frame.size.width){
                                                            image = [MFUtil getScaledImage:image scaledToMaxWidth:self.tableView.frame.size.width];
                                                            cell.contentImageView.image = image;
                                                        }
                                                        
                                                        [self.tableView beginUpdates];
                                                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                        [self.tableView endUpdates];
                                                    }];
                }
                if ([[content objectForKey:@"TYPE"] isEqualToString:@"FILE"]) {
                    filePath = [NSString urlDecodeString:[content objectForKey:@"VALUE"]];
                    
                    NSString *fileName = @"";
                    @try{
                        NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
                        fileName = [filePath substringFromIndex:range.location+1];
                        
                    } @catch (NSException *exception) {
                        fileName = filePath;
                        NSLog(@"Exception : %@", exception);
                    }
                    
                    cell.fileName.text = fileName;
                    
                    NSRange range2 = [fileName rangeOfString:@"." options:NSBackwardsSearch];
                    NSString *fileExt = [[fileName substringFromIndex:range2.location+1] lowercaseString];
                    
                    if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_img.png"];
                        
                    } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_movie.png"];
                        
                    } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_music.png"];
                        
                    } else if([fileExt isEqualToString:@"psd"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_psd.png"];
                        
                    } else if([fileExt isEqualToString:@"ai"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_ai.png"];
                        
                    } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_word.png"];
                        
                    } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_ppt.png"];
                        
                    } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_excel.png"];
                        
                    } else if([fileExt isEqualToString:@"pdf"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_pdf.png"];
                        
                    } else if([fileExt isEqualToString:@"txt"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_txt.png"];
                        
                    } else if([fileExt isEqualToString:@"hwp"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_hwp.png"];
                        
                    } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
                        cell.fileIcon.image = [UIImage imageNamed:@"file_zip.png"];
                        
                    } else {
                        cell.fileIcon.image = [UIImage imageNamed:@"file_document.png"];
                    }
                }
            }
            
            if(filePath!=nil && ![filePath isEqualToString:@""]){
                //NSLog(@"filePath : %@", filePath);
                cell.fileViewHeight.constant = 45;
                cell.fileView.hidden = NO;
                cell.fileIcon.hidden = NO;
                cell.fileName.hidden = NO;
                
                cell.fileView.frame = CGRectMake(cell.frame.origin.x, 350, cell.contentView.frame.size.width, 0);
                
                
                if(![description isEqualToString:@""] && ![originImagePath isEqualToString:@""]) {
                    cell.fileView.frame = CGRectMake(cell.frame.origin.x, cell.contentImageView.frame.origin.y+cell.contentImageView.frame.size.height+7, cell.contentView.frame.size.width, 45);
                    
                } else if([description isEqualToString:@""] && ![originImagePath isEqualToString:@""]){
                    cell.fileView.frame = CGRectMake(cell.frame.origin.x, cell.descriptionLabel.frame.origin.y+cell.contentImageView.frame.size.height+10, cell.contentView.frame.size.width, 45);
                    
                } else if(![description isEqualToString:@""] && [originImagePath isEqualToString:@""]){
                    cell.fileView.frame = CGRectMake(cell.frame.origin.x, cell.descriptionLabel.frame.origin.y+cell.descriptionLabel.frame.size.height+4, cell.contentView.frame.size.width, 45);
                    
                } else {
                    cell.fileView.frame = CGRectMake(cell.frame.origin.x, cell.descriptionLabel.frame.origin.y, cell.contentView.frame.size.width, 45);
                    //NSLog(@"cell.fileView.frame.origin.y : %f, cell.fileView.frame.size.height : %f", cell.fileView.frame.origin.y, cell.fileView.frame.size.height);
                }
            }
            else {
                cell.fileViewHeight.constant = 0;
                cell.fileView.hidden = YES;
                cell.fileIcon.hidden = YES;
                cell.fileName.hidden = YES;
                cell.fileView.frame = CGRectMake(cell.frame.origin.x, cell.fileView.frame.origin.y, cell.contentView.frame.size.width, 0);
            }
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self performSegueWithIdentifier:@"PROFILE_POST_DETAIL" sender:indexPath];
    appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
    
    @try{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PostDetailViewController *destination = (PostDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destination];
        
        navController.navigationBar.translucent = NO;
        navController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
        navController.navigationBar.tintColor = [UIColor whiteColor];
        
        NSError *error;
        
        destination._postNo = [[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"DATA_NO"];
        destination._postDate = [NSString urlDecodeString:[[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"DATA_DATE"]];
        
        NSString *ref1 = [NSString urlDecodeString:[[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"REF_01"]];
        NSDictionary *ref1Dict = [NSDictionary dictionary];
        NSData *jsonData1 = [ref1 dataUsingEncoding:NSUTF8StringEncoding];
        ref1Dict = [NSJSONSerialization JSONObjectWithData:jsonData1 options:kNilOptions error:&error];
        destination._snsName = [ref1Dict objectForKey:@"SNS_NM"];
        
        NSString *ref2 = [NSString urlDecodeString:[[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"REF_02"]];
        NSDictionary *ref2Dict = [NSDictionary dictionary];
        NSData *jsonData2 = [ref2 dataUsingEncoding:NSUTF8StringEncoding];
        ref2Dict = [NSJSONSerialization JSONObjectWithData:jsonData2 options:kNilOptions error:&error];
        
        destination._readCnt = [ref2Dict objectForKey:@"POST_READ_COUNT"];
        destination._commCnt = [ref2Dict objectForKey:@"POST_COMMENT_COUNT"];
        destination._isRead = [ref2Dict objectForKey:@"IS_READ"];
        
        destination.indexPath  = indexPath;
        destination.fromSegue = @"PROFILE_POST_DETAIL";
        
        NSDictionary *postInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.userNo,@"CUSER_NO", nil];
        destination.postInfo = postInfo;
        
        navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:navController animated:YES completion:nil];
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

- (void)closeButtonClick{
    
}

#pragma mark - TTTAttributedLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    //    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
    //
    //    }];
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phoneNumber]] options:@{} completionHandler:nil];
}

@end
