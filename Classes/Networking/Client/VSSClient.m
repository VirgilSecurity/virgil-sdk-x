//
//  VSSKeysClient.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSClient.h"

#import "VSSPublicKey.h"
#import "VSSPublicKeyExtended.h"
#import "VSSPrivateKey.h"
#import "VSSCard.h"
#import "VSSSign.h"

#import "VSSRequest.h"
#import "VSSServiceConfig.h"
#import "VSSRequestContextExtended.h"
#import "NSObject+VSSUtils.h"

#import "VSSGetPublicKeyRequest.h"
#import "VSSDeletePublicKeyRequest.h"
#import "VSSCreateCardRequest.h"
#import "VSSGetCardRequest.h"
#import "VSSSignCardRequest.h"
#import "VSSUnsignCardRequest.h"
#import "VSSSearchCardRequest.h"
#import "VSSSearchAppCardRequest.h"
#import "VSSDeleteCardRequest.h"

#import "VSSVerifyIdentityRequest.h"
#import "VSSConfirmIdentityRequest.h"

#import "VSSStorePrivateKeyRequest.h"
#import "VSSGrabPrivateKeyRequest.h"
#import "VSSDeletePrivateKeyRequest.h"

@interface VSSClient ()

@property (nonatomic, strong) NSMutableDictionary * __nonnull serviceCards;

@end

@implementation VSSClient

@synthesize serviceCards = _serviceCards;

#pragma mark - Overrides

- (void)setupClientWithCompletionHandler:(void (^)(NSError *error))completionHandler {
    /// Re-create serviceCards map
    self.serviceCards = [[NSMutableDictionary alloc] init];
    NSInteger __block requestCount = 0;
    /// For all serviceID from configuration we need to get a card.
    for (NSString *serviceID in [self.serviceConfig serviceIDList]) {
        VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
            @synchronized(self) {
                requestCount--;
            }
            
            if (request.error != nil) {
                if (completionHandler != nil) {
                    completionHandler(request.error);
                }
                return;
            }

            VSSSearchAppCardRequest *r = [request as:[VSSSearchAppCardRequest class]];
            if (r.cards.count > 0) {
                /// Here should be only one item. So we are interested in first.
                VSSCard *serviceCard = [r.cards[0] as:[VSSCard class]];
                self.serviceCards[serviceID] = serviceCard;
            }
            if (completionHandler != nil) {
                if (requestCount == 0) {
                    completionHandler(nil);
                }
            }
        };
        
        VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys]];
        VSSSearchAppCardRequest *cardSearchRequest = [[VSSSearchAppCardRequest alloc] initWithContext:context value:[self.serviceConfig serviceCardValueForServiceID:serviceID]];
        cardSearchRequest.completionHandler = handler;
        @synchronized(self) {
            requestCount++;
        }
        [self send:cardSearchRequest];
    }
}

#pragma mark - Public key related functionality

- (void)getPublicKeyWithId:(GUID *)keyId completionHandler:(void(^)(VSSPublicKey * __nullable key, NSError * __nullable error))completionHandler {
    if (keyId.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-200 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to get public key: public key id is not set.", @"GetPublicKeyError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSGetPublicKeyRequest *r = [request as:[VSSGetPublicKeyRequest class]];
            completionHandler(r.publicKey, nil);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:nil cardId:nil password:nil];
    VSSGetPublicKeyRequest *request = [[VSSGetPublicKeyRequest alloc] initWithContext:context publicKeyId:keyId];
    request.completionHandler = handler;
    [self send:request];
}

- (void)getPublicKeyWithId:(GUID *)keyId card:(VSSCard *)card privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(VSSPublicKeyExtended *key, NSError *error))completionHandler {
    if (keyId.length == 0 || card.Id.length == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-201 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to get public key: public key id or/and virgil card id or/and private key is/are not set.", @"GetPublicKeySignedError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSGetPublicKeyRequest *r = [request as:[VSSGetPublicKeyRequest class]];
            completionHandler(r.publicKey, nil);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:privateKey cardId:card.Id password:nil];
    VSSGetPublicKeyRequest *request = [[VSSGetPublicKeyRequest alloc] initWithContext:context publicKeyId:keyId];
    request.completionHandler = handler;
    [self send:request];
}

