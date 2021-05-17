//
//  ImageDrawViewController.m
//  mFinity
//
//  Created by hilee on 07/01/2019.
//  Copyright © 2019 Jun hyeong Park. All rights reserved.
//

#import "ImageDrawViewController.h"
#import "MFinityAppDelegate.h"

@interface ImageDrawViewController () {
    UIImage *resultImg;
    MFinityAppDelegate *appDelegate;
    float originWidth;
    float originHeight;
    
    UIButton *toolRight1;
    UIButton *toolRight2;
}

@end

@implementation ImageDrawViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    originWidth = self.getBgImg.size.width;
    originHeight = self.getBgImg.size.height;
    
    NSLog(@"self.getBgImg.size.width : %f, self.getBgImg.size.height : %f", self.getBgImg.size.width, self.getBgImg.size.height);
    
    resultImg = nil;
    
    //resultImg = [self setResizeImage:self.getBgImg onImageView:self.imgCanvas];
    //self.imgCanvas.image = resultImg;
    
    //[self viewDidLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIButton *navLeft = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [navLeft setTitle:@"취소" forState:UIControlStateNormal];
    [navLeft setTitleColor:[appDelegate myRGBfromHex:@"006FFF"] forState:UIControlStateNormal];
    [navLeft addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithCustomView:navLeft];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIButton *navRight = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [navRight setTitle:@"저장" forState:UIControlStateNormal];
    [navRight setTitleColor:[appDelegate myRGBfromHex:@"006FFF"] forState:UIControlStateNormal];
    [navRight addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:navRight];
    self.navigationItem.rightBarButtonItem = rightBtn;

    toolRight1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [toolRight1 setImage:[UIImage imageNamed:@"tool_pencil_over.png"] forState:UIControlStateNormal];
    [toolRight1 addTarget:self action:@selector(penClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *toolRightBtn1 = [[UIBarButtonItem alloc]initWithCustomView:toolRight1];
    
    toolRight2 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [toolRight2 setImage:[UIImage imageNamed:@"tool_eraser.png"] forState:UIControlStateNormal];
    [toolRight2 addTarget:self action:@selector(eraserClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *toolRightBtn2 = [[UIBarButtonItem alloc]initWithCustomView:toolRight2];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //NSArray *barButtonArr = [[NSArray alloc] initWithObjects:flexibleSpace, toolRightBtn1, flexibleSpace, toolRightBtn2, flexibleSpace, nil];
    NSArray *barButtonArr = [[NSArray alloc] initWithObjects:toolRightBtn1, flexibleSpace, flexibleSpace, flexibleSpace, toolRightBtn2, nil];
    self.toolBar.items = barButtonArr;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    //CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-self.toolBar.frame.size.height;
    CGFloat screenHeight = self.imgCanvas.frame.size.height;
    
    resultImg = nil;
    
    if(originWidth > originHeight){
        resultImg = [self setResizeImage:self.getBgImg :screenWidth :YES];
    } else if(originWidth < originHeight){
        resultImg = [self setResizeImage:self.getBgImg :screenHeight :NO];
    } else {
        if(originWidth<screenWidth/2){
            resultImg = resultImg = [self setResizeImage:self.getBgImg :originWidth*2 :YES];
        } else {
            resultImg = [self setResizeImage:self.getBgImg :screenWidth :YES];
        }
    }
    
    self.imgCanvas.image = resultImg;
    
    [self.contentView setFrame:CGRectMake((self.imgCanvas.frame.size.width/2)-(resultImg.size.width/2), (self.imgCanvas.frame.size.height/2)-(resultImg.size.height/2)+self.contentView.frame.origin.y, resultImg.size.width, resultImg.size.height)];
    
//    if(resultImg.size.width<self.imgCanvas.frame.size.width){
//        [self.contentView setFrame:CGRectMake((self.imgCanvas.frame.size.width/2)-(resultImg.size.width/2), (self.imgCanvas.frame.size.height/2)-(resultImg.size.height/2)+self.contentView.frame.origin.y, resultImg.size.width, resultImg.size.height)];
//    } else {
//        [self.contentView setFrame:CGRectMake(0, (self.imgCanvas.frame.size.height/2)-(resultImg.size.height/2)+self.contentView.frame.origin.y, resultImg.size.width, resultImg.size.height)];
//    }
}

-(void)leftSideMenuButtonPressed:(id)sender{
    [self.delegate returnEditImage:self.bgImgPath];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)rightSideMenuButtonPressed:(id)sender{
    NSLog(@"%s", __func__);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"저장" message:@"저장하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         
                                                         UIGraphicsBeginImageContextWithOptions(self.contentView.bounds.size, NO, 0.0);
                                                         [self.imgCanvas.image drawAtPoint:CGPointMake(0, 0)];
                                                         [self.contentView drawViewHierarchyInRect:self.contentView.bounds afterScreenUpdates:NO];
                                                         
                                                         UIImage * drawImg = UIGraphicsGetImageFromCurrentImageContext();
                                                         drawImg = [self originScaledImage:drawImg originWidth:originWidth originHeight:originHeight];
                                                         
                                                         UIGraphicsEndImageContext();
                                                         
                                                         //앨범에 저장
                                                         //UIImageWriteToSavedPhotosAlbum(drawImg, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                                                         
                                                         //로컬에 저장
                                                         NSString *savePath = [NSString stringWithFormat:@"%@/%@/photo",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], appDelegate.comp_no];
                                                         NSString *fileName = [self createPhotoFileName];
                                                         NSData *imgData = UIImagePNGRepresentation(drawImg);
                                                         NSString *imgPath =[savePath stringByAppendingPathComponent:fileName];
                                                         NSLog(@"imgPath : %@", imgPath);
                                                         [imgData writeToFile:imgPath atomically:YES];
                                                         
                                                         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"저장" message:@"저장되었습니다." preferredStyle:UIAlertControllerStyleAlert];
                                                         UIAlertAction* okButton2 = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                                                           handler:^(UIAlertAction * action) {
                                                                                                               [self.delegate returnEditImage:imgPath];
                                                                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                               //로컬에 저장안하면 저장되었습니다 알림 다른데 띄워야함.
                                                                                                               [self dismissViewControllerAnimated:YES completion:nil];
                                                                                                           }];
                                                         
                                                         [alert addAction:okButton2];
                                                         [self presentViewController:alert animated:YES completion:nil];
                                                     }];
    [alert addAction:cancelButton];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"저장되었습니다." message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             NSLog(@"photo saved");
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             [self dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(NSString *)createPhotoFileName{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    NSString *filename = @"";
    filename = [filename stringByAppendingString:@"EDIT("];
    
    filename = [filename stringByAppendingString:currentTime];
    filename = [filename stringByAppendingString:@").jpg"];
    return filename;
}
/*
- (UIImage*)setResizeImage:(UIImage *)imageToResize onImageView:(UIImageView *)imageView {
    CGFloat oldWidth = imageToResize.size.width;
    CGFloat oldHeight = imageToResize.size.height;
    
    CGFloat scaleFactor=1;
    
    NSLog(@"oldWidth : %f, oldHeight : %f", oldWidth, oldHeight);
    NSLog(@"imageView Width : %f, imageView Height : %f", imageView.frame.size.width, imageView.frame.size.height);
    
    if(oldHeight/oldWidth>1.7){
        scaleFactor = imageView.frame.size.height / oldHeight;
    } else {
        scaleFactor = imageView.frame.size.width / oldWidth;
    }
    
//    if(oldWidth>oldHeight){
//        scaleFactor = imageView.frame.size.width / oldWidth;
//    } else {
//        scaleFactor = imageView.frame.size.height / oldHeight;
//    }
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [imageToResize drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
*/

- (UIImage*)setResizeImage:(UIImage *)image :(float)imgSize :(BOOL)isLandscape {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    if(isLandscape) scaleFactor = imgSize / oldWidth; //가로고정
    else scaleFactor = imgSize / oldHeight; //높이고정
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)originScaledImage:(UIImage *)image originWidth:(CGFloat)width originHeight:(CGFloat)height {
    CGSize originSize = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContextWithOptions(originSize, false, 0.0);
    [image drawInRect:CGRectMake(0, 0, originSize.width, originSize.height)];
    UIImage *originImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return originImage;
}

#pragma mark - ToolBar Item Action
- (IBAction)penClick:(id)sender {
    [toolRight1 setImage:[UIImage imageNamed:@"tool_pencil_over.png"] forState:UIControlStateNormal];
    [toolRight2 setImage:[UIImage imageNamed:@"tool_eraser.png"] forState:UIControlStateNormal];
    
    [(MainDrawView *)self.canvasView setCurType:PEN];
}

- (IBAction)eraserClick:(id)sender {
    [toolRight1 setImage:[UIImage imageNamed:@"tool_pencil.png"] forState:UIControlStateNormal];
    [toolRight2 setImage:[UIImage imageNamed:@"tool_eraser_over.png"] forState:UIControlStateNormal];
    
    //canvasView의 배경색을 clear로 해야 선이 지워짐.
    [(MainDrawView *)self.canvasView setCurType:ERASE];
}


- (IBAction)clearClick:(id)sender {
    [self.canvasView canvasClear];
}

@end
