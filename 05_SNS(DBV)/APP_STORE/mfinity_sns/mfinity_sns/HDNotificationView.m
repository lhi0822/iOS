//
//  HDNotificationView.m
//  HDNotificationView
//
//  Created by iOS Developer on 4/3/15.
//  Copyright (c) 2015 AnG. All rights reserved.
//

#import "HDNotificationView.h"
#import "UIDevice-Hardware.h"

#define NOTIFICATION_VIEW_FRAME_HEIGHT          64.0f

#define LABEL_TITLE_FONT_SIZE                   14.0f
#define LABEL_MESSAGE_FONT_SIZE                 13.0f

#define IMAGE_VIEW_ICON_CORNER_RADIUS           3.0f
#define IMAGE_VIEW_ICON_FRAME                   CGRectMake(15.0f, 8.0f, 20.0f, 20.0f)
#define DRAG_HANDLER_FRAME                      CGRectMake([[UIScreen mainScreen] bounds].size.width/2-30,NOTIFICATION_VIEW_FRAME_HEIGHT-5,60,3)
#define LABEL_TITLE_FRAME                       CGRectMake(45.0f, 3.0f, [[UIScreen mainScreen] bounds].size.width - 45.0f, 26.0f)
#define LABEL_TITLE_FRAME_WITHOUT_IMAGE         CGRectMake(5.0f, 3.0f, [[UIScreen mainScreen] bounds].size.width - 5.0f, 26.0f)
#define LABEL_MESSAGE_FRAME_HEIGHT              35.0f
#define LABEL_MESSAGE_FRAME                     CGRectMake(45.0f, 25.0f, [[UIScreen mainScreen] bounds].size.width - 45.0f, LABEL_MESSAGE_FRAME_HEIGHT)
#define LABEL_MESSAGE_FRAME_WITHOUT_IMAGE       CGRectMake(5.0f, 25.0f, [[UIScreen mainScreen] bounds].size.width - 5.0f, LABEL_MESSAGE_FRAME_HEIGHT)

#define NOTIFICATION_VIEW_SHOWING_DURATION                  5.0f    /// second(s)
#define NOTIFICATION_VIEW_SHOWING_ANIMATION_TIME            0.3f    /// second(s)

@implementation HDNotificationView

static BOOL _isDragging;
BOOL isVerticalPan;

