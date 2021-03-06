//
//  LongChatViewController.m
//  mfinity_sns
//
//  Created by hilee on 2018. 4. 5..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "LongChatViewController.h"
#import "MFUtil.h"
#import "MFDBHelper.h"

@interface LongChatViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation LongChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];

    self.navigationController.navigationBar.backgroundColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:NSLocalizedString(@"chat_long_text_view_all", @"chat_long_text_view_all")];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeModal:)];
    
    //self.textView.userInteractionEnabled = NO;
    self.textView.editable = NO;
    
    //로컬디비저장
    NSString *longContent = [appDelegate.dbHelper selectString:[appDelegate.dbHelper getContentLongChat:self.chatNo]];
    if(longContent!=nil&&![longContent isEqualToString:@""]){
        self.textView.text = longContent;
        
    } else {
        [self callWebService:@"getChatInfo"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)callWebService:(NSString *)serviceName{
    @try{
        //getChatInfo : usrNo, roomNo, chatNo
        
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl]; //appDelegate.main_url;
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
        NSString *paramString = nil;
        
        if([serviceName isEqualToString:@"getChatInfo"]){
            paramString = [NSString stringWithFormat:@"usrNo=%@&roomNo=%@&chatNo=%@&dvcId=%@", myUserNo, self.roomNo, self.chatNo, [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"DVCID"]]];
        }
        
        MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
        session.delegate = self;
        if ([session start]) {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSession Delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    if (error != nil) {
        
    }else{
        NSString *wsName = [[session.url absoluteString] lastPathComponent];
        NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
        if ([result isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"getChatInfo"]) {
                //로컬디비저장
                NSArray *dataSet = [session.returnDictionary objectForKey:@"DATASET"];
                NSString *content = [NSString urlDecodeString:[[dataSet objectAtIndex:0] objectForKey:@"CONTENT"]];
                
                NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                
                NSString *longContent = [dict objectForKey:@"VALUE"];
                self.textView.text = longContent;
                
                longContent = [longContent stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                NSString *sqlString = [appDelegate.dbHelper updateChatContent:longContent chatNo:self.chatNo];
                [appDelegate.dbHelper crudStatement:sqlString];
            }
        }else{
            NSString *errorMsg = [NSString stringWithFormat:@"%@\n%@",session.url,error];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:errorMsg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    [SVProgressHUD dismiss];
}

- (void)returnError:(MFURLSession *)session error:(NSError *)error{
    [SVProgressHUD dismiss];
    NSLog(@"error : %@", error);
    if(error.code == -1001){
        //요청한 시간이 초과되었습니다.
        [self callWebService:@"getChatInfo"];
    }
}

@end
