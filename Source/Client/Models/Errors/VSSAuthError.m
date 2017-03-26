//
//  VSSAuthError.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/22/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSAuthError.h"

/// HTTP 500. Server error status is returned on internal application errors
const NSInteger kVSSAuthInternalError                                   = 10000;

/// HTTP 400. Request error status is returned on request data validation errors
const NSInteger kVSSAuthResourceOwnerUuidValidationError                = 53000;
const NSInteger kVSSAuthVirgilCardNotFoundError                         = 53010;
const NSInteger kVSSAuthVirgilCardNotAccessibleError                    = 53011;
const NSInteger kVSSAuthEncryptedMessageValidationFailedError           = 53020;
const NSInteger kVSSAuthAuthAttemptExpiredError                         = 53030;
const NSInteger kVSSAuthGrantTypeNotSupportedError                      = 53040;
const NSInteger kVSSAuthAuthAttemptNotFoundError                        = 53050;
const NSInteger kVSSAuthAuthCodeExpiredError                            = 53060;
const NSInteger kVSSAuthAuthCodeAlreadyUserError                        = 53070;
const NSInteger kVSSAuthAccessCodeInvalidError                          = 53080;
const NSInteger kVSSAuthRefreshTokenNotFoundError                       = 53090;
const NSInteger kVSSAuthResourceOwnerVirgilCardNotVerifiedError         = 53100;

@implementation VSSAuthError

- (NSString *)message {
    NSString *message = nil;
    
    switch (self.code) {
            /// HTTP 500. Server error status is returned on internal application errors
        case kVSSAuthInternalError: message = @"Internal application error."; break;
            
            /// HTTP 400. This status is returned on request data errors.
        case kVSSAuthResourceOwnerUuidValidationError: message = @"The resource owner uuid validation failed"; break;
        case kVSSAuthVirgilCardNotFoundError: message = @"The Virgil card specified by Uuid doesn't exist on the Virgil Keys service"; break;
        case kVSSAuthVirgilCardNotAccessibleError: message = @"The Auth service cannot get access to the Virgil card specified by id. The card in application scope and can't be retrieved"; break;
        case kVSSAuthEncryptedMessageValidationFailedError: message = @"Encrypted message validation failed"; break;
        case kVSSAuthAuthAttemptExpiredError: message = @"The authentication attempt instance has expired already"; break;
        case kVSSAuthGrantTypeNotSupportedError: message = @"Grant type is not supported as it is outside of the list: ['authorization_code']"; break;
        case kVSSAuthAuthAttemptNotFoundError: message = @"Unable to find an authorization attempt by the specified code"; break;
        case kVSSAuthAuthCodeExpiredError: message = @"An authorization code has expired already"; break;
        case kVSSAuthAuthCodeAlreadyUserError: message = @"An authorization code was used previously"; break;
        case kVSSAuthAccessCodeInvalidError: message = @"The Access code is invalid"; break;
        case kVSSAuthRefreshTokenNotFoundError: message = @"The Refresh token not found"; break;
        case kVSSAuthResourceOwnerVirgilCardNotVerifiedError: message = @"The Resource owner's Virgil card not verified"; break;
    }
    
    
    return message;
}

@end
