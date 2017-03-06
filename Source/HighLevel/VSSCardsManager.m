//
//  VSSCardsManager.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCardsManager.h"
#import "VSSVirgilCardPrivate.h"
#import "VSSCardsManagerPrivate.h"
#import "VSSCreateApplicationCardRequest.h"
#import "VSSCreateGlobalCardRequest.h"
#import "VSSModelCommonsPrivate.h"
#import "VSSRequestSigner.h"
#import "VSSVirgilKeyPrivate.h"
#import "VSSVirgilIdentityPrivate.h"
#import "VSSVirgilGlobalIdentityPrivate.h"
#import "VSSRevokeApplicationCardRequest.h"
#import "VSSRevokeGlobalCardRequest.h"
#import "VSSVirgilApi.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCardsManager

- (instancetype)initWithContext:(VSSVirgilApiContext *)context {
    self = [super init];
    if (self) {
        _context = context;
    }
    
    return self;
}

- (VSSVirgilCard *)createCardWithIdentity:(VSSVirgilIdentity *)identity ownerKey:(VSSVirgilKey *)ownerKey data:(NSDictionary<NSString *, NSString *> *)data error:(NSError **)errorPtr {
    NSString *device = [self.context.deviceManager getDeviceModel];
    NSString *deviceName = [self.context.deviceManager getDeviceName];
    NSData *publicKeyData = [ownerKey exportPublicKey];
    
    if (!identity.isConfimed) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Identity passed to createCard method should be confirmed. Confirm Identity first." }];
        }
        return nil;
    }
    
    VSSCreateCardRequest *request;
    VSSVirgilGlobalIdentity *globalIdentity = [identity as:[VSSVirgilGlobalIdentity class]];
    
    if (globalIdentity != nil) {
        request = [VSSCreateGlobalCardRequest createGlobalCardRequestWithIdentity:identity.value identityType:identity.type validationToken:globalIdentity.token publicKeyData:publicKeyData data:data device:device deviceName:deviceName];
    }
    else {
        request = [VSSCreateApplicationCardRequest createApplicationCardRequestWithIdentity:identity.value identityType:identity.type publicKeyData:publicKeyData data:data device:device deviceName:deviceName];
    }
    
    VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.context.crypto];
    if (!([signer selfSignRequest:request withPrivateKey:ownerKey.privateKey error:errorPtr]))
        return nil;
    
    return [[VSSVirgilCard alloc] initWithContext:self.context request:request];
}

- (VSSVirgilCard *)createCardWithIdentity:(VSSVirgilIdentity *)identity ownerKey:(VSSVirgilKey *)ownerKey error:(NSError **)errorPtr {
    return [self createCardWithIdentity:identity ownerKey:ownerKey data:nil error:errorPtr];
}

- (void)publishCard:(VSSVirgilCard *)card completion:(void (^)(NSError *))callback; {
    [card publishWithCompletion:callback];
}

- (void)searchCardsUsingCriteria:(VSSSearchCardsCriteria *)criteria completion:(void (^)(NSArray<VSSVirgilCard *>*, NSError *))callback {
    [self.context.client searchCardsUsingCriteria:criteria completion:^(NSArray<VSSCard *> *cards, NSError *error) {
        if (error != nil || cards == nil) {
            callback(nil, error);
            return;
        }
        
        NSMutableArray<VSSVirgilCard *> *virgilCards = [[NSMutableArray alloc] initWithCapacity:cards.count];
        for (VSSCard *card in cards) {
            VSSVirgilCard *virgilCard = [[VSSVirgilCard alloc] initWithContext:self.context card:card];
            
            [virgilCards addObject:virgilCard];
        }
        
        callback(virgilCards, nil);
    }];
}

- (void)searchCardsWithIdentities:(NSArray<NSString *> *)identities completion:(void (^)(NSArray<VSSVirgilCard *> *, NSError *))callback {
    VSSSearchCardsCriteria *criteria = [VSSSearchCardsCriteria searchCardsCriteriaWithIdentities:identities];
    
    [self searchCardsUsingCriteria:criteria completion:callback];
}

