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

@property (nonatomic, readonly) id<VSSCrypto> __nonnull crypto;
@property (nonatomic, copy, readonly) NSDictionary * __nonnull verifiers;

@end

@implementation VSSCardValidator

- (instancetype)initWithCrypto:(id<VSSCrypto>)crypto {
    self = [super init];
    if (self) {
        _crypto = crypto;
        
        NSData *servicePublicKeyData = [[NSData alloc] initWithBase64EncodedString:kVSSServicePublicKey options:0];
        VSSPublicKey *servicePublicKey = [crypto importPublicKey:servicePublicKeyData];
        if (servicePublicKey == nil)
            return nil;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[kVSSServiceCardId] = servicePublicKey;
        
        _verifiers = dict;
    }
    
    return self;
}

- (void)addVerifierWithId:(NSString *)verifierId publicKey:(NSData *)publicKey {
    if ([publicKey length] == 0)
        return;

    VSSPublicKey *importedPublicKey = [self.crypto importPublicKey:publicKey];
    if (importedPublicKey == nil)
        return;
    
    ((NSMutableDictionary *)_verifiers)[verifierId] = importedPublicKey;
}

- (BOOL)validateCard:(VSSCardModel *)card {
    // Support for legacy Cards.
    if ([card.cardVersion isEqualToString:@"3.0"])
        return YES;
    
    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintOfData:card.snapshot];
    
    NSMutableDictionary *verifiers = [self.verifiers mutableCopy];
    VSSPublicKey *creatorPublicKey = [self.crypto importPublicKey:card.data.publicKey];
    verifiers[fingerprint.hexValue] = creatorPublicKey;

    for (NSString *verifierId in self.verifiers.allKeys) {
        NSData *signature = card.signatures[verifierId];
        if (signature == nil)
            return NO;
        
        NSError *error;
        BOOL isValid = [self.crypto verifyData:fingerprint.value signature:signature signerPublicKey:self.verifiers[verifierId] error:&error];
        
        if (!isValid)
            return NO;
    }

    return YES;
}

@end
