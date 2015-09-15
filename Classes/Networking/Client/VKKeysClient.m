//
//  VKKeysClient.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKKeysClient.h"

#import <VirgilFrameworkiOS/VFServiceRequest.h>
#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

#import <VirgilCryptoiOS/VCSigner.h>
#import <VirgilCryptoiOS/VCKeyPair.h>

#import "VKCreatePublicKeyRequest.h"
#import "VKGetPublicKeyRequest.h"
#import "VKUpdatePublicKeyRequest.h"
#import "VKDeletePublicKeyRequest.h"
#import "VKResetPublicKeyRequest.h"
#import "VKPersistPublicKeyRequest.h"
#import "VKSearchPublicKeyRequest.h"
#import "VKCreateUserDataRequest.h"
#import "VKDeleteUserDataRequest.h"
#import "VKPersistUserDataRequest.h"
#import "VKResendConfirmationUserDataRequest.h"

static NSString *const kVKKeysClientErrorDomain = @"VirgilKeysClientErrorDomain";

@interface VKKeysClient ()

/**
 * Performs security sign for the actual HTTP request body with given private key, converts sign data to base64 format and set the specific HTTP header for the HTTP request.
 *
 * @param request VFServiceRequest object container for HTTP request which need to be signed.
 * @param key NSData with private key data.
 * @param keyPassword NSString with password that protect the private key data. May be nil in case of unprotected private key.
 * @return NSError in case of some error during sign process or nil if all has finished successfuly.
 */
- (NSError *)signRequest:(VFServiceRequest *)request privateKey:(NSData *)key keyPassword:(NSString *)keyPassword;

@end

@implementation VKKeysClient

#pragma mark - Overrides

- (NSString *)serviceURL {
#warning SET PROPER URL!
    return @"https://keys-stg.virgilsecurity.com/v2";
//    return @"https://keys.virgilsecurity.com/v2";
}

- (void)send:(VFServiceRequest *)request {
    if (self.token.length > 0) {
        [request setRequestHeaders:@{ @"X-VIRGIL-APPLICATION-TOKEN": self.token }];
    }
    
    [super send:request];
}

#pragma mark - Public key related functionality

