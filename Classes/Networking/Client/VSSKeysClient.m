//
//  VSSKeysClient.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysClient.h"

#import <VirgilKit/VSSPrivateKey.h>
#import <VirgilKit/VSSUserData.h>
#import <VirgilKit/VSSServiceRequest.h>
#import <VirgilKit/NSObject+VSSUtils.h>

#import <VirgilFoundation/VSSSigner.h>
#import <VirgilFoundation/VSSKeyPair.h>

#import "VSSCreatePublicKeyRequest.h"
#import "VSSGetPublicKeyRequest.h"
#import "VSSUpdatePublicKeyRequest.h"
#import "VSSDeletePublicKeyRequest.h"
#import "VSSResetPublicKeyRequest.h"
#import "VSSPersistPublicKeyRequest.h"
#import "VSSSearchPublicKeyRequest.h"
#import "VSSCreateUserDataRequest.h"
#import "VSSDeleteUserDataRequest.h"
#import "VSSPersistUserDataRequest.h"
#import "VSSResendConfirmationUserDataRequest.h"

static NSString *const kVSSKeysClientErrorDomain = @"VirgilKeysClientErrorDomain";

@interface VSSKeysClient ()

/**
 * Performs security sign for the actual HTTP request body with given private key, converts sign data to base64 format and set the specific HTTP header for the HTTP request.
 *
 * @param request VFServiceRequest object container for HTTP request which need to be signed.
 * @param key VFPrivateKey container with private key data.
 * @return NSError in case of some error during sign process or nil if all has finished successfuly.
 */
- (NSError * __nullable)signRequest:(VSSServiceRequest * __nonnull)request privateKey:(VSSPrivateKey * __nonnull)key;

@end

@implementation VSSKeysClient

#pragma mark - Overrides

- (NSString *)serviceURL {
    return @"https://keys.virgilsecurity.com/v2";
}

- (void)send:(VSSServiceRequest *)request {
    if (self.token.length > 0) {
        [request setRequestHeaders:@{ @"X-VIRGIL-APPLICATION-TOKEN": self.token }];
    }
    
    [super send:request];
}

#pragma mark - Public key related functionality

- (void)createPublicKey:(VSSPublicKey *)publicKey privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(VSSPublicKey *pubKey, NSError *error))completionHandler {
    if (publicKey == nil || privateKey == nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-103 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the creation of the public key can not be signed. Public or private key is absent.", @"CreatePublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }

        if (completionHandler != nil) {
            VSSCreatePublicKeyRequest *pkrequest = [request as:[VSSCreatePublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    
    VSSCreatePublicKeyRequest *request = [[VSSCreatePublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKey:publicKey];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey];
    if (signError != nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, signError);
            });
        }
        return;
    }
    
    [self send:request];
}

- (void)getPublicKeyId:(GUID *)publicKeyId completionHandler:(void(^)(VSSPublicKey *pubKey, NSError *error))completionHandler {
    if (publicKeyId.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-104 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the public key can not be sent. Public key's id is not set.", @"GetPublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSGetPublicKeyRequest *pkrequest = [request as:[VSSGetPublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    
    VSSGetPublicKeyRequest *request = [[VSSGetPublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId];
    request.completionHandler = handler;
    [self send:request];
}

- (void)updatePublicKeyId:(GUID *)publicKeyId privateKey:(VSSPrivateKey *)privateKey newKeyPair:(VSSKeyPair *)keyPair newKeyPassword:(NSString *)newKeyPassword completionHandler:(void(^)(VSSPublicKey *pubKey, NSError *error))completionHandler {
    if (publicKeyId.length == 0 || privateKey.key.length == 0 || keyPair == nil || keyPair.publicKey.length == 0 || keyPair.privateKey.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-105 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the public key's update can not be sent. Public key's id is not set, private key is not set or new key pair is not valid.", @"UpdatePublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSUpdatePublicKeyRequest *pkrequest = [request as:[VSSUpdatePublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    
    VSSUpdatePublicKeyRequest *request = [[VSSUpdatePublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId newKeyPair:keyPair keyPassword:newKeyPassword];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey];
    if (signError != nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, signError);
            });
        }
        return;
    }
    
    [request setRequestHeaders:@{ @"X-VIRGIL-REQUEST-SIGN-PK-ID": publicKeyId }];
    [self send:request];
}

- (void)deletePublicKeyId:(GUID *)publicKeyId privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(NSError *error))completionHandler {
    if (publicKeyId.length == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVSSKeysClientErrorDomain code:-106 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the deletion of the public key can not be sent. Public key's id is not set or private key is missing.", @"DeletePublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            completionHandler(nil);
        }
    };
    
    VSSDeletePublicKeyRequest *request = [[VSSDeletePublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey];
    if (signError != nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(signError);
            });
        }
        return;
    }
    
    [request setRequestHeaders:@{ @"X-VIRGIL-REQUEST-SIGN-PK-ID": publicKeyId }];
    [self send:request];
}

