
//
//  VSSVraError.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/25/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSError.h"

/// HTTP 500. Server error status is returned on internal application errors
extern const NSInteger kVSSVraInternalError;

/// HTTP 400. This status is returned on request data errors.
extern const NSInteger kVSSVraDevelopmentPortalSignNotFoundError;
extern const NSInteger kVSSVraDevelopmentPortalSignInvalidError;
extern const NSInteger kVSSVraDevelopmentPortalCardNotFoundError;
extern const NSInteger kVSSVraIdentityValidationTokenInvalidOrExpiredError;
extern const NSInteger kVSSVraProvidedCardNotFoundOrIvalidError;

/// HTTP 404. This status is returned in case of routing error.
extern const NSInteger kVSSVraRequestRouteNotFoundError;

/**
 * Concrete subclass representing the errors returning by the VRA Service.
 */
@interface VSSVraError : VSSError

@end
