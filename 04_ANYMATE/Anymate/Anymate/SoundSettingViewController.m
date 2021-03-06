//
//  SoundSettingViewController.m
//  Anymate
//
//  Created by Jun HyungPark on 2015. 4. 23..
//  Copyright (c) 2015년 Kyeong In Park. All rights reserved.
//

#import "SoundSettingViewController.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundSettingViewController ()

@end

@implementation SoundSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBar.topItem.title = @"알림음 설정";
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *soundId = @"";
    switch ([prefs integerForKey:@"SOUND_NUMBER"]) {
        case 0:
            soundId = @"anymate";
            break;
        case 1:
            soundId = @"default";
        default:
            break;
    }
    NSString *_urlString = [NSString stringWithFormat:@"%@/m/main/?event=set_sound&token=%@&sound_id=%@",[prefs objectForKey:@"URL"],appDelegate.fcmToken,soundId];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_urlString]];
    NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [urlConnection start];
    if (urlConnection) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}
#pragma mark
#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSString *errorMessage = [error localizedDescription];
    NSLog(@"error url : %@",connection.currentRequest.URL);
    NSLog(@"%s error : %@",__FUNCTION__,error);
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"에러" message:errorMessage delegate:self
                                        cancelButtonTitle:@"확인" otherButtonTitles:nil];
    [alert show];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [HTTPresponse statusCode];
    
    if (statusCode==404||statusCode==500) {
        NSString *errorMessage = [NSString stringWithFormat:@"%ld\n서버 에러입니다.",(long)statusCode];
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"에러" message:errorMessage delegate:self
                                            cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [alert show];
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"connectionDidFinishLoading");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
#pragma mark
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.textLabel.text = @"Anymate 알림음";
            break;
        
        case 1:
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.textLabel.text = @"기본 알림음";
            break;
        
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (indexPath.row == [prefs integerForKey:@"SOUND_NUMBER"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    for (id algoPath in [tableView indexPathsForVisibleRows]){
        UITableViewCell *tmpCell = [tableView cellForRowAtIndexPath:algoPath];
        tmpCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSString *soundPath=nil;
    SystemSoundID SoundID;
    if(indexPath.row==0){
        soundPath = [[NSBundle mainBundle] pathForResource:@"anymate" ofType:@"caf"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &SoundID);
        AudioServicesPlayAlertSound(SoundID);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    } else if(indexPath.row==1){
        AudioServicesPlayAlertSound(1007);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:indexPath.row forKey:@"SOUND_NUMBER"];
    [prefs synchronize];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
