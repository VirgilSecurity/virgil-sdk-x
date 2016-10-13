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
#import "VSSRequestSigner.h"

NSString *const kApplicationToken = <#NSString: Application Access Token#>;
NSString *const kApplicationPublicKeyBase64 = <# NSString: Application Public Key #>;
NSString *const kApplicationPrivateKeyBase64 = <#NSString: Application Private Key in base64#>;
NSString *const kApplicationPrivateKeyPassword = <#NSString: Application Private Key password#>;
NSString *const kApplicationIdentityType = <#NSString: Application Identity Type#>;
NSString *const kApplicationId = <#NSString: Application Id#>;

@implementation VSSTestsUtils

- (instancetype)initWithCrypto:(VSSCrypto *)crypto {
    self = [super init];
    if (self) {
        _crypto = crypto;
    }
    
    return self;
}

#pragma mark - Private logic

- (VSSCard * __nonnull)instantiateCard {
    VSSKeyPair *keyPair = [self.crypto generateKeyPair];
    NSData *exportedPublicKey = [self.crypto exportPublicKey:keyPair.publicKey];
    
    // some random value
    NSString *identityValue = [[NSUUID UUID] UUIDString];
    NSString *identityType = kApplicationIdentityType;
    VSSCard *card = [VSSCard cardWithIdentity:identityValue identityType:identityType publicKey:exportedPublicKey];
    
    NSData *privateAppKeyData = [[NSData alloc] initWithBase64EncodedString:kApplicationPrivateKeyBase64 options:0];
    
    VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKey:privateAppKeyData password:kApplicationPrivateKeyPassword];
    
    VSSRequestSigner *requestSigner = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
    
    NSError *error;
    [requestSigner applicationSignRequest:card withPrivateKey:keyPair.privateKey error:&error];
    [requestSigner authoritySignRequest:card appId:kApplicationId withPrivateKey:appPrivateKey error:&error];
    
    return card;
}

- (VSSRevokeCard * __nonnull)instantiateRevokeCardForCard:(VSSCard * __nonnull)card {
    VSSRevokeCard *revokeCard = [VSSRevokeCard revokeCardWithId:card.identifier reason:VSSCardRevocationReasonUnspecified];
    
    VSSRequestSigner *requestSigner = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
    
    NSData *privateAppKeyData = [[NSData alloc] initWithBase64EncodedString:kApplicationPrivateKeyBase64 options:0];
    
    VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKey:privateAppKeyData password:kApplicationPrivateKeyPassword];
    
    NSError *error;
    [requestSigner authoritySignRequest:revokeCard appId:kApplicationId withPrivateKey:appPrivateKey error:&error];
    
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
