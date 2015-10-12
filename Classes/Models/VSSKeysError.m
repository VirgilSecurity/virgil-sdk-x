//
//  VSSKeysError.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysError.h"

// General errors
const NSInteger kVSSKeysInternalError                             = 10000;
const NSInteger kVSSKeysJSONRequestError                          = 10100;
//Request sign errors
const NSInteger kVSSKeysUUIDDuplicateError                        = 10200;
const NSInteger kVSSKeysUUIDError                                 = 10201;
const NSInteger kVSSKeysSignHeaderError                           = 10202;
const NSInteger kVSSKeysPublicKeyHeaderError                      = 10203;
const NSInteger kVSSKeysSignError                                 = 10204;
const NSInteger kVSSKeysPublicKeyUUIDError                        = 10207;
const NSInteger kVSSKeysPublicKeyApplicationViolationError        = 10209;
const NSInteger kVSSKeysPublicKeyBase64EncodingError              = 10210;
const NSInteger kVSSKeysPublicKeyUUIDMatchError                   = 10211;
//Application token errors
const NSInteger kVSSKeysApplicationTokenError                     = 10205;
const NSInteger kVSSKeysStatisticsError                           = 10206;
//Endpoints errors
const NSInteger kVSSKeysPublicKeyRequiredError                    = 10208;
const NSInteger kVSSKeysActionTokenError                          = 20010;
const NSInteger kVSSKeysConfirmationCodesNumberError              = 20011;
const NSInteger kVSSKeysConfirmationCodeError                     = 20012;
const NSInteger kVSSKeysPublicKeyIsNotFoundError                  = 20100;
const NSInteger kVSSKeysPublicKeyLengthError                      = 20101;
const NSInteger kVSSKeysPublicKeyError                            = 20102;
const NSInteger kVSSKeysPublicKeyEncodingError                    = 20103;
const NSInteger kVSSKeysPublicKeyUserDataUnconfirmedError         = 20104;
const NSInteger kVSSKeysPublicKeyUserIdError                      = 20105;
const NSInteger kVSSKeysPublicKeyUDIDRegisteredError              = 20107;
const NSInteger kVSSKeysPublicKeyUDIDsRegisteredError             = 20108;
const NSInteger kVSSKeysPublicKeyIsNotFoundForApplicationError    = 20110;
const NSInteger kVSSKeysPublicKeyIsFoundForApplicationError       = 20111;
const NSInteger kVSSKeysPublicKeyIsRegisteredForApplicationError  = 20112;
const NSInteger kVSSKeysUUIDSignVerificationError                 = 20113;
const NSInteger kVSSKeysUserDataIsNotFoundError                   = 20200;
const NSInteger kVSSKeysUserDataTypeError                         = 20202;
const NSInteger kVSSKeysUserDataDomainError                       = 20203;
const NSInteger kVSSKeysUserDataEmailError                        = 20204;
const NSInteger kVSSKeysUserDataPhoneError                        = 20205;
const NSInteger kVSSKeysUserDataConstraintError                   = 20210;
const NSInteger kVSSKeysUserDataConfirmationEntityError           = 20211;
const NSInteger kVSSKeysUserDataConfirmationTokenError            = 20212;
const NSInteger kVSSKeysUserDataConfirmationDuplicateError        = 20213;
const NSInteger kVSSKeysUserDataClassError                        = 20214;
const NSInteger kVSSKeysUserDataDomainValueError                  = 20215;
const NSInteger kVSSKeysUserDataUserIdConfirmationDuplicateError  = 20216;
const NSInteger kVSSKeysUserDataIsNotConfirmedError               = 20217;
const NSInteger kVSSKeysUserDataValueError                        = 20218;
const NSInteger kVSSKeysUserDataUserInfoError                     = 20300;

@implementation VSSKeysError

