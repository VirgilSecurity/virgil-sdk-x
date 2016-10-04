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

/// HTTP 401. Auth error status is returned on authorization errors
extern const NSInteger kVSSCardsIdHeaderDuplicationError;
extern const NSInteger kVSSCardsIdHeaderInvalidError;
extern const NSInteger kVSSCardsSignHeaderNotFoundError;
extern const NSInteger kVSSCardsCardIdHeaderInvalidError;
extern const NSInteger kVSSCardsSignHeaderInvalidError;
extern const NSInteger kVSSCardsPublicKeyValueNotFoundError;
extern const NSInteger kVSSCardsPublicKeyValueEncodingError;
extern const NSInteger kVSSCardsPublicKeyIdsMatchError;
extern const NSInteger kVSSCardsPublicKeyIdInvalidError;
extern const NSInteger kVSSCardsCardIdsMatchError;
extern const NSInteger kVSSCardsApplicationTokenInvalidError;
extern const NSInteger kVSSCardsStatisticsError;

/// HTTP 400. Request error status is returned on request data validation errors
extern const NSInteger kVSSCardsJSONError;
extern const NSInteger kVSSCardsPublicKeyIdError;
extern const NSInteger kVSSCardsPublicKeyLengthError;
extern const NSInteger kVSSCardsPublicKeyEncodingError;
extern const NSInteger kVSSCardsIdentityTypeError;
extern const NSInteger kVSSCardsIdentityEmailError;
extern const NSInteger kVSSCardsIdentityUnconfirmedApplicationError;
extern const NSInteger kVSSCardsIdentityApplicationValueError;
extern const NSInteger kVSSCardsCardNotFoundError;
extern const NSInteger kVSSCardsCardSignsListInvalidError;
extern const NSInteger kVSSCardsCardSignedDigestInvalidError;
extern const NSInteger kVSSCardsCardDataFormatInvalidError;
extern const NSInteger kVSSCardsCardDataArrayFormatInvalidError;
extern const NSInteger kVSSCardsCardDataLengthInvalidError;
extern const NSInteger kVSSCardsSignNotFoundError;
extern const NSInteger kVSSCardsSignedDigestInvalidError;
extern const NSInteger kVSSCardsSignedDigestEncodingError;
extern const NSInteger kVSSCardsSignDuplicationError;
extern const NSInteger kVSSCardsSearchValueInvalidError;
extern const NSInteger kVSSCardsApplicationSearchValueInvalidError;
extern const NSInteger kVSSCardsCardSignsFormatError;
extern const NSInteger kVSSCardsIdentityTokenInvalidError;
extern const NSInteger kVSSCardsCardRevocationMatchError;
extern const NSInteger kVSSCardsIdentityServiceError;
extern const NSInteger kVSSCardsIdentitiesInvalidError;
extern const NSInteger kVSSCardsIdentityInvalidError;

/**
 * Concrete subclass representing the errors returning by the Virgil Keys Service.
 */
@interface VSSCardsError : VSSError

@end
