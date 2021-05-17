//
//  MyMessageViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 6. 4..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "MyMessageViewController.h"
#import "RMQServerViewController.h"

@interface MyMessageViewController () {
    AppDelegate *appDelegate;
}

@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *minHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *maxHeightConstraint;

@end

@implementation MyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"fromSegue : %@", self.fromSegue);

    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChangeCustomRoomName:) name:@"noti_ChangeCustomRoomName" object:nil];
    
    NSArray *subViews = [self.navigationController.navigationBar subviews];
    
    for (UIView *subview in subViews) {
        NSString *viewName = [NSString stringWithFormat:@"%@",[subview class]];
        if ([viewName isEqualToString:@"UITextField"]) {
            [subview removeFromSuperview];
        }
    }
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"complete", @"complete")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(rightSideMenuButtonPressed:)];
    
    self.msgCount.hidden = YES;
    
    self.msgTextView.text = self.statusMsg;
    self.msgTextView.textContainer.maximumNumberOfLines = 0;
    self.msgTextView.fromSegue = self.fromSegue;
    self.msgTextView.pasteDelegate = self;
    
    
    if([self.fromSegue isEqualToString:@"BOARD_MSG_NAME"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"board_create_name", @"board_create_name")];
        self.label1.text = NSLocalizedString(@"board_create_name_null", @"board_create_name_null");
        
    } else if([self.fromSegue isEqualToString:@"BOARD_MSG_DESC"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"board_info_desc", @"board_info_desc")];
        self.label1.text = NSLocalizedString(@"board_create_desc_null", @"board_create_desc_null");
        
    } else if([self.fromSegue isEqualToString:@"MY_MSG_CHANGE_PUSH"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"myinfo_status", @"myinfo_status")];
        self.label1.text = NSLocalizedString(@"myinfo_status_null", @"myinfo_status_null");
        
    } else if([self.fromSegue isEqualToString:@"CHAT_SET_ROOM_NAME_MODAL"]){
        self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"chat_change_room_name", @"chat_change_room_name")];
        self.label1.text = NSLocalizedString(@"change_chat_room_name_null", @"change_chat_room_name_null");
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(leftSideMenuButtonPressed:)];
        
    }else {
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)noti_ChangeProfilePush:(NSNotification *)notification {
    NSLog();
    NSArray *dataSet = [notification.userInfo objectForKey:@"DATASET"];
    NSString *profileMsg = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"PROFILE_MSG"]];
    self.msgTextView.text = profileMsg;
}

- (void)noti_ChangeCustomRoomName:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *result = [userInfo objectForKey:@"RESULT"];
    if([result isEqualToString:@"SUCCESS"]){
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"change_chat_room_failed", @"change_chat_room_failed") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self callWebService];
}

- (void)callWebService{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
    NSString *compNo = [appDelegate.appPrefs objectForKey:@"COMP_NO"];
    
    NSString *msg = [self.msgTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    msg = [MFUtil replaceEncodeToChar:msg];
    
    if([self.fromSegue isEqualToString:@"BOARD_MSG_NAME"]){
        if(msg!=nil&&![msg isEqualToString:@""]){
            NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"NAME",@"TYPE", msg,@"SNS_NAME", nil];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeSubInfo1" object:nil userInfo:dic];
            
        } else {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"board_create_name_null", @"board_create_name_null") preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
            });
        }
        
    } else if([self.fromSegue isEqualToString:@"BOARD_MSG_DESC"]){
        if(msg==nil&&[msg isEqualToString:@""]){
            msg = @"";
        }
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"DESC",@"TYPE", msg,@"SNS_DESC", nil];
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_ChangeSubInfo1" object:nil userInfo:dic];
        
    } else if([self.fromSegue isEqualToString:@"MY_MSG_CHANGE_PUSH"]){
        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&msg=%@&compNo=%@&dvcId=%@", userNo, msg, compNo, [appDelegate.appPrefs objectForKey:@"DVC_ID"]];
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:@"saveProfileMsg"]];
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        if ([session start]) {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
        
    } else if([self.fromSegue isEqualToString:@"CHAT_SET_ROOM_NAME_MODAL"]){
        [RMQServerViewController sendChangeRoomNamePush:self.msgTextView.text roomNo:self.changeRoomNo];
        
    } else {
        
    }
}

- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    if (error!=nil) {
        NSLog(@"error : %@",error);
    } else{
        [self.navigationController popViewControllerAnimated:YES];
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
    NSDictionary* info = [notification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (@available(iOS 11.0, *)) {
        kbSize.height = kbSize.height - self.view.safeAreaInsets.bottom;
    } else {
        kbSize.height = kbSize.height;
    }
    
    if ([notification name]==UIKeyboardWillShowNotification) {
        self.keyboardHeight.constant = kbSize.height;
        [self.view layoutIfNeeded];
        
    }else if([notification name]==UIKeyboardWillHideNotification){
        self.keyboardHeight.constant = 0;
        [self.view layoutIfNeeded];
    }
    [UIView commitAnimations];
}

-(void)textViewDidChange:(MFTextView *)textView{
    NSString *str = textView.text;
    if([str rangeOfString:@" "].location != NSNotFound) str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(str.length>0){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

-(void)textViewDidChangeSelection:(MFTextView *)textView{
    
}

-(BOOL)composerTextView:(MFTextView *)textView shouldPasteWithSender:(id)sender{
    return YES;
}

@end
