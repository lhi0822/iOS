//
//  SDKCommandLineApp.h
//  Entrust IdentityGuard Mobile SDK
//  Command Line Example
//
//  Copyright (c) 2013 Entrust, Inc. All rights reserved.
//  Use is subject to the terms of the accompanying license agreement. Entrust Confidential.
//

#import <Foundation/Foundation.h>
#import "ETIdentity.h"

@interface SDKCommandLineApp : NSObject
{
    ETIdentity *identity;
}

@property (nonatomic, strong, readwrite) ETIdentity *identity;


- (void) loadIdentity;
- (BOOL) isLoadedIdentity;

/**
 * Start running the application.
 */
- (void) startApp;

@end
