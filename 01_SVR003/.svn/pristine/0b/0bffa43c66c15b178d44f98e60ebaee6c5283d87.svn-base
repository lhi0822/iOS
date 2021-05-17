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
@interface SignPadViewController (){
    BOOL isDashLine;
}

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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [(MainDrawView *)self.canvasView setCurType:PEN];
    
    CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen]bounds].size.height;
    
    [self.canvasView setFrame:CGRectMake(10, 10, screenWidth-20, screenHeight/2)];
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
    
//    drawScreen = [[MFLineDrawView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,480)];
//    [drawScreen setBackgroundColor:[UIColor whiteColor]];
//    [self.view addSubview:drawScreen];
    
    isDashLine = NO;
    
    CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen]bounds].size.height;
    
    if(isDashLine){
        //점선긋기---------------------------------------------------------------
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setBounds:self.canvasView.bounds];
        [shapeLayer setPosition:self.canvasView.center];
        [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
        [shapeLayer setStrokeColor:[[UIColor lightGrayColor] CGColor]];
        [shapeLayer setLineWidth:1.0f];
        [shapeLayer setLineJoin:kCALineJoinRound];
        [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5],[NSNumber numberWithInt:5],nil]];
        
        CGMutablePathRef path = CGPathCreateMutable();
        //    CGPathMoveToPoint(path, NULL, self.view.frame.size.width/3+20, self.canvasView.frame.origin.y);
        //    CGPathAddLineToPoint(path, NULL, self.view.frame.size.width/3+20, self.canvasView.frame.size.height);
        CGPathMoveToPoint(path, NULL, screenWidth/3, 0);
        CGPathAddLineToPoint(path, NULL, screenWidth/3, screenHeight/2);
        [shapeLayer setPath:path];
        CGPathRelease(path);
        [self.canvasView.layer addSublayer:shapeLayer]; //view에 추가하면 저장 시 점선 안나옴, canvasView에 추가하면 저장 시 점선 포함
        
        CAShapeLayer *shapeLayer2 = [CAShapeLayer layer];
        [shapeLayer2 setBounds:self.canvasView.bounds];
        [shapeLayer2 setPosition:self.canvasView.center];
        [shapeLayer2 setFillColor:[[UIColor clearColor] CGColor]];
        [shapeLayer2 setStrokeColor:[[UIColor lightGrayColor] CGColor]];
        [shapeLayer2 setLineWidth:1.0f];
        [shapeLayer2 setLineJoin:kCALineJoinRound];
        [shapeLayer2 setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5],[NSNumber numberWithInt:5],nil]];
        
        CGMutablePathRef path2 = CGPathCreateMutable();
        //    CGPathMoveToPoint(path2, NULL, (self.view.frame.size.width/3+20)*2, self.canvasView.frame.origin.y);
        //    CGPathAddLineToPoint(path2, NULL, (self.view.frame.size.width/3+20)*2, self.canvasView.frame.size.height);
        CGPathMoveToPoint(path2, NULL, (screenWidth/3)*2, 0);
        CGPathAddLineToPoint(path2, NULL, (screenWidth/3)*2, screenHeight/2);
        [shapeLayer2 setPath:path2];
        CGPathRelease(path2);
        [self.canvasView.layer addSublayer:shapeLayer2];
        //점선긋기---------------------------------------------------------------
        
    }
    
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
    //button3.frame = CGRectMake((320/2)-(button3.frame.size.width/2), 22-(button3.frame.size.height/2), button3.frame.size.width, button3.frame.size.height);
    button3.frame = CGRectMake((screenWidth/2)-(button3.frame.size.width/2), 22-(button3.frame.size.height/2), button3.frame.size.width, button3.frame.size.height);
    [button3 addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventValueChanged];
    
    [self.navigationController.navigationBar addSubview:button3];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)clearButtonClick{
//    [drawScreen.pathArray removeAllObjects];
//    [drawScreen.myPath removeAllPoints];
//    [drawScreen setNeedsDisplay];
    
    [(MainDrawView *)self.canvasView canvasClear];
}
- (void)cancelButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveButtonClick{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [drawScreen.layer renderInContext:context];
    
    UIGraphicsBeginImageContextWithOptions(self.canvasView.bounds.size, NO, 0.0);
    [self.canvasView drawViewHierarchyInRect:self.canvasView.bounds afterScreenUpdates:NO];
    
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