- (BOOL)isIphoneX
{
    NSString *modelStr = [[[UIDevice currentDevice] modelIdentifier] stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
    NSArray *modelIdArr = [modelStr componentsSeparatedByString:@","];
//    NSLog(@"modelStr : %@", modelStr);

    NSString *platformNumber = [modelIdArr objectAtIndex:0];
    int modelNum = [platformNumber intValue];
    if(modelNum <= 6){
        //5s 이하
    } else if(modelNum > 6 && modelNum < 10){
        //6~8, X
        if([modelStr isEqualToString:@"8,4"]){ //SE
            platformNumber = @"5";
        }
    } else {
        if([modelStr isEqualToString:@"10,1"]||[modelStr isEqualToString:@"10,2"]||[modelStr isEqualToString:@"10,5"]){ //8
            platformNumber = @"9";
        }
        if([modelStr isEqualToString:@"12,8"]){ //SE2
            platformNumber = @"9";
        }
    }
    
    if([platformNumber intValue] < 10) return NO;
    else return YES;
}
- (int)navBarBottom {
    return [self isIphoneX] ? 88 : 64;
}
-(CGRect)dragHandlerFrame{
    return [self isIphoneX] ? CGRectMake([[UIScreen mainScreen] bounds].size.width/2-30,[self navBarBottom]-7,60,3) : CGRectMake([[UIScreen mainScreen] bounds].size.width/2-30,[self navBarBottom]-5,60,3);
}
- (int)labelMessageFrameHeight {
    return [self isIphoneX] ? 65 : 35;
}
-(CGRect)imageViewIconFrame{
    return [self isIphoneX] ? CGRectMake(15.0f, 38.0f, 20.0f, 20.0f) : CGRectMake(15.0f, 8.0f, 20.0f, 20.0f);
}
-(CGRect)labelTilteFrame{
    return [self isIphoneX] ? CGRectMake(45.0f, 33.0f, [[UIScreen mainScreen] bounds].size.width - 45.0f, 26.0f) : CGRectMake(45.0f, 3.0f, [[UIScreen mainScreen] bounds].size.width - 45.0f, 26.0f);
}
-(CGRect)labelTitileFrameWithoutImg{
    return [self isIphoneX] ? CGRectMake(10.0f, 33.0f, [[UIScreen mainScreen] bounds].size.width - 5.0f, 26.0f) : CGRectMake(10.0f, 3.0f, [[UIScreen mainScreen] bounds].size.width - 5.0f, 26.0f);
}
-(CGRect)labelMessageFrame{
    return [self isIphoneX] ? CGRectMake(45.0f, 55.0f, [[UIScreen mainScreen] bounds].size.width - 45.0f, [self labelMessageFrameHeight]) : CGRectMake(45.0f, 25.0f, [[UIScreen mainScreen] bounds].size.width - 45.0f, [self labelMessageFrameHeight]);
}
-(CGRect)labelMessageFrameWithoutImg{
    return [self isIphoneX] ? CGRectMake(10.0f, 55.0f, [[UIScreen mainScreen] bounds].size.width - 5.0f, [self labelMessageFrameHeight]) :CGRectMake(10.0f, 25.0f, [[UIScreen mainScreen] bounds].size.width - 5.0f, [self labelMessageFrameHeight]);
}


/// -------------------------------------------------------------------------------------------
#pragma mark - INIT
/// -------------------------------------------------------------------------------------------
+ (instancetype)sharedInstance
{
    static id _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    //self = [super initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, NOTIFICATION_VIEW_FRAME_HEIGHT)];
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [self navBarBottom])];
    if (self) {
        
        /// Enable orientation tracking
        if (![[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) {
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        }
        
        /// Add Orientation notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationStatusDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        /// Set up UI
        [self setUpUI];
    }
    
    return self;
}

/// -------------------------------------------------------------------------------------------
#pragma mark - ACTIONS
/// -------------------------------------------------------------------------------------------
- (void)setUpUI
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        self.barTintColor = nil;
        self.translucent = YES;
        self.barStyle = UIBarStyleBlack;
    }
    else {
        [self setTintColor:[UIColor colorWithRed:5 green:31 blue:75 alpha:1]];
    }
    
    self.layer.zPosition = MAXFLOAT;
    self.backgroundColor = [UIColor clearColor];
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    
    self.frame = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [self navBarBottom]);
    
    /// Icon
    if (!_imgIcon) {
        _imgIcon = [[UIImageView alloc] init];
    }
    _imgIcon.frame = [self imageViewIconFrame]; //IMAGE_VIEW_ICON_FRAME;
    [_imgIcon setContentMode:UIViewContentModeScaleAspectFill];
    [_imgIcon.layer setCornerRadius:IMAGE_VIEW_ICON_CORNER_RADIUS];
    [_imgIcon setClipsToBounds:YES];
    if (![_imgIcon superview]) {
        [self addSubview:_imgIcon];
    }
    
    /// Title
    if (!_lblTitle) {
        _lblTitle = [[UILabel alloc] init];
    }
    _lblTitle.frame = [self labelTilteFrame];//LABEL_TITLE_FRAME;
    [_lblTitle setTextColor:[UIColor whiteColor]];
    [_lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LABEL_TITLE_FONT_SIZE]];
    [_lblTitle setNumberOfLines:1];
    if (![_lblTitle superview]) {
        [self addSubview:_lblTitle];
    }
    
    /// Message
    if (!_lblMessage) {
        _lblMessage = [[UILabel alloc] init];
    }
    _lblMessage.frame = [self labelMessageFrame];//LABEL_MESSAGE_FRAME;
    [_lblMessage setTextColor:[UIColor whiteColor]];
    [_lblMessage setFont:[UIFont fontWithName:@"HelveticaNeue" size:LABEL_MESSAGE_FONT_SIZE]];
    [_lblMessage setNumberOfLines:1];
    _lblMessage.lineBreakMode = NSLineBreakByTruncatingTail;
    if (![_lblMessage superview]) {
        [self addSubview:_lblMessage];
    }
    [self fixLabelMessageSize];
    
    //Drag Handler
    if(!_dragHandler) {
        _dragHandler = [[UIView alloc]init];
        [self addSubview:_dragHandler];
    }
    _dragHandler.frame = [self dragHandlerFrame];//DRAG_HANDLER_FRAME;
    _dragHandler.layer.cornerRadius = 2;
    _dragHandler.backgroundColor = [UIColor whiteColor];
    if(![_dragHandler superview]) {
        [self addSubview:_dragHandler];
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notificationViewDidTap:)];
    [self addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(notificationViewDidPan:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];

}

