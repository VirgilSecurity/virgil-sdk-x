//
//  VSSAuthError.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/22/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSError.h"

/// HTTP 500. Server error status is returned on internal application errors
extern const NSInteger kVSSAuthInternalError;

/// HTTP 400. Request error status is returned on request data validation errors
extern const NSInteger kVSSAuthResourceOwnerUuidValidationError;
extern const NSInteger kVSSAuthVirgilCardNotFoundError;
extern const NSInteger kVSSAuthVirgilCardNotAccessibleError;
extern const NSInteger kVSSAuthEncryptedMessageValidationFailedError;
extern const NSInteger kVSSAuthAuthAttemptExpiredError;
extern const NSInteger kVSSAuthGrantTypeNotSupportedError;
extern const NSInteger kVSSAuthAuthAttemptNotFoundError;
extern const NSInteger kVSSAuthAuthCodeExpiredError;
extern const NSInteger kVSSAuthAuthCodeAlreadyUserError;
extern const NSInteger kVSSAuthAccessCodeInvalidError;
extern const NSInteger kVSSAuthRefreshTokenNotFoundError;
extern const NSInteger kVSSAuthResourceOwnerVirgilCardNotVerifiedError;

/**
 * Concrete subclass representing the errors returning by the Virgil Auth Service.
 */
@interface VSSAuthError : VSSError

@end
