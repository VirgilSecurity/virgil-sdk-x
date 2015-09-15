//
//  VKError.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKError.h"

// General errors
static const NSInteger kVKInternalError                             = 10000;
static const NSInteger kVKJSONRequestError                          = 10100;
//Request sign errors
static const NSInteger kVKUUIDDuplicateError                        = 10200;
static const NSInteger kVKUUIDError                                 = 10201;
static const NSInteger kVKSignHeaderError                           = 10202;
static const NSInteger kVKPublicKeyHeaderError                      = 10203;
static const NSInteger kVKSignError                                 = 10204;
static const NSInteger kVKPublicKeyUUIDError                        = 10207;
static const NSInteger kVKPublicKeyApplicationViolationError        = 10209;
static const NSInteger kVKPublicKeyBase64EncodingError              = 10210;
static const NSInteger kVKPublicKeyUUIDMatchError                   = 10211;
//Application token errors
static const NSInteger kVKApplicationTokenError                     = 10205;
static const NSInteger kVKStatisticsError                           = 10206;
//Endpoints errors
static const NSInteger kVKPublicKeyRequiredError                    = 10208;
static const NSInteger kVKActionTokenError                          = 20010;
static const NSInteger kVKConfirmationCodesNumberError              = 20011;
static const NSInteger kVKConfirmationCodeError                     = 20012;
static const NSInteger kVKPublicKeyIsNotFoundError                  = 20100;
static const NSInteger kVKPublicKeyLengthError                      = 20101;
static const NSInteger kVKPublicKeyError                            = 20102;
static const NSInteger kVKPublicKeyEncodingError                    = 20103;
static const NSInteger kVKPublicKeyUserDataUnconfirmedError         = 20104;
static const NSInteger kVKPublicKeyUserIdError                      = 20105;
static const NSInteger kVKPublicKeyUDIDRegisteredError              = 20107;
static const NSInteger kVKPublicKeyUDIDsRegisteredError             = 20108;
static const NSInteger kVKPublicKeyIsNotFoundForApplicationError    = 20110;
static const NSInteger kVKPublicKeyIsFoundForApplicationError       = 20111;
static const NSInteger kVKPublicKeyIsRegisteredForApplicationError  = 20112;
static const NSInteger kVKUUIDSignVerificationError                 = 20113;
static const NSInteger kVKUserDataIsNotFoundError                   = 20200;
static const NSInteger kVKUserDataTypeError                         = 20202;
static const NSInteger kVKUserDataDomainError                       = 20203;
static const NSInteger kVKUserDataEmailError                        = 20204;
static const NSInteger kVKUserDataPhoneError                        = 20205;
static const NSInteger kVKUserDataConstraintError                   = 20210;
static const NSInteger kVKUserDataConfirmationEntityError           = 20211;
static const NSInteger kVKUserDataConfirmationTokenError            = 20212;
static const NSInteger kVKUserDataConfirmationDuplicateError        = 20213;
static const NSInteger kVKUserDataClassError                        = 20214;
static const NSInteger kVKUserDataDomainValueError                  = 20215;
static const NSInteger kVKUserDataUserIdConfirmationDuplicateError  = 20216;
static const NSInteger kVKUserDataIsNotConfirmedError               = 20217;
static const NSInteger kVKUserDataValueError                        = 20218;
static const NSInteger kVKUserDataUserInfoError                     = 20300;

@implementation VKError

