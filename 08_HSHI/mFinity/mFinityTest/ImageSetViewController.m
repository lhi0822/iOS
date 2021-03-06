//
//  ImageSetViewController.m
//  mFinity
//
//  Created by hilee on 28/11/2018.
//  Copyright © 2018 Jun hyeong Park. All rights reserved.
//

#import "ImageSetViewController.h"
#import "ImageTableViewCell.h"
#import "SVProgressHUD.h"
#import "UIViewController+MJPopupViewController.h"
#import "UploadProcessViewController.h"

#define BOUNDARY @"---------------------------14737809831466499882746641449"

@interface ImageSetViewController (){
    MFinityAppDelegate *appDelegate;
    NSMutableArray *dataArr;
}

@end

@implementation ImageSetViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 300;
    
    [self.cameraBtn setTitle:NSLocalizedString(@"촬영", @"") forState:UIControlStateNormal];
    [self.cameraBtn addTarget:self action:@selector(cameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.albumBtn setTitle:NSLocalizedString(@"사진첩", @"") forState:UIControlStateNormal];
    [self.albumBtn addTarget:self action:@selector(albumBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.saveBtn setTitle:NSLocalizedString(@"사진 올리기", @"") forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    dataArr = [NSMutableArray array];
    
    if ([self.maxSize isEqualToString:@"0"]) self.maxSize = @"816";
    NSLog(@"maxSize: %@", self.maxSize);
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/image/"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    if (issue) {
        NSLog(@"directory success");
    }else{
        NSLog(@"directory failed");
        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:FALSE attributes:nil error:nil];
    }
}

-(void)cameraBtnClick{
    if([self.count isEqualToString:@"0"]||[self.count isEqualToString:@""]) self.count = @"20";
    //else self.count = @"6";
    
    NSLog(@"dataArr.count : %lu, self.count : %@", (unsigned long)dataArr.count, self.count);
    
    if(dataArr.count >= [self.count intValue]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"사진등록은 %@장까지 가능합니다.", @"사진등록은 %@장까지 가능합니다."), self.count] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        [self cameraAccessCheck];
    }
    
}

-(void)albumBtnClick{
    if([self.count isEqualToString:@"0"]||[self.count isEqualToString:@""]) self.count = @"20";
    //else self.count = @"6";
    
    if(dataArr.count >= [self.count intValue]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"사진등록은 %@장까지 가능합니다.", @"사진등록은 %@장까지 가능합니다."), self.count] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        [self photoAccessCheck:@"PHOTO"];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.navigationBar.backgroundColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }
}

-(void)saveBtnClick{
    NSLog(@"%s", __func__);
    if(dataArr.count<=0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"업로드 할 파일이 없습니다.", @"업로드 할 파일이 없습니다.") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"사진을 업로드 하시겠습니까?", @"사진을 업로드 하시겠습니까?") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"취소", @"취소")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             [self fileUpload]; 
                                                         }];
        [alert addAction:cancelButton];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)fileUpload{
    NSLog(@"%s",__FUNCTION__);
    UploadProcessViewController *vc = [[UploadProcessViewController alloc] init];
    vc.dataArr = dataArr;
    vc.deleteFlag = self.deleteFlag;
    vc.uploadUrl = self.uploadUrl;
    vc.delegate = self;
    [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
}

-(NSString *)createPhotoFileName{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    NSString *filename = @"";
    filename = [filename stringByAppendingString:@"("];
    
    filename = [filename stringByAppendingString:currentTime];
    filename = [filename stringByAppendingString:@").png"];
    return filename;
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArr.count;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewAutomaticDimension;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    ImageTableViewCell *imgCell = (ImageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ImageTableViewCell"];
    if (imgCell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"ImageTableViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[ImageTableViewCell class]]) {
                imgCell = (ImageTableViewCell *) currentObject;
                [imgCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    
    imgCell.imgView.image = nil;
    
    UIImage *imgValue = [[dataArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
    
    [imgCell.imgView setUserInteractionEnabled:YES];
    imgCell.imgView.image = imgValue;
    imgCell.imgView.tag = indexPath.row;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imgLongClick:)];
    longPress.minimumPressDuration = 0.5;
    longPress.delegate = self;
    [imgCell.imgView addGestureRecognizer:longPress];
    
    return imgCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)imgLongClick:(UILongPressGestureRecognizer *)gesture{
    CGPoint p = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        //NSLog(@"long press on table view but not on a row");
    } else if (gesture.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"사진 삭제", @"사진 삭제") message:NSLocalizedString(@"삭제하시겠습니까?", @"삭제하시겠습니까?") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"확인", @"확인")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self deleteImage:indexPath.row];
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"취소", @"취소")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action){
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        
        [alert addAction:cancelButton];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        
    }
}

