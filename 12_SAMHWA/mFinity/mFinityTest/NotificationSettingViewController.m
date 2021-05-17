//
//  NotificationSettingViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "NotificationSettingViewController.h"
#import "MFinityAppDelegate.h"
@interface NotificationSettingViewController ()

@end

@implementation NotificationSettingViewController

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
    _tableView.sectionHeaderHeight = 30;
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
	_imageView.image = bgImage;
    //[self.navigationItem setTitle:NSLocalizedString(@"message32", @"")];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = NSLocalizedString(@"message32", @"");
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    }
    self.navigationItem.titleView = label;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) switchValueChanged:(id)sender {
    
    UISwitch *tmpSwitch = (UISwitch*)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (tmpSwitch.on) {
        [prefs setObject:@"YES" forKey:@"Update"];
    } else {
        [prefs setObject:@"NO" forKey:@"Update"];
    }
    [prefs synchronize];
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(section == 0){
		return 1;
	}else {
		return 2;
	}
    
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.textColor= [appDelegate myRGBfromHex:appDelegate.subFontColor];
    int fontSize = 17;
    int fontSize2 = 10;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    switch ([prefs integerForKey:@"FONT_SIZE"]) {
        case 1:
            fontSize = fontSize+5;
            fontSize2 = fontSize2+3;
            break;
        case 2:
            fontSize = fontSize+10;
            fontSize2 = fontSize2+5;
            break;
        default:
            break;
    }
	if([indexPath section]==0)
	{
        
        NSString *str = NSLocalizedString(@"message33", @"");
        cell.textLabel.text = str;
        cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        UISwitch *updateSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(screenWidth-100, 9, 50, 50)];
        if (![appDelegate.subFontColor isEqualToString:@"#FFFFFF"]) {
            [updateSwitch setOnTintColor:[appDelegate myRGBfromHex:appDelegate.subFontColor]];
        }
        //[updateSwitch setOnTintColor:[appDelegate myRGBfromHex:appDelegate.subFontColor]];
        
        if ( [[prefs stringForKey:@"Update"] isEqualToString:@"YES"]) {
            [updateSwitch setOn:YES];
        }else {
            [updateSwitch setOn:NO];
        }
        
        if ([prefs stringForKey:@"Update"]==nil) {
            [updateSwitch setOn:YES];
        }
        [updateSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:updateSwitch];
        
	}else if ([indexPath section]==1) {
        
        if(indexPath.row==0){
            cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
            cell.textLabel.text = NSLocalizedString(@"message34", @"");
        } else {
            cell.textLabel.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
            cell.textLabel.alpha = 0.7;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:fontSize2];
            cell.textLabel.numberOfLines=2;
            cell.textLabel.text = NSLocalizedString(@"message50", @"");
        }
	}
    // Configure the cell...
    //cell.textLabel.text = @"Info...!";

    cell.backgroundColor = [[UIColor alloc]initWithRed:0 green:0 blue:0 alpha:0.05];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

@end