- (void)showNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message isAutoHide:(BOOL)isAutoHide onTouch:(void (^)())onTouch
{
    /// Invalidate _timerHideAuto
    if (_timerHideAuto) {
        [_timerHideAuto invalidate];
        _timerHideAuto = nil;
    }
    
    /// onTouch
    _onTouch = onTouch;
    
    /// Image
    if (image) {
        [_imgIcon setImage:image];
    }
    else {
        [_imgIcon setImage:nil];
        _lblTitle.frame =[self labelTitileFrameWithoutImg];//LABEL_TITLE_FRAME_WITHOUT_IMAGE;
        _lblMessage.frame = [self labelMessageFrameWithoutImg];//LABEL_MESSAGE_FRAME_WITHOUT_IMAGE;
    }
    
    /// Title
    if (title) {
        [_lblTitle setText:title];
    }
    else {
        [_lblTitle setText:@""];
    }
    
    /// Message
    if (message) {
        [_lblMessage setText:message];
    }
    else {
        [_lblMessage setText:@""];
    }
    [self fixLabelMessageSize];
    
    /// Prepare frame
    CGRect frame = self.frame;
    frame.origin.y = -frame.size.height;
    self.frame = frame;
    
    /// Add to window
    [UIApplication sharedApplication].delegate.window.windowLevel = UIWindowLevelStatusBar;
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    
    /// Showing animation
    [UIView animateWithDuration:NOTIFICATION_VIEW_SHOWING_ANIMATION_TIME
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         CGRect frame = self.frame;
                         frame.origin.y += frame.size.height;
                         self.frame = frame;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
    // Schedule to hide
    if (isAutoHide) {
        _timerHideAuto = [NSTimer scheduledTimerWithTimeInterval:NOTIFICATION_VIEW_SHOWING_DURATION
                                                          target:self
                                                        selector:@selector(hideNotificationView)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}
- (void)hideNotificationView
{
    [self hideNotificationViewOnComplete:nil];
}
- (void)hideNotificationViewOnComplete:(void (^)())onComplete
{
    if(!_isDragging) {
        [UIView animateWithDuration:NOTIFICATION_VIEW_SHOWING_ANIMATION_TIME
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             CGRect frame = self.frame;
                             frame.origin.y -= frame.size.height;
                             self.frame = frame;
                             
                         } completion:^(BOOL finished) {
                             
                             [self removeFromSuperview];
                             [UIApplication sharedApplication].delegate.window.windowLevel = UIWindowLevelNormal;
                             
                             // Invalidate _timerAutoClose
                             if (_timerHideAuto) {
                                 [_timerHideAuto invalidate];
                                 _timerHideAuto = nil;
                             }
                             
                             if (onComplete) {
                                 onComplete();
                             }
                         }];
    }
    else {
        if (_timerHideAuto) {
            [_timerHideAuto invalidate];
            _timerHideAuto = nil;
        }
    }
    
}
- (void)notificationViewDidTap:(UIGestureRecognizer *)gesture
{
    if (_onTouch) {
        _onTouch();
    }
}
- (void)notificationViewDidPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded){
        _isDragging = NO;
        if(self.frame.origin.y<0 || (!_timerHideAuto)) {
            [self hideNotificationView];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateBegan) {
        _isDragging = YES;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self.superview];
        // Figure out where the user is trying to drag the view.
        CGPoint newCenter = CGPointMake(self.superview.bounds.size.width / 2,
                                        gesture.view.center.y + translation.y);
        // See if the new position is in bounds.
        if (newCenter.y >= (-1 * [self navBarBottom]/2) && newCenter.y <= [self navBarBottom]/2) {
            gesture.view.center = newCenter;
            [gesture setTranslation:CGPointZero inView:self.superview];
        }
    }
}

/// ----------------------------------------------------------------------------------
#pragma mark - GESTURE DELEGATE
/// ----------------------------------------------------------------------------------
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if([panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        CGPoint translation = [panGestureRecognizer translationInView:self];
        isVerticalPan = fabs(translation.y) > fabs(translation.x); // BOOL property
        return YES;
    }
    else if ([panGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        
        [self notificationViewDidTap:panGestureRecognizer];
        return NO;
    }
    else {
        return NO;
    }
}

/// -------------------------------------------------------------------------------------------
#pragma mark - HELPER
/// -------------------------------------------------------------------------------------------
- (void)fixLabelMessageSize
{
    CGSize size = [_lblMessage sizeThatFits:CGSizeMake([[UIScreen mainScreen] bounds].size.width - 45.0f, MAXFLOAT)];
    CGRect frame = _lblMessage.frame;
    frame.size.height = (size.height > [self labelMessageFrameHeight] ? [self labelMessageFrameHeight] : size.height);
    _lblMessage.frame = frame;
}

/// -------------------------------------------------------------------------------------------
#pragma mark - ORIENTATION NOTIFICATION
/// -------------------------------------------------------------------------------------------
- (void)orientationStatusDidChange:(NSNotification *)notification
{
    [self setUpUI];
}

/// -------------------------------------------------------------------------------------------
#pragma mark - UTILITY FUNCS
/// -------------------------------------------------------------------------------------------
+ (void)showNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message
{
    [HDNotificationView showNotificationViewWithImage:image title:title message:message isAutoHide:YES onTouch:nil];
}
+ (void)showNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message isAutoHide:(BOOL)isAutoHide
{
    [HDNotificationView showNotificationViewWithImage:image title:title message:message isAutoHide:isAutoHide onTouch:nil];
}
+ (void)showNotificationViewWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message isAutoHide:(BOOL)isAutoHide onTouch:(void (^)())onTouch
{
    [[HDNotificationView sharedInstance] showNotificationViewWithImage:image title:title message:message isAutoHide:isAutoHide onTouch:onTouch];
}
+ (void)hideNotificationView
{
    [HDNotificationView hideNotificationViewOnComplete:nil];
}
+ (void)hideNotificationViewOnComplete:(void (^)())onComplete
{
    [[HDNotificationView sharedInstance] hideNotificationViewOnComplete:onComplete];
}

@end
