//
//  FontSettingViewController.m
//  mFinity
//
//  Created by Park on 2014. 4. 2..
//  Copyright (c) 2014년 Jun hyeong Park. All rights reserved.
//

#import "FontSettingViewController.h"
#import "MFinityAppDelegate.h"
@interface FontSettingViewController ()

@end

@implementation FontSettingViewController

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
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = NSLocalizedString(@"message154", @"");
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    }self.navigationItem.titleView = label;
    
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    NSData *lDecryptData = [[NSData dataWithContentsOfFile:appDelegate.lSubBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *lBgImage = [UIImage imageWithData:lDecryptData];
    
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    if ((interfaceOrientation == UIDeviceOrientationLandscapeLeft)||(interfaceOrientation == UIDeviceOrientationLandscapeRight)) {
        
        if (lBgImage==nil) {
            lBgImage = [UIImage imageNamed:@"w_default2.png"];
        }
        _imageView.image = lBgImage;
        
    }else{
        if (bgImage==nil) {
            bgImage = [UIImage imageNamed:@"default2.png"];
        }
        _imageView.image = bgImage;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIInterfaceOrientation toInterfaceOrientation = self.interfaceOrientation;
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft)||(toInterfaceOrientation == UIDeviceOrientationLandscapeRight)) {
        NSData *lDecryptData = [[NSData dataWithContentsOfFile:appDelegate.lSubBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
        UIImage *lBgImage = [UIImage imageWithData:lDecryptData];
        if (lBgImage==nil) {
            lBgImage = [UIImage imageNamed:@"w_default2.png"];
        }
        _imageView.image = lBgImage;
        
    }else{
        NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
        UIImage *bgImage = [UIImage imageWithData:decryptData];
        
        if (bgImage==nil) {
            bgImage = [UIImage imageNamed:@"default2.png"];
        }
        _imageView.image = bgImage;
        
    }
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft)||(toInterfaceOrientation == UIDeviceOrientationLandscapeRight)) {
        NSData *lDecryptData = [[NSData dataWithContentsOfFile:appDelegate.lSubBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
        UIImage *lBgImage = [UIImage imageWithData:lDecryptData];
        if (lBgImage==nil) {
            lBgImage = [UIImage imageNamed:@"w_default2.png"];
        }
        _imageView.image = lBgImage;
        
    }else{
        NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
        UIImage *bgImage = [UIImage imageWithData:decryptData];
        
        if (bgImage==nil) {
            bgImage = [UIImage imageNamed:@"default2.png"];
        }
        _imageView.image = bgImage;
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.textLabel.text = NSLocalizedString(@"message155", @"");
            break;
        case 1:
            cell.textLabel.font = [UIFont systemFontOfSize:22];
            cell.textLabel.text = NSLocalizedString(@"message156", @"");
            break;
        case 2:
            cell.textLabel.font = [UIFont systemFontOfSize:27];
            cell.textLabel.text = NSLocalizedString(@"message157", @"");
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (indexPath.row == [prefs integerForKey:@"FONT_SIZE"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    for (id algoPath in [tableView indexPathsForVisibleRows]){
        UITableViewCell *tmpCell = [tableView cellForRowAtIndexPath:algoPath];
        tmpCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:indexPath.row forKey:@"FONT_SIZE"];
    [prefs synchronize];
}
@end
