//
//  LockSettingViewController.m
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 25..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import "LockSettingViewController.h"
#import "MFinityAppDelegate.h"
@interface LockSettingViewController ()

@end

@implementation LockSettingViewController

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
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication] delegate];

	//[self.navigationController.navigationBar setTintColor:[appDelegate myRGBfromHex:appDelegate.naviBarColor]];
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 180, 44)];
    label.textColor = [appDelegate myRGBfromHex:appDelegate.naviFontColor];
    label.text = NSLocalizedString(@"message29", @"");
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    if ([appDelegate.naviIsShadow isEqualToString:@"Y"]) {
        label.shadowOffset = CGSizeMake([appDelegate.naviShadowOffset floatValue], [appDelegate.naviShadowOffset floatValue]);
        label.shadowColor = [appDelegate myRGBfromHex:appDelegate.naviShadowColor];
    }
    self.navigationItem.titleView = label;
    
    NSData *decryptData = [[NSData dataWithContentsOfFile:appDelegate.subBgImagePath] AES256DecryptWithKey:appDelegate.AES256Key];
    UIImage *bgImage = [UIImage imageWithData:decryptData];
	imageView.image = bgImage;
	[switchControl addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    if (![appDelegate.subFontColor isEqualToString:@"#FFFFFF"]) {
        [switchControl setOnTintColor:[appDelegate myRGBfromHex:appDelegate.subFontColor]];
    }
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ( [[prefs stringForKey:@"Lock"] isEqualToString:@"YES"]) {
		[switchControl setOn:YES];
	}else {
		[switchControl setOn:NO];
	}
	
	if ([prefs stringForKey:@"Lock"]==nil) {
		[switchControl setOn:NO];
	}
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
	UIColor *color = [appDelegate myRGBfromHex:appDelegate.subFontColor];
	[label1 setTextColor:color];
	[label2 setTextColor:color];
    [label3 setTextColor:color];
    label1.text = NSLocalizedString(@"message30", @"");
    label2.text = NSLocalizedString(@"message29", @"");
    label3.text = NSLocalizedString(@"message31", @"");
    
    label1.font = [UIFont systemFontOfSize:fontSize];
    label2.font = [UIFont systemFontOfSize:fontSize];
    label3.font = [UIFont systemFontOfSize:fontSize];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchValueChanged:(id)sender{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if (switchControl.on) {
		//NSLog(@"swithon");
		[prefs setObject:@"YES" forKey:@"Lock"];
	}else {
		//NSLog(@"switchoff");
		[prefs setObject:@"NO" forKey:@"Lock"];
	}
	[prefs synchronize];
}

@end