- (void)deletePublicKeyId:(GUID * __nonnull)publicKeyId completionHandler:(void(^ __nullable)(VSSActionToken *__nullable actionToken, NSError * __nullable error))completionHandler {
    if (publicKeyId.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-106 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the deletion of the public key can not be sent. Public key's id is not set.", @"DeletePublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSDeletePublicKeyRequest *pkrequest = [request as:[VSSDeletePublicKeyRequest class]];
            completionHandler(pkrequest.actionToken, nil);
        }
    };
    
    VSSDeletePublicKeyRequest *request = [[VSSDeletePublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId];
    request.completionHandler = handler;
    
    [self send:request];
}

- (void)resetPublicKeyId:(GUID *)publicKeyId keyPair:(VSSKeyPair *)keyPair keyPassword:(NSString *)keyPassword completionHandler:(void(^)(VSSActionToken *actionToken, NSError *error))completionHandler {
    if (publicKeyId.length == 0 || keyPair == nil || keyPair.publicKey.length == 0 || keyPair.privateKey.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-107 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the reset of the public key can not be sent. Public key's id is not set or new key pair is invalid.", @"ResetPublicKey") }]);
            });
        }
        return;
    }

    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSResetPublicKeyRequest *pkrequest = [request as:[VSSResetPublicKeyRequest class]];
            completionHandler(pkrequest.actionToken, nil);
        }
    };
    
    VSSResetPublicKeyRequest *request = [[VSSResetPublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId publicKey:keyPair.publicKey];
    request.completionHandler = handler;
    
    VSSPrivateKey *pKey = [[VSSPrivateKey alloc] initWithKey:keyPair.privateKey password:keyPassword];
    NSError *signError = [self signRequest:request privateKey:pKey];
    if (signError != nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, signError);
            });
        }
        return;
    }
    
    [self send:request];
}

- (void)persistPublicKeyId:(GUID *)publicKeyId actionToken:(VSSActionToken *)actionToken completionHandler:(void(^)(VSSPublicKey *pubKey, NSError *error))completionHandler {
    if (publicKeyId.length == 0 || actionToken == nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-108 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the persist public key can not be sent. Public key's id is not set or action token is invalid.", @"PersistPublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSPersistPublicKeyRequest *pkrequest = [request as:[VSSPersistPublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    VSSPersistPublicKeyRequest *request = [[VSSPersistPublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId actionToken:actionToken];
    request.completionHandler = handler;
    [self send:request];
}

- (void)searchPublicKeyId:(GUID *)publicKeyId privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(VSSPublicKey *pubKey, NSError *error))completionHandler {
    if (publicKeyId.length == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-109 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the searching of the public key can not be sent. Public key's id is not set private key is not set.", @"SearchPublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSSearchPublicKeyRequest *pkrequest = [request as:[VSSSearchPublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    
    VSSSearchPublicKeyRequest *request = [[VSSSearchPublicKeyRequest alloc] initWithBaseURL:self.serviceURL userIdValue:nil];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey];
    if (signError != nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, signError);
            });
        }
        return;
    }
    
    [request setRequestHeaders:@{ @"X-VIRGIL-REQUEST-SIGN-PK-ID": publicKeyId }];
    [self send:request];
}

- (void)searchPublicKeyUserIdValue:(NSString *)value completionHandler:(void(^)(VSSPublicKey *pubKey, NSError *error))completionHandler {
    if (value.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-110 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the searching of the public key can not be sent. User id value is not set.", @"SearchPublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSSearchPublicKeyRequest *pkrequest = [request as:[VSSSearchPublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    
    VSSSearchPublicKeyRequest *request = [[VSSSearchPublicKeyRequest alloc] initWithBaseURL:self.serviceURL userIdValue:value];
    request.completionHandler = handler;
    [self send:request];
}

#pragma mark - User data related functionality

- (void)createUserData:(VSSUserData *)userData publicKeyId:(GUID *)publicKeyId privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(VSSUserDataExtended *uData, NSError *error))completionHandler {
    if (userData == nil || publicKeyId.length == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-111 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the creation of the user data can not be sent. User data value is not valid, public key's id is not set or private key is absent.", @"CreateUserData") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSCreateUserDataRequest *udrequest = [request as:[VSSCreateUserDataRequest class]];
            completionHandler(udrequest.userData, nil);
        }
    };
    
    VSSCreateUserDataRequest *request = [[VSSCreateUserDataRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId userData:userData];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey];
    if (signError != nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, signError);
            });
        }
        return;
    }
    
    [request setRequestHeaders:@{ @"X-VIRGIL-REQUEST-SIGN-PK-ID": publicKeyId }];
    [self send:request];
}

