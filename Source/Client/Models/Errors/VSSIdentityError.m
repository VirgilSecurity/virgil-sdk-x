//
//  VSSIdentityError.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/16/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentityError.h"

/// HTTP 500. Server error status is returned on internal application errors
const NSInteger kVSSIdentityInternalError                               = 10000;

/// HTTP 400. Request error status is returned on request data validation errors
const NSInteger kVSSIdentityJSONError                                   = 40000;
const NSInteger kVSSIdentityIdentityTypeInvalidError                    = 40100;
const NSInteger kVSSIdentityIdentityTTLInvalidError                     = 40110;
const NSInteger kVSSIdentityIdentityCTLInvalidError                     = 40120;
const NSInteger kVSSIdentityTokenMissingError                           = 40130;
const NSInteger kVSSIdentityTokenDoesntMatchError                       = 40140;
const NSInteger kVSSIdentityTokenExpiredError                           = 40150;
const NSInteger kVSSIdentityTokenCannotBeDecryptedError                 = 40160;
const NSInteger kVSSIdentityTokenInvalidError                           = 40170;
const NSInteger kVSSIdentityIdentityIsNotUnconfirmedError               = 40180;
const NSInteger kVSSIdentityHashInvalidError                            = 40190;
const NSInteger kVSSIdentityEmailValueValidationFailedError             = 40200;
const NSInteger kVSSIdentityConfirmationCodeInvalidError                = 40210;
const NSInteger kVSSIdentityApplicationValueInvalidError                = 40300;
const NSInteger kVSSIdentityApplicationSignedMessageInvalidError        = 40310;
const NSInteger kVSSIdentityEntityNotFoundError                         = 41000;
const NSInteger kVSSIdentityConfirmationPerionHasExpiredError           = 41010;

@implementation VSSIdentityError

- (NSString *)message {
    NSString *message = nil;
    
    switch (self.code) {
        case kVSSIdentityInternalError: message = @"Internal application error"; break;
            
        /// HTTP 400. Request error status is returned on request data validation errors
        case kVSSIdentityJSONError: message = @"JSON specified as a request body is invalid"; break;
        case kVSSIdentityIdentityTypeInvalidError: message = @"Identity type is invalid"; break;
        case kVSSIdentityIdentityTTLInvalidError: message = @"Identity's ttl is invalid"; break;
        case kVSSIdentityIdentityCTLInvalidError: message = @"Identity's ctl is invalid"; break;
        case kVSSIdentityTokenMissingError: message = @"Identity's token parameter is missing"; break;
        case kVSSIdentityTokenDoesntMatchError: message = @"Identity's token doesn't match parameters"; break;
        case kVSSIdentityTokenExpiredError: message = @"Identity's token has expired"; break;
        case kVSSIdentityTokenCannotBeDecryptedError: message = @"Identity's token cannot be decrypted"; break;
        case kVSSIdentityTokenInvalidError: message = @"Identity's token parameter is invalid"; break;
        case kVSSIdentityIdentityIsNotUnconfirmedError: message = @"Identity is not unconfirmed"; break;
        case kVSSIdentityHashInvalidError: message = @"Hash to be signed parameter is invalid"; break;
        case kVSSIdentityEmailValueValidationFailedError: message = @"Email identity value validation failed"; break;
        case kVSSIdentityConfirmationCodeInvalidError: message = @"Identity's confirmation code is invalid"; break;
        case kVSSIdentityApplicationValueInvalidError: message = @"Application value is invalid"; break;
        case kVSSIdentityApplicationSignedMessageInvalidError: message = @"Application's signed message is invalid"; break;
        case kVSSIdentityEntityNotFoundError: message = @"Identity entity was not found"; break;
        case kVSSIdentityConfirmationPerionHasExpiredError: message = @"Identity's confirmation period has expired"; break;
    }
    
    return message;
}

@end
