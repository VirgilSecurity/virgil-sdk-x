//
//  VKError.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <VirgilFrameworkiOS/VFError.h>

// General errors
extern const NSInteger kVKInternalError;
extern const NSInteger kVKJSONRequestError;
//Request sign errors
extern const NSInteger kVKUUIDDuplicateError;
extern const NSInteger kVKUUIDError;
extern const NSInteger kVKSignHeaderError;
extern const NSInteger kVKPublicKeyHeaderError;
extern const NSInteger kVKSignError;
extern const NSInteger kVKPublicKeyUUIDError;
extern const NSInteger kVKPublicKeyApplicationViolationError;
extern const NSInteger kVKPublicKeyBase64EncodingError;
extern const NSInteger kVKPublicKeyUUIDMatchError;
//Application token errors
extern const NSInteger kVKApplicationTokenError;
extern const NSInteger kVKStatisticsError;
//Endpoints errors
extern const NSInteger kVKPublicKeyRequiredError;
extern const NSInteger kVKActionTokenError;
extern const NSInteger kVKConfirmationCodesNumberError;
extern const NSInteger kVKConfirmationCodeError;
extern const NSInteger kVKPublicKeyIsNotFoundError;
extern const NSInteger kVKPublicKeyLengthError;
extern const NSInteger kVKPublicKeyError;
extern const NSInteger kVKPublicKeyEncodingError;
extern const NSInteger kVKPublicKeyUserDataUnconfirmedError;
extern const NSInteger kVKPublicKeyUserIdError;
extern const NSInteger kVKPublicKeyUDIDRegisteredError;
extern const NSInteger kVKPublicKeyUDIDsRegisteredError;
extern const NSInteger kVKPublicKeyIsNotFoundForApplicationError;
extern const NSInteger kVKPublicKeyIsFoundForApplicationError;
extern const NSInteger kVKPublicKeyIsRegisteredForApplicationError;
extern const NSInteger kVKUUIDSignVerificationError;
extern const NSInteger kVKUserDataIsNotFoundError;
extern const NSInteger kVKUserDataTypeError;
extern const NSInteger kVKUserDataDomainError;
extern const NSInteger kVKUserDataEmailError;
extern const NSInteger kVKUserDataPhoneError;
extern const NSInteger kVKUserDataConstraintError;
extern const NSInteger kVKUserDataConfirmationEntityError;
extern const NSInteger kVKUserDataConfirmationTokenError;
extern const NSInteger kVKUserDataConfirmationDuplicateError;
extern const NSInteger kVKUserDataClassError;
extern const NSInteger kVKUserDataDomainValueError;
extern const NSInteger kVKUserDataUserIdConfirmationDuplicateError;
extern const NSInteger kVKUserDataIsNotConfirmedError;
extern const NSInteger kVKUserDataValueError;
extern const NSInteger kVKUserDataUserInfoError;

@interface VKError : VFError

@end