- (void)createPublicKey:(VKPublicKey *)publicKey privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler {
    if (publicKey == nil || privateKey == nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVKKeysClientErrorDomain code:-103 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the creation of the public key can not be signed. Public or private key is absent.", @"CreatePublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }

        if (completionHandler != nil) {
            VKCreatePublicKeyRequest *pkrequest = [request as:[VKCreatePublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    
    VKCreatePublicKeyRequest *request = [[VKCreatePublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKey:publicKey];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey keyPassword:keyPassword];
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

- (void)getPublicKeyId:(GUID *)publicKeyId completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler {
    if (publicKeyId.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVKKeysClientErrorDomain code:-104 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the public key can not be sent. Public key's id is not set.", @"GetPublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VKGetPublicKeyRequest *pkrequest = [request as:[VKGetPublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    
    VKGetPublicKeyRequest *request = [[VKGetPublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId];
    request.completionHandler = handler;
    [self send:request];
}

- (void)updatePublicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword newKeyPair:(VCKeyPair *)keyPair newKeyPassword:(NSString *)newKeyPassword completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler {
    if (publicKeyId.length == 0 || privateKey.length == 0 || keyPair == nil || keyPair.publicKey.length == 0 || keyPair.privateKey.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVKKeysClientErrorDomain code:-105 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the public key's update can not be sent. Public key's id is not set, private key is not set or new key pair is not valid.", @"UpdatePublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VKUpdatePublicKeyRequest *pkrequest = [request as:[VKUpdatePublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    
    VKUpdatePublicKeyRequest *request = [[VKUpdatePublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId newKeyPair:keyPair keyPassword:newKeyPassword];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey keyPassword:keyPassword];
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

- (void)deletePublicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(VKActionToken *actionToken, NSError *error))completionHandler {
    if (publicKeyId.length == 0 || privateKey.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVKKeysClientErrorDomain code:-106 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the deletion of the public key can not be sent. Public key's id is not set or private key is missing.", @"DeletePublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VKDeletePublicKeyRequest *pkrequest = [request as:[VKDeletePublicKeyRequest class]];
            completionHandler(pkrequest.actionToken, nil);
        }
    };
    
    VKDeletePublicKeyRequest *request = [[VKDeletePublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey keyPassword:keyPassword];
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

- (void)resetPublicKeyId:(GUID *)publicKeyId keyPair:(VCKeyPair *)keyPair keyPassword:(NSString *)keyPassword completionHandler:(void(^)(VKActionToken *actionToken, NSError *error))completionHandler {
    if (publicKeyId.length == 0 || keyPair == nil || keyPair.publicKey.length == 0 || keyPair.privateKey.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVKKeysClientErrorDomain code:-107 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the reset of the public key can not be sent. Public key's id is not set or new key pair is invalid.", @"ResetPublicKey") }]);
            });
        }
        return;
    }

    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VKResetPublicKeyRequest *pkrequest = [request as:[VKResetPublicKeyRequest class]];
            completionHandler(pkrequest.actionToken, nil);
        }
    };
    
    VKResetPublicKeyRequest *request = [[VKResetPublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId publicKey:keyPair.publicKey];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:keyPair.privateKey keyPassword:keyPassword];
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

- (void)persistPublicKeyId:(GUID *)publicKeyId actionToken:(VKActionToken *)actionToken completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler {
    if (publicKeyId.length == 0 || actionToken == nil) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVKKeysClientErrorDomain code:-108 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the persist public key can not be sent. Public key's id is not set or action token is invalid.", @"PersistPublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VKPersistPublicKeyRequest *pkrequest = [request as:[VKPersistPublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    VKPersistPublicKeyRequest *request = [[VKPersistPublicKeyRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId actionToken:actionToken];
    request.completionHandler = handler;
    [self send:request];
}

- (void)searchPublicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler {
    if (publicKeyId.length == 0 || privateKey.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVKKeysClientErrorDomain code:-109 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the searching of the public key can not be sent. Public key's id is not set private key is not set.", @"SearchPublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VKSearchPublicKeyRequest *pkrequest = [request as:[VKSearchPublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    
    VKSearchPublicKeyRequest *request = [[VKSearchPublicKeyRequest alloc] initWithBaseURL:self.serviceURL userIdValue:nil];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey keyPassword:keyPassword];
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

- (void)searchPublicKeyUserIdValue:(NSString *)value completionHandler:(void(^)(VKPublicKey *pubKey, NSError *error))completionHandler {
    if (value.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVKKeysClientErrorDomain code:-110 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the searching of the public key can not be sent. User id value is not set.", @"SearchPublicKey") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VKSearchPublicKeyRequest *pkrequest = [request as:[VKSearchPublicKeyRequest class]];
            completionHandler(pkrequest.publicKey, nil);
        }
    };
    
    VKSearchPublicKeyRequest *request = [[VKSearchPublicKeyRequest alloc] initWithBaseURL:self.serviceURL userIdValue:value];
    request.completionHandler = handler;
    [self send:request];
}

#pragma mark - User data related functionality

- (void)createUserData:(VKUserData *)userData publicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(VKUserData *uData, NSError *error))completionHandler {
    if (userData == nil || publicKeyId.length == 0 || privateKey.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVKKeysClientErrorDomain code:-111 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the creation of the user data can not be sent. User data value is not valid, public key's id is not set or private key is absent.", @"CreateUserData") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VKCreateUserDataRequest *udrequest = [request as:[VKCreateUserDataRequest class]];
            completionHandler(udrequest.userData, nil);
        }
    };
    
    VKCreateUserDataRequest *request = [[VKCreateUserDataRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:nil userData:userData];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey keyPassword:keyPassword];
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

- (void)createUserData:(VKUserData *)userData publicKeyId:(GUID *)publicKeyId completionHandler:(void(^)(VKUserData *uData, NSError *error))completionHandler {
    if (userData == nil || publicKeyId.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVKKeysClientErrorDomain code:-112 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the creation of the user data can not be sent. User data value is not valid or public key's id is not set.", @"CreateUserData") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VKCreateUserDataRequest *udrequest = [request as:[VKCreateUserDataRequest class]];
            completionHandler(udrequest.userData, nil);
        }
    };
    
    VKCreateUserDataRequest *request = [[VKCreateUserDataRequest alloc] initWithBaseURL:self.serviceURL publicKeyId:publicKeyId userData:userData];
    request.completionHandler = handler;
    [self send:request];
}

- (void)deleteUserDataId:(GUID *)userDataId publicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(NSError *error))completionHandler {
    if (userDataId.length == 0 || publicKeyId.length == 0 || privateKey.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVKKeysClientErrorDomain code:-113 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the deletion of the user data can not be sent. User data id is not set, public key's id is not set or private key is absent.", @"DeleteUserData") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            completionHandler(nil);
        }
    };
    
    VKDeleteUserDataRequest *request = [[VKDeleteUserDataRequest alloc] initWithBaseURL:self.serviceURL userDataId:userDataId];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey keyPassword:keyPassword];
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
                completionHandler([NSError errorWithDomain:kVKKeysClientErrorDomain code:-114 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the persist of the user data can not be sent. User data id is not set or confirmation code is absent.", @"PersistUserData") }]);
            });
        }
        return;
    }

    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            completionHandler(nil);
        }
    };
    
    VKPersistUserDataRequest *request = [[VKPersistUserDataRequest alloc] initWithBaseURL:self.serviceURL userDataId:userDataId confirmationCode:code];
    request.completionHandler = handler;
    [self send:request];
}

