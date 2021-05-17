//
//  RemoveContentsViewController.m
//  mFinity
//
//  Created by Park on 13. 9. 10..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "RemoveContentsViewController.h"
#import "MFinityAppDelegate.h"
#import "UIViewController+KNSemiModal.h"
@interface RemoveContentsViewController (){
    NSMutableArray *deleteArray;
    NSString *deleteTitle;
}

@end

@implementation RemoveContentsViewController

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
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSLog(@"naviBarColor : %@",appDelegate.naviBarColor);
    [_toolBar setBarTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
    [_toolBar setTranslucent:NO];
    
    //_toolBar.barStyle = UIBarStyleDefault;
    //_toolBar.alpha = 1.0;
    //_toolBar.tintColor = [appDelegate myRGBfromHex:appDelegate.naviBarColor];
    //_toolBar.backgroundColor =[appDelegate myRGBfromHex:appDelegate.naviBarColor];
    _button2.title = NSLocalizedString(@"message52", @"취소");
    _button.title = NSLocalizedString(@"message51", @"확인");
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = NSLocalizedString(@"message38", @"");
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    }
    self.navigationItem.titleView = label;
    
    deleteArray = [[NSMutableArray alloc] init];
    //[deleteArray	addObject:NSLocalizedString(@"message39", @"")];
    
    //2018.06 UI개선
//    [deleteArray    addObject:NSLocalizedString(@"message40", @"")];
//    [deleteArray  addObject:NSLocalizedString(@"message41", @"")];
//    [deleteArray  addObject:NSLocalizedString(@"message116", @"")];
    [deleteArray	addObject:NSLocalizedString(@"message42", @"")];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark Action Event Handler
