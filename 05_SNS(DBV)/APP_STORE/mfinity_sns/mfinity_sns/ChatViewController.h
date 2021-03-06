//
//  ChatViewController.h
//  mfinity_sns
//
//  Created by hilee on 2017. 4. 21..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import <Photos/Photos.h>
#import <sqlite3.h>

#import "TOCropViewController.h"
#import "TTTAttributedLabel.h"
#import "SDAVAssetExportSession.h"
#import "HISImageViewer.h"
#import "JSQMessagesInputToolbar.h"
#import "JTSImageViewController.h"
#import "MFTextView.h"

#import "AppDelegate.h"
#import "ChatMessageData.h"
#import "ChatListViewController.h"
#import "MFURLSession.h"
#import "ChatConnectSocket.h"
#import "SetMediaDataHandler.h"

#import "AccessAuthCheck.h"
#import "AttachViewController.h"
#import "ShareSelectViewController.h"
#import "ResendChatMessage.h"
 
@interface ChatViewController : UIViewController <JSQMessagesInputToolbarDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, MFURLSessionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, NSURLConnectionDataDelegate, NSURLSessionDelegate,
UISearchControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UIGestureRecognizerDelegate, MFTextViewDelegate, TOCropViewControllerDelegate, TTTAttributedLabelDelegate, SDAVAssetExportSessionDelegate, ChatConnectSocketDelegate, SetMediaDataDelegate, UIDocumentPickerDelegate>{
    BOOL isRefresh;
    BOOL isDragging;
    
    int rowCnt;
    
    BOOL isHideKeyboard;
    BOOL isSmallContents;
    BOOL isLargeContents;
    
    HISImageViewer *imageViewer;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet JSQMessagesInputToolbar *inputToolbar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;

@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSString *roomNo;
@property (strong, nonatomic) NSString *roomNoti;

@property (strong, nonatomic) UIButton *mediaButton;
@property BOOL isFlag;

@property (strong, nonatomic) NSMutableArray *assetArray;

@property (nonatomic,strong) NSString *fromSegue;
@property (nonatomic,strong) NSDictionary *notiChatDic;

@property (nonatomic,strong) NSMutableDictionary *editInfoDic;
@property (strong, nonatomic) NSMutableArray *sendingMsgArr;

@property (strong, nonatomic) NSString *tapImgUser;
@property (strong, nonatomic) NSString *tapImgDate;

@property (strong, nonatomic) NSString *searchText;

@property (strong, nonatomic) NSDictionary *snsInfoDic;

@property (nonatomic, strong) UIImage *failedImg;

@property (nonatomic, assign) TOCropViewCroppingStyle croppingStyle;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGRect croppedFrame;
@property (nonatomic, assign) NSInteger angle;

-(void)searchChatContent: (NSString *)text;
-(void)closeSearchChat;

-(void)shareChatUpdate;
-(void)viewWillAppear:(BOOL)animated;

@end