- (void)resendConfirmationUserDataId:(GUID *)userDataId publicKeyId:(GUID *)publicKeyId privateKey:(NSData *)privateKey keyPassword:(NSString *)keyPassword completionHandler:(void(^)(NSError *error))completionHandler {
    if (userDataId.length == 0 || publicKeyId.length == 0 || privateKey.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVKKeysClientErrorDomain code:-115 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Request for the confirmation code of the user data can not be sent. User data id is not set, public key id is not set or private key is absent.", @"ResendConfirmationUserData") }]);
            });
        }
        return;
    }
    
    ServiceRequestCompletionHandler handler = ^(VFServiceRequest *request) {
        if (request.status != Done) {
            if (completionHandler != nil) {
                completionHandler(request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            completionHandler(nil);
        }
    };
    
    VKResendConfirmationUserDataRequest *request = [[VKResendConfirmationUserDataRequest alloc] initWithBaseURL:self.serviceURL userDataId:userDataId];
    request.completionHandler = handler;
    
    NSError *signError = [self signRequest:request privateKey:privateKey keyPassword:keyPassword];
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

- (NSError *)signRequest:(VFServiceRequest *)request privateKey:(NSData *)key keyPassword:(NSString *)keyPassword {
    if (request == nil || key.length == 0) {
        VFCLDLog(@"There is nothing to sign: request or/and private key is/are not given.");
        return [NSError errorWithDomain:kVKKeysClientErrorDomain code:-100 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"There is nothing to sign: request or/and private key is/are not given.", @"Sign for the request is not possible.") }];
    }
    
    // Sign request body with given key.
    VCSigner *signer = [[VCSigner alloc] init];
    NSData *signData = [signer signData:request.request.HTTPBody privateKey:key keyPassword:keyPassword];
    if (signData.length == 0) {
        VFCLDLog(@"Unable to sign request data with given private key.");
        return [NSError errorWithDomain:kVKKeysClientErrorDomain code:-101 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to sign the request with given private key.", @"Sign for the request is failed.") }];;
    }
    
    // Encode sign to base64
    NSString *encodedSign = [signData base64EncodedStringWithOptions:0];
    if (encodedSign.length == 0) {
        VFCLDLog(@"Unable to encode received sign into base64 format.");
        return [NSError errorWithDomain:kVKKeysClientErrorDomain code:-102 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to encode sign data to base64 format.", @"Sign for request can not be encoded.") }];;
    }
    
    [request setRequestHeaders:@{ @"X-VIRGIL-REQUEST-SIGN": encodedSign }];
    return nil;
}

@end
