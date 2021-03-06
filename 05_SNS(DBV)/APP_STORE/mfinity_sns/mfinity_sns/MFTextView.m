//
//  MFTextView.m
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 4..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import "MFTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+JSQMessages.h"

@interface MFTextView ()

@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *minHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *maxHeightConstraint;

@end

@implementation MFTextView
@synthesize pasteDelegate;

- (void)MFConfigureTextView
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    CGFloat cornerRadius = 6.0f;
    
    self.delegate = self;
    
    self.backgroundColor = [UIColor whiteColor];
    //self.backgroundColor = [UIColor yellowColor];
    self.layer.borderWidth = 0.5f;
    //self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.cornerRadius = cornerRadius;
    
    self.scrollIndicatorInsets = UIEdgeInsetsMake(cornerRadius, 0.0f, cornerRadius, 0.0f);
    
    self.textContainerInset = UIEdgeInsetsMake(4.0f, 2.0f, 4.0f, 2.0f);
    
    self.contentInset = UIEdgeInsetsMake(1.0f, 0.0f, 1.0f, 0.0f);
    
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    
    self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.textColor = [UIColor blackColor];
    self.textAlignment = NSTextAlignmentNatural;
    
    self.contentMode = UIViewContentModeRedraw;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    
    self.text = nil;
    
    _placeHolder = nil;
    _placeHolderTextColor = [UIColor lightGrayColor];
    _placeHolderInsets = UIEdgeInsetsMake(5.0, 7.0, 5.0, 7.0);
    
    [self associateConstraints];
    [self MFAddTextViewNotificationObservers];
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    
    if (self) {
        [self MFConfigureTextView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self MFConfigureTextView];
}

- (void)dealloc
{
    [self MFRemoveTextViewNotificationObservers];
}

- (void)associateConstraints {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            
            if (constraint.relation == NSLayoutRelationEqual) {
                self.heightConstraint = constraint;
            }
            
            else if (constraint.relation == NSLayoutRelationLessThanOrEqual) {
                self.maxHeightConstraint = constraint;
            }
            
            else if (constraint.relation == NSLayoutRelationGreaterThanOrEqual) {
                self.minHeightConstraint = constraint;
            }
        }
    }
}


- (void)layoutSubviews // 메세지 전송창 크기
{
    [super layoutSubviews];
    
    // calculate size needed for the text to be visible without scrolling
    CGSize sizeThatFits = [self sizeThatFits:self.frame.size];
    float newHeight = sizeThatFits.height;
    
    if (self.maxHeightConstraint) {
        newHeight = MIN(newHeight, 70.0f); // 기본값 : self.maxHeightConstraint.constant
    }
    
    // if there is any maximal height constraint set, make sure we consider that
    if (self.minHeightConstraint) {
        newHeight = MAX(newHeight, self.minHeightConstraint.constant);
    }
    
    // update the height constraint
    self.heightConstraint.constant = newHeight;
}

#pragma mark - Composer text view
- (BOOL)hasText
{
    return ([[self.text jsq_stringByTrimingWhitespace] length] > 0);
}

