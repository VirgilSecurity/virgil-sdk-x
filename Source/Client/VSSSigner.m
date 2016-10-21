//
//  VSSSigner.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSigner.h"
#import "VSSCard.h"
#import "NSObject+VSSUtils.h"

NSString *const kVSSSignerErrorDomain = @"VSSSignerErrorDomain";

@implementation VSSSigner

- (instancetype)initWithCrypto:(id<VSSCrypto>)crypto {
    self = [super init];
    if (self) {
        _crypto = crypto;
    }
    
    return self;
}

- (BOOL)ownerSignData:(VSSSignedData * __nonnull)data withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError **)errorPtr {
    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:data.snapshot];
    
    NSError *error;
    NSData *signature = [self.crypto generateSignatureForData:fingerprint.value withPrivateKey:privateKey error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    [data addSignature:signature forFingerprint:fingerprint.hexValue];
    
    return YES;
}

- (BOOL)authoritySignData:(VSSSignedData * __nonnull)data forAppId:(NSString * __nonnull)appId withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError **)errorPtr {
    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:data.snapshot];
    
    // FIXME: We need to check owner Signature for VSSCard
    // but VSSRevokeCard doesn't contain owner signature
    VSSCard *card = [data as:[VSSCard class]];
    if (card != nil) {
        BOOL isSignedByOwner = YES;
        NSData *ownerSignature = data.signatures[fingerprint.hexValue];
        
        if (ownerSignature != nil) {
            NSError *error;
            VSSPublicKey *publicKey = [self.crypto importPublicKeyFromData:card.data.publicKey];
            BOOL isVerified = [self.crypto verifyData:fingerprint.value withSignature:ownerSignature usingSignerPublicKey:publicKey error:&error];
            
            if (error != nil) {
                if (errorPtr != nil)
                    *errorPtr = error;
                return NO;
            }
            
            if (!isVerified)
                isSignedByOwner = NO;
        }
        else {
            isSignedByOwner = NO;
        }
        
        if (!isSignedByOwner) {
            if (errorPtr != nil) {
                *errorPtr = [[NSError alloc] initWithDomain:kVSSSignerErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Error validating owner signature" }];
            }
            return NO;
        }
    }

    NSError *error;
    NSData *signature = [self.crypto generateSignatureForData:fingerprint.value withPrivateKey:privateKey error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    [data addSignature:signature forFingerprint:appId];
    return YES;
}

@end
