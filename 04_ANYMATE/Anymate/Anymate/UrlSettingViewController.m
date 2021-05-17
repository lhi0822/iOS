//
//  SettingViewController.m
//  Anymate
//
//  Created by Kyeong In Park on 12. 12. 26..
//  Copyright (c) 2012년 Kyeong In Park. All rights reserved.
//

#import "UrlSettingViewController.h"
#import "AppDelegate.h"
@interface UrlSettingViewController ()

@end

@implementation UrlSettingViewController
@synthesize returnDic;
@synthesize gwUrl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"SettingView DidLoad");
    // Do any additional setup after loading the view from its nib.
    self.view.userInteractionEnabled = YES;
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"url_setting", @"url_setting");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:@"#19385b"]];
    urlField.keyboardType = UIKeyboardTypeURL;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    urlFieldRect = urlField.frame;
    portFieldRect = portField.frame;
    confirmRect = confirm.frame;
    cancelRect = cancel.frame;
    int offset;
    if ([appDelegate.model_nm isEqualToString:@"iPhone 5"]) {
        offset = 130;
    }else{
        offset = 90;
    }
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        urlField.frame = CGRectMake(urlField.frame.origin.x+offset
                                    , urlField.frame.origin.y, urlField.frame.size.width, urlField.frame.size.height);
        portField.frame = CGRectMake(portField.frame.origin.x+offset
                                     , portField.frame.origin.y, portField.frame.size.width, portField.frame.size.height);
        confirm.frame = CGRectMake(confirm.frame.origin.x+offset
                                   , confirm.frame.origin.y, confirm.frame.size.width, confirm.frame.size.height);
        cancel.frame = CGRectMake(cancel.frame.origin.x+offset
                                  , cancel.frame.origin.y, cancel.frame.size.width, cancel.frame.size.height);
        [logoView setFrame:CGRectMake(logoView.frame.origin.x+offset, logoView.frame.origin.y, logoView.frame.size.width, logoView.frame.size.height)];
        
    }
    confirm.backgroundColor = [appDelegate myRGBfromHex:@"2D4260"];
    cancel.backgroundColor = [appDelegate myRGBfromHex:@"2D4260"];
    imageView.image = [UIImage imageNamed:@"bg_login.png"];
}

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
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height)];
    }else if([notification name]==UIKeyboardWillHideNotification){

        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height)];
    }
    [UIView commitAnimations];
}

- (void)_removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(IBAction)endEditing:(id)sender{
    [urlField resignFirstResponder];
    [portField resignFirstResponder];
}
- (IBAction)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)confirm:(id)sender{
    
    if ([urlField.text isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"url_error_title", @"url_error_title") message:NSLocalizedString(@"url_error_null", @"url_error_null") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        self.gwUrl = urlField.text;
        NSString *gwPort = portField.text;
    
//        if (![[self.gwUrl substringToIndex:5] isEqualToString:@"http"]) {
//            NSString *http = @"http://";
//            self.gwUrl = [http stringByAppendingString:self.gwUrl];
//        }
//
//        if ([gwPort isEqualToString:@""]) {
//            gwPort = @"80";
//        }

        
        NSString *protocol = @"";
        if([self.gwUrl rangeOfString:@"http:/"].location != NSNotFound){
            if([gwPort isEqualToString:@""] || [gwPort isEqualToString:@"80"]){
                //port가 80일 경우 빼기
                
            } else {
                self.gwUrl = [self.gwUrl stringByAppendingString:[NSString stringWithFormat:@":%@", gwPort]];
            }

        } else if([self.gwUrl rangeOfString:@"https:/"].location != NSNotFound){
            if([gwPort isEqualToString:@""]){
                self.gwUrl = [self.gwUrl stringByAppendingString:@":443"];
                
            } else {
                self.gwUrl = [self.gwUrl stringByAppendingString:[NSString stringWithFormat:@":%@", gwPort]];
            }

        } else {
            //프로토콜이 없을 경우
            if([gwPort isEqualToString:@""] || [gwPort isEqualToString:@"80"]){
                //port가 80일 경우 빼기
                protocol = @"http://";
                self.gwUrl = [protocol stringByAppendingString:self.gwUrl];

            } else if([gwPort isEqualToString:@"443"]){
                protocol = @"https://";
                self.gwUrl = [protocol stringByAppendingString:[NSString stringWithFormat:@"%@:443", self.gwUrl]];
                
            } else {
                protocol = @"http://";
                self.gwUrl = [protocol stringByAppendingString:[NSString stringWithFormat:@"%@:%@", self.gwUrl, gwPort]];
            }
        }
        
        
        NSLog(@"self.gwURL : %@", self.gwUrl);
        
        NSString *urlString = [NSString stringWithFormat:@"%@/m/main/?event=get_comp_array",self.gwUrl];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request setTimeoutInterval:10.0];
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [urlConnection start];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%s error : %ld",__FUNCTION__,(long)error.code);
    if (error.code == -1003) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"error_msg1", @"error_msg1") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"error_msg2", @"error_msg2") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", @"ok") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"str : %@",str);
    NSError *error;
    self.returnDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.gwUrl forKey:@"URL"];
    [prefs synchronize];
    
    NSLog(@"self.returnDic : %@", self.returnDic);
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingString:@"/compInfo.plist"];
    [self.returnDic writeToFile:filePath atomically:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isSet = @"YES";
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int offset;
    if ([appDelegate.model_nm isEqualToString:@"iPhone 5"]) {
        offset = 130;
    }else{
        offset = 90;
    }
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [logoView setFrame:CGRectMake(logoView.frame.origin.x+offset, logoView.frame.origin.y, logoView.frame.size.width, logoView.frame.size.height)];
        urlField.frame = CGRectMake(urlFieldRect.origin.x+offset
                                    , urlField.frame.origin.y, urlField.frame.size.width, urlField.frame.size.height);
        portField.frame = CGRectMake(portFieldRect.origin.x+offset
                                     , portField.frame.origin.y, portField.frame.size.width, portField.frame.size.height);
        confirm.frame = CGRectMake(confirmRect.origin.x+offset
                                   , confirm.frame.origin.y, confirm.frame.size.width, confirm.frame.size.height);
        cancel.frame = CGRectMake(cancelRect.origin.x+offset
                                  , cancel.frame.origin.y, cancel.frame.size.width, cancel.frame.size.height);
        
    }else{
        [logoView setFrame:CGRectMake(logoView.frame.origin.x-offset, logoView.frame.origin.y, logoView.frame.size.width, logoView.frame.size.height)];
        urlField.frame = CGRectMake(urlFieldRect.origin.x
                                    , urlField.frame.origin.y, urlField.frame.size.width, urlField.frame.size.height);
        portField.frame = CGRectMake(portFieldRect.origin.x
                                     , portField.frame.origin.y, portField.frame.size.width, portField.frame.size.height);
        confirm.frame = CGRectMake(confirmRect.origin.x
                                   , confirm.frame.origin.y, confirm.frame.size.width, confirm.frame.size.height);
        cancel.frame = CGRectMake(cancelRect.origin.x
                                  , cancel.frame.origin.y, cancel.frame.size.width, cancel.frame.size.height);

    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotate{
    return YES;
}

- (void)dealloc {
    [urlField release];
    [portField release];
    [imageView release];
    [confirm release];
    [cancel release];
    [logoView release];
    [super dealloc];
}
@end
