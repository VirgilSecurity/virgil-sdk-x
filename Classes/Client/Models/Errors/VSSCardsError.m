//
//  VSSCardsError.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSCardsError.h"

/// HTTP 500. Server error status is returned on internal application errors
const NSInteger kVSSCardsInternalError                               = 10000;

/// HTTP 401. Auth error status is returned on authorization errors
const NSInteger kVSSCardsIdHeaderDuplicationError                    = 20100;
const NSInteger kVSSCardsIdHeaderInvalidError                        = 20101;
const NSInteger kVSSCardsSignHeaderNotFoundError                     = 20200;
const NSInteger kVSSCardsCardIdHeaderInvalidError                    = 20201;
const NSInteger kVSSCardsSignHeaderInvalidError                      = 20202;
const NSInteger kVSSCardsPublicKeyValueNotFoundError                 = 20203;
const NSInteger kVSSCardsPublicKeyValueEncodingError                 = 20204;
const NSInteger kVSSCardsPublicKeyIdsMatchError                      = 20205;
const NSInteger kVSSCardsPublicKeyIdInvalidError                     = 20206;
const NSInteger kVSSCardsCardIdsMatchError                           = 20208;
const NSInteger kVSSCardsApplicationTokenInvalidError                = 20300;
const NSInteger kVSSCardsStatisticsError                             = 20301;

/// HTTP 400. Request error status is returned on request data validation errors
const NSInteger kVSSCardsJSONError                                   = 30000;
const NSInteger kVSSCardsPublicKeyIdError                            = 30100;
const NSInteger kVSSCardsPublicKeyLengthError                        = 30101;
const NSInteger kVSSCardsPublicKeyEncodingError                      = 30102;
const NSInteger kVSSCardsIdentityTypeError                           = 30201;
const NSInteger kVSSCardsIdentityEmailError                          = 30202;
const NSInteger kVSSCardsIdentityUnconfirmedApplicationError         = 30203;
const NSInteger kVSSCardsIdentityApplicationValueError               = 30204;
const NSInteger kVSSCardsCardNotFoundError                           = 30300;
const NSInteger kVSSCardsCardSignsListInvalidError                   = 30301;
const NSInteger kVSSCardsCardSignedDigestInvalidError                = 30302;
const NSInteger kVSSCardsCardDataFormatInvalidError                  = 30303;
const NSInteger kVSSCardsCardDataArrayFormatInvalidError             = 30304;
const NSInteger kVSSCardsCardDataLengthInvalidError                  = 30305;
const NSInteger kVSSCardsSignNotFoundError                           = 30400;
const NSInteger kVSSCardsSignedDigestInvalidError                    = 30402;
const NSInteger kVSSCardsSignedDigestEncodingError                   = 30403;
const NSInteger kVSSCardsSignDuplicationError                        = 30404;
const NSInteger kVSSCardsSearchValueInvalidError                     = 31000;
const NSInteger kVSSCardsApplicationSearchValueInvalidError          = 31010;
const NSInteger kVSSCardsCardSignsFormatError                        = 31020;
const NSInteger kVSSCardsIdentityTokenInvalidError                   = 31030;
const NSInteger kVSSCardsCardRevocationMatchError                    = 31040;
const NSInteger kVSSCardsIdentityServiceError                        = 31050;
const NSInteger kVSSCardsIdentitiesInvalidError                      = 31060;
const NSInteger kVSSCardsIdentityInvalidError                        = 31070;

@implementation VSSCardsError

