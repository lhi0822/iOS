//
//  ProfileFileViewController2.m
//  mfinity_sns
//
//  Created by hilee on 2017. 10. 13..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "ProfileFileViewController2.h"
#import "ProfileFileViewCell.h"
#import "PostDetailViewController.h"

@interface ProfileFileViewController2 () {
    AppDelegate *appDelegate;
}

@end

@implementation ProfileFileViewController2

static CGSize gridSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ProfileFileViewCell" bundle:nil] forCellWithReuseIdentifier:@"ProfileFileViewCell"];
    
    self.lastPostNo = @"1";
    [self callGetFileList];
}

-(void)viewWillAppear:(BOOL)animated {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
    gridSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)callGetFileList{
    NSString *urlString = appDelegate.main_url;
    NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&compNo=%@&refTy=3&stPostSeq=%@&target_usrNo=%@&dvcId=%@", myUserNo, compNo, self.lastPostNo, self.userNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
    
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
            [self callGetFileList];
            
        } else{
#ifdef DEBUG
            NSLog(@"%s \n Error Message : %@",__FUNCTION__,error);
#endif

        }
    }else{
        NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
        NSMutableArray *dataSets = [session.returnDictionary objectForKey:@"DATASET"];
        
        NSString *seq = [[NSString alloc]init];
        for(int i=1; i<=dataSets.count; i++){
            seq = [NSString stringWithFormat:@"%d", [self.lastPostNo intValue]+i];
        }
        
        if ([result isEqualToString:@"SUCCESS"]) {
            if ([self.lastPostNo intValue]==1) {
                self.lastPostNo = seq;
                self.dataSetArray = [NSMutableArray arrayWithArray:dataSets];

            } else{
                if (dataSets.count>0){
                    self.lastPostNo = seq;
                    [self.dataSetArray addObjectsFromArray:dataSets]; //deep copy
                }
            }
            [self.collectionView reloadData];
            
        }else{
#ifdef DEBUG
            NSLog(@"%s \n Error Message : %@",__FUNCTION__,[session.returnDictionary objectForKey:@"MESSAGE"]);
#endif
        }
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(self.dataSetArray.count > 0){
        return self.dataSetArray.count;
        
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProfileFileViewCell *cell = (ProfileFileViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileFileViewCell" forIndexPath:indexPath];
    cell.imgView.image=nil;
    cell.fileImgView.image=nil;
    
    NSDictionary *dataSetItem = [self.dataSetArray objectAtIndex:indexPath.item];
    
    NSString *dataContent = [NSString urlDecodeString:[dataSetItem objectForKey:@"DATA_CONTENT"]];
    //NSString *dataDate = [NSString urlDecodeString:[dataSetItem objectForKey:@"DATA_DATE"]];
    //NSString *dataNo = [dataSetItem objectForKey:@"DATA_NO"];
    //NSString *dataType = [NSString urlDecodeString:[dataSetItem objectForKey:@"DATA_TYPE"]];
    NSString *ref1 = [NSString urlDecodeString:[dataSetItem objectForKey:@"REF_01"]];
    //NSString *ref2 = [NSString urlDecodeString:[dataSetItem objectForKey:@"REF_02"]];
    NSString *ref3 = [dataSetItem objectForKey:@"REF_03"];
    
    NSError *error;
    NSDictionary *contentDict = [NSDictionary dictionary];
    NSData *jsonData = [dataContent dataUsingEncoding:NSUTF8StringEncoding];
    contentDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
    cell.fileName.text = ref1;
    cell.fileName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    if([ref3 isEqualToString:@"Photo"]){
        //NSString *orgFile = [contentDict objectForKey:@"ORIGIN"];
        NSString *thumbFile = [contentDict objectForKey:@"THUMB"];
        
        NSURL *url = [NSURL URLWithString:[thumbFile stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imgView.hidden = NO;
                        cell.smallView.hidden = YES;
                        
                        cell.imgView.image = [MFUtil imageByScalingAndCroppingForSize:CGSizeMake(cell.imgView.frame.size.width, cell.imgView.frame.size.height) :image];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imgView.hidden = YES;
                        cell.smallView.hidden = NO;
                        
                        cell.fileImgView.image = [UIImage imageNamed:@"close_red.png"];;
                    });
                }
            }
        }];
        [task resume];
        
    } else if([ref3 isEqualToString:@"File"]){
        cell.imgView.hidden = YES;
        cell.smallView.hidden = NO;
        
        NSRange range = [ref1 rangeOfString:@"." options:NSBackwardsSearch];
        NSString *fileExt = [[ref1 substringFromIndex:range.location+1] lowercaseString];
        
        if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_img.png"];
            
        } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_movie.png"];
            
        } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_music.png"];
            
        } else if([fileExt isEqualToString:@"psd"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_psd.png"];
            
        } else if([fileExt isEqualToString:@"ai"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_ai.png"];
            
        } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_word.png"];
            
        } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_ppt.png"];
            
        } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_excel.png"];
            
        } else if([fileExt isEqualToString:@"pdf"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_pdf.png"];
            
        } else if([fileExt isEqualToString:@"txt"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_txt.png"];
            
        } else if([fileExt isEqualToString:@"hwp"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_hwp.png"];
            
        } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
            cell.fileImgView.image = [UIImage imageNamed:@"file_zip.png"];
            
        } else {
            cell.fileImgView.image = [UIImage imageNamed:@"file_document.png"];
        }
    }
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"PROFILE_FILE_DETAIL" sender:indexPath];
}

#pragma mark <UICollectionViewDelegate>
- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * scale, CGRectGetHeight(self.view.bounds) * scale);
    return targetSize;
}
// 컬렉션과 컬렉션 height 간격
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

// 컬렉션과 컬렉션 width 간격
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    return CGSizeMake(screenWidth/4, screenWidth/4);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"PROFILE_FILE_DETAIL"]){
        appDelegate.toolBarBtnTitle = NSLocalizedString(@"regist", @"regist");
        
        UINavigationController *nav = segue.destinationViewController;
        PostDetailViewController *destination = [[nav childViewControllers] objectAtIndex:0];
        
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        destination._postNo = [[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"DATA_NO"];
        destination._postDate = [NSString urlDecodeString:[[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"DATA_DATE"]];
        
        destination._snsNo = [[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"REF_02"];
        destination._snsName = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getSnsName:[[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"REF_02"]]];
        
        destination._readCnt = [[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"POST_READ_COUNT"];
        destination._commCnt = [[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"POST_COMMENT_COUNT"];
        destination._isRead = [[self.dataSetArray objectAtIndex:indexPath.item] objectForKey:@"IS_READ"];

        destination.indexPath  = indexPath;
        destination.fromSegue = segue.identifier;
        
        NSDictionary *postInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.userNo,@"CUSER_NO", nil];
        destination.postInfo = postInfo;
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_DeletePost:) name:@"noti_DeletePost" object:nil];
    }
}

@end
