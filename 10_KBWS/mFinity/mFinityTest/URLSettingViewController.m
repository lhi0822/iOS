//
//  URLSettingViewController.m
//  mFinity
//
//  Created by Park on 2014. 2. 4..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import "URLSettingViewController.h"
#import "MFinityAppDelegate.h"
#import "URLInsertViewController.h"

@interface URLSettingViewController (){
    MFinityAppDelegate *appDelegate;
    NSString *urlString;
    BOOL viewPushed;
}

@end

@implementation URLSettingViewController

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
    self.navigationController.navigationBarHidden = NO;
    
    CGRect screen = [[UIScreen mainScreen]bounds];
	CGFloat screenWidth = screen.size.width;
	CGFloat screenHeight = screen.size.height;
    
    if (screenHeight/screenWidth <= 1.5) {
        EditButton.frame = CGRectMake(EditButton.frame.origin.x, EditButton.frame.origin.y+20
                                      , EditButton.frame.size.width, EditButton.frame.size.height);
        DelButton.frame = CGRectMake(DelButton.frame.origin.x, DelButton.frame.origin.y+20
                                     , DelButton.frame.size.width, DelButton.frame.size.height);
        CreateButton.frame = CGRectMake(CreateButton.frame.origin.x, CreateButton.frame.origin.y+20
                                        , CreateButton.frame.size.width, CreateButton.frame.size.height);
        EditLabel.frame = CGRectMake(EditLabel.frame.origin.x, EditLabel.frame.origin.y+20
                                     , EditLabel.frame.size.width, EditLabel.frame.size.height);
        DelLabel.frame = CGRectMake(DelLabel.frame.origin.x, DelLabel.frame.origin.y+20
                                    , DelLabel.frame.size.width, DelLabel.frame.size.height);
        CreateLabel.frame = CGRectMake(CreateLabel.frame.origin.x, CreateLabel.frame.origin.y+20
                                       , CreateLabel.frame.size.width, CreateLabel.frame.size.height);
    }
    
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    //MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *path = [prefs stringForKey:@"LoginImagePath"];
    NSData *decryptData = [[NSData dataWithContentsOfFile:path] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    //UIImage *bgImage = [UIImage imageWithContentsOfFile:path];
    
    [self.navigationItem.backBarButtonItem setAction:@selector(backButtonClick)];
    if (bgImage==nil) {
        _imageView.image = [UIImage imageNamed:@"bg.png"];
    }else{
        _imageView.image = bgImage;
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"NAVIFONTCOLOR"]];
    label.text = @"접속정보설정";
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    if ([[prefs objectForKey:@"NAVIISSHADOW"] isEqualToString:@"Y"]) {
        label.shadowColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"NAVISHADOWCOLOR"]];
        label.shadowOffset = CGSizeMake([[prefs objectForKey:@"NAVISHADOWOFFSET"] floatValue], [[prefs objectForKey:@"NAVISHADOWOFFSET"] floatValue]);
    }
    self.navigationItem.titleView = label;
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    UIBarButtonItem *left;
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(backEvent:)];
        
    }else{
        
        left = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(backEvent:)];
    }
    
    self.navigationItem.backBarButtonItem = left;
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingFormat:@"/URLConnectionInfo.plist"];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager isReadableFileAtPath:filePath]) {
        //NSLog(@"info file exist");
        NSPropertyListFormat format;
        fileDic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
    }else{
        //NSLog(@"info file not exist");
        
    }
    
    nameList = [NSMutableArray arrayWithArray:[fileDic allKeys]];
    if ([prefs objectForKey:@"URL_NAME"]==nil) {
        NSString *str = [nameList objectAtIndex:0];
        _label.text = str;
        _label.text =[fileDic objectForKey:str];
        [_pickerView selectRow:0 inComponent:0 animated:YES];
    }else{
        _keyName = [prefs objectForKey:@"URL_NAME"];
        _label.text =[fileDic objectForKey:_keyName];
        int row = [nameList indexOfObject:_keyName];
        [_pickerView selectRow:row inComponent:0 animated:YES];
    }
    if ([prefs objectForKey:@"NAVIBARCOLOR"]==nil) {
        _pickerView.backgroundColor = [UIColor whiteColor];
    }else{
        _pickerView.backgroundColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"NAVIBARCOLOR"]];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (viewPushed) {
        viewPushed = NO;
    } else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if (![[prefs objectForKey:@"URL_NAME"]isEqualToString:_keyName]) {
            [prefs setObject:_keyName forKey:@"URL_NAME"];
            [prefs synchronize];
            appDelegate.changeURL = YES;
            //[self removeData];
        }
        appDelegate.main_url = [NSString stringWithFormat:@"%@/dataservice41", _label.text];
    }
}
-(void)removeData{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"URL_INFO"];
    [prefs removeObjectForKey:@"UserInfo_ID"];
    [prefs removeObjectForKey:@"isSave"];
    [prefs removeObjectForKey:@"Update"];
    [prefs removeObjectForKey:@"startTabNumber"];
    [prefs removeObjectForKey:@"AutoLogin_ID"];
    [prefs removeObjectForKey:@"AutoLogin_PWD"];
    [prefs removeObjectForKey:@"isAutoLogin"];
    [prefs removeObjectForKey:@"AUTO_LOGIN_DATE"];
    [prefs synchronize];
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [arrayPaths objectAtIndex:0];
    NSFileManager *manager =[NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
    //NSLog(@"fileList : %@",fileList);
    for (int i=0; i<[fileList count]; i++) {
        NSString *str = [fileList objectAtIndex:i];
        NSString *fileName = [docDir stringByAppendingPathComponent:str];
        //NSLog(@"fileName : %@",fileName);
        if (![[fileName lastPathComponent] isEqualToString:@"URLConnectionInfo.plist"]) {
          [manager removeItemAtPath:fileName error:NULL];
        }
    }
    //NSLog(@"[manager contentsOfDirectoryAtPath:docDir error:NO]; : %@",[manager contentsOfDirectoryAtPath:docDir error:NO]);
    NSString *LibraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    LibraryPath = [LibraryPath stringByAppendingPathComponent:@"Application Support"];
    LibraryPath = [LibraryPath stringByAppendingPathComponent:@"oracle"];
    NSString *filePath = LibraryPath;
    if ([manager isReadableFileAtPath:filePath]) {
        [manager removeItemAtPath:filePath error:nil];
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingFormat:@"/URLConnectionInfo.plist"];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager isReadableFileAtPath:filePath]) {
        //NSLog(@"info file exist");
        NSPropertyListFormat format;
        fileDic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
    }else{
        //NSLog(@"info file not exist");
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    nameList = [NSMutableArray arrayWithArray:[fileDic allKeys]];
    [_pickerView reloadAllComponents];
    if ([prefs objectForKey:@"URL_NAME"]==nil) {
        NSString *str = [nameList objectAtIndex:0];
        _label.text = str;
        _label.text =[fileDic objectForKey:str];
        [_pickerView selectRow:0 inComponent:0 animated:YES];
    }else{
        _keyName = [prefs objectForKey:@"URL_NAME"];
        _label.text =[fileDic objectForKey:_keyName];
        int row = [nameList indexOfObject:_keyName];
        [_pickerView selectRow:row inComponent:0 animated:YES];
    }
}
#pragma mark
#pragma mark PickerView Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [nameList count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [nameList objectAtIndex:row];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _label.text = [fileDic objectForKey:[nameList objectAtIndex:row]];
    _keyName = [nameList objectAtIndex:row];
    /*
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_keyName forKey:@"URL_NAME"];
    [prefs synchronize];
     */
    
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* nameLabel = (UILabel*)view;
    if (!nameLabel){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        nameLabel = [[UILabel alloc] init];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:30.0f]];
        nameLabel.textColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"NAVIFONTCOLOR"]];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.text = [nameList objectAtIndex:row];
        //nameLabel.backgroundColor = [UIColor blackColor];
    
    }
    // Fill the label text here
    
    return nameLabel;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 60;
}
#pragma mark
#pragma mark IBAction Method
-(IBAction)Edit:(id)sender{

    URLInsertViewController *vc = [[URLInsertViewController alloc]init];
    vc.isEdit = YES;
    vc.serverName = _keyName;
    NSString *fullUrl = _label.text;
    NSArray *tmp = [fullUrl componentsSeparatedByString:@":"];
    vc.urlAddress = [NSString stringWithFormat:@"%@:%@",tmp[0],tmp[1]];
    vc.urlPort = tmp[2];

    [self.navigationController pushViewController:vc animated:YES];
    viewPushed = YES;
    UIButton *button = (UIButton *)sender;
    button.alpha = 0.3;
}
-(IBAction)Edit2:(id)sender{
    UIButton *button = (UIButton *)sender;
    button.alpha = 0.7;
}
-(IBAction)Edit3:(id)sender{
    UIButton *button = (UIButton *)sender;
    button.alpha = 0.3;
}
-(IBAction)Del:(id)sender{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingFormat:@"/URLConnectionInfo.plist"];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableDictionary *dic;
    if ([manager isReadableFileAtPath:filePath]) {
        //NSLog(@"info file exist");
        NSPropertyListFormat format;
        dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
    }else{
        //NSLog(@"info file not exist");
    }
    if ([dic count]!=1) {
        [dic removeObjectForKey:_keyName];
        [dic writeToFile:filePath atomically:YES];
        [nameList removeObject:_keyName];
        [_pickerView reloadAllComponents];
        /*
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[nameList objectAtIndex:0] forKey:@"URL_NAME"];
        [prefs synchronize];
         */
        _keyName =[nameList objectAtIndex:0];
        NSString *str = [nameList objectAtIndex:0];
        
        _label.text =[fileDic objectForKey:str];
        [_pickerView selectRow:0 inComponent:0 animated:YES];

    }else if ([dic count]==1){
        NSError *error;
        [manager removeItemAtPath:filePath error:&error];
        URLInsertViewController *vc = [[URLInsertViewController alloc]init];
        vc.isAllRemove = YES;
        [self.navigationController pushViewController:vc animated:YES];
        viewPushed = YES;
    }
    UIButton *button = (UIButton *)sender;
    button.alpha = 0.3;
    
}
-(IBAction)Del2:(id)sender{
    UIButton *button = (UIButton *)sender;
    button.alpha = 0.7;
}
-(IBAction)Del3:(id)sender{
    UIButton *button = (UIButton *)sender;
    button.alpha = 0.3;
}
-(IBAction)Create:(id)sender{
    URLInsertViewController *vc = [[URLInsertViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    viewPushed = YES;
    UIButton *button = (UIButton *)sender;
    button.alpha = 0.3;
}
-(IBAction)Create2:(id)sender{
    UIButton *button = (UIButton *)sender;
    button.alpha = 0.7;
}
-(IBAction)Create3:(id)sender{
    UIButton *button = (UIButton *)sender;
    button.alpha = 0.3;
}
#pragma mark
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