- (NSString *)message {
    NSString *message = nil;
    switch (self.code) {
        case kVSSCardsInternalError:
            message = @"Internal service error.";
            break;
        case kVSSCardsIdHeaderDuplicationError:
            message = @"The request ID header was used already.";
            break;
        case kVSSCardsIdHeaderInvalidError:
            message = @"The request ID header is invalid.";
            break;
        case kVSSCardsSignHeaderNotFoundError:
            message = @"The request sign header not found.";
            break;
        case kVSSCardsCardIdHeaderInvalidError:
            message = @"The Virgil Card ID header not specified or incorrect.";
            break;
        case kVSSCardsSignHeaderInvalidError:
            message = @" The request sign header is invalid.";
            break;
        case kVSSCardsPublicKeyValueNotFoundError:
            message = @"Public Key value is required in request body.";
            break;
        case kVSSCardsPublicKeyValueEncodingError:
            message = @"Public Key value in request body must be base64 encoded value.";
            break;
        case kVSSCardsPublicKeyIdsMatchError:
            message = @"Public Key IDs in URL part and public key for the Virgil Card retrieved from X-VIRGIL-REQUEST-SIGN-VIRGIL-CARD-ID header must match.";
            break;
        case kVSSCardsPublicKeyIdInvalidError:
            message = @"The public key id in the request body is invalid.";
            break;
        case kVSSCardsCardIdsMatchError:
            message = @"Virgil card ids in url and authentication header must match.";
            break;
        case kVSSCardsApplicationTokenInvalidError:
            message = @"The Virgil application token was not specified or invalid.";
            break;
        case kVSSCardsStatisticsError:
            message = @"The Virgil statistics application error.";
            break;
        case kVSSCardsJSONError:
            message = @"JSON specified as a request body is invalid.";
            break;
        case kVSSCardsPublicKeyIdError:
            message = @"Public Key ID is invalid.";
            break;
        case kVSSCardsPublicKeyLengthError:
            message = @"Public key length invalid.";
            break;
        case kVSSCardsPublicKeyEncodingError:
            message = @"Public key must be base64-encoded string.";
            break;
        case kVSSCardsIdentityTypeError:
            message = @"Identity type is invalid. Valid types are: 'email', 'application'.";
            break;
        case kVSSCardsIdentityEmailError:
            message = @"Email value specified for the email identity is invalid.";
            break;
        case kVSSCardsIdentityUnconfirmedApplicationError:
            message = @"Cannot create unconfirmed application identity.";
            break;
        case kVSSCardsIdentityApplicationValueError:
            message = @"Application value specified for the application identity is invalid.";
            break;
        case kVSSCardsCardNotFoundError:
            message = @"Signed Virgil Card not found by UUID provided.";
            break;
        case kVSSCardsCardSignsListInvalidError:
            message = @"Virgil Card's signs list contains an item with invalid signed_id value.";
            break;
        case kVSSCardsCardSignedDigestInvalidError:
            message = @"Virgil Card's one of sined digests is invalid.";
            break;
        case kVSSCardsCardDataFormatInvalidError:
            message = @"Virgil Card's data parameters must be strings.";
            break;
        case kVSSCardsCardDataArrayFormatInvalidError:
            message = @"Virgil Card's data parameters must be an array of strings.";
            break;
        case kVSSCardsCardDataLengthInvalidError:
            message = @"Virgil Card custom data entry value length validation failed.";
            break;
        case kVSSCardsSignNotFoundError:
            message = @"Sign object not found for id specified.";
            break;
        case kVSSCardsSignedDigestInvalidError:
            message = @"The signed digest value is invalid.";
            break;
        case kVSSCardsSignedDigestEncodingError:
            message = @"Sign Signed digest must be base64 encoded string.";
            break;
        case kVSSCardsSignDuplicationError:
            message = @"Cannot save the Sign because it exists already.";
            break;
        case kVSSCardsSearchValueInvalidError:
            message = @"Value search parameter is mandatory.";
            break;
        case kVSSCardsApplicationSearchValueInvalidError:
            message = @"Search value parameter is mandatory for the application search.";
            break;
        case kVSSCardsCardSignsFormatError:
            message = @"Virgil Card's signs parameter must be an array.";
            break;
        case kVSSCardsIdentityTokenInvalidError:
            message = @"Identity validation token is invalid.";
            break;
        case kVSSCardsCardRevocationMatchError:
            message = @"Virgil Card revokation parameters do not match Virgil Card's identity.";
            break;
        case kVSSCardsIdentityServiceError:
            message = @"Virgil Identity service error.";
            break;
        case kVSSCardsIdentitiesInvalidError:
            message = @"Identities parameter is invalid.";
            break;
        case kVSSCardsIdentityInvalidError:
            message = @"Identity validation failed.";
            break;
        default:
            break;
    }
    
    return message;
}

@end
