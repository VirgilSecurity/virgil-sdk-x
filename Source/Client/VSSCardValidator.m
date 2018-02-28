//
//  VSSCardValidator.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/5/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardValidator.h"
#import "VSSFingerprint.h"

static NSString * const kVSSCardsServiceCardId = @"3e29d43373348cfb373b7eae189214dc01d7237765e572db685839b64adca853";
static NSString * const kVSSCardsServicePublicKey = @"LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUNvd0JRWURLMlZ3QXlFQVlSNTAxa1YxdFVuZTJ1T2RrdzRrRXJSUmJKcmMyU3lhejVWMWZ1RytyVnM9Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQo=";

static NSString * const kVSSVraServiceCardId = @"67b8ee8e53b4c0c6b65b4bbdda6fa159e8208f58ffc290ec61a72c3fd07ad035";
static NSString * const kVSSVraServicePublicKey = @"LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUNvd0JRWURLMlZ3QXlFQVdwQ25zME5oVzlyWU1VUWJoeXBSNTRGbm1RYTVJZzVqaXBKSzJWaVpzSzg9Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQo=";

@interface VSSCardValidator ()

@property (nonatomic, readwrite) id<VSSCrypto> __nonnull crypto;
@property (nonatomic, copy, readwrite) NSDictionary<NSString *, VSSPublicKey *> * __nonnull verifiers;

- (void)addVerifierWithId:(NSString * __nonnull)verifierId publicKey:(VSSPublicKey * __nonnull)publicKey;

@end

@implementation VSSCardValidator

- (id)copyWithZone:(NSZone *)zone {
    VSSCardValidator *copy = [[VSSCardValidator alloc] initWithCrypto:self.crypto];
    
    for (NSString *cardId in self.verifiers) {
        if ([cardId isEqualToString:kVSSCardsServiceCardId] || [cardId isEqualToString:kVSSVraServiceCardId])
            continue;
        
        [copy addVerifierWithId:cardId publicKey:self.verifiers[cardId]];
    }
    
    copy.useVirgilServiceVerifiers = self.useVirgilServiceVerifiers;
    copy.verifyV3Cards = self.verifyV3Cards;
    
    return copy;
}

- (instancetype)initWithCrypto:(id<VSSCrypto>)crypto {
    self = [super init];
    if (self) {
        _crypto = crypto;
        self.useVirgilServiceVerifiers = YES;
        self.verifyV3Cards = NO;
        
        NSData *cardsServicePublicKeyData = [[NSData alloc] initWithBase64EncodedString:kVSSCardsServicePublicKey options:0];
        VSSPublicKey *cardsServicePublicKey = [crypto importPublicKeyFromData:cardsServicePublicKeyData];
        if (cardsServicePublicKey == nil)
            return nil;
        
        NSData *vraServicePublicKeyData = [[NSData alloc] initWithBase64EncodedString:kVSSVraServicePublicKey options:0];
        VSSPublicKey *vraServicePublicKey = [crypto importPublicKeyFromData:vraServicePublicKeyData];
        if (vraServicePublicKey == nil)
            return nil;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[kVSSCardsServiceCardId] = cardsServicePublicKey;
        dict[kVSSVraServiceCardId] = vraServicePublicKey;
        
        _verifiers = dict;
    }
    
    return self;
}

- (BOOL)addVerifierWithId:(NSString *)verifierId publicKeyData:(NSData *)publicKeyData {
    if (publicKeyData.length == 0)
        return NO;

    VSSPublicKey *publicKey = [self.crypto importPublicKeyFromData:publicKeyData];
    if (publicKey == nil)
        return NO;

    [self addVerifierWithId:verifierId publicKey:publicKey];
    return YES;
}

- (void)addVerifierWithId:(NSString *)verifierId publicKey:(VSSPublicKey *)publicKey {
    ((NSMutableDictionary *)_verifiers)[verifierId] = publicKey;
}

- (BOOL)validateCardResponse:(VSSCardResponse *)cardResponse {
    // Support for legacy Cards.
    if ([cardResponse.cardVersion isEqualToString:@"3.0"])
        return self.verifyV3Cards;

    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:cardResponse.snapshot];
    
    NSString *cardId = fingerprint.hexValue;
    if (![cardResponse.identifier isEqualToString:cardId])
        return NO;
    
    NSMutableDictionary *verifiers = [self.verifiers mutableCopy];
    VSSPublicKey *creatorPublicKey = [self.crypto importPublicKeyFromData:cardResponse.model.publicKeyData];
    verifiers[cardId] = creatorPublicKey;

    for (NSString *verifierId in verifiers.allKeys) {
        BOOL isVraSignature = [verifierId isEqualToString:kVSSVraServiceCardId];
        BOOL isCardsServiceSignature = [verifierId isEqualToString:kVSSCardsServiceCardId];
        BOOL isSelfSignature = [verifierId isEqualToString:cardId];

        // Don't verify with BuiltIn verifiers
        if (!self.useVirgilServiceVerifiers && (isVraSignature || isCardsServiceSignature)) {
            continue;
        }
        
        switch (cardResponse.model.scope) {
            case VSSCardScopeGlobal:
                // For Global cards only Vra, Cards Servive and Self signatures are verified
                if (!isVraSignature
                    && !isCardsServiceSignature
                    && !isSelfSignature) {
                    continue;
                }
                break;
                
            case VSSCardScopeApplication:
                //  Don't verify Vra signature for non-global cards
                if (isVraSignature) {
                    continue;
                }
                break;
        }
        
        NSData *signature = cardResponse.signatures[verifierId];
        if (signature == nil)
            return NO;
        
        NSError *error;
        BOOL isVerified = [self.crypto verifyData:fingerprint.value withSignature:signature usingSignerPublicKey:verifiers[verifierId] error:&error];

        if (!isVerified)
            return NO;
    }

    return YES;
}

@end
