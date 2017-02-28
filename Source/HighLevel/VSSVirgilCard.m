//
//  VSSVirgilCard.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilCardPrivate.h"
#import "VSSModelCommonsPrivate.h"

@implementation VSSVirgilCard

- (instancetype)initWithContext:(VSSVirgilApiContext * __nonnull)context model:(VSSCard *)model {
    self = [super init];
    if (self) {
        _context = context;
        _model = model;
    }
    
    return self;
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

- (NSString *)identifier {
    return self.model.identifier;
}

- (NSString *)identity {
    return self.model.identity;
}

- (NSString *)identityType {
    return self.model.identityType;
}

- (NSDictionary<NSString *, NSString *> *)data {
    return self.model.data;
}

- (NSData *)publicKey {
    return self.model.publicKeyData;
}

- (NSDictionary<NSString *, NSString *> *)info {
    return self.model.info;
}

- (VSSCardScope)scope {
    return self.model.scope;
}

@end
