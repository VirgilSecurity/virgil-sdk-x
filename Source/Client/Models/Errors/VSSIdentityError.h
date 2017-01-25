//
//  VSSIdentityError.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/16/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSError.h"

/// HTTP 500. Server error status is returned on internal application errors
extern const NSInteger kVSSIdentityInternalError;

/// HTTP 400. Request error status is returned on request data validation errors
extern const NSInteger kVSSIdentityJSONError;
extern const NSInteger kVSSIdentityIdentityTypeInvalidError;
extern const NSInteger kVSSIdentityIdentityTTLInvalidError;
extern const NSInteger kVSSIdentityIdentityCTLInvalidError;
extern const NSInteger kVSSIdentityTokenMissingError;
extern const NSInteger kVSSIdentityTokenDoesntMatchError;
extern const NSInteger kVSSIdentityTokenExpiredError;
extern const NSInteger kVSSIdentityTokenCannotBeDecryptedError;
extern const NSInteger kVSSIdentityTokenInvalidError;
extern const NSInteger kVSSIdentityIdentityIsNotUnconfirmedError;
extern const NSInteger kVSSIdentityHashInvalidError;
extern const NSInteger kVSSIdentityEmailValueValidationFailedError;
extern const NSInteger kVSSIdentityConfirmationCodeInvalidError;
extern const NSInteger kVSSIdentityApplicationValueInvalidError;
extern const NSInteger kVSSIdentityApplicationSignedMessageInvalidError;
extern const NSInteger kVSSIdentityEntityNotFoundError;
extern const NSInteger kVSSIdentityConfirmationPerionHasExpiredError;

/**
 * Concrete subclass representing the errors returning by the Virgil Identity Service.
 */
@interface VSSIdentityError : VSSError

@end