- (void)deletePublicKeyWithId:(GUID *)keyId identities:(NSArray <NSDictionary *>*)identities card:(VSSCard *)card privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(NSError *error))completionHandler {
    if (keyId.length == 0 || identities.count == 0 || card.Id.length == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVSSRequestErrorDomain code:-202 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to delete public key: public key id or/and identites list or/and virgil card id or/and private key is/are not set.", @"DeletePublicKeySignedError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (completionHandler != nil) {
            completionHandler(request.error);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:privateKey cardId:card.Id password:nil];
    VSSDeletePublicKeyRequest *request = [[VSSDeletePublicKeyRequest alloc] initWithContext:context publicKeyId:keyId identities:identities];
    request.completionHandler = handler;
    [self send:request];
}

- (void)createCardWithPublicKeyId:(GUID *)keyId identity:(NSDictionary *)identity data:(NSDictionary *)data signs:(NSArray <NSDictionary *>*)signs privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(VSSCard *card, NSError *error))completionHandler {
    if (keyId.length == 0 || identity.count == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-210 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to create card: public key id or/and identity or/and private key is/are not set.", @"CreateCardByKeyIDSignedError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSCreateCardRequest *r = [request as:[VSSCreateCardRequest class]];
            completionHandler(r.card, nil);

        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:privateKey cardId:nil password:nil];
    VSSCreateCardRequest *request = [[VSSCreateCardRequest alloc] initWithContext:context publicKeyId:keyId identity:identity data:data signs:signs];
    request.completionHandler = handler;
    [self send:request];
}

- (void)createCardWithPublicKey:(NSData *)key identity:(NSDictionary *)identity data:(NSDictionary *)data signs:(NSArray <NSDictionary *>*)signs privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(VSSCard *card, NSError *error))completionHandler {
    if (key.length == 0 || identity.count == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-211 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to create card: public key or/and identity or/and private key is/are not set.", @"CreateCardByKeyDataSignedError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSCreateCardRequest *r = [request as:[VSSCreateCardRequest class]];
            completionHandler(r.card, nil);
            
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:privateKey cardId:nil password:nil];
    VSSCreateCardRequest *request = [[VSSCreateCardRequest alloc] initWithContext:context publicKey:key identity:identity data:data signs:signs];
    request.completionHandler = handler;
    [self send:request];
}

- (void)getCardWithCardId:(GUID *)cardId completionHandler:(void(^)(VSSCard *card, NSError *error))completionHandler {
    if (cardId.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-212 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to get a card: card id is not set.", @"GetCardUnsignedError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSGetCardRequest *r = [request as:[VSSGetCardRequest class]];
            completionHandler(r.card, nil);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:nil cardId:nil password:nil];
    VSSGetCardRequest *request = [[VSSGetCardRequest alloc] initWithContext:context cardId:cardId];
    request.completionHandler = handler;
    [self send:request];
}

- (void)signCardWithCardId:(GUID *)cardId digest:(NSData *)digest signerCard:(VSSCard *)signerCard privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(VSSSign *sign, NSError *error))completionHandler {
    if (cardId.length == 0 || digest.length == 0 || signerCard.Id.length == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-213 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to sign a card: card id and/or signed digest and/or signer card id and/or private key is/are not set.", @"SignCardSignedError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSSignCardRequest *r = [request as:[VSSSignCardRequest class]];
            completionHandler(r.Sign, nil);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:privateKey cardId:signerCard.Id password:nil];
    VSSSignCardRequest *request = [[VSSSignCardRequest alloc] initWithContext:context signerCardId:signerCard.Id signedCardId:cardId digest:digest];
    request.completionHandler = handler;
    [self send:request];
}

