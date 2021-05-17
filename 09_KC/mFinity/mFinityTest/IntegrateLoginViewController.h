//
//  ;;
//  mFinityTest
//
//  Created by Kyeong In Park on 13. 2. 21..
//  Copyright (c) 2013년 Jun hyeong Park. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFinityAppDelegate.h"
@interface IntegrateLoginViewController : UIViewController{
    MFinityAppDelegate *appDelegate;
    NSString *userid;
    NSString *tabInfo;
    NSString *pwd;
    NSString *deployURL;
    NSString *serverVersion;
    NSString *failedMessage;
    NSString *forcedDownFlag;
    NSString *forcedDownMessage;
    NSMutableData *receiveData;
    NSMutableData *offLineData;
    NSString *syncFlag;
    
    NSThread *thread;
    BOOL isSucceed;
    NSString *errorMessage;
    NSMutableArray *readArray;
    int index;
    BOOL isSubscriptionSucceed;
    
}

- (NSString *)resultUserCheck:(NSDictionary *)loginDic;
- (BOOL)saveFile;
- (void)updateApplication;

- (void)deleteSubscription;
- (void)syncAgent;
- (void)fileUpload:(NSString *)filePath;
@end
