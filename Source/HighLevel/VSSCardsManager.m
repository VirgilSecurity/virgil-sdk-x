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
#import "VSSModelCommonsPrivate.h"
#import "VSSRevokeUserCardRequest.h"
#import "VSSVirgilKeyPrivate.h"
#import "VSSVirgilIdentityPrivate.h"
#import "VSSEmailIdentityPrivate.h"
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
    
    VSSCreateCardRequest *request = [identity generateRequestWithPublicKeyData:publicKeyData data:data device:device deviceName:deviceName];
    if (request == nil) {
        if (errorPtr != nil) {
            *errorPtr = [[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Identity passed to createCard method should be confirmed. Confirm Identity first." }];
        }
        return nil;
    }
    
    if (!([self.context.requestSigner selfSignRequest:request withPrivateKey:ownerKey.privateKey error:errorPtr]))
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
    VSSVirgilCard *card = [[VSSVirgilCard alloc] initWithContext:self.context data:data];
    
    // Validate card if it's published
    if (card.isPublished) {
        BOOL verified = [self.context.client.serviceConfig.cardValidator validateCardResponse:card.card.cardResponse];
        
        if (!verified)
            return nil;
    }
    
    return card;
}

- (void)revokeCard:(VSSVirgilCard *)card completion:(void (^)(NSError *))callback {
    if (card.scope != VSSCardScopeApplication) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"To revoke Email card call revokeEmailCard method" }]);
        return;
    }
    
    VSSRevokeCardRequest *request = [VSSRevokeUserCardRequest revokeUserCardRequestWithCardId:card.identifier reason:VSSCardRevocationReasonUnspecified];
    
    VSSPrivateKey *appKey = [self.context.credentials getAppKeyUsingCrypto:self.context.crypto];
    if (appKey == nil) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"To revoke Application card you need to provide Credentials with correct private key to VirgilApiContext" }]);
        return;
    }
    NSString *appId = self.context.credentials.appId;
    if (appId.length == 0) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"To revoke Application card you need to provide Credentials with correct app id to VirgilApiContext" }]);
        return;
    }
    NSError *error;
    [self.context.requestSigner authoritySignRequest:request forAppId:appId withPrivateKey:appKey error:&error];
    if (error != nil) {
        callback(error);
        return;
    }
    
    [self.context.client revokeCardWithRequest:request completion:callback];
}

- (void)revokeEmailCard:(VSSVirgilCard *)card identity:(VSSEmailIdentity *)identity ownerKey:(VSSVirgilKey *)ownerKey completion:(void (^)(NSError *))callback {
    if (card.scope != VSSCardScopeGlobal) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"To revoke Global card call revokeCard method" }]);
        return;
    }
    
    if (!identity.isConfimed) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Identity passed to revokeGlobalCard method should be confirmed. Confirm Identity first." }]);
        return;
    }
    
    VSSRevokeCardRequest *request = [VSSRevokeEmailCardRequest revokeEmailCardRequestWithCardId:card.identifier validationToken:identity.token reason:VSSCardRevocationReasonUnspecified];

    NSError *error;
    [self.context.requestSigner authoritySignRequest:request forAppId:card.identifier withPrivateKey:ownerKey.privateKey error:&error];
    if (error != nil) {
        callback(error);
        return;
    }
    
    [self.context.client revokeCardWithRequest:request completion:callback];
}

@end