- (void)unsignCardWithId:(GUID *)cardId signerCard:(VSSCard *)signerCard privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(NSError *error))completionHandler {
    if (cardId.length == 0 || signerCard.Id.length == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVSSRequestErrorDomain code:-214 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to unsign a card: card id and/or signer card id and/or private key is/are not set.", @"UnsignCardSignedError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (completionHandler != nil) {
            completionHandler(request.error);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:privateKey cardId:signerCard.Id password:nil];
    VSSUnsignCardRequest *request = [[VSSUnsignCardRequest alloc] initWithContext:context signerCardId:signerCard.Id signedCardId:cardId];
    request.completionHandler = handler;
    [self send:request];
}

- (void)searchCardWithIdentityValue:(NSString *)value type:(VSSIdentityType)type relations:(NSArray <GUID *>*)relations unconfirmed:(NSNumber *)unconfirmed completionHandler:(void(^)(NSArray <VSSCard *>*cards, NSError *error))completionHandler {
    if (value.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-215 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to search for a card: idetity value is not set.", @"SearchCardError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSSearchCardRequest *r = [request as:[VSSSearchCardRequest class]];
            completionHandler(r.cards, nil);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:nil cardId:nil password:nil];
    VSSSearchCardRequest *request = [[VSSSearchCardRequest alloc] initWithContext:context value:value type:type relations:relations unconfirmed:unconfirmed];
    request.completionHandler = handler;
    [self send:request];
    
}

- (void)searchAppCardWithIdentityValue:(NSString *)value completionHandler:(void(^)(NSArray <VSSCard *>*cards, NSError *error))completionHandler {
    if (value.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-216 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to search for an application's card: idetity value is not set.", @"SearchAppCardError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSSearchAppCardRequest *r = [request as:[VSSSearchAppCardRequest class]];
            completionHandler(r.cards, nil);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:nil cardId:nil password:nil];
    VSSSearchAppCardRequest *request = [[VSSSearchAppCardRequest alloc] initWithContext:context value:value];
    request.completionHandler = handler;
    [self send:request];
}

- (void)deleteCardWithCardId:(GUID *)cardId identity:(NSDictionary *)identity privateKey:(VSSPrivateKey *)privateKey completionHandler:(void(^)(NSError *error))completionHandler {
    if (cardId.length == 0 || identity.count == 0 || privateKey.key.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVSSRequestErrorDomain code:-217 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to delete a card: card id or/and idetity or/and private key is/are not set.", @"DeleteCardError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (completionHandler != nil) {
            completionHandler(request.error);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDKeys] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:privateKey cardId:cardId password:nil];
    VSSDeleteCardRequest *request = [[VSSDeleteCardRequest alloc] initWithContext:context cardId:cardId identity:identity];
    request.completionHandler = handler;
    [self send:request];
}

- (void)verifyIdentityWithType:(VSSIdentityType)type value:(NSString *)value completionHandler:(void(^)(GUID *actionId, NSError *error))completionHandler {
    [self verifyIdentityWithType:type value:value extraFields:nil completionHandler:completionHandler];
}

- (void)verifyIdentityWithType:(VSSIdentityType)type value:(NSString *)value extraFields:(NSDictionary *)extraFields completionHandler:(void(^)(GUID *actionId, NSError *error))completionHandler {
    if (type == VSSIdentityTypeUnknown || value.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-220 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to initiate verification procedure: identity type or/and identity value is/are not set.", @"VerifyIdentityError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSVerifyIdentityRequest *r = [request as:[VSSVerifyIdentityRequest class]];
            completionHandler(r.actionId, nil);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDIdentity] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDIdentity] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:nil cardId:nil password:nil];
    VSSVerifyIdentityRequest *request = [[VSSVerifyIdentityRequest alloc] initWithContext:context type:type value:value extraFields:extraFields];
    request.completionHandler = handler;
    [self send:request];
}