-(void)deleteImage :(NSInteger)index{
    NSLog(@"index : %ld", (long)index);
    [dataArr removeObjectAtIndex:index];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadData];
    }];
}

-(void)setImageFromNoti :(NSArray *)imgArr{
    NSLog(@"%s",__FUNCTION__);
    //이미지 개수 체크 해야함.
    @try {
        //파일 로컬 경로에 저장 / 사이즈 조절한것도 저장
        NSString *savePath = [NSString stringWithFormat:@"%@/image",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
        
        for(int i=0; i<imgArr.count; i++){
            NSString *fileName = [self createPhotoFileName];
            
            UIImage *image = [imgArr objectAtIndex:i];
            
            //210104 파라미터가 원본사이즈보다 클 경우 원본에 맞춤
            int imgHeight = image.size.height;
            int imgWidth = image.size.width;
            int longSize;
            if(imgWidth >= imgHeight) longSize = imgWidth;
            else longSize = imgHeight;
            
            if([self.maxSize intValue] > longSize) self.maxSize = [NSString stringWithFormat:@"%d",longSize];
            NSLog(@"MAXSIZE : %@", self.maxSize);
            
//            NSData *thumbData = [[NSData alloc] init];
            UIImage *uploadImg = [[UIImage alloc] init];
            uploadImg = [self getScaledImage:image scaledToFixLongSide:[self.maxSize floatValue]];
            
//            NSData *data = UIImagePNGRepresentation(uploadImg);
            NSData *data = UIImageJPEGRepresentation(uploadImg, 1.0f);
            NSLog(@"data File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
            
            uploadImg = [UIImage imageWithData:data];
//            thumbData = UIImagePNGRepresentation(uploadImg);
            NSString *thumbImgPath =[savePath stringByAppendingPathComponent:fileName];
            [data writeToFile:thumbImgPath atomically:YES];
            NSLog(@"thumbImgPath : %@", thumbImgPath);
            
            UIImage *bindImg = [self getScaledImage:[imgArr objectAtIndex:i] scaledToMaxWidth:self.view.frame.size.width-10];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"IMG" forKey:@"TYPE"];
            [dict setObject:fileName forKey:@"NAME"];
            [dict setObject:bindImg forKey:@"VALUE"];
            [dict setObject:uploadImg forKey:@"UPLOAD_VALUE"];
            [dict setObject:thumbImgPath forKey:@"FILE_PATH"];
            
            [dataArr insertObject:dict atIndex:dataArr.count];
        }
        
        //NSLog(@"dataArr : %@", dataArr);
        
        [UIView performWithoutAnimation:^{
            [self.tableView reloadData];
        }];
        
        [SVProgressHUD dismiss];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //이미지 추가한 곳에 스크롤을 두기 위해.
            NSIndexPath *lastCell = [NSIndexPath indexPathForItem:dataArr.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
        
    } @catch (NSException *exception) {
        NSLog(@"%s Exception : %@", __func__, exception);
    }
}

- (void)cameraAccessCheck {
    //NSLog(@"%s", __func__);
    @try{
        int osVer = [[UIDevice currentDevice].systemVersion floatValue];
        [self photoAccessCheck:@"CAMERA"];
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized) {
            //NSLog(@"AVAuthorizationStatusAuthorized status : %ld", (long)status);
            NSLog(@"카메라 접근 허용일 경우");
            dispatch_async(dispatch_get_main_queue(), ^{
                picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
            });
            
        } else if(status == AVAuthorizationStatusDenied) {
            NSLog(@"카메라 접근 허용되지않았을 경우");
            if(osVer >= 8){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 카메라]에서 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 카메라]에서 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else if(status == AVAuthorizationStatusNotDetermined){ // not determined
            //NSLog(@"AVAuthorizationStatusNotDetermined status : %ld", (long)status);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){ // Access has been granted ..do something
                    dispatch_async(dispatch_get_main_queue(), ^{
                        picker = [[UIImagePickerController alloc] init];
                        picker.delegate = self;
                        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        [self presentViewController:picker animated:YES completion:nil];
                    });
                    
                } else { // Access denied ..do something
                    if(osVer >= 8){
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 카메라]에서 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                             [[UIApplication sharedApplication] openURL:url];
                                                                             
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         }];
                        
                        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * action) {
                                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             }];
                        [alert addAction:okButton];
                        [alert addAction:cancelButton];
                        [self presentViewController:alert animated:YES completion:nil];
                        
                    } else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 카메라]에서 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                             [[UIApplication sharedApplication] openURL:url];
                                                                             
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         }];
                        
                        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * action) {
                                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             }];
                        [alert addAction:okButton];
                        [alert addAction:cancelButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    
                }
            }];
            
        } else {
            NSLog(@"status : %ld", (long)status);
        }
        
    } @catch(NSException *exception){
        
    }
}

