//
//  NotificationSettingViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "NotificationSettingViewController.h"
#import "MFinityAppDelegate.h"
#import "NotificationSettingViewCell.h"

@interface NotificationSettingViewController (){
    MFinityAppDelegate *appDelegate;
    NSMutableArray *keyArr;
}

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

- (void)viewDidLoad{
    [super viewDidLoad];
    
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    _tableView.sectionHeaderHeight = 30;
    
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
	_imageView.image = bgImage;
    
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
    
    keyArr = [[NSMutableArray alloc] init];
    [keyArr addObject:NSLocalizedString(@"message33", @"")];
    [keyArr addObject:NSLocalizedString(@"message34", @"")];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) switchValueChanged:(id)sender {
    UISwitch *tmpSwitch = (UISwitch*)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *pushFlag;
    
    if (tmpSwitch.on) {
        if(tmpSwitch.tag == 100){
            [prefs setObject:@"YES" forKey:@"Update"];
            
        } else if(tmpSwitch.tag == 101){
            [prefs setObject:@"YES" forKey:@"PushNoti"];
            pushFlag = @"Y";
        }
        
    } else {
        if(tmpSwitch.tag == 100){
            [prefs setObject:@"NO" forKey:@"Update"];
            
        } else if(tmpSwitch.tag == 101){
            [prefs setObject:@"NO" forKey:@"PushNoti"];
            pushFlag = @"N";
        }
    }
    [prefs synchronize];

    if(tmpSwitch.tag == 101){
        //pushNoti 값 변경하는 웹서비스 호출
        NSString *urlString = [[NSString alloc] initWithFormat:@"%@/pushNotiUpdate",appDelegate.main_url];
        NSString *paramString = [[NSString alloc]initWithFormat:@"cuserno=%@&dvcid=%@&pushflag=%@",appDelegate.user_no, [MFinityAppDelegate getUUID], pushFlag];
        NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSLog(@"urlString : %@", urlString);
        NSLog(@"paramString : %@", paramString);

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: paramData];
        [request setTimeoutInterval:30.0];
        NSURLConnection *urlCon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [urlCon start];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	if(section == 0){
//		return 1;
//	}else {
//		return 2;
//	}
    return keyArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationSettingViewCell *cell = (NotificationSettingViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NotificationSettingViewCell"];
    if (cell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"NotificationSettingViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[NotificationSettingViewCell class]]) {
                cell = (NotificationSettingViewCell *) currentObject;
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    
    cell.txtLabel.textColor= [appDelegate myRGBfromHex:appDelegate.subFontColor];
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
    
    if (![appDelegate.subFontColor isEqualToString:@"#FFFFFF"]) {
        [cell.valueSwitch setOnTintColor:[appDelegate myRGBfromHex:appDelegate.subFontColor]];
    }
    
    cell.txtLabel.font = [UIFont systemFontOfSize:fontSize];
    cell.txtLabel.text = [keyArr objectAtIndex:indexPath.row];
    cell.valueSwitch.tag = 100 + indexPath.row;
    
    if(indexPath.row==0) {
        if ([prefs stringForKey:@"Update"]==nil || [[prefs stringForKey:@"Update"] isEqualToString:@"YES"]) {
            [cell.valueSwitch setOn:YES];
        }else {
            [cell.valueSwitch setOn:NO];
        }
        
    }else if (indexPath.row==1) {
        if ([prefs stringForKey:@"PushNoti"]==nil || [[prefs stringForKey:@"PushNoti"] isEqualToString:@"YES"]) {
            [cell.valueSwitch setOn:YES];
        }else {
            [cell.valueSwitch setOn:NO];
        }
    }
    
    [cell.valueSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    /*
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
    
	if([indexPath section]==0) {
        NSString *str = NSLocalizedString(@"message33", @"");
        cell.textLabel.text = str;
        cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
        
        UISwitch *updateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-15, 9, 50, 50)];
        if (![appDelegate.subFontColor isEqualToString:@"#FFFFFF"]) {
            [updateSwitch setOnTintColor:[appDelegate myRGBfromHex:appDelegate.subFontColor]];
        }
        
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
     */
    
    cell.backgroundColor = [[UIColor alloc]initWithRed:0 green:0 blue:0 alpha:0.05];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    NSLog(@"error : %@",error);
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
//    NSLog(@"statusCode : %ld", (long)statusCode);
    
    if(statusCode == 404 || statusCode == 500){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [connection cancel];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{

}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

@end
