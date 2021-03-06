//
//  SignPadViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 3. 19..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "SignPadViewController.h"
#import "MFinityAppDelegate.h"
#import "WebViewController.h"
#import "CustomSegmentedControl.h"
@interface SignPadViewController ()

@end

@implementation SignPadViewController

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
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
        self.navigationController.navigationBar.barTintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    }
    UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    _label.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    _label.text = @"Sign Pad";
    _label.font = [UIFont boldSystemFontOfSize:18.0];
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.subIsShadow isEqualToString:@"Y"]) {
        _label.shadowOffset = CGSizeMake([appDelegate.subShadowOffset floatValue], [appDelegate.subShadowOffset floatValue]);
        _label.shadowColor = [appDelegate myRGBfromHex:appDelegate.subShadowColor];
    }
    //self.navigationItem.titleView = _label;
    
    drawScreen=[[MFLineDrawView alloc]initWithFrame:CGRectMake(0, 0, 320,480)];
    [drawScreen setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:drawScreen];
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    CustomSegmentedControl *button;
    button= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Clear",nil]
                                                offColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                 onColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                            offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                             onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                fontSize:12];
    button.momentary = YES;
    [button addTarget:self action:@selector(clearButtonClick) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=left;
    CustomSegmentedControl *button2;
    button2= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Cancel",nil]
                                                 offColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                  onColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                             offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                              onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                 fontSize:12];
    button2.momentary = YES;
    [button2 addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button2];
    self.navigationItem.rightBarButtonItem=right;
    
    CustomSegmentedControl *button3;
    button3= [[CustomSegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Save",nil]
                                                 offColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                  onColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                             offTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                              onTextColor:[appDelegate myRGBfromHex:appDelegate.mainFontColor]
                                                 fontSize:12];
    button3.momentary = YES;
    button3.frame = CGRectMake((320/2)-(button3.frame.size.width/2), 22-(button3.frame.size.height/2), button3.frame.size.width, button3.frame.size.height);
    [button3 addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventValueChanged];
    //UIBarButtonItem *center = [[UIBarButtonItem alloc] initWithCustomView:button2];
    
    [self.navigationController.navigationBar addSubview:button3];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)clearButtonClick{
    //NSLog(@"centerButtonClick");
    [drawScreen.pathArray removeAllObjects];
    [drawScreen.myPath removeAllPoints];
    [drawScreen setNeedsDisplay];
    //NSLog(@"drawScreen.pathArray : %@",drawScreen.pathArray);
    //NSLog(@"drawScreen.myPath : %@",drawScreen.myPath);
}
- (void)cancelButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveButtonClick{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [drawScreen.layer renderInContext:context];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(screenshot)];
    
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDate *today = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
	NSString *currentTime = [dateFormatter stringFromDate:today];
	
	NSString *filename = appDelegate.user_no;
	filename = [filename stringByAppendingString:@"("];
    
	filename = [filename stringByAppendingString:currentTime];
	filename = [filename stringByAppendingString:@")"];
    NSString *filename2 = [filename stringByAppendingFormat:@".thum"];
    filename = [filename stringByAppendingFormat:@".png"];
    
    NSString *saveFolder = [self getPhotoFilePath];
    NSString *saveSign = [saveFolder stringByAppendingFormat:@"/%@",filename];
    [imageData writeToFile:saveSign atomically:YES];
    UITabBarController *tabBarController = (UITabBarController *)self.presentingViewController;
    NSArray *arr = [tabBarController viewControllers];
    UINavigationController *naviController = [arr objectAtIndex:[tabBarController selectedIndex]];
    NSArray *arr2 =[naviController viewControllers];
    
    UIImage *thumImage = [self resizedImage:screenshot inRect:CGRectMake(0, 0, 60, 60)];
	NSData *thumData = [NSData dataWithData:UIImagePNGRepresentation(thumImage)];
    NSString *saveThum = [saveFolder stringByAppendingFormat:@"/%@",filename2];
    [thumData writeToFile:saveThum atomically:YES];
    NSLog(@"filename : %@ | filename2 : %@",filename,filename2);
    //NSArray *arr = [self.navigationController viewControllers];
    WebViewController *webView = [[naviController viewControllers] objectAtIndex:arr2.count-1];
    
    if (_userSpecific == nil) {
        [webView signSave:saveSign];
    }else{
        [webView signSave:saveSign :_userSpecific :_callbackFunc];
    }
    
    //self.presentingViewController
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(UIImage *) resizedImage:(UIImage *)img inRect:(CGRect)frameRect {
	UIGraphicsBeginImageContext(frameRect.size);
	[img drawInRect:frameRect];
	return UIGraphicsGetImageFromCurrentImageContext();
}

-(NSString *)getPhotoFilePath{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
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
@end
