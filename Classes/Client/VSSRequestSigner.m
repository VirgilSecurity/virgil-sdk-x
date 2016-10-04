//
//  VSSRequestSigner.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequestSigner.h"

@implementation VSSRequestSigner

- (instancetype)initWithCrypto:(NSObject<VSSCrypto> *)crypto {
    self = [super init];
    if (self) {
        _crypto = crypto;
    }
    
    return self;
}

- (void)applicationSignRequest:(VSSSignedData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError **)errorPtr {
    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintOfData:data.snapshot];
    
    NSError *error;
    NSData *signature = [self.crypto signData:fingerprint.value privateKey:privateKey error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return;
    }
    
    [data addSignature:signature forFingerprint:fingerprint.hexValue];
}

- (void)authoritySignRequest:(VSSSignedData * __nonnull)data appId:(NSString * __nonnull)appId withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError **)errorPtr {
    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintOfData:data.snapshot];
    
    NSError *error;
    NSData *signature = [self.crypto signData:fingerprint.value privateKey:privateKey error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return;
    }
    
    [data addSignature:signature forFingerprint:appId];
}

@end
