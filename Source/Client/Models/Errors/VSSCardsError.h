//
//  VSSCardsError.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSError.h"

/// HTTP 500. Server error status is returned on internal application errors
extern const NSInteger kVSSCardsInternalError;

/// HTTP 401. Authorization errors
extern const NSInteger kVSSCardsTokenMissingOrInvalidError;
extern const NSInteger kVSSCardsAuthenticatorError;
extern const NSInteger kVSSCardsAccessTokenValidationError;
extern const NSInteger kVSSCardsApplicationNotFoundError;

/// HTTP 403. Forbidden
extern const NSInteger kVSSCardsCardNotAvailableError;

/// HTTP 400. Request error status is returned on request data validation errors
extern const NSInteger kVSSCardsJSONError;
extern const NSInteger kVSSCardsDataInconsistencyError;
extern const NSInteger kVSSCardsGlobalCardIdentityTypeError;
extern const NSInteger kVSSCardsCardScopeError;
extern const NSInteger kVSSCardsCardIdValidationFailedError;
extern const NSInteger kVSSCardsCardDataTooBigError;
extern const NSInteger kVSSCardsCardInfoParameterEmptyError;
extern const NSInteger kVSSCardsCardInfoParameterTooBigError;
extern const NSInteger kVSSCardsCardDataParameterError;
extern const NSInteger kVSSCardsCSRParameterMissingOrInvalidError;
extern const NSInteger kVSSCardsIdentitiesError;
extern const NSInteger kVSSCardsIdentityTypeError;
extern const NSInteger kVSSCardsSegregatedIdentityError;
extern const NSInteger kVSSCardsIdentityEmailError;
extern const NSInteger kVSSCardsIdentityApplicationError;
extern const NSInteger kVSSCardsPublicKeyLengthError;
extern const NSInteger kVSSCardsPublicKeyFormatError;
extern const NSInteger kVSSCardsCardDataParameterKVError;
extern const NSInteger kVSSCardsCardDataParameterStrError;
extern const NSInteger kVSSCardsDataTooBigError;
extern const NSInteger kVSSCardsCSRSignsMissingOrInvalidError;
extern const NSInteger kVSSCardsCSRDigestMissingOrInvalidError;
extern const NSInteger kVSSCardsCardIdMismatchError;
extern const NSInteger kVSSCardsCSRSignForIdentityServiceError;
extern const NSInteger kVSSCardsGlobalCardUnconfirmedError;
extern const NSInteger kVSSCardsDuplicateFingerprintError;
extern const NSInteger kVSSCardsRevocationReasonMissingOrInvalidError;
extern const NSInteger kVSSCardsSCRValidationFailedError;
extern const NSInteger kVSSCardsSCROneOfSignersNotFoundError;
extern const NSInteger kVSSCardsSCRSignItemInvalidOrMissingClientError;
extern const NSInteger kVSSCardsSCRSignItemInvalidOrMissingVRAError;
extern const NSInteger kVSSCardsRelationSignInvalidError;
extern const NSInteger kVSSCardsRelationSignNotFoundError;
extern const NSInteger kVSSCardsRelatedSnapshotNotFoundError;
extern const NSInteger kVSSCardsRelationAlreadyExistsError;
extern const NSInteger kVSSCardsCardNotFoundForCSRError;
extern const NSInteger kVSSCardsRelationDoesntExistError;

/**
 * Concrete subclass representing the errors returning by the Virgil Keys Service.
 */
@interface VSSCardsError : VSSError

@end
