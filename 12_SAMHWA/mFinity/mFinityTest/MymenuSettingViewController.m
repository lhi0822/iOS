//
//  MymenuSettingViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "MymenuSettingViewController.h"
#import "MFinityAppDelegate.h"
#import "MenuSettingViewCell.h"
#import "LoginViewController.h"
@interface MymenuSettingViewController ()

@end

@implementation MymenuSettingViewController

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
    paramValue = @"";
	menu_name =@"";
	MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = NSLocalizedString(@"message43", @"");
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.subIsShadow isEqualToString:@"Y"]) {
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    } self.navigationItem.titleView = label;
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
	imageView.image = bgImage;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBtnClick)];
    
    
    NSString *urlString;
    NSString *param;
    if (appDelegate.isAES256) {
        urlString = [[NSString alloc] initWithFormat:@"%@/MENU_LIST",appDelegate.main_url];
        param = [[NSString alloc]initWithFormat:@"cuser_no=%@&devOs=I&devTy=P&returnType=JSON&encType=AES256",appDelegate.user_no];
    }else{
        urlString = [[NSString alloc] initWithFormat:@"%@/MENU_LIST",appDelegate.main_url];
        param = [[NSString alloc]initWithFormat:@"cuser_no=%@&devOs=I&devTy=P&returnType=JSON",appDelegate.user_no];
        
    }
    
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:10.0];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
	if(urlConnection){
		receiveData = [[NSMutableData alloc] init];
	}else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
	urlKind = @"1";
    myTableView.rowHeight = 50;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark Action Event Handler
- (void)rightBtnClick{
    for (int index = 0; index < [menuCheckDictionary count]; index++) {
		if ([[menuCheckDictionary objectForKey:[NSString stringWithFormat:@"%d",index]] isEqualToString:@"TRUE"]) {
			paramValue = [NSString stringWithFormat:@"%@%@,",paramValue,[menuNoDictionary objectForKey:[NSString stringWithFormat:@"%d",index]]];
		}
	}
	
	menuRegDictionary = [[NSMutableDictionary alloc] init];
	
	if ([paramValue length] > 0) {
		paramValue = [paramValue substringToIndex:[paramValue length] - 1];
	}
	
	MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSString *urlString;
    NSString *param;
	if (appDelegate.isAES256) {
        urlString = [[NSString alloc] initWithFormat:@"%@/MY_MENU_REG",appDelegate.main_url];
	    param = [[NSString alloc] initWithFormat:@"cuser_no=%@&menu_no=%@&returnType=JSON&encType=AES256",appDelegate.user_no, paramValue];
    }else{
        urlString = [[NSString alloc] initWithFormat:@"%@/MY_MENU_REG",appDelegate.main_url];
	    param = [[NSString alloc] initWithFormat:@"cuser_no=%@&menu_no=%@&returnType=JSON",appDelegate.user_no, paramValue];
	    
    }
	urlKind = @"2";
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: postData];
    [request setTimeoutInterval:10.0];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    if(urlConnection){
		receiveData = [[NSMutableData alloc] init];
	}else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	}
	
	paramValue = @"";
}

