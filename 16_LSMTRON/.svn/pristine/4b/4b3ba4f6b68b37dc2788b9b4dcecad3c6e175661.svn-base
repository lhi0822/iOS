//
//  FileListViewController.h
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 27..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MFinityAppDelegate.h"
@interface FileListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate,UIGestureRecognizerDelegate, UIActionSheetDelegate>{
    NSMutableArray *listData;
	IBOutlet UITableView    *myTableView;
	NSInteger indexRow;
	NSMutableArray *selectedArray;
	BOOL inPseudoEditMode;
	UIImage *selectedImage;
	UIImage *unselectedImage;
    
    MFinityAppDelegate *appDelegate;
}
-(void) navigationGoBack;
- (void) populateSelectedArray;

-(IBAction)doDelete;
-(IBAction)allDelete;
@end
