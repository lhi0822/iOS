/*
 
 ETLaunchUrlParams.h
 Entrust IdentityGuard Mobile SDK
 
 Copyright (c) 2014 Entrust, Inc. All rights reserved.
 Use is subject to the terms of the accompanying license agreement. Entrust Confidential.
 
 */


#import <Foundation/Foundation.h>

/**
 * Base object for parsing launch URL.
 */
@interface ETLaunchUrlParams : NSObject
{
@private
    /**
     * The parameter that describes which action should be
     * performed after processing the launch URL.  You can
     * look at this or the subclass type to determine which
     * action should be performed.
     */
    NSString *action;
    
    /**
     * The URL scheme that was used to launch the application.
     * You can check this to ensure it is an expected value.
     */
    NSString *scheme;
    
    /**
     * The original URL request.
     */
    NSURL *url;
}
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSURL *url;


@end

/**
 * The launch parameters from an activate new soft token
 * identity link.
 */
@interface ETActivationLaunchUrlParams : ETLaunchUrlParams
{
@private
    /**
     * The URL that should used to activate the soft token.
     * Note: Generally this is the URL of the config.json file
     * which contains the transaction component URL however if
     * you are hosting the config.json file in the transaction
     * component then it is already the right address.
     */
    NSString *registrationUrl;
    
    /**
     * The soft token serial number that will be activated.
     */
    NSString *serialNumber;
    
    /**
     * The registration password used to authenticate.
     */
    NSString *registrationPassword;
}
@property (nonatomic, strong) NSString *registrationUrl;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *registrationPassword;

@end

/**
 * The decrypted launch parameters from a secure offline activation QR code.
 * The values of this type of launch URL allow an application to populate the
 * fields on the add or create soft token identity screen.
 */
@interface ETOfflineActivationLaunchUrlParams : ETLaunchUrlParams
{
@private
    /**
     * The soft token serial number.
     */
    NSString *serialNumber;
    
    /**
     * The soft token activation code.
     */
    NSString *activationCode;
    
    /**
     * The soft token identity provider address.
     * @optional
     */
    NSString *registrationUrl;
    
    /**
     * The soft token identity Security Policy string.
     * @optional
     */
    NSString *securityPolicy;
}
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *activationCode;
@property (nonatomic, strong) NSString *registrationUrl;
@property (nonatomic, strong) NSString *securityPolicy;

@end

/**
 * The launch parameters from a secure offline activation QR code.
 * This type of launch URL must be decrypted using a password
 * entered by the user to obtain the original offline activation
 * launch URL parameter.
 */
@interface ETSecureOfflineActivationLaunchUrlParams : ETLaunchUrlParams
{
@private
    /**
     * The encrypted message as a base64 encoded string.
     */
    NSString *encryptedMessage;
    
    /**
     * The message version as a base64 encoded string.
     */
    NSString *version;
    
    /**
     * The message MAC as a base64 encoded string.
     */
    NSString *mac;
}
@property (nonatomic, strong) NSString *encryptedMessage;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *version;

- (ETOfflineActivationLaunchUrlParams *) decryptUsingPassword:(NSString *)password;

@end

/**
 * The launch parameters from an offline transaction QR code.
 */
@interface ETOfflineTransactionUrlParams : ETLaunchUrlParams
{
@private
    /**
     * The encrypted message.
     */
    NSString *encryptedMessage;
    
    /**
     * The soft token serial number that the transaction belongs to.
     */
    NSString *serialNumber;
    
    /**
     * The version of this message.
     */
    NSString *version;
    
    /**
     * The MAC for this message.
     */
    NSString *mac;
}
@property (nonatomic, strong) NSString *encryptedMessage;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *mac;

@end