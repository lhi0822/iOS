//
//  NotiChatViewController.h
//  mfinity_sns
//
//  Created by hilee on 10/05/2019.
//  Copyright © 2019 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ChatMessageData.h"
#import "MFURLSession.h"
//#import "SRWebSocket.h"
#import "HISImageViewer.h"
#import "ChatToastView.h"
#import "TTTAttributedLabel.h"
#import "ChatConnectSocket.h"


@interface NotiChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, JSQMessagesInputToolbarDelegate, MFURLSessionDelegate, SRWebSocketDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UIGestureRecognizerDelegate, TTTAttributedLabelDelegate> {
    int rowCnt;
//    SRWebSocket *socket;
    HISImageViewer *imageViewer;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (strong, nonatomic) IBOutlet JSQMessagesInputToolbar *inputToolbar;

@property (strong, nonatomic) ChatToastView *toastView;

@property (strong, nonatomic) ChatMessageData *msgData;

@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSString *roomNo;
@property (strong, nonatomic) NSString *roomNoti;

@property (strong, nonatomic) NSString *fromSegue;

-(void)searchChatContent: (NSString *)text;
-(void)closeSearchChat;
@property (strong, nonatomic) NSString *searchText;

@end


