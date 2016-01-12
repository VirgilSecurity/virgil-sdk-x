//
//  VSSKeysError.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <VirgilKit/VSSError.h>

// General errors
extern const NSInteger kVSSKeysInternalError;
extern const NSInteger kVSSKeysJSONRequestError;
//Request sign errors
extern const NSInteger kVSSKeysUUIDDuplicateError;
extern const NSInteger kVSSKeysUUIDError;
extern const NSInteger kVSSKeysSignHeaderError;
extern const NSInteger kVSSKeysPublicKeyHeaderError;
extern const NSInteger kVSSKeysSignError;
extern const NSInteger kVSSKeysPublicKeyUUIDError;
extern const NSInteger kVSSKeysPublicKeyApplicationViolationError;
extern const NSInteger kVSSKeysPublicKeyBase64EncodingError;
extern const NSInteger kVSSKeysPublicKeyUUIDMatchError;
//Application token errors
extern const NSInteger kVSSKeysApplicationTokenError;
extern const NSInteger kVSSKeysStatisticsError;
//Endpoints errors
extern const NSInteger kVSSKeysPublicKeyRequiredError;
extern const NSInteger kVSSKeysActionTokenError;
extern const NSInteger kVSSKeysConfirmationCodesNumberError;
extern const NSInteger kVSSKeysConfirmationCodeError;
extern const NSInteger kVSSKeysPublicKeyIsNotFoundError;
extern const NSInteger kVSSKeysPublicKeyLengthError;
extern const NSInteger kVSSKeysPublicKeyError;
extern const NSInteger kVSSKeysPublicKeyEncodingError;
extern const NSInteger kVSSKeysPublicKeyUserDataUnconfirmedError;
extern const NSInteger kVSSKeysPublicKeyUserIdError;
extern const NSInteger kVSSKeysPublicKeyUDIDRegisteredError;
extern const NSInteger kVSSKeysPublicKeyUDIDsRegisteredError;
extern const NSInteger kVSSKeysPublicKeyIsNotFoundForApplicationError;
extern const NSInteger kVSSKeysPublicKeyIsFoundForApplicationError;
extern const NSInteger kVSSKeysPublicKeyIsRegisteredForApplicationError;
extern const NSInteger kVSSKeysUUIDSignVerificationError;
extern const NSInteger kVSSKeysUserDataIsNotFoundError;
extern const NSInteger kVSSKeysUserDataTypeError;
extern const NSInteger kVSSKeysUserDataDomainError;
extern const NSInteger kVSSKeysUserDataEmailError;
extern const NSInteger kVSSKeysUserDataPhoneError;
extern const NSInteger kVSSKeysUserDataConstraintError;
extern const NSInteger kVSSKeysUserDataConfirmationEntityError;
extern const NSInteger kVSSKeysUserDataConfirmationTokenError;
extern const NSInteger kVSSKeysUserDataConfirmationDuplicateError;
extern const NSInteger kVSSKeysUserDataClassError;
extern const NSInteger kVSSKeysUserDataDomainValueError;
extern const NSInteger kVSSKeysUserDataUserIdConfirmationDuplicateError;
extern const NSInteger kVSSKeysUserDataIsNotConfirmedError;
extern const NSInteger kVSSKeysUserDataValueError;
extern const NSInteger kVSSKeysUserDataUserInfoError;

@interface VSSKeysError : VSSError

@end