#pragma mark - Setters
- (void)setPlaceHolder:(NSString *)placeHolder
{
    if ([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    
    _placeHolder = [placeHolder copy];
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor
{
    if ([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }
    
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

- (void)setPlaceHolderInsets:(UIEdgeInsets)placeHolderInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(placeHolderInsets, _placeHolderInsets)) {
        return;
    }
    
    _placeHolderInsets = placeHolderInsets;
    [self setNeedsDisplay];
}

#pragma mark - UITextView overrides
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    if (self.contentSize.height <= self.bounds.size.height + 1){
        self.contentOffset = CGPointZero; // Fix wrong contentOfset
    }
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

- (void)paste:(id)sender
{
    if (!self.pasteDelegate || [self.pasteDelegate composerTextView:self shouldPasteWithSender:sender]) {
        [super paste:sender];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if ([self.text length] == 0 && self.placeHolder) {
        [self.placeHolderTextColor set];
        
        [self.placeHolder drawInRect:UIEdgeInsetsInsetRect(rect, self.placeHolderInsets)
                      withAttributes:[self MFPlaceholderTextAttributes]];
    }
}

#pragma mark - Notifications

- (void)MFAddTextViewNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MFDidReceiveTextViewNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MFDidReceiveTextViewNotification:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MFDidReceiveTextViewNotification:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)MFRemoveTextViewNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:self];
}

- (void)MFDidReceiveTextViewNotification:(NSNotification *)notification {
    [self setNeedsDisplay];
}


- (BOOL)textView:(MFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [textView scrollRangeToVisible:[textView selectedRange]];
    NSUInteger textViewByte = [textView.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger textByte = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    if([self.fromSegue isEqualToString:@"BOARD_MSG_NAME"]){
        if (textViewByte + textByte > 140){
            //NSLog(@"게시판 이름 글자수 제한");
            return NO;
        }
    } else if([self.fromSegue isEqualToString:@"BOARD_MSG_DESC"]){
        if (textViewByte + textByte > 1000){
            //NSLog(@"게시판 설명 글자수 제한");
            return NO;
        }
    } else if([self.fromSegue isEqualToString:@"MY_MSG_CHANGE_PUSH"]){
        if (textViewByte + textByte > 100){
            //NSLog(@"상태메시지 글자수 제한");
            return NO;
        }
        
    } else if([self.fromSegue isEqualToString:@"CHAT_SET_ROOM_NAME_MODAL"]){
        if (textViewByte + textByte > 100){
            //NSLog(@"채팅방 이름 글자수 제한");
            return NO;
        }
    }
    else if([self.fromSegue isEqualToString:@"CHAT_CONTENT"]){
        NSString *currText = [textView.text stringByAppendingString:text];
        
        if (textViewByte + textByte > 5000){
            //NSLog(@"채팅 글자수 제한");
            
            NSString *string = [self fetchStringWithOriginalString:currText withByteLength:5000];
        
            textView.text = string;
            textView.selectedRange = NSMakeRange(textView.text.length, 0);
            
            return NO;
        }
    }
    else if([self.fromSegue isEqualToString:@"POST_COMMENT"]){
        NSString *currText = [textView.text stringByAppendingString:text];
        
       if (textViewByte + textByte > 500){
           NSLog(@"POST 댓글 글자수 제한");
           
           NSString *string = [self fetchStringWithOriginalString:currText withByteLength:500];
           textView.text = string;
           textView.selectedRange = NSMakeRange(textView.text.length, 0);
           
           return NO;
       }
        
//        NSData *contentData = [prevStr dataUsingEncoding:NSUTF8StringEncoding];
        //                        contentData = [contentData subdataWithRange:NSMakeRange(0, 200)];
        //                        prevStr = [[NSString alloc] initWithBytes:[contentData bytes] length:[contentData length] encoding:NSUTF8StringEncoding];
        
       [self.pasteDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
           
    } else if([self.fromSegue isEqualToString:@"TASK_COMMENT"]){
       if (textViewByte + textByte > 500){
           //NSLog(@"TASK 댓글 글자수 제한");
           return NO;
       }
        
    } else {
        [self.pasteDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    
    return YES;
}

- (NSString *)fetchStringWithOriginalString:(NSString *)originalString withByteLength:(NSUInteger)length {
    NSData* originalData=[originalString dataUsingEncoding:NSUTF8StringEncoding];
    const char *originalBytes = originalData.bytes;
    
    //make sure to use a loop to get a not nil string.
    //because your certain length data may be not decode by NSString
    for (NSUInteger i = length; i > 0; i--) {
        NSData *data = [NSData dataWithBytes:originalBytes length:i];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string) {
            return string;
        }
    }
    return @"";
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    textView.backgroundColor = [UIColor whiteColor];//[UIColor grayColor];
    return YES;
}

-(void)textViewDidChange:(MFTextView *)textView{
    [self.pasteDelegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(MFTextView *)textView{
    [self.pasteDelegate textViewDidChangeSelection:textView];
}

#pragma mark - Utilities

- (NSDictionary *)MFPlaceholderTextAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = self.textAlignment;
    
    return @{ NSFontAttributeName : self.font,
              NSForegroundColorAttributeName : self.placeHolderTextColor,
              NSParagraphStyleAttributeName : paragraphStyle };
}

#pragma mark - UIMenuController

- (BOOL)canBecomeFirstResponder
{
    return [super canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    [UIMenuController sharedMenuController].menuItems = nil;
    return [super canPerformAction:action withSender:sender];
}

@end
