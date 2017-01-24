//
//  VSSCardValidator.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/5/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardValidator.h"
#import "VSSFingerPrint.h"

static NSString * const kVSSServiceCardId = @"3e29d43373348cfb373b7eae189214dc01d7237765e572db685839b64adca853";
static NSString * const kVSSServicePublicKey = @"LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUNvd0JRWURLMlZ3QXlFQVlSNTAxa1YxdFVuZTJ1T2RrdzRrRXJSUmJKcmMyU3lhejVWMWZ1RytyVnM9Ci0tLS0tRU5EIFBVQkxJQyBLRVktLS0tLQo=";

@interface VSSCardValidator ()

@property (nonatomic, readwrite) id<VSSCrypto> __nonnull crypto;
@property (nonatomic, copy, readwrite) NSDictionary<NSString *, VSSPublicKey *> * __nonnull verifiers;

- (void)addVerifierWithId:(NSString * __nonnull)verifierId publicKey:(VSSPublicKey * __nonnull)publicKey;

@end

@implementation VSSCardValidator

- (id)copyWithZone:(NSZone *)zone {
    VSSCardValidator *copy = [[VSSCardValidator alloc] initWithCrypto:self.crypto];
    
    for (NSString *cardId in self.verifiers) {
        if ([cardId isEqualToString:kVSSServiceCardId])
            continue;
        
        [copy addVerifierWithId:cardId publicKey:self.verifiers[cardId]];
    }
    
    return copy;
}

- (instancetype)initWithCrypto:(id<VSSCrypto>)crypto {
    self = [super init];
    if (self) {
        _crypto = crypto;
        
        NSData *servicePublicKeyData = [[NSData alloc] initWithBase64EncodedString:kVSSServicePublicKey options:0];
        VSSPublicKey *servicePublicKey = [crypto importPublicKeyFromData:servicePublicKeyData];
        if (servicePublicKey == nil)
            return nil;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[kVSSServiceCardId] = servicePublicKey;
        
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
        return YES;

    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:cardResponse.snapshot];
    
    if (![cardResponse.identifier isEqualToString:fingerprint.hexValue])
        return NO;
    
    NSMutableDictionary *verifiers = [self.verifiers mutableCopy];
    VSSPublicKey *creatorPublicKey = [self.crypto importPublicKeyFromData:cardResponse.model.publicKeyData];
    verifiers[fingerprint.hexValue] = creatorPublicKey;

    for (NSString *verifierId in verifiers.allKeys) {
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
