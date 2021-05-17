//
//  MFTextView.h
//  mfinity_sns
//
//  Created by hilee on 2018. 1. 4..
//  Copyright © 2018년 com.dbvalley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MFTextView;

NS_ASSUME_NONNULL_BEGIN

@protocol MFTextViewDelegate;

@interface MFTextView : UITextView <UITextViewDelegate>

@property (strong, nonatomic) NSString *fromSegue;
@property (copy, nonatomic, nullable) NSString *placeHolder;
@property (strong, nonatomic) UIColor *placeHolderTextColor;
@property (assign, nonatomic) UIEdgeInsets placeHolderInsets;

- (BOOL)hasText;

@property (weak, nonatomic) id <MFTextViewDelegate> pasteDelegate;

@end

@protocol MFTextViewDelegate <NSObject>

@optional
- (BOOL)composerTextView:(MFTextView *)textView shouldPasteWithSender:(id)sender;
- (void)textView:(MFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(MFTextView *)textView;
- (void)textViewDidChangeSelection:(MFTextView *)textView;
@end

NS_ASSUME_NONNULL_END