- (void)photoAccessCheck :(NSString *)mediaType{
    //NSLog(@"%s", __func__);
    @try{
        int osVer = [[UIDevice currentDevice].systemVersion floatValue];
        PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
        
        if (photoStatus == PHAuthorizationStatusAuthorized) {
            //NSLog(@"Access has been granted.");
            if([mediaType isEqualToString:@"PHOTO"]){
                //[self performSegueWithIdentifier:@"BOARD_PHLIB_MODAL" sender:@"PHOTO"];
            }
            
        } else if (photoStatus == PHAuthorizationStatusDenied) {
            //NSLog(@"Access has been denied.");
            if(osVer >= 8){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 사진]에서 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 사진]에서 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else if (photoStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    NSLog(@"1 StatusNotDetermined Access has been granted.");
                    if([mediaType isEqualToString:@"PHOTO"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //[self performSegueWithIdentifier:@"BOARD_PHLIB_MODAL" sender:@"PHOTO"];
                        });
                    }
                    
                } else {
                    NSLog(@"2 StatusNotDetermined Access has been granted.");
                }
            }];
        } else if (photoStatus == PHAuthorizationStatusRestricted) {
            NSLog(@"Restricted access - normally won't happen.");
        }
        
        return;
        
    } @catch(NSException *exception){
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}


#pragma mark - UIImagePickerController Delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%s",__FUNCTION__);
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
        
    } else{
        [SVProgressHUD showWithStatus:@"이미지를 가져오는 중입니다."];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            NSData *data = UIImagePNGRepresentation(image); //UIImageJPEGRepresentation(value, 0.7);
            NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
            
            [picker dismissViewControllerAnimated:YES completion:nil];
            
            if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            } else {
                NSError *error;
                [self image:image didFinishSavingWithError:error contextInfo:nil];
            }
        });
    }
}

-(void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        NSLog(@"video saved");
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"%s : %f %f",__FUNCTION__,image.size.width,image.size.height);
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        NSLog(@"photo saved");
        
        NSArray *imageArray = [[NSArray alloc] initWithObjects:image, nil];
        [self setImageFromNoti :imageArray];
    }
}

- (UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    
    scaleFactor = width / oldWidth;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)getScaledImage:(UIImage *)image scaledToMaxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    
    //if (oldWidth > width) {
    scaleFactor = height / oldHeight;
    //} else  //oldWidth<width and height==0이면, scale하지 않음.
    //    return image;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)getScaledImage:(UIImage *)image scaledToFixLongSide:(CGFloat)fixedValue {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    
    if(oldWidth<=oldHeight){
        scaleFactor = fixedValue / oldHeight; //높이고정
    } else {
        scaleFactor = fixedValue / oldWidth; //높이고정
    }
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    NSLog(@"oldWidth : %f, oldHeight : %f", oldWidth, oldHeight);
    NSLog(@"newWidth : %f, newHeight : %f", newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0f);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    NSData *data = UIImageJPEGRepresentation(newImage, 1.0f);
//    NSLog(@"new File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
//    newImage = [UIImage imageWithData:data];
//    UIImageWriteToSavedPhotosAlbum(newImage, self, nil, nil);
    
    return newImage;
}

-(void)UploadProcessViewReturn:(NSString *)result :(NSMutableArray *)returnArr{
    NSLog(@"%s",__func__);
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    @try{
        NSDictionary *returnDic = [[NSDictionary alloc] initWithObjectsAndKeys:returnArr, @"RETURN", nil];
        
        if([result isEqualToString:@"SUCCEED"]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"업로드 완료" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"executeHSHIImageUploadReturn" object:self userInfo:returnDic];
                                                                 [self.navigationController popViewControllerAnimated:YES];
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    } @catch(NSException *e){
        NSLog(@"%s exception : %@",__func__, e);
    }
}

@end

