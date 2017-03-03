//
//  VSSVirgilCard.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilCardPrivate.h"
#import "VSSModelCommonsPrivate.h"
#import "VSSVirgilApi.h"
#import "VSSRequestSigner.h"

@implementation VSSVirgilCard

- (instancetype)initWithContext:(VSSVirgilApiContext *)context request:(VSSCreateCardRequest *)request {
    self = [super init];
    if (self) {
        _context = context;
        _request = request;
    }
    
    return self;
}

- (instancetype)initWithContext:(VSSVirgilApiContext *)context card:(VSSCard *)card {
    self = [super init];
    if (self) {
        _context = context;
        _card = card;
    }
    
    return self;
}

- (BOOL)isPublished {
    return self.card != nil;
}

- (NSData *)encryptData:(NSData *)data error:(NSError **)errorPtr {
    VSSPublicKey *publicKey = [self.context.crypto importPublicKeyFromData:self.publicKey];
    
    return [self.context.crypto encryptData:data forRecipients:@[publicKey] error:errorPtr];
}

- (BOOL)verifyData:(NSData *)data withSignature:(NSData *)signature error:(NSError **)errorPtr {
    VSSPublicKey *publicKey = [self.context.crypto importPublicKeyFromData:self.publicKey];
    
    return [self.context.crypto verifyData:data withSignature:signature usingSignerPublicKey:publicKey error:errorPtr];
}

//+ (void)getCardWithId:(NSString *)cardId completion:(void (^)(VSSVirgilCard*, NSError *))callback {
//    [self.context.client getCardWithId:cardId completion:^(VSSCard *foundCard, NSError *error) {
//        VSSVirgilCard *virgilCard = nil;
//        if (foundCard != nil) {
//            virgilCard = [[VSSVirgilCard alloc] initWithModel:foundCard];
//        }
//        
//        callback(virgilCard, error);
//    }];
//}
//
//+ (void)searchGlobalCardsWithIdentity:(NSString *)identity identityType:(VSSGlobalIdentityType)type completion:(void (^)(NSArray<VSSVirgilCard *> *, NSError *))callback {
//    return [self searchGlobalCardsWithIdentities:@[identity] identityType:type completion:callback];
//}
//
//+ (void)searchGlobalCardsWithIdentities:(NSArray<NSString *> *)identities identityType:(VSSGlobalIdentityType)type completion:(void (^)(NSArray<VSSVirgilCard *>*, NSError *))callback {
//    id<VSSClient> client = VSSVirgilConfig.sharedInstance.client;
//    
//    VSSSearchCardsCriteria *criteria = [VSSSearchCardsCriteria searchCardsCriteriaWithScope:VSSCardScopeGlobal identityType:vss_getGlobalIdentityTypeString(type) identities:identities];
//    
//    [client searchCardsUsingCriteria:criteria completion:^(NSArray<VSSCard *> *cards, NSError *error) {
//        NSMutableArray<VSSVirgilCard *> *virgilCards = nil;
//        
//        if (cards.count > 0) {
//            virgilCards = [[NSMutableArray alloc] initWithCapacity:cards.count];
//            
//            for (VSSCard *card in cards) {
//                [virgilCards addObject:[[VSSVirgilCard alloc] initWithModel:card]];
//            }
//        }
//        
//        callback(virgilCards, error);
//    }];
//}
//
//+ (void)searchCardsWithIdentity:(NSString *)identity identityType:(NSString *)type completion:(void (^)(NSArray<VSSVirgilCard *> *, NSError *))callback {
//    [self searchCardsWithIdentities:@[identity] identityType:type completion:callback];
//}
//
//+ (void)searchCardsWithIdentities:(NSArray<NSString *> *)identities identityType:(NSString *)type completion:(void (^)(NSArray<VSSVirgilCard *> *, NSError *))callback {
//    id<VSSClient> client = VSSVirgilConfig.sharedInstance.client;
//    
//    VSSSearchCardsCriteria *criteria = [VSSSearchCardsCriteria searchCardsCriteriaWithScope:VSSCardScopeApplication identityType:type identities:identities];
//    
//    [client searchCardsUsingCriteria:criteria completion:^(NSArray<VSSCard *> *cards, NSError *error) {
//        NSMutableArray<VSSVirgilCard *> *virgilCards = nil;
//        
//        if (cards.count > 0) {
//            virgilCards = [[NSMutableArray alloc] initWithCapacity:cards.count];
//            
//            for (VSSCard *card in cards) {
//                [virgilCards addObject:[[VSSVirgilCard alloc] initWithModel:card]];
//            }
//        }
//        
//        callback(virgilCards, error);
//    }];
//}
//
//+ (void)createCardWithRequest:(VSSCreateCardRequest *)request completion:(void (^)(VSSVirgilCard *, NSError *))callback {
//    id<VSSClient> client = VSSVirgilConfig.sharedInstance.client;
//    
//    [client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
//        VSSVirgilCard *virgilCard = nil;
//        if (card != nil) {
//            virgilCard = [[VSSVirgilCard alloc] initWithModel:card];
//        }
//        
//        callback(virgilCard, error);
//    }];
//}
//
//+ (void)revokeCardWithRequest:(VSSRevokeCardRequest *)request completion:(void (^)(NSError *))callback {
//    id<VSSClient> client = VSSVirgilConfig.sharedInstance.client;
//    
//    [client revokeCardWithRequest:request completion:callback];
//}

- (void)publishWithCompletion:(void (^)(NSError *))callback {
    if (self.isPublished) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"This card is already published" }]);
        return;
    }
    
    switch (self.scope) {
        case VSSCardScopeGlobal: break;
        case VSSCardScopeApplication: {
            if (self.context.credentials == nil) {
                callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"To create Application card you need to provide Credentials to VirgilApiContext" }]);
                return;
            }
            NSString *appId = self.context.credentials.appId;
            VSSPrivateKey *appKey = self.context.credentials.appKey;
            VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.context.crypto];
            NSError *error;
            [signer authoritySignRequest:self.request forAppId:appId withPrivateKey:appKey error:&error];
            if (error != nil) {
                callback(error);
                return;
            }
                
            break;
        }
    }
    
    [self.context.client createCardWithRequest:self.request completion:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            callback(error);
            return;
        }
        
        self.card = card;
        callback(nil);
    }];
}

- (NSString *)identifier {
    if (self.card != nil)
        return self.card.identifier;
    
    return nil;
}

- (NSString *)identity {
    if (self.card != nil)
        return self.card.identity;
    else
        return self.request.snapshotModel.identity;
}

- (NSString *)identityType {
    if (self.card != nil)
        return self.card.identityType;
    else
        return self.request.snapshotModel.identityType;
}

- (NSData *)publicKey {
    if (self.card != nil)
        return self.card.publicKeyData;
    else
        return self.request.snapshotModel.publicKeyData;
}

- (NSDictionary<NSString *, NSString *> *)customFields {
    if (self.card != nil)
        return self.card.data;
    else
        return self.request.snapshotModel.data;
}

- (NSDictionary<NSString *, NSString *> *)info {
    if (self.card != nil)
        return self.card.info;
    else
        return self.request.snapshotModel.info;
}

- (VSSCardScope)scope {
    if (self.card != nil)
        return self.card.scope;
    else
        return self.request.snapshotModel.scope;
}

@end