- (NSString *)message {
    NSString *message = nil;
    switch (self.code) {
        case kVKInternalError:
            message = @"Internal service error.";
            break;
        case kVKJSONRequestError:
            message = @"JSON specified as a request is invalid.";
            break;
        case kVKUUIDDuplicateError:
            message = @"The request_sign_uuid parameter was already used for another request.";
            break;
        case kVKUUIDError:
            message = @"The request_sign_uuid parameter is invalid.";
            break;
        case kVKSignHeaderError:
            message = @"The request sign header not found.";
            break;
        case kVKPublicKeyHeaderError:
            message = @"The Public Key header not specified or incorrect.";
            break;
        case kVKSignError:
            message = @"The request sign specified is incorrect.";
            break;
        case kVKPublicKeyUUIDError:
            message = @"The Public Key UUID passed in header was not confirmed yet.";
            break;
        case kVKPublicKeyApplicationViolationError:
            message = @"Public Key specified in authorization header is registered for another application.";
            break;
        case kVKPublicKeyBase64EncodingError:
            message = @"Public Key value in request body for POST /public-key endpoint must be base64 encoded value.";
            break;
        case kVKPublicKeyUUIDMatchError:
            message = @"Public Key UUIDs in URL part and X-VIRGIL-REQUEST-SIGN-PK-ID header must match.";
            break;
        case kVKApplicationTokenError:
            message = @"The Virgil application token not specified or invalid.";
            break;
        case kVKStatisticsError:
            message = @"The Virgil statistics application error.";
            break;
        case kVKPublicKeyRequiredError:
            message = @"Public Key value required in request body.";
            break;
        case kVKActionTokenError:
            message = @"Action token is invalid, expired on not found.";
            break;
        case kVKConfirmationCodesNumberError:
            message = @"Action token's confirmation codes number doesn't match.";
            break;
        case kVKConfirmationCodeError:
            message = @"One of action token's confirmation codes is invalid.";
            break;
        case kVKPublicKeyIsNotFoundError:
            message = @"Public Key object not found for id specified.";
            break;
        case kVKPublicKeyLengthError:
            message = @"Public key length invalid.";
            break;
        case kVKPublicKeyError:
            message = @"Public key not specified.";
            break;
        case kVKPublicKeyEncodingError:
            message = @"Public key must be base64-encoded string.";
            break;
        case kVKPublicKeyUserDataUnconfirmedError:
            message = @"Public key must contain confirmed UserData entities.";
            break;
        case kVKPublicKeyUserIdError:
            message = @"Public key must contain at least one 'user ID' entry.";
            break;
        case kVKPublicKeyUDIDRegisteredError:
            message = @"There is UDID registered for current application already.";
            break;
        case kVKPublicKeyUDIDsRegisteredError:
            message = @"UDIDs specified are registered for several accounts.";
            break;
        case kVKPublicKeyIsNotFoundForApplicationError:
            message = @"Public key is not found for any application.";
            break;
        case kVKPublicKeyIsFoundForApplicationError:
            message = @"Public key is found for another application.";
            break;
        case kVKPublicKeyIsRegisteredForApplicationError:
            message = @"Public key is registered for another application.";
            break;
        case kVKUUIDSignVerificationError:
            message = @"Sign verification failed for request UUID parameter in PUT /public-key.";
            break;
        case kVKUserDataIsNotFoundError:
            message = @"User Data object not found for id specified.";
            break;
        case kVKUserDataTypeError:
            message = @"User Data type specified as user identity is invalid.";
            break;
        case kVKUserDataDomainError:
            message = @"Domain value specified for the domain identity is invalid.";
            break;
        case kVKUserDataEmailError:
            message = @"Email value specified for the email identity is invalid.";
            break;
        case kVKUserDataPhoneError:
            message = @"Phone value specified for the phone identity is invalid.";
            break;
        case kVKUserDataConstraintError:
            message = @"User Data integrity constraint violation.";
            break;
        case kVKUserDataConfirmationEntityError:
            message = @"User Data confirmation entity not found.";
            break;
        case kVKUserDataConfirmationTokenError:
            message = @"User Data confirmation token invalid.";
            break;
        case kVKUserDataConfirmationDuplicateError:
            message = @"User Data was already confirmed and does not need further confirmation.";
            break;
        case kVKUserDataClassError:
            message = @"User Data class specified is invalid.";
            break;
        case kVKUserDataDomainValueError:
            message = @"Domain value specified for the domain identity is invalid.";
            break;
        case kVKUserDataUserIdConfirmationDuplicateError:
            message = @"This user id had been confirmed earlier.";
            break;
        case kVKUserDataIsNotConfirmedError:
            message = @"The user data is not confirmed yet.";
            break;
        case kVKUserDataValueError:
            message = @"The user data value is required.";
            break;
        case kVKUserDataUserInfoError:
            message = @"User info data validation failed.";
            break;
        default:
            break;
    }
    
    return message;
}

@end
