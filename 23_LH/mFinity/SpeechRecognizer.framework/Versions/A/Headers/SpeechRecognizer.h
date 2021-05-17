//
//  SpeechRecognizer.h
//  v1.1
//
//  Created by 김기수 on 13. 7. 29.
//  Copyright (c) 2013년 김기수(heisice@gmail.com) All rights reserved.
//  http://blog.heisice.com/category/iOS%20Dev/SpeechRecognizer
//
//
//  v1.1 : iOS7 및 Xcode 5 환경 적용
//
//  v1.0 : 첫 버전 공개
//

typedef enum {
    SpeechRecognizerStatusError = -1,
    SpeechRecognizerStatusWait = 0,
    SpeechRecognizerStatusListening,
    SpeechRecognizerStatusProcessing,
    SpeechRecognizerStatusRecognition,
} SpeechRecognizerStatus;

@protocol SpeechRecognizerDelegate <NSObject>

@optional
- (void)speechRecognizerStatus:(SpeechRecognizerStatus)status;
- (void)speechRecognizerResult:(NSDictionary*)result;
- (void)speechRecognizerMicPower:(float)power;

@end

@interface SpeechRecognizer : NSObject {
        
}

+ (SpeechRecognizer*)sharedObject;

@property (nonatomic, strong) NSString *language; // default: ko_KR / en-US, en-GB, de-DE, ...
@property (nonatomic, assign) id<SpeechRecognizerDelegate> delegate;

- (void)start;
- (void)stop;

@end
