//
//  InfoViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "MFInfoViewController.h"
#import "MFinityAppDelegate.h"
#import "UIDevice+IdentifierAddition.h"
#import <dlfcn.h>
@interface MFInfoViewController ()

@end

@implementation MFInfoViewController

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
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [UIColor whiteColor]; //[appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = NSLocalizedString(@"message26", @"");
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    }self.navigationItem.titleView = label;
    
    _imageView.backgroundColor = [appDelegate myRGBfromHex:appDelegate.cBgColor];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }else if(section == 1){
		return 2;
	}else {
        return 1;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    int fontSize = 17;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    switch ([prefs integerForKey:@"FONT_SIZE"]) {
        case 1:
            fontSize = fontSize+5;
            break;
        case 2:
            fontSize = fontSize+10;
            break;
        default:
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
    cell.textLabel.textColor = [appDelegate myRGBfromHex:appDelegate.cFontColor]; //[appDelegate myRGBfromHex:appDelegate.subFontColor];
    if([indexPath section]==0){
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) cell.textLabel.text = @"Tablet";
        else cell.textLabel.text = @"Phone";
            
    }else if([indexPath section]==1){
		
		if(indexPath.row==0){
			NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
			NSString *versionString = [NSString stringWithString:NSLocalizedString(@"message27", @"")];
            versionString = [versionString stringByAppendingString:@"\t:   "];
			versionString = [versionString stringByAppendingString:versionStr];
			cell.textLabel.text = versionString;
			
		}else {
			NSString *versionString = [NSString stringWithString:NSLocalizedString(@"message28", @"")];
            versionString = [versionString stringByAppendingString:@"\t:   "];
			versionString = [versionString stringByAppendingString:appDelegate.serverVersion];
            cell.textLabel.textColor = [UIColor blueColor];
			cell.textLabel.text = versionString;
			
		}
        
	}else if ([indexPath section]==2) {
		UIDevice *myDevice = [UIDevice currentDevice];
		NSString *osVersion = @"iOS";
		osVersion = [osVersion stringByAppendingString:@" "];
		osVersion = [osVersion stringByAppendingString:myDevice.systemVersion];
		cell.textLabel.text = osVersion;
	}else if ([indexPath section]==3) {
		cell.textLabel.text = appDelegate.comp_name;
	}else if([indexPath section]==4){
        cell.textLabel.text = appDelegate.user_id;
    }else if ([indexPath section]==5) {
        NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"]; //[MFinityAppDelegate getUUID];
		NSString *showId = [deviceId substringFromIndex:deviceId.length-5];
        cell.textLabel.text = showId;
	}
    
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UILabel *label = [[UILabel alloc]init];
	label.backgroundColor = [UIColor blackColor];
    label.alpha = 0.5;
    int fontSize = 17;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    switch ([prefs integerForKey:@"FONT_SIZE"]) {
        case 1:
            fontSize = fontSize+5;
            break;
        case 2:
            fontSize = fontSize+10;
            break;
        default:
            break;
    }
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = [UIColor whiteColor];
    if (section==0) {
        
		label.text = @"    App Type";
		return label;
    }else if (section==1) {
        
		label.text = @"    App Version";
		return label;
	}else if(section==2) {
        
		label.text = @"    OS Version";
		return label;
	}else if (section==3) {
        
		label.text = @"    Company";
		return label;
    }else if (section==4) {
        
        label.text = @"    Account";
        return label;
	}else if (section==5) {
        
        label.text = @"    Device Id";
        return label;
	}else {
        return nil;
    }
	
}
#pragma mark
#pragma mark MFInfo Utils



@end
