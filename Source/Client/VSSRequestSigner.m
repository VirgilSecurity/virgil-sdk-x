//
//  VSSRequestSigner.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequestSigner.h"
#import "VSSCreateCardRequest.h"
#import "NSObject+VSSUtils.h"

NSString *const kVSSRequestSignerErrorDomain = @"VSSRequestSignerErrorDomain";

// FIXME
@implementation VSSRequestSigner

- (instancetype)initWithCrypto:(id<VSACrypto>)crypto {
    self = [super init];
    if (self) {
        _crypto = crypto;
    }
    
    return self;
}

- (BOOL)selfSignRequest:(id<VSSSignable> __nonnull)request withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError **)errorPtr {
    return NO;
//    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:request.snapshot];
//    
//    NSError *error;
//    NSData *signature = [self.crypto generateSignatureForData:fingerprint.value withPrivateKey:privateKey error:&error];
//    
//    if (error != nil) {
//        if (errorPtr != nil)
//            *errorPtr = error;
//        return NO;
//    }
//    
//    return [request addSignature:signature forFingerprint:fingerprint.hexValue];
}

- (BOOL)authoritySignRequest:(id<VSSSignable> __nonnull)request forAppId:(NSString * __nonnull)appId withPrivateKey:(VSSPrivateKey * __nonnull)privateKey error:(NSError **)errorPtr {
    return NO;
//    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:request.snapshot];
//
//    NSError *error;
//    NSData *signature = [self.crypto generateSignatureForData:fingerprint.value withPrivateKey:privateKey error:&error];
//    
//    if (error != nil) {
//        if (errorPtr != nil)
//            *errorPtr = error;
//        return NO;
//    }
//    
//    return [request addSignature:signature forFingerprint:appId];
}

- (NSString *)getCardIdForRequest:(id<VSSSignable>)request {
    return @"";
//    VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:request.snapshot];
//    
//    return fingerprint.hexValue;
}

@end