- (void)deleteUserDataId:(GUID *)userDataId publicKeyId:(GUID *)publicKeyId privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(NSError *error))completionHandler {
    if (userDataId.length == 0 || publicKeyId.length == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVSSKeysClientErrorDomain code:-113 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the deletion of the user data can not be sent. User data id is not set, public key's id is not set or private key is absent.", @"DeleteUserData") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            completionHandler(nil);
        }
    };
    
    VSSDeleteUserDataRequest *request = [[VSSDeleteUserDataRequest alloc] initWithBaseURL:self.serviceURL userDataId:userDataId];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey];
    if (signError != nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(signError);
            });
        }
        return;
    }
    
    [request setRequestHeaders:@{ @"X-VIRGIL-REQUEST-SIGN-PK-ID": publicKeyId }];
    [self send:request];
}

- (void)persistUserDataId:(GUID *)userDataId confirmationCode:(NSString *)code completionHandler:(void(^)(NSError *error))completionHandler {
    if (userDataId.length == 0 || code.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVSSKeysClientErrorDomain code:-114 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the persist of the user data can not be sent. User data id is not set or confirmation code is absent.", @"PersistUserData") }]);
            });
        }
        return;
    }

    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            completionHandler(nil);
        }
    };
    
    VSSPersistUserDataRequest *request = [[VSSPersistUserDataRequest alloc] initWithBaseURL:self.serviceURL userDataId:userDataId confirmationCode:code];
    request.completionHandler = handler;
    [self send:request];
}

- (void)resendConfirmationUserDataId:(GUID *)userDataId publicKeyId:(GUID *)publicKeyId privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(NSError *error))completionHandler {
    if (userDataId.length == 0 || publicKeyId.length == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVSSKeysClientErrorDomain code:-115 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the confirmation code of the user data can not be sent. User data id is not set, public key id is not set or private key is absent.", @"ResendConfirmationUserData") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VSSServiceRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            completionHandler(nil);
        }
    };
    
    VSSResendConfirmationUserDataRequest *request = [[VSSResendConfirmationUserDataRequest alloc] initWithBaseURL:self.serviceURL userDataId:userDataId];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey];
    if (signError != nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(signError);
            });
        }
        return;
    }
    
    [request setRequestHeaders:@{ @"X-VIRGIL-REQUEST-SIGN-PK-ID": publicKeyId }];
    [self send:request];
}

#pragma mark - Private class logic

- (NSError *)signRequest:(VSSServiceRequest *)request privateKey:(VSSPrivateKey *)privateKey {
    if (request == nil || privateKey.key.length == 0) {
        VFCLDLog(@"There is nothing to sign: request or/and private key is/are not given.");
        return [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-100 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"There is nothing to sign: request or/and private key is/are not given.", @"Sign for the request is not possible.") }];
    }
    
    // Sign request body with given key.
    VSSSigner *signer = [[VSSSigner alloc] init];
    NSData *signData = [signer signData:request.request.HTTPBody privateKey:privateKey.key keyPassword:privateKey.password];
    if (signData.length == 0) {
        VFCLDLog(@"Unable to sign request data with given private key.");
        return [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-101 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to sign the request with given private key.", @"Sign for the request is failed.") }];;
    }
    
    // Encode sign to base64
    NSString *encodedSign = [signData base64EncodedStringWithOptions:0];
    if (encodedSign.length == 0) {
        VFCLDLog(@"Unable to encode received sign into base64 format.");
        return [NSError errorWithDomain:kVSSKeysClientErrorDomain code:-102 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to encode sign data to base64 format.", @"Sign for request can not be encoded.") }];;
    }
    
    [request setRequestHeaders:@{ @"X-VIRGIL-REQUEST-SIGN": encodedSign }];
    return nil;
}

@end
