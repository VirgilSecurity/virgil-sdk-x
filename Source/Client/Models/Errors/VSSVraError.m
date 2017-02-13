//
//  VSSVraError.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/25/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVraError.h"

/// HTTP 500. Server error status is returned on internal application errors
const NSInteger kVSSVraInternalError                                    = 10000;

/// HTTP 400. This status is returned on request data errors.
const NSInteger kVSSVraDevelopmentPortalSignNotFoundError               = 30300;
const NSInteger kVSSVraDevelopmentPortalSignInvalidError                = 30301;
const NSInteger kVSSVraDevelopmentPortalCardNotFoundError               = 30302;
const NSInteger kVSSVraIdentityValidationTokenInvalidOrExpiredError     = 30303;
const NSInteger kVSSVraProvidedCardNotFoundOrIvalidError                = 30304;

/// HTTP 404. This status is returned in case of routing error.
const NSInteger kVSSVraRequestRouteNotFoundError                        = 50010;

@implementation VSSVraError

- (NSString *)message {
    NSString *message = nil;
    
    switch (self.code) {
        /// HTTP 500. Server error status is returned on internal application errors
        case kVSSVraInternalError: message = @"Internal application error."; break;
        
        /// HTTP 400. This status is returned on request data errors.
        case kVSSVraDevelopmentPortalSignNotFoundError: message = @"Development Portal sign was not found inside the meta.signs property"; break;
        case kVSSVraDevelopmentPortalSignInvalidError: message = @"Development Portal sign is invalid"; break;
        case kVSSVraDevelopmentPortalCardNotFoundError: message = @"Development Portal Virgil Card was not found on Cards service"; break;
        case kVSSVraIdentityValidationTokenInvalidOrExpiredError: message = @"Identity Validation Token is invalid or has expired"; break;
        case kVSSVraProvidedCardNotFoundOrIvalidError: message = @"Provided Virgil Card was not found or invalid"; break;
        
        /// HTTP 404. This status is returned in case of routing error.
        case kVSSVraRequestRouteNotFoundError: message = @"Requested route was not found"; break;
    }

    
    return message;
}

@end
