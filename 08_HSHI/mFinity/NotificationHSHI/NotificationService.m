//
//  NotificationService.m
//  NotificationHSHI
//
//  Created by hilee on 19/12/2018.
//  Copyright © 2018 Jun hyeong Park. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSDictionary *userInfo = request.content.userInfo;
    if (userInfo == nil) {
        [self contentComplete];
        return;
    }
    
    NSString *msg = [userInfo[@"aps"] objectForKey:@"alert"];
    NSString *mediaUrl = userInfo[@"PUSH_IMG"];
    NSString *mediaType = userInfo[@"MEDIA_TYPE"];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@", msg];
    
    // load the attachment
    [self loadAttachmentForUrlString:mediaUrl
                            withType:mediaType
                   completionHandler:^(UNNotificationAttachment *attachment) {
                       if (attachment) {
                           self.bestAttemptContent.attachments = [NSArray arrayWithObject:attachment];
                       }
                       [self contentComplete];
                   }];
}


- (void)contentComplete {
    self.contentHandler(self.bestAttemptContent);
}

- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    
    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }
    
    if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    
    if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    
    return [@"." stringByAppendingString:ext];
}

- (void)loadAttachmentForUrlString:(NSString *)urlString withType:(NSString *)type completionHandler:(void(^)(UNNotificationAttachment *))completionHandler  {
    
    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlString];
    NSString *fileExt = [self fileExtensionForMediaType:type];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL
                completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
                    if (error != nil) {
                        NSLog(@"%@", error.localizedDescription);
                    } else {
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
                        [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
                        
                        NSError *attachmentError = nil;
                        attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
                        if (attachmentError) {
                            NSLog(@"%@", attachmentError.localizedDescription);
                        }
                    }
                    completionHandler(attachment);
                }] resume];
}


@end