-(void) switchValueChanged:(id)sender {
	
	UISwitch *tmpSwitch = (UISwitch*)sender;
	
	if (tmpSwitch.on) {
        [menuCheckDictionary setObject:@"TRUE" forKey:[NSString stringWithFormat:@"%d",[sender tag]]];
		//[col4 replaceObjectAtIndex:[sender tag] withObject:[NSString stringWithFormat:@"TRUE"]];
	} else {
        [menuCheckDictionary setObject:@"FALSE" forKey:[NSString stringWithFormat:@"%d",[sender tag]]];
		//[col4 replaceObjectAtIndex:[sender tag] withObject:[NSString stringWithFormat:@"FALSE"]];
	}
    
}
#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
	//[receiveData release];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
    [alertView show];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPresponse statusCode];
	
	if(statusCode == 404 || statusCode == 500){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
		[connection cancel];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message12", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
		
	}else{
		[receiveData setLength:0];
	}
	
	
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[receiveData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	//[self parserJsonData:receiveData];
    
    //if seed
	//[self parserJsonData:[MFinityAppDelegate getDecodeData:receiveData]];
    //if nomal
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *methodArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [methodArr objectAtIndex:0];
    if ([methodName isEqualToString:@"MY_MENU_REG"]) {
        [self parserJsonDataNotList:receiveData];
    }else{
        [self parserJsonData:receiveData];
    }
    
    
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}
#pragma mark
#pragma mark JSON Data Parsing
- (void)parserJsonDataNotList:(NSData *)data{
    NSError *error;
    NSDictionary *dic;
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    @try {
        // if AES256
        NSString *encString =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        
        dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        // if nomal
        //dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"error : %@",error);
        NSLog(@"exception : %@",exception);
    }
    
    if ([[dic objectForKey:@"V0"]isEqualToString:@"True"]) {
        menuRegDictionary = [[NSMutableDictionary alloc]initWithDictionary:dic];
        [self insertResult];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            
            //로그인화면으로 이동
            LoginViewController *lc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            lc.modalPresentationStyle = UIModalPresentationFullScreen;
            lc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [appDelegate.window setRootViewController:lc];
        }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)parserJsonData:(NSData *)data{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSError *error;
    NSDictionary *dic;
    @try {
        // if AES256
        NSString *encString =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString *decString ;
        if (appDelegate.isAES256) {
            decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
        }
        else{
            decString = encString;
        }
        
        dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        // if nomal
        //dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"error : %@",error);
        NSLog(@"exception : %@",exception);
    }
    
    if ([[[dic objectForKey:@"0"]objectForKey:@"V0"]isEqualToString:@"False"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message121", @"") message:NSLocalizedString(@"message127", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"message51", @"message51") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            
            //로그인화면으로 이동
            LoginViewController *lc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            lc.modalPresentationStyle = UIModalPresentationFullScreen;
            lc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [appDelegate.window setRootViewController:lc];
        }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        
        NSMutableDictionary *decrytDic = [[NSMutableDictionary alloc]init];
        for (int i=1; i<[[dic allKeys]count];i++) {
            NSDictionary *tempDic = [dic objectForKey:[NSString stringWithFormat:@"%d",i]];
            [decrytDic setObject:[MFinityAppDelegate getAllValueUrlDecoding:tempDic] forKey:[NSString stringWithFormat:@"%d",i]];
        }
        if ([urlKind isEqualToString:@"1"]) {
            menuCheckDictionary = [[NSMutableDictionary alloc]init];
            menuNameDictionary = [[NSMutableDictionary alloc]init];
            menuNoDictionary = [[NSMutableDictionary alloc]init];
            
            for (int i=0; i<[decrytDic count]; i++) {
                [menuNoDictionary setObject:[[decrytDic objectForKey:[NSString stringWithFormat:@"%d",i+1]] objectForKey:@"V1"] forKey:[NSString stringWithFormat:@"%d",i]];
                [menuNameDictionary setObject:[[decrytDic objectForKey:[NSString stringWithFormat:@"%d",i+1]] objectForKey:@"V2"] forKey:[NSString stringWithFormat:@"%d",i]];
                [menuCheckDictionary setObject:[[decrytDic objectForKey:[NSString stringWithFormat:@"%d",i+1]] objectForKey:@"V4"] forKey:[NSString stringWithFormat:@"%d",i]];
            }
        }else if([urlKind isEqualToString:@"2"]){
            //NSLog(@"dic : %@",dic);
            for (int i=1; i<[decrytDic count]; i++) {
                [menuRegDictionary setObject:[[decrytDic objectForKey:[NSString stringWithFormat:@"%d",i]] objectForKey:@"V1"] forKey:[NSString stringWithFormat:@"%d",i]];
            }
            [self insertResult];
        }
        
        [myTableView reloadData];
    }
    
}

#pragma mark
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [menuNoDictionary count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MenuSettingViewCell";
    
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    MenuSettingViewCell *cell = (MenuSettingViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"MenuSettingViewCell" owner:self options:nil];
		
		
		for (id currentObject in topLevelObject) {
			if ([currentObject isKindOfClass:[MenuSettingViewCell class]]) {
				cell = (MenuSettingViewCell *) currentObject;
				break;
			}
		}
		
    }
	
//    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, 9, 94, 31)];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth-70, 9, 94, 31)];
	//[mySwitch setAlternateColors:YES];
	mySwitch.tag = indexPath.row;
    if (![appDelegate.subFontColor isEqualToString:@"#FFFFFF"]) {
        [mySwitch setOnTintColor:[appDelegate myRGBfromHex:appDelegate.subFontColor]];
    }
	[mySwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
	if ([[menuCheckDictionary objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]] isEqualToString:@"TRUE"]) {
		[mySwitch setOn:YES];
	} else {
		[mySwitch setOn:NO];
	}
	
	[cell.contentView addSubview:mySwitch];
	
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
	cell.txtTitle.font = [UIFont systemFontOfSize:fontSize];
	cell.txtTitle.text = [menuNameDictionary objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
	cell.txtTitle.textColor = [appDelegate myRGBfromHex:appDelegate.subFontColor];
	return cell;
}

#pragma mark
#pragma mark MymenuSetting Utils
-(void) insertResult {
    
	if ([[menuRegDictionary objectForKey:@"V1"] isEqualToString:@"True"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message67", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message68", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
		
	}
}


@end
