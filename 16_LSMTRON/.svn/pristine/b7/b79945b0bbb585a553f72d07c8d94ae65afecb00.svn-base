//
//  PullRefreshTableView.h
//  PullRefreshTableView
//
//  Created by j2enty on 11. 12. 12..
//  Copyright (c) 2011년 j2enty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullRefreshTableView : UITableViewController<UIScrollViewDelegate>
{
@private
    UILabel                                 *lbRefreshTime;
    UIImageView                             *ivRefreshArrow;
    UIActivityIndicatorView                 *spRefresh;
    
    NSString                                *refreshTime;
    BOOL                                    isRefresh;
    BOOL                                    isDragging;
    
    UILabel                                 *lbRefreshTime2;
    UIImageView                             *ivRefreshArrow2;
    UIActivityIndicatorView                 *spRefresh2;
    
    NSString                                *refreshTime2;
    BOOL                                    isRefresh2;
    BOOL                                    isDragging2;
}
@property (nonatomic, assign)BOOL isNotice;
- (void)startLoading;
- (void)stopLoading;
- (void)deleteLoading;
@end
