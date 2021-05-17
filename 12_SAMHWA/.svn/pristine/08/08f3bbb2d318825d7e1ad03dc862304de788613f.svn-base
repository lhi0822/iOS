//
//  LockInsertView.m
//  EzSmart
//
//  Created by mac on 11. 9. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LockInsertView.h"
#import "MFinityAppDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <dlfcn.h>
#import <mach/port.h>
#import <mach/kern_return.h>
#import "FBEncryptorAES.h"
@implementation LockInsertView

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int fontSize = 17;
    
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
	MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
	UIImage *bgImage = [UIImage imageWithData:decryptData];
	imageView.image = bgImage;
	UIColor *color = [appDelegate myRGBfromHex:appDelegate.subFontColor];
	[label1 setTextColor:color];
	[label2 setTextColor:color];
    [label3 setTextColor:color];
    label1.text = NSLocalizedString(@"message23", @"");
    label2.text = NSLocalizedString(@"message24", @"");
    label3.text = NSLocalizedString(@"message25", @"");
    [confirmBtn setTitle:NSLocalizedString(@"message51", @"확인") forState:UIControlStateNormal];
    [exitBtn setTitle:NSLocalizedString(@"message59", @"종료") forState:UIControlStateNormal];
    exitBtn.backgroundColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"LOGINONCOLOR"]];
    confirmBtn.backgroundColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"LOGINONCOLOR"]];
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
#pragma mark 
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	//NSInteger statusCode = [HTTPresponse statusCode];
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    if ([methodName isEqualToString:@"MLogout"]) {
        exit(0);
    }else if([methodName isEqualToString:@"MUnlockSession"]){
        
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *urlStr = connection.currentRequest.URL.absoluteString;
    NSArray *tempArr = [[urlStr lastPathComponent] componentsSeparatedByString:@"?"];
    NSString *methodName = [tempArr objectAtIndex:0];
    NSError *error;
    NSDictionary *dic;
    if ([methodName isEqualToString:@"MUnlockSession"]) {
        @try {
            NSString *encString =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSString *decString ;
            if (appDelegate.isAES256) {
                decString = [encString AES256DecryptWithKeyString:appDelegate.AES256Key];
            }
            else{
                decString = encString;
            }
            
            dic = [NSJSONSerialization JSONObjectWithData:[decString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            
        }
        @catch (NSException *exception) {
            NSLog(@"exception : %@",exception);
        }
        NSLog(@"dic : %@",dic);
        if ([[dic objectForKey:@"V0"]isEqualToString:@"True"]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
#pragma mark
#pragma mark Action Event Handler
- (IBAction) okButton {
	MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *dvcid = [MFinityAppDelegate getUUID];
    UIDevice *myDevice = [UIDevice currentDevice];
    NSString *osName = @"iOS";
    NSString *encodingID = [FBEncryptorAES encryptBase64String:appDelegate.user_id
                                                     keyString:appDelegate.AES256Key
                                                 separateLines:NO];
    
    NSString *encodingPWD = [FBEncryptorAES encryptBase64String:appDelegate.passWord
                                                      keyString:appDelegate.AES256Key
                                                  separateLines:NO];
    encodingID = [encodingID urlEncodeUsingEncoding:NSUTF8StringEncoding];
    encodingPWD = [encodingPWD urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString =[NSString stringWithFormat:@"%@/MUnlockSession",appDelegate.main_url];
    NSString *param;
    
    if (appDelegate.isAES256) {
        
        param = [[NSString alloc]initWithFormat:@"DEV_ID=%@&DEV_OS=%@&DEMO_FLAG=%@&CUSER_NO=%@&userId=%@&passwd=%@&COMP_NO=%@&PUSH_ID1=%@&PUSH_ID2=-&encType=AES256",dvcid,osName,appDelegate.noAuth,appDelegate.user_no,encodingID,encodingPWD,appDelegate.comp_no,appDelegate.appDeviceToken];
        
    }else{
        param = [[NSString alloc]initWithFormat:@"DEV_ID=%@&DEV_OS=%@&DEMO_FLAG=%@&CUSER_NO=%@&userId=%@&passwd=%@&COMP_NO=%@&PUSH_ID1=%@&PUSH_ID2=-",dvcid,osName,appDelegate.noAuth,appDelegate.user_no,encodingID,encodingPWD,appDelegate.comp_no,appDelegate.appDeviceToken];
    }
    
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
	if ([passWordField.text isEqualToString:appDelegate.passWord] ) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: postData];
        [request setTimeoutInterval:10.0];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        [conn start];
        //[self dismissViewControllerAnimated:YES completion:nil];
        
	}else {
		[passWordField resignFirstResponder];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message62", @"") message:NSLocalizedString(@"message63", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
		[alert show];
		
	}
    
}
- (IBAction) exitButton {
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/MLogout",appDelegate.main_url]]];
    [request setHTTPMethod:@"POST"];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [conn start];

	//exit(0);
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {

	if ([textField isEqual:passWordField]) {
		[passWordField resignFirstResponder];
		
	}
	return YES;
}
-(IBAction) textFieldDoneEditing:(id)sender{
	[sender resignFirstResponder];
	[self okButton];
}
#pragma mark
#pragma mark Lock Utils
#pragma mark



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/



@end
