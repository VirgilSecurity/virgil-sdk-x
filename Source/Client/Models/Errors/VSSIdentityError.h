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
extern const NSInteger kVSSIdentityIdentityTypeInvalid;
extern const NSInteger kVSSIdentityIdentityTTLInvalid;
extern const NSInteger kVSSIdentityIdentityCTLInvalid;
extern const NSInteger kVSSIdentityTokenMissing;
extern const NSInteger kVSSIdentityTokenDoesntMatch;
extern const NSInteger kVSSIdentityTokenExpired;
extern const NSInteger kVSSIdentityTokenCannotBeDecrypted;
extern const NSInteger kVSSIdentityTokenInvalid;
extern const NSInteger kVSSIdentityIdentityIsNotUnconfirmed;
extern const NSInteger kVSSIdentityHashInvalid;
extern const NSInteger kVSSIdentityEmailValueValidationFailed;
extern const NSInteger kVSSIdentityConfirmationCodeInvalid;
extern const NSInteger kVSSIdentityApplicationValueInvalid;
extern const NSInteger kVSSIdentityApplicationSignedMessageInvalid;
extern const NSInteger kVSSIdentityEntityNotFound;
extern const NSInteger kVSSIdentityConfirmationPerionHasExpired;

/**
 * Concrete subclass representing the errors returning by the Virgil Identity Service.
 */
@interface VSSIdentityError : VSSError

@end
