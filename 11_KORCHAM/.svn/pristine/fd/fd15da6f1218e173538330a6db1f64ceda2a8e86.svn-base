//
//  MFSignPadViewController.m
//  kocham.consumer
//
//  Created by Jun HyungPark on 2016. 8. 23..
//  Copyright © 2016년 DBValley. All rights reserved.
//

#import "MFSignPadViewController.h"

@interface MFSignPadViewController ()

@end

@implementation MFSignPadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    drawScreen=[[MFLineDrawView alloc]initWithFrame:self.signView.frame];
    [drawScreen setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:drawScreen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)clearButtonClick:(id)sender{
    [drawScreen.pathArray removeAllObjects];
    [drawScreen.myPath removeAllPoints];
    [drawScreen setNeedsDisplay];
}
-(IBAction)saveButtonClick:(id)sender{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [drawScreen.layer renderInContext:context];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(screenshot)];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    
    NSString *filename = @"(";
    filename = [filename stringByAppendingString:currentTime];
    filename = [filename stringByAppendingString:@")"];
    NSString *filename2 = [filename stringByAppendingFormat:@".thum"];
    filename = [filename stringByAppendingFormat:@".png"];
    
    NSString *saveFolder = [self getPhotoFilePath];
    NSString *saveSign = [saveFolder stringByAppendingFormat:@"/%@",filename];
    [imageData writeToFile:saveSign atomically:YES];
    
    UIImage *thumImage = [self resizedImage:screenshot inRect:CGRectMake(0, 0, 60, 60)];
    NSData *thumData = [NSData dataWithData:UIImagePNGRepresentation(thumImage)];
    NSString *saveThum = [saveFolder stringByAppendingFormat:@"/%@",filename2];
    [thumData writeToFile:saveThum atomically:YES];
    NSLog(@"filename : %@ | filename2 : %@",filename,filename2);
    
    [self.delegate returnSignFilePath:saveSign];
    
    //[self dismissSemiModalView];
}

-(IBAction)cancelButtonClick:(id)sender{
    //[self dismissSemiModalView];
}

-(UIImage *) resizedImage:(UIImage *)img inRect:(CGRect)frameRect {
    UIGraphicsBeginImageContext(frameRect.size);
    [img drawInRect:frameRect];
    return UIGraphicsGetImageFromCurrentImageContext();
}

-(NSString *)getPhotoFilePath{
    
    NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *photoFolder = @"photo";
    NSString *saveFolder = [documentFolder stringByAppendingFormat:@"/%@",photoFolder];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL issue = [fileManager isReadableFileAtPath:saveFolder];
    if (issue) {
        NSLog(@"directory success");
    }else{
        NSLog(@"directory failed");
        [fileManager createDirectoryAtPath:saveFolder withIntermediateDirectories:FALSE attributes:nil error:nil];
    }
    return saveFolder;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
