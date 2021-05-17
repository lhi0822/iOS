//
//  URLSettingViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 10. 30..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "URLSettingViewController.h"
#import "MFUtil.h"
#import "AppDelegate.h"

@interface URLSettingViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation URLSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBarHidden = YES;
    
    isHideKeyboard = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.dataSource=self;
    self.pickerView.delegate=self;
    self.compTextField.inputView = self.pickerView;
    
    self._toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 44)];
    self._button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(inputAccessoryViewDidFinish)];
    [self._toolBar setItems:[NSArray arrayWithObject: self._button] animated:NO];
    self.compTextField.inputAccessoryView = self._toolBar;
    
    self._button.title = NSLocalizedString(@"done", @"done");
    [self.pickerView selectRow:0 inComponent:0 animated:YES];
    
    self.urlTextField.placeholder = NSLocalizedString(@"URL(ex: gw.dbvalley.com)", @"");
    self.urlTextField.text = @"gw.dbvalley.com";
    self.urlTextField.keyboardType = UIKeyboardTypeURL;
    [self.urlTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    self.portTextField.placeholder = NSLocalizedString(@"(Default : 80)", @"");
    
    [self.textButton setTitle:NSLocalizedString(@"접속 테스트", @"") forState:UIControlStateNormal];
    [self.textButton addTarget:self action:@selector(connTestClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.saveButton setTitle:NSLocalizedString(@"접속정보 저장", @"") forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.compDic=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)connTestClick{
    if ([self.urlTextField.text isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"설정 오류", @"설정 오류") message:NSLocalizedString(@"URL을 적어주세요.", @"URL을 적어주세요.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        self.gwUrl = self.urlTextField.text;
        NSString *gwPort = self.portTextField.text;
        
        if (![[self.gwUrl substringToIndex:5]isEqualToString:@"http"]) {
            NSString *http = @"http://";
            self.gwUrl = [http stringByAppendingString:self.gwUrl];
        }
        if ([gwPort isEqualToString:@""]) {
            gwPort = @"80";
        }
        
        NSString *urlString = [NSString stringWithFormat:@"%@/m/main/?event=get_comp_array",self.gwUrl];
        NSURL *url = [NSURL URLWithString:urlString];
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:nil];
        session.delegate = self;
        if ([session start]) {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
    }
}

-(void)inputAccessoryViewDidFinish{
    self.compTextField.text = self.compNm;
    [self.compTextField resignFirstResponder];
}

-(void)saveClick{
    if(self.compNm!=nil&&![self.compTextField.text isEqualToString:@""]){
        [appDelegate.appPrefs setObject:self.compCode forKey:@"CPN_CODE"];
        [appDelegate.appPrefs synchronize];
        
        [self performSegueWithIdentifier:@"URL_TO_INTRO_PUSH" sender:self];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.compNm =[[self.compDic allValues] objectAtIndex:row];
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return self.compDic.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [[self.compDic allValues] objectAtIndex:row];
}

- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error {
    [SVProgressHUD dismiss];
    if (error==nil) {
        [appDelegate.appPrefs setObject:self.gwUrl forKey:@"URL"];
        [appDelegate.appPrefs synchronize];
        
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        filePath = [filePath stringByAppendingString:@"/compInfo.plist"];
        [session.returnDictionary writeToFile:filePath atomically:YES];
        
        self.compDic = session.returnDictionary;
        
        NSArray *allValues = [self.compDic allValues];
        NSArray *allKeys = [self.compDic allKeys];
        for (int i=0; i<[allValues count]; i++) {
            if ([self.compNm isEqualToString:[allValues objectAtIndex:i]]) {
                self.compCode = [allKeys objectAtIndex:i];
                //NSLog(@"self.compCode : %@", self.compCode);
            }
        }
        
        if(self.compDic.count==1) {
            self.compCode = [allKeys objectAtIndex:0];
            self.compNm = [allValues objectAtIndex:0];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"테스트 성공", @"테스트 성공") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];

    }else{
        if([[NSString stringWithFormat:@"%@", error] rangeOfString:@"Code=-1003"].location != NSNotFound){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"정보가 올바르지 않습니다.", @"정보가 올바르지 않습니다.") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:NSLocalizedString(@"exception_msg_unknownhostexception", @"exception_msg_unknownhostexception") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
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
- (void)_removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


@end
