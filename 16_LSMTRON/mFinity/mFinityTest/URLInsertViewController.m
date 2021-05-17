//
//  URLInsertViewController.m
//  mFinity
//
//  Created by Park on 2013. 11. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "URLInsertViewController.h"
#import "LoginViewController.h"
#import "SVProgressHUD.h"
@interface URLInsertViewController ()

@end

@implementation URLInsertViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
BOOL isButton;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isHideKeyboard = YES;
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = screen.size.width;
    CGFloat screenHeight = screen.size.height;
    
    if (screenHeight/screenWidth <= 1.5) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *path = [prefs stringForKey:@"LoginImagePath"];
    NSData *decryptData = [[NSData dataWithContentsOfFile:path] AES256DecryptWithKey:appDelegate.AES256Key];
    
    guideLabel.text = NSLocalizedString(@"message150", @"");
    UIImage *bgImage = [UIImage imageWithData:decryptData];
    if (bgImage==nil) {
        _imageView.image = [UIImage imageNamed:@"login.png"];
    }else{
        _imageView.image = bgImage;
    }
    hostLabel.text = NSLocalizedString(@"message144", @"");
    portLabel.text = NSLocalizedString(@"message145", @"");
    nameLabel.text = NSLocalizedString(@"message151", @"");
    hostField.clearButtonMode = UITextFieldViewModeWhileEditing;
    portField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"NAVIFONTCOLOR"]];
    
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    if ([[prefs objectForKey:@"NAVIISSHADOW"] isEqualToString:@"Y"]) {
        label.shadowColor = [appDelegate myRGBfromHex:[prefs objectForKey:@"NAVISHADOWCOLOR"]];
        label.shadowOffset = CGSizeMake([[prefs objectForKey:@"NAVISHADOWOFFSET"] floatValue], [[prefs objectForKey:@"NAVISHADOWOFFSET"] floatValue]);
    }
    
    if (_isEdit) {
        label.text = @"접속정보수정";
        NSArray *arr = [_urlAddress componentsSeparatedByString:@"://"];
        hostField.text = [arr objectAtIndex:1];
        portField.text = _urlPort;
        nameField.text = _serverName;
    }else{
        if (_isAllRemove) {
            self.navigationController.navigationBarHidden = YES;
        }
        label.text = @"접속정보입력";
        //hostField.text = @"http://";
    }
    self.navigationItem.titleView = label;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark Action Event Handler
- (void)keyboardWillAnimate:(NSNotification *)notification{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    if ([notification name]==UIKeyboardWillShowNotification) {
        if(isHideKeyboard){
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 50, self.view.frame.size.width, self.view.frame.size.height)];
            isHideKeyboard = NO;
        }
    }else if([notification name]==UIKeyboardWillHideNotification){
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50,self.view.frame.size.width, self.view.frame.size.height)];
        isHideKeyboard = YES;
    }
    [UIView commitAnimations];
}
-(IBAction) backgroundTouch:(id)sender{
    [hostField resignFirstResponder];
    [portField resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:nameField]) {
        [hostField becomeFirstResponder];
    }else if ([textField isEqual:hostField]) {
        [portField becomeFirstResponder];
    }else {
        [portField resignFirstResponder];
        [self TestConnection];
    }
    return YES;
}
-(IBAction)TestConnection{
    [hostField resignFirstResponder];
    [portField resignFirstResponder];
    if (!isButton) {
        NSString *temp = hostField.text;
        NSString *mainUrl;
        if ([temp hasPrefix:@"http://"]||[temp hasPrefix:@"https://"]) {
            mainUrl = [NSString stringWithFormat:@"%@:%@",hostField.text,portField.text];
        }else{
            mainUrl = [NSString stringWithFormat:@"https://%@:%@",hostField.text,portField.text];
        }
        
        NSString *lastStr = [mainUrl substringFromIndex:[mainUrl length]-1];
        if([lastStr isEqualToString:@":"]){
            mainUrl = [mainUrl substringToIndex:[mainUrl length]-1];
        }
        
        NSLog(@"mainUrl : %@",mainUrl);
        NSString *urlString = [NSString stringWithFormat:@"%@/dataservice41",mainUrl];
        NSString *webServiceString = [urlString stringByAppendingString:@"/MLogout"];
        
        urlInfo = urlString;
        receiveData = [[NSMutableData alloc]init];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [SVProgressHUD show];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:webServiceString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        [urlRequest setHTTPMethod:@"POST"];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
        [conn start];
        
        isButton = YES;
    }
    
    
}
#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    if(statusCode == 404){
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        [connection cancel];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message146", @"") message:NSLocalizedString(@"message147", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    
    NSString *url = [NSString stringWithFormat:@"%@",connection.currentRequest.URL];
    if ([url hasPrefix:@"https"] && error.code == -1001) {
        NSString *temp = [url substringFromIndex:8];
        NSString *httpString = @"http://";
        httpString = [httpString stringByAppendingString:temp];
        NSString *lastComponent = [[NSString alloc]initWithFormat:@"/%@",[httpString lastPathComponent]];
        NSArray *arr = [httpString componentsSeparatedByString:lastComponent];
        urlInfo = arr[0];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:httpString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        [urlRequest setHTTPMethod:@"POST"];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
        [conn start];
        
    }else{
        [SVProgressHUD dismiss];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message56", @"") message:NSLocalizedString(@"message13", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message56", @"") otherButtonTitles: nil];
        [alertView show];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receiveData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
    
    NSString *returnString = [[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
    
    if ([returnString isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message146", @"") message:NSLocalizedString(@"message147", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"message148", @"") message:NSLocalizedString(@"message149", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles: nil];
        [alertView show];
    }
}
#pragma mark
#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    isButton = NO;
    
    if([alertView.title isEqualToString:NSLocalizedString(@"message148", @"")]){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:urlInfo forKey:@"URL_ADDRESS"];
        [prefs synchronize];
        NSLog(@"urlInfo : %@",urlInfo);
        NSLog(@"prefs : %@",[prefs objectForKey:@"URL_ADDRESS"]);
        appDelegate.main_url = urlInfo;
        LoginViewController *vc = [[LoginViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
