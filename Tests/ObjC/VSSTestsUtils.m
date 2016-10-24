//
//  VSSTestsCommon.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSTestsUtils.h"
#import "VSSKeyPair.h"
#import "VSSPrivateKey.h"
#import "VSSSigner.h"

@implementation VSSTestsUtils

- (instancetype)initWithCrypto:(VSSCrypto *)crypto consts:(VSSTestsConst *)consts {
    self = [super init];
    if (self) {
        _crypto = crypto;
        _consts = consts;
    }
    
    return self;
}

- (VSSCard * __nonnull)instantiateCard {
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    
    // some random value
    NSString *identityValue = [[NSUUID UUID] UUIDString];
    NSString *identityType = self.consts.applicationIdentityType;
    VSSCard *card = [VSSCard cardWithIdentity:identityValue identityType:identityType publicKey:exportedPublicKey];
    
    NSData *privateAppKeyData = [[NSData alloc] initWithBase64EncodedString:self.consts.applicationPrivateKeyBase64 options:0];
    
    VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKeyFromData:privateAppKeyData withPassword:self.consts.applicationPrivateKeyPassword];
    
    VSSSigner *signer = [[VSSSigner alloc] initWithCrypto:self.crypto];
    
    NSError *error;
    [signer ownerSignData:card withPrivateKey:keyPair.privateKey error:&error];
    [signer authoritySignData:card forAppId:self.consts.applicationId withPrivateKey:appPrivateKey error:&error];
    
    return card;
}

- (VSSRevokeCard * __nonnull)instantiateRevokeCardForCard:(VSSCard * __nonnull)card {
    VSSRevokeCard *revokeCard = [VSSRevokeCard revokeCardWithCardId:card.identifier reason:VSSCardRevocationReasonUnspecified];
    
    VSSSigner *signer = [[VSSSigner alloc] initWithCrypto:self.crypto];
    
    NSData *privateAppKeyData = [[NSData alloc] initWithBase64EncodedString:self.consts.applicationPrivateKeyBase64 options:0];
    
    VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKeyFromData:privateAppKeyData withPassword:self.consts.applicationPrivateKeyPassword];
    
    NSError *error;
    [signer authoritySignData:revokeCard forAppId:self.consts.applicationId withPrivateKey:appPrivateKey error:&error];
    
    return revokeCard;
}

- (BOOL)checkCard:(VSSCard * __nonnull)card1 isEqualToCard:(VSSCard * __nonnull)card2 {
    BOOL equals = [card1.snapshot isEqualToData:card2.snapshot]
        && [card1.data.identityType isEqualToString:card2.data.identityType]
        && [card1.data.identity isEqualToString:card2.data.identity];
    
    return equals;
}

- (BOOL)checkRevokeCard:(VSSRevokeCard *)revokeCard1 isEqualToRevokeCard:(VSSRevokeCard * __nonnull)revokeCard2 {
    BOOL equals = [revokeCard1.snapshot isEqualToData:revokeCard2.snapshot]
        && [revokeCard1.data.cardId isEqualToString:revokeCard2.data.cardId]
        && revokeCard1.data.revocationReason == revokeCard2.data.revocationReason;
    
    return equals;
}

@end