- (void)confirmIdentityWithActionId:(GUID *)actionId code:(NSString *)code ttl:(NSNumber *)ttl ctl:(NSNumber *)ctl completionHandler:(void(^)(VSSIdentityType type, NSString *value, NSString *validationToken, NSError *error))completionHandler {
    if (actionId.length == 0 || code.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(VSSIdentityTypeUnknown, nil, nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-221 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to confirm identity: action id or/and confirmation code is/are not set.", @"ConfirmIdentityError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(VSSIdentityTypeUnknown, nil, nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSConfirmIdentityRequest *r = [request as:[VSSConfirmIdentityRequest class]];
            completionHandler(r.type, r.value, r.validationToken, nil);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDIdentity] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDIdentity] serviceCard:sCard requestEncrypt:@NO responseVerify:@YES privateKey:nil cardId:nil password:nil];
    VSSConfirmIdentityRequest *request = [[VSSConfirmIdentityRequest alloc] initWithContext:context actionId:actionId code:code ttl:ttl ctl:ctl];
    request.completionHandler = handler;
    [self send:request];
}

- (void)storePrivateKey:(VSSPrivateKey *)privateKey cardId:(GUID *)cardId completionHandler:(void(^)(NSError *error))completionHandler {
    if (privateKey.key.length == 0 || cardId.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVSSRequestErrorDomain code:-230 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to store private key: card id or/and private key is/are not set.", @"StorePrivateKeyError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (completionHandler != nil) {
            completionHandler(request.error);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDPrivateKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDPrivateKeys] serviceCard:sCard requestEncrypt:@YES responseVerify:@NO privateKey:privateKey cardId:cardId password:nil];
    VSSStorePrivateKeyRequest *request = [[VSSStorePrivateKeyRequest alloc] initWithContext:context privateKey:privateKey.key cardId:cardId];
    request.completionHandler = handler;
    [self send:request];
}

- (void)grabPrivateKeyWithIdentity:(NSDictionary *)identity cardId:(GUID *)cardId password:(NSString *)password completionHandler:(void(^)(NSData *keyData, GUID *cardId, NSError *error))completionHandler {
    if (identity.count == 0 || cardId.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler(nil, nil, [NSError errorWithDomain:kVSSRequestErrorDomain code:-231 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to grab private key: card id or/and identity is/are not set.", @"GrabPrivateKeyError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (completionHandler != nil) {
                completionHandler(nil, nil, request.error);
            }
            return;
        }
        
        if (completionHandler != nil) {
            VSSGrabPrivateKeyRequest *r = [request as:[VSSGrabPrivateKeyRequest class]];
            completionHandler(r.privateKey, r.cardId, nil);
        }
        return;
    };
    
    NSString *responsePassword = password;
    if (responsePassword.length == 0) {
        responsePassword = [[[[[NSUUID UUID] UUIDString] lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:30];
    }
    else {
        if (responsePassword.length > 30) {
            responsePassword = [responsePassword substringToIndex:30];
        }
    }
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDPrivateKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDPrivateKeys] serviceCard:sCard requestEncrypt:@YES responseVerify:@NO privateKey:nil cardId:cardId password:responsePassword];
    VSSGrabPrivateKeyRequest *request = [[VSSGrabPrivateKeyRequest alloc] initWithContext:context identity:identity cardId:cardId];
    request.completionHandler = handler;
    [self send:request];
}

- (void)deletePrivateKey:(VSSPrivateKey *)privateKey cardId:(GUID *)cardId completionHandler:(void(^)(NSError *error))completionHandler {
    if (privateKey.key.length == 0 || cardId.length == 0) {
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                completionHandler([NSError errorWithDomain:kVSSRequestErrorDomain code:-232 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to delete private key: card id or/and private key is/are not set.", @"DeletePrivateKeyError") }]);
            });
        }
        return;
    }
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (completionHandler != nil) {
            completionHandler(request.error);
        }
        return;
    };
    
    VSSCard *sCard = [self.serviceCards[kVSSServiceIDPrivateKeys] as:[VSSCard class]];
    VSSRequestContextExtended *context = [[VSSRequestContextExtended alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDPrivateKeys] serviceCard:sCard requestEncrypt:@YES responseVerify:@NO privateKey:privateKey cardId:cardId password:nil];
    VSSDeletePrivateKeyRequest *request = [[VSSDeletePrivateKeyRequest alloc] initWithContext:context cardId:cardId];
    request.completionHandler = handler;
    [self send:request];
}

@end
