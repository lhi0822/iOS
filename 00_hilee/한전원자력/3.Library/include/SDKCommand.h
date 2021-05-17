//
//  SDKCommand.h
//  Entrust IdentityGuard Mobile SDK
//  Command Line Example
//
//  Copyright (c) 2013 Entrust, Inc. All rights reserved.
//  Use is subject to the terms of the accompanying license agreement. Entrust Confidential.
//

#import <Foundation/Foundation.h>

/**
 * Defines the methods for an SDK Command that can be
 * displayed and invoked from the Example application.
 */
@protocol SDKCommand <NSObject>

@required

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
