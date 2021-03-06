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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        //NSLog(@"%s : isMovingFromParentViewController",__FUNCTION__);
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    //2018.06 UI개선
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.view.backgroundColor = [appDelegate myRGBfromHex:[prefs stringForKey:@"TabBarColor"]];
    
    if([appDelegate.mainType isEqualToString:@"1"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            appDelegate.scrollView.hidden = YES;
            self.tabBarController.tabBar.hidden = NO;
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            appDelegate.scrollView.hidden = NO;
            self.tabBarController.tabBar.hidden = YES;
            
            [_imageView setFrame:CGRectMake(_tableView.frame.origin.x, appDelegate.scrollView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height)];
            [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, appDelegate.scrollView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height)];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"2"]){
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            appDelegate.scrollView.hidden = YES;
            self.tabBarController.tabBar.hidden = NO;
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            appDelegate.scrollView.hidden = NO;
            self.tabBarController.tabBar.hidden = YES;
            
            [_imageView setFrame:CGRectMake(_tableView.frame.origin.x, appDelegate.scrollView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height)];
            [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, appDelegate.scrollView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height)];
        }
        
    } else if([appDelegate.mainType isEqualToString:@"3"]){
        appDelegate.scrollView.hidden = NO;
        self.tabBarController.tabBar.hidden = YES;
        
        if([appDelegate.tabBarType isEqualToString:@"B"]){
            [_imageView setFrame:CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height)];
            
        } else if([appDelegate.tabBarType isEqualToString:@"T"]){
            [_imageView setFrame:CGRectMake(_tableView.frame.origin.x, appDelegate.scrollView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height)];
            [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, appDelegate.scrollView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height)];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = NSLocalizedString(@"message26", @"");
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    }self.navigationItem.titleView = label;
    
    NSData *decryptData2 = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData2];
    _imageView.image = bgImage;
    //[self.navigationItem setTitle:NSLocalizedString(@"message26", @"")];
    //_tableView.sectionHeaderHeight = 50;
    //_tableView.rowHeight = 50;

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
    return 7;
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
    cell.textLabel.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
    if([indexPath section]==0){
        cell.textLabel.text = @"Phone";
        
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
//        NSString *deviceId = [MFinityAppDelegate getUUID];
        NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
		NSString *showId = [deviceId substringFromIndex:deviceId.length-5];
        //NSLog(@"device id : %@",deviceId);
        //NSLog(@"show id : %@",showId);
        cell.textLabel.text = showId;
        
        [appDelegate loginHistoryToLogFile:[NSString stringWithFormat:@"%s //시스템정보 화면",__func__] result:nil];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnDvcId:)];
        [cell.textLabel setUserInteractionEnabled:YES];
        [cell.textLabel addGestureRecognizer:tap];
        
	}else if ([indexPath section]==6) {
		if (appDelegate.isOffLine) {
            cell.textLabel.text = @"Off-Line Mode";
        }else{
            cell.textLabel.text = @"On-Line Mode";
        }
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
        
	}else if (section==6){
		label.text = @"    On-Off Mode";
		return label;
        
    }else {
        return nil;
    }
	
}
#pragma mark
#pragma mark MFInfo Utils

- (void)tapOnDvcId:(UITapGestureRecognizer*)tap{
    NSLog(@"%s", __func__);
    
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;

        [mailCont setSubject:[NSString stringWithFormat:@"[삼호중공업] %@_Log", appDelegate.user_id]];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"hilee@dbvalley.com"]];
//        [mailCont setMessageBody:@"Don't ever want to give you up" isHTML:NO];
        
        NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *compFolder = [documentFolder stringByAppendingFormat:@"/hshi.mobile.ios.mfinity/10"];
        NSString *fileName = [NSString stringWithFormat:@"%@/SmartOne_Login.log", compFolder];
        NSLog(@"fileName : %@", fileName);
        
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:fileName];
        [mailCont addAttachmentData:data mimeType:@"log" fileName:fileName];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    
    } else {
        NSString *recipients = @"mailto:?cc=&subject=";
        NSString *body = @"&body=";
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email] options:@{} completionHandler:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"    App Type";
    }else if (section==1) {
		return @"    App Version";
	}else if(section==2) {
		return @"    OS Version";
	}else if (section==3) {
		return @"    Company";
    }else if (section==4) {
        return @"    Account";
	}else if (section==5) {
        return @"    Device Id";
	}else if (section==6){
		return @"    On-Off Mode";
    }else {
		return nil;
    }
}*/



@end