- (NSString *)message {
    NSString *message = nil;
    switch (self.code) {
        case kVSSKeysInternalError:
            message = @"Internal service error.";
            break;
        case kVSSKeysJSONRequestError:
            message = @"JSON specified as a request is invalid.";
            break;
        case kVSSKeysUUIDDuplicateError:
            message = @"The request_sign_uuid parameter was already used for another request.";
            break;
        case kVSSKeysUUIDError:
            message = @"The request_sign_uuid parameter is invalid.";
            break;
        case kVSSKeysSignHeaderError:
            message = @"The request sign header not found.";
            break;
        case kVSSKeysPublicKeyHeaderError:
            message = @"The Public Key header not specified or incorrect.";
            break;
        case kVSSKeysSignError:
            message = @"The request sign specified is incorrect.";
            break;
        case kVSSKeysPublicKeyUUIDError:
            message = @"The Public Key UUID passed in header was not confirmed yet.";
            break;
        case kVSSKeysPublicKeyApplicationViolationError:
            message = @"Public Key specified in authorization header is registered for another application.";
            break;
        case kVSSKeysPublicKeyBase64EncodingError:
            message = @"Public Key value in request body for POST /public-key endpoint must be base64 encoded value.";
            break;
        case kVSSKeysPublicKeyUUIDMatchError:
            message = @"Public Key UUIDs in URL part and X-VIRGIL-REQUEST-SIGN-PK-ID header must match.";
            break;
        case kVSSKeysApplicationTokenError:
            message = @"The Virgil application token not specified or invalid.";
            break;
        case kVSSKeysStatisticsError:
            message = @"The Virgil statistics application error.";
            break;
        case kVSSKeysPublicKeyRequiredError:
            message = @"Public Key value required in request body.";
            break;
        case kVSSKeysActionTokenError:
            message = @"Action token is invalid, expired on not found.";
            break;
        case kVSSKeysConfirmationCodesNumberError:
            message = @"Action token's confirmation codes number doesn't match.";
            break;
        case kVSSKeysConfirmationCodeError:
            message = @"One of action token's confirmation codes is invalid.";
            break;
        case kVSSKeysPublicKeyIsNotFoundError:
            message = @"Public Key object not found for id specified.";
            break;
        case kVSSKeysPublicKeyLengthError:
            message = @"Public key length invalid.";
            break;
        case kVSSKeysPublicKeyError:
            message = @"Public key not specified.";
            break;
        case kVSSKeysPublicKeyEncodingError:
            message = @"Public key must be base64-encoded string.";
            break;
        case kVSSKeysPublicKeyUserDataUnconfirmedError:
            message = @"Public key must contain confirmed UserData entities.";
            break;
        case kVSSKeysPublicKeyUserIdError:
            message = @"Public key must contain at least one 'user ID' entry.";
            break;
        case kVSSKeysPublicKeyUDIDRegisteredError:
            message = @"There is UDID registered for current application already.";
            break;
        case kVSSKeysPublicKeyUDIDsRegisteredError:
            message = @"UDIDs specified are registered for several accounts.";
            break;
        case kVSSKeysPublicKeyIsNotFoundForApplicationError:
            message = @"Public key is not found for any application.";
            break;
        case kVSSKeysPublicKeyIsFoundForApplicationError:
            message = @"Public key is found for another application.";
            break;
        case kVSSKeysPublicKeyIsRegisteredForApplicationError:
            message = @"Public key is registered for another application.";
            break;
        case kVSSKeysUUIDSignVerificationError:
            message = @"Sign verification failed for request UUID parameter in PUT /public-key.";
            break;
        case kVSSKeysUserDataIsNotFoundError:
            message = @"User Data object not found for id specified.";
            break;
        case kVSSKeysUserDataTypeError:
            message = @"User Data type specified as user identity is invalid.";
            break;
        case kVSSKeysUserDataDomainError:
            message = @"Domain value specified for the domain identity is invalid.";
            break;
        case kVSSKeysUserDataEmailError:
            message = @"Email value specified for the email identity is invalid.";
            break;
        case kVSSKeysUserDataPhoneError:
            message = @"Phone value specified for the phone identity is invalid.";
            break;
        case kVSSKeysUserDataConstraintError:
            message = @"User Data integrity constraint violation.";
            break;
        case kVSSKeysUserDataConfirmationEntityError:
            message = @"User Data confirmation entity not found.";
            break;
        case kVSSKeysUserDataConfirmationTokenError:
            message = @"User Data confirmation token invalid.";
            break;
        case kVSSKeysUserDataConfirmationDuplicateError:
            message = @"User Data was already confirmed and does not need further confirmation.";
            break;
        case kVSSKeysUserDataClassError:
            message = @"User Data class specified is invalid.";
            break;
        case kVSSKeysUserDataDomainValueError:
            message = @"Domain value specified for the domain identity is invalid.";
            break;
        case kVSSKeysUserDataUserIdConfirmationDuplicateError:
            message = @"This user id had been confirmed earlier.";
            break;
        case kVSSKeysUserDataIsNotConfirmedError:
            message = @"The user data is not confirmed yet.";
            break;
        case kVSSKeysUserDataValueError:
            message = @"The user data value is required.";
            break;
        case kVSSKeysUserDataUserInfoError:
            message = @"User info data validation failed.";
            break;
        default:
            break;
    }
    
    return message;
}

@end