-(IBAction)cancel:(id)sender{
    [self dismissSemiModalView];
}
-(IBAction)remove:(id)sender{
    if (deleteTitle==nil) {
        //deleteTitle =NSLocalizedString(@"message40", @"");
        deleteTitle =NSLocalizedString(@"message42", @"");
    }
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:deleteTitle message:NSLocalizedString(@"message74", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""), nil];
    [alertView show];
}
-(IBAction) backgroundTouch:(id)sender{
    NSLog(@"backgroundTouch");
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark
#pragma mark UIPickerView Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	deleteTitle = [deleteArray objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
	return [deleteArray count];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [deleteArray objectAtIndex:row];
}
#pragma mark
#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:NSLocalizedString(@"message66", @"")]) {
        if (buttonIndex == 0) {
            exit(0);
        }else{
            [self dismissSemiModalView];
        }
    }else if(alertView.title==nil){
        
    }else{
        if(buttonIndex==0){
            if ([deleteTitle isEqualToString:NSLocalizedString(@"message39", @"")]) {
                NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [arrayPaths objectAtIndex:0];
                ////NSLog(@"docdir : %@",docDir);
                docDir = [docDir stringByAppendingPathComponent:@"icon/"];
                ////NSLog(@"current docdir : %@",docDir);
                NSFileManager *manager =[NSFileManager defaultManager];
                NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                ////NSLog(@"fileList : %@",fileList);
                for (int i=0; i<[fileList count]; i++) {
                    NSString *str = [fileList objectAtIndex:i];
                    str = [docDir stringByAppendingPathComponent:str];
                    ////NSLog(@"delete file : %@",str);
                    [manager removeItemAtPath:str error:NULL];
                    
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"message66", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
                [alert show];
                
            }else if([deleteTitle isEqualToString:NSLocalizedString(@"message40", @"")]){
                NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [arrayPaths objectAtIndex:0];
                docDir = [docDir stringByAppendingPathComponent:@"photo/"];
                ////NSLog(@"docDir : %@",docDir);
                NSFileManager *manager =[NSFileManager defaultManager];
                NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                ////NSLog(@"fileList : %@",fileList);
                for (int i=0; i<[fileList count]; i++) {
                    NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    ////NSLog(@"jpg fileName : %@",fileName);
                    [manager removeItemAtPath:fileName error:NULL];
                    
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"message66", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
                [alert show];
                
            }else if([deleteTitle isEqualToString:NSLocalizedString(@"message41", @"")]){
                NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [arrayPaths objectAtIndex:0];
                docDir = [docDir stringByAppendingPathComponent:@"video/"];
                
                NSFileManager *manager =[NSFileManager defaultManager];
                NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                
                for (int i=0; i<[fileList count]; i++) {
                    NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    [manager removeItemAtPath:fileName error:NULL];
                    
                }
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"message66", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
                [alert show];
                
            }else if([deleteTitle isEqualToString:NSLocalizedString(@"message42", @"모두 삭제")]){
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs removeObjectForKey:@"URL_ADDRESS"];
                [prefs removeObjectForKey:@"UserInfo_ID"];
                [prefs removeObjectForKey:@"isSave"];
                [prefs removeObjectForKey:@"Update"];
                [prefs removeObjectForKey:@"COMMON_DOWNLOAD"];
                [prefs removeObjectForKey:@"IntroCount"];
                [prefs removeObjectForKey:@"IntroImagePath"];
                [prefs removeObjectForKey:@"LOGINOFFCOLOR"];
                [prefs removeObjectForKey:@"LOGINONCOLOR"];
                [prefs removeObjectForKey:@"LoginImagePath"];
                [prefs removeObjectForKey:@"MAINFONTCOLOR"];
                [prefs removeObjectForKey:@"MainBgFilePath"];
                [prefs removeObjectForKey:@"NAVIBARCOLOR"];
                [prefs removeObjectForKey:@"NAVIFONTCOLOR"];
                [prefs removeObjectForKey:@"NAVIISSHADOW"];
                [prefs removeObjectForKey:@"NAVISHADOWCOLOR"];
                [prefs removeObjectForKey:@"NAVISHAODWOFFSET"];
                [prefs removeObjectForKey:@"OFFLINE_FLAG"];
                [prefs removeObjectForKey:@"OFFLINE_ID"];
                [prefs removeObjectForKey:@"RES_VER"];
                [prefs removeObjectForKey:@"SubOffButtonFilePath"];
                [prefs removeObjectForKey:@"SubBgFilePath"];
                [prefs removeObjectForKey:@"SubOnButtonFilePath"];
                [prefs removeObjectForKey:@"TabBarColor"];
                [prefs removeObjectForKey:@"UserInfo_ID"];
                [prefs removeObjectForKey:@"isSave"];
                [prefs removeObjectForKey:@"startTabNumber"];
                [prefs removeObjectForKey:@"startString"];
                [prefs synchronize];
                NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [arrayPaths objectAtIndex:0];
                NSFileManager *manager =[NSFileManager defaultManager];
                NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                for (int i=0; i<[fileList count]; i++) {
                    NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    [manager removeItemAtPath:fileName error:NULL];
                }
                NSString *libPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
                libPath = [libPath stringByAppendingPathComponent:@"Application Support"];
                NSString *oracleLibPath = [libPath stringByAppendingPathComponent:@"oracle"];
                NSString *dbvalleyLibPath = [libPath stringByAppendingPathComponent:@"dbvalley"];
                //documentPath = [documentPath stringByAppendingPathComponent:@"sqlite_db"];
                
                //documentPath = [documentPath stringByAppendingPathComponent:[appDelegate.user_id uppercaseString]];
                
                [manager removeItemAtPath:oracleLibPath error:nil];
                [manager removeItemAtPath:dbvalleyLibPath error:nil];
                
                [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
                
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
                [alert show];
                
            }else if([deleteTitle isEqualToString:NSLocalizedString(@"message116", @"")]){
                MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];
                NSString *documentFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *compFolder = [documentFolder stringByAppendingPathComponent:appDelegate.comp_no];
                NSString *webAppFolder = [compFolder stringByAppendingPathComponent:@"webapp"];
                
                NSFileManager *manager =[NSFileManager defaultManager];
                NSArray *fileList = [manager contentsOfDirectoryAtPath:webAppFolder error:NO];
                
                for (int i=0; i<[fileList count]; i++) {
                    NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [webAppFolder stringByAppendingPathComponent:str];
                    [manager removeItemAtPath:fileName error:NULL];
                    
                }
                
                NSPropertyListFormat format;
                NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                filePath = [filePath stringByAppendingFormat:@"/%@/webAppVersion.plist",appDelegate.comp_no];

                NSMutableDictionary *dic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:filePath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];

                for(NSString *key in [dic allKeys]){
                    [dic removeObjectForKey:key];
                }
                [dic writeToFile:filePath atomically:YES];

                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""),nil];
                [alert show];
                
            }
        }else if(buttonIndex==1){
            
        }
    }
    
    
}
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if([alertView.title isEqualToString:NSLocalizedString(@"message37", @"")]){
		if (buttonIndex == 0) {
			NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
			[prefs setObject:indexTitle forKey:@"startString"];
			[prefs setInteger:[tabNameArray indexOfObject:indexTitle] forKey:@"startTabNumber"];
			[prefs synchronize];
			
		}
		
	} else if([alertView.title isEqualToString:NSLocalizedString(@"message66", @"")]){
        if (buttonIndex == 0) {
            exit(0);
        }else{
            
        }
    }else if ([alertView.title isEqualToString:NSLocalizedString(@"message121", @"")]) {
        exit(0);
    }else if([alertView.title isEqualToString:NSLocalizedString(@"message38", @"")]){
		if(buttonIndex==0){
			if ([deleteTitle isEqualToString:NSLocalizedString(@"message39", @"")]) {
				NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *docDir = [arrayPaths objectAtIndex:0];
                ////NSLog(@"docdir : %@",docDir);
                docDir = [docDir stringByAppendingPathComponent:@"icon/"];
                ////NSLog(@"current docdir : %@",docDir);
				NSFileManager *manager =[NSFileManager defaultManager];
				NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                ////NSLog(@"fileList : %@",fileList);
				for (int i=0; i<[fileList count]; i++) {
					NSString *str = [fileList objectAtIndex:i];
                    str = [docDir stringByAppendingPathComponent:str];
                    ////NSLog(@"delete file : %@",str);
                    [manager removeItemAtPath:str error:NULL];
					
				}
				UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
				[alert show];
                
			}else if([deleteTitle isEqualToString:NSLocalizedString(@"message40", @"")]){
				NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *docDir = [arrayPaths objectAtIndex:0];
                docDir = [docDir stringByAppendingPathComponent:@"photo/"];
                ////NSLog(@"docDir : %@",docDir);
				NSFileManager *manager =[NSFileManager defaultManager];
				NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                ////NSLog(@"fileList : %@",fileList);
				for (int i=0; i<[fileList count]; i++) {
					NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    ////NSLog(@"jpg fileName : %@",fileName);
                    [manager removeItemAtPath:fileName error:NULL];
					
				}
				UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
				[alert show];
                
			}else if([deleteTitle isEqualToString:NSLocalizedString(@"message41", @"")]){
				NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *docDir = [arrayPaths objectAtIndex:0];
                docDir = [docDir stringByAppendingPathComponent:@"video/"];
                
				NSFileManager *manager =[NSFileManager defaultManager];
				NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                
				for (int i=0; i<[fileList count]; i++) {
					NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    [manager removeItemAtPath:fileName error:NULL];
					
				}
				UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:nil];
				[alert show];
                
			}else if([deleteTitle isEqualToString:NSLocalizedString(@"message42", @"")]){
				NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *docDir = [arrayPaths objectAtIndex:0];
				NSFileManager *manager =[NSFileManager defaultManager];
				NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
				for (int i=0; i<[fileList count]; i++) {
					NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    [manager removeItemAtPath:fileName error:NULL];
                    
                }
				UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""),nil];
				[alert show];
                
			}else if([deleteTitle isEqualToString:NSLocalizedString(@"message116", @"")]){
                NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *docDir = [arrayPaths objectAtIndex:0];
                docDir = [docDir stringByAppendingPathComponent:@"webapp/"];
                
				NSFileManager *manager =[NSFileManager defaultManager];
				NSArray *fileList = [manager contentsOfDirectoryAtPath:docDir error:NO];
                
				for (int i=0; i<[fileList count]; i++) {
					NSString *str = [fileList objectAtIndex:i];
                    NSString *fileName = [docDir stringByAppendingPathComponent:str];
                    [manager removeItemAtPath:fileName error:NULL];
					
				}
				UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"message66", @"") message:NSLocalizedString(@"message65", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"message51", @"") otherButtonTitles:NSLocalizedString(@"message52", @""),nil];
				[alert show];
                
            }
		}else if(buttonIndex==1){
            
		}
	}
	
}
  */


@end
