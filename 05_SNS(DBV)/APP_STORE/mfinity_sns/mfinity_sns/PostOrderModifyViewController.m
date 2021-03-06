//
//  PostOrderModifyViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 4. 10..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "PostOrderModifyViewController.h"
#import "MFUtil.h"

#import "PostModifyTextCell.h"
#import "SDImageCache.h"
#import "MFDBHelper.h"
#import "AppDelegate.h"

@interface PostOrderModifyViewController () {
    SDImageCache *imgCache;
    UIImage *thumbImg;
    AppDelegate *appDelegate;
}

@end

@implementation PostOrderModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"post_content_order_title", @"post_content_order_title")];
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"close", @"close") style:UIBarButtonItemStylePlain target:self action:@selector(leftSideMenuButtonPressed:)];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"complete", @"complete") style:UIBarButtonItemStylePlain target:self action:@selector(rightSideMenuButtonPressed:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_TeamExit:) name:@"noti_TeamExit" object:nil];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    
    [self.tableView setEditing:YES animated:YES];
    
    imgCache = [SDImageCache sharedImageCache];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    [imgCache makeDiskCachePath:cachePath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)leftSideMenuButtonPressed:(id)sender {
    @try{
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"post_content_order_cancel", @"post_content_order_cancel") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action){
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action){
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        [actionSheet addAction:okAction];
        [actionSheet addAction:cancelAction];
        [self presentViewController:actionSheet animated:YES completion:nil];
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)rightSideMenuButtonPressed:(id)sender {
    @try{
        NSMutableArray *result = [NSMutableArray array];
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
        
        NSArray<PostModifyTextCell *> *txtCells = self.tableView.visibleCells;
        
        NSLog(@"순서변경.. self.contentArr : %@", self.contentArr);
        
        for(int i=0; i<txtCells.count; i++){
            PostModifyTextCell *cell = [txtCells objectAtIndex:i];
            NSString *title = cell.tmpLabel.text;
            
            for(int j=0; j<self.contentArr.count; j++){
                NSString *tmpType = [[self.contentArr objectAtIndex:j] objectForKey:@"TYPE"];
                NSString *tmpValue;
                
                if(_isEdit){
                    if([tmpType isEqualToString:@"TEXT"]){
                        tmpValue = [NSString urlDecodeString:[[self.contentArr objectAtIndex:j] objectForKey:@"VALUE"]];
                        
                    } else if([tmpType isEqualToString:@"IMG"]){
                        NSDictionary *valueDic = [[self.contentArr objectAtIndex:j] objectForKey:@"VALUE"];
                        tmpValue = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                        
                    } else if([tmpType isEqualToString:@"VIDEO"]){
                        NSDictionary *valueDic = [[self.contentArr objectAtIndex:j] objectForKey:@"VALUE"];
                        tmpValue = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                        
                    } else if([tmpType isEqualToString:@"FILE"]){
                        tmpValue = [NSString urlDecodeString:[[self.contentArr objectAtIndex:j] objectForKey:@"VALUE"]];
                    }
                    
                } else {
                    if([tmpType isEqualToString:@"TEXT"]){
                        tmpValue = [NSString urlDecodeString:[[self.contentArr objectAtIndex:j] objectForKey:@"VALUE"]];
                        
                    } else if([tmpType isEqualToString:@"IMG"]){
                        tmpValue = [NSString stringWithFormat:@"%@",[[self.contentArr objectAtIndex:j] objectForKey:@"VALUE"]];
                        
                    } else if([tmpType isEqualToString:@"VIDEO"]){
                        tmpValue = [NSString stringWithFormat:@"%@",[[self.contentArr objectAtIndex:j] objectForKey:@"VALUE"]];
                        
                    } else if([tmpType isEqualToString:@"FILE"]){
                        tmpValue = [NSString urlDecodeString:[[self.contentArr objectAtIndex:j] objectForKey:@"VALUE"]];
                    }
                }
                
                if([title isEqualToString:tmpValue]){
                    NSDictionary *valueDic = [self.contentArr objectAtIndex:j];
                    [result addObject:valueDic];
                }
            }
        }
        
        [resultDic setObject:result forKey:@"DATASET"];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_PostOrderModify" object:nil userInfo:resultDic];
        }];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - UITableView Delegate & Datasrouce
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *contentDic = [self.contentArr objectAtIndex:indexPath.row];
    NSString *type = [contentDic objectForKey:@"TYPE"];
    
    if([type isEqualToString:@"TEXT"]){
        return UITableViewAutomaticDimension;
        
    } else if([type isEqualToString:@"IMG"]){
        return 200;
        
    } else if([type isEqualToString:@"VIDEO"]){
        return 200;
    
    } else if([type isEqualToString:@"FILE"]){
        return UITableViewAutomaticDimension;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostModifyTextCell *txtCell = (PostModifyTextCell *)[tableView dequeueReusableCellWithIdentifier:@"PostModifyTextCell"];
    
    if (txtCell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"PostModifyTextCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[PostModifyTextCell class]]) {
                txtCell = (PostModifyTextCell *) currentObject;
                [txtCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    
    @try{
        NSDictionary *contentDic = [self.contentArr objectAtIndex:indexPath.row];
        NSString *type = [contentDic objectForKey:@"TYPE"];
        NSString *value = nil;
        txtCell.imgView.image = nil;
        txtCell.tmpLabel.hidden = YES;
        
        if([type isEqualToString:@"TEXT"]){
            txtCell.txtLabel.hidden = NO;
            txtCell.imgView.hidden = YES;
            txtCell.fileButton.hidden = YES;
            txtCell.videoContainer.hidden = YES;
            
            value = [NSString urlDecodeString:[contentDic objectForKey:@"VALUE"]];
            
            txtCell.tmpLabel.text = value;
            
            txtCell.txtLabel.text = value;
            [txtCell.txtLabel setNumberOfLines:0];
            
            txtCell.textLabelConstraint.constant = 0;
            
        } else if([type isEqualToString:@"IMG"]){
            txtCell.txtLabel.hidden = YES;
            txtCell.imgView.hidden = NO;
            txtCell.fileButton.hidden = YES;
            txtCell.videoContainer.hidden = YES;
            
            txtCell.textLabelConstraint.constant = 172;
            
            if(self.isEdit){
                NSDictionary *valueDic = [contentDic objectForKey:@"VALUE"];
                value = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
                txtCell.tmpLabel.text = value;
                [imgCache queryDiskCacheForKey:value done:^(UIImage *image, SDImageCacheType cacheType) {
                    if(image!=nil){
                        thumbImg = image;
                        txtCell.imgView.image = thumbImg;
                    }
                }];
                
            } else {
                txtCell.tmpLabel.text = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"VALUE"]];
                thumbImg = [contentDic objectForKey:@"VALUE"];
                txtCell.imgView.image = thumbImg;
            }
                
        } else if([type isEqualToString:@"VIDEO"]){
            txtCell.txtLabel.hidden = YES;
            txtCell.imgView.hidden = NO;
            txtCell.fileButton.hidden = YES;
            txtCell.videoContainer.hidden = NO;
            
            txtCell.textLabelConstraint.constant = 172;
            
            if(self.isEdit){
                NSDictionary *valueDic = [contentDic objectForKey:@"VALUE"];
                //서버 리턴 썸네일 있을 때
                value = [NSString urlDecodeString:[valueDic objectForKey:@"THUMB"]];
                txtCell.tmpLabel.text = value;
                [txtCell.imgView sd_setImageWithURL:[NSURL URLWithString:value]
                                       placeholderImage:nil
                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                  
                                              }];
                
            } else {
                txtCell.tmpLabel.text = [NSString stringWithFormat:@"%@",[contentDic objectForKey:@"VALUE"]];
                thumbImg = [contentDic objectForKey:@"VALUE"];
                txtCell.imgView.image = thumbImg;
            }
            
            
        } else if([type isEqualToString:@"FILE"]){
            txtCell.txtLabel.hidden = YES;
            txtCell.imgView.hidden = YES;
            txtCell.fileButton.hidden = NO;
            txtCell.videoContainer.hidden = YES;
            
            value = [NSString urlDecodeString:[contentDic objectForKey:@"VALUE"]];
            
            NSString *fileName = @"";
            @try{
                fileName = [value lastPathComponent];
                
            } @catch (NSException *exception) {
                fileName = value;
                NSLog(@"Exception : %@", exception);
            }
            
            txtCell.tmpLabel.text = value;
            [txtCell.fileButton setTitle:fileName forState:UIControlStateNormal];
            
            NSRange range = [value rangeOfString:@"." options:NSBackwardsSearch];
            NSString *fileExt = [[value substringFromIndex:range.location+1] lowercaseString];
            
            if([fileExt isEqualToString:@"jpg"]||[fileExt isEqualToString:@"jpeg"]||[fileExt isEqualToString:@"gif"]||[fileExt isEqualToString:@"png"]||[fileExt isEqualToString:@"tiff"]||[fileExt isEqualToString:@"bmp"]||[fileExt isEqualToString:@"heic"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_img.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"mp4"]||[fileExt isEqualToString:@"mkv"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"mov"]||[fileExt isEqualToString:@"swf"]||[fileExt isEqualToString:@"mpg"]||[fileExt isEqualToString:@"mpeg"]||[fileExt isEqualToString:@"vob"]||[fileExt isEqualToString:@"asf"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_movie.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"mp3"]||[fileExt isEqualToString:@"wav"]||[fileExt isEqualToString:@"ogg"]||[fileExt isEqualToString:@"wma"]||[fileExt isEqualToString:@"m4a"]||[fileExt isEqualToString:@"flac"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_music.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"psd"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_psd.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"ai"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_ai.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"docx"]||[fileExt isEqualToString:@"doc"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_word.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"pptx"]||[fileExt isEqualToString:@"ppt"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_ppt.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"xls"]||[fileExt isEqualToString:@"xlsx"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_excel.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"pdf"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_pdf.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"txt"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_txt.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"hwp"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_hwp.png"] forState:UIControlStateNormal];
                
            } else if([fileExt isEqualToString:@"zip"]||[fileExt isEqualToString:@"rar"]||[fileExt isEqualToString:@"egg"]||[fileExt isEqualToString:@"alz"]||[fileExt isEqualToString:@"7z"]){
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_zip.png"] forState:UIControlStateNormal];
                
            } else {
                [txtCell.fileButton setImage:[UIImage imageNamed:@"file_document.png"] forState:UIControlStateNormal];
            }
            
            txtCell.fileButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [txtCell.fileButton setImageEdgeInsets:UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0)];
            [txtCell.fileButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -5.0, 0.0, 0.0)];
        }
        
        return txtCell;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
    
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
}

- (void)noti_TeamExit:(NSNotification *)notification {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TeamSelectExit" object:nil];
    }];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_TeamExit" object:nil];
}

@end
