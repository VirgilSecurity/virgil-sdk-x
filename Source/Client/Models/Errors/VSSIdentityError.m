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
const NSInteger kVSSIdentityIdentityTypeInvalid                         = 40100;
const NSInteger kVSSIdentityIdentityTTLInvalid                          = 40110;
const NSInteger kVSSIdentityIdentityCTLInvalid                          = 40120;
const NSInteger kVSSIdentityTokenMissing                                = 40130;
const NSInteger kVSSIdentityTokenDoesntMatch                            = 40140;
const NSInteger kVSSIdentityTokenExpired                                = 40150;
const NSInteger kVSSIdentityTokenCannotBeDecrypted                      = 40160;
const NSInteger kVSSIdentityTokenInvalid                                = 40170;
const NSInteger kVSSIdentityIdentityIsNotUnconfirmed                    = 40180;
const NSInteger kVSSIdentityHashInvalid                                 = 40190;
const NSInteger kVSSIdentityEmailValueValidationFailed                  = 40200;
const NSInteger kVSSIdentityConfirmationCodeInvalid                     = 40210;
const NSInteger kVSSIdentityApplicationValueInvalid                     = 40300;
const NSInteger kVSSIdentityApplicationSignedMessageInvalid             = 40310;
const NSInteger kVSSIdentityEntityNotFound                              = 41000;
const NSInteger kVSSIdentityConfirmationPerionHasExpired                = 41010;

@implementation VSSIdentityError

- (NSString *)message {
    NSString *message = nil;
    
    switch (self.code) {
        case kVSSIdentityInternalError: message = @"Internal application error"; break;
            
        /// HTTP 400. Request error status is returned on request data validation errors
        case kVSSIdentityJSONError: message = @"JSON specified as a request body is invalid"; break;
        case kVSSIdentityIdentityTypeInvalid: message = @"Identity type is invalid"; break;
        case kVSSIdentityIdentityTTLInvalid: message = @"Identity's ttl is invalid"; break;
        case kVSSIdentityIdentityCTLInvalid: message = @"Identity's ctl is invalid"; break;
        case kVSSIdentityTokenMissing: message = @"Identity's token parameter is missing"; break;
        case kVSSIdentityTokenDoesntMatch: message = @"Identity's token doesn't match parameters"; break;
        case kVSSIdentityTokenExpired: message = @"Identity's token has expired"; break;
        case kVSSIdentityTokenCannotBeDecrypted: message = @"Identity's token cannot be decrypted"; break;
        case kVSSIdentityTokenInvalid: message = @"Identity's token parameter is invalid"; break;
        case kVSSIdentityIdentityIsNotUnconfirmed: message = @"Identity is not unconfirmed"; break;
        case kVSSIdentityHashInvalid: message = @"Hash to be signed parameter is invalid"; break;
        case kVSSIdentityEmailValueValidationFailed: message = @"Email identity value validation failed"; break;
        case kVSSIdentityConfirmationCodeInvalid: message = @"Identity's confirmation code is invalid"; break;
        case kVSSIdentityApplicationValueInvalid: message = @"Application value is invalid"; break;
        case kVSSIdentityApplicationSignedMessageInvalid: message = @"Application's signed message is invalid"; break;
        case kVSSIdentityEntityNotFound: message = @"Identity entity was not found"; break;
        case kVSSIdentityConfirmationPerionHasExpired: message = @"Identity's confirmation period has expired"; break;
    }
    
    return message;
}

@end