- (void)searchCardsWithIdentityType:(NSString *)identityType identities:(NSArray<NSString *> *)identities completion:(void (^)(NSArray<VSSVirgilCard *> *, NSError *))callback {
    VSSSearchCardsCriteria *criteria = [VSSSearchCardsCriteria searchCardsCriteriaWithIdentityType:identityType identities:identities];
    
    [self searchCardsUsingCriteria:criteria completion:callback];
}

- (void)searchGlobalCardsWithIdentities:(NSArray<NSString *> *)identities completion:(void (^)(NSArray<VSSVirgilCard *> *, NSError *))callback {
    VSSSearchCardsCriteria *criteria = [VSSSearchCardsCriteria searchCardsCriteriaWithScope:VSSCardScopeGlobal identityType:nil identities:identities];;
    
    [self searchCardsUsingCriteria:criteria completion:callback];
}

- (void)searchGlobalCardsWithIdentityType:(NSString *)identityType identities:(NSArray<NSString *> *)identities completion:(void (^)(NSArray<VSSVirgilCard *> *, NSError *))callback {
    VSSSearchCardsCriteria *criteria = [VSSSearchCardsCriteria searchCardsCriteriaWithScope:VSSCardScopeGlobal identityType:identityType identities:identities];;
    
    [self searchCardsUsingCriteria:criteria completion:callback];
}

- (void)getCardWithId:(NSString *)cardId completion:(void (^)(VSSVirgilCard *, NSError *))callback {
    [self.context.client getCardWithId:cardId completion:^(VSSCard *card, NSError *error) {
        if (error != nil || card == nil) {
            callback(nil, error);
            return;
        }
        
        VSSVirgilCard *virgilCard = [[VSSVirgilCard alloc] initWithContext:self.context card:card];
        callback(virgilCard, nil);
    }];
}

- (VSSVirgilCard *)importVirgilCardFromData:(NSString *)data {
    return [[VSSVirgilCard alloc] initWithContext:self.context data:data];
}

- (void)revokeCard:(VSSVirgilCard *)card completion:(void (^)(NSError *))callback {
    if (card.scope != VSSCardScopeApplication) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"To revoke Application card call revokeGlobalCard method" }]);
        return;
    }
    
    VSSRevokeCardRequest *request = [VSSRevokeApplicationCardRequest revokeApplicationCardRequestWithCardId:card.identifier reason:VSSCardRevocationReasonUnspecified];
    
    if (self.context.credentials == nil) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"To revoke Application card you need to provide Credentials to VirgilApiContext" }]);
        return;
    }
    NSString *appId = self.context.credentials.appId;
    VSSPrivateKey *appKey = self.context.credentials.appKey;
    VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.context.crypto];
    NSError *error;
    [signer authoritySignRequest:request forAppId:appId withPrivateKey:appKey error:&error];
    if (error != nil) {
        callback(error);
        return;
    }
    
    [self.context.client revokeCardWithRequest:request completion:callback];
}

- (void)revokeGlobalCard:(VSSVirgilCard *)card identity:(VSSVirgilGlobalIdentity *)identity ownerKey:(VSSVirgilKey *)ownerKey completion:(void (^)(NSError *))callback {
    if (card.scope != VSSCardScopeGlobal) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"To revoke Global card call revokeCard method" }]);
        return;
    }
    
    if (!identity.isConfimed) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Identity passed to revokeGlobalCard method should be confirmed. Confirm Identity first." }]);
        return;
    }
    
    VSSRevokeCardRequest *request = [VSSRevokeGlobalCardRequest revokeGlobalCardRequestWithCardId:card.identifier validationToken:identity.token reason:VSSCardRevocationReasonUnspecified];

    VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.context.crypto];
    NSError *error;
    [signer authoritySignRequest:request forAppId:card.identifier withPrivateKey:ownerKey.privateKey error:&error];
    if (error != nil) {
        callback(error);
        return;
    }
    
    [self.context.client revokeCardWithRequest:request completion:callback];
}

@end
