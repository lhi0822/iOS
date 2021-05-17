//
//  BaseSDKCommand.h
//  Entrust IdentityGuard Mobile SDK
//  Command Line Example
//
//  Copyright (c) 2013 Entrust, Inc. All rights reserved.
//  Use is subject to the terms of the accompanying license agreement. Entrust Confidential.
//

#import <Foundation/Foundation.h>
#import "SDKCommand.h"
#import "SDKCommandLineApp.h"
#import "SDKUtils.h"

@interface BaseSDKCommand : NSObject <SDKCommand>
{
    SDKCommandLineApp *app;
    NSString *name;
    NSString *description;
}

/**
 * Initialize the command.
 * @param app The main application class.
 * @return The initialized instance.
 */
- (id) initWithApp:(SDKCommandLineApp *)app;

/**
 * Gets the name of the command.
 * @return The name of the command.
 */
- (NSString *) getName;

/**
 * Gets the description of the command.
 * @return The description of the command.
 */
- (NSString *) getDescription;

/**
 * Performs the command action.
 */
- (void) performCommand;

/**
 * Returns whether the command is applicable to the
 * current application state.
 * @return YES if the command can be run, NO otherwise.
 */
- (BOOL) isApplicable;

@end
