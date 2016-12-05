//
//  VSSKeyPair.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeyPair.h"
#import "VSSKeyPairPrivate.h"

@implementation VSSKeyPair

#pragma mark - Lifecycle

- (instancetype)initWithPrivateKey:(VSSPrivateKey * __nonnull)privateKey publicKey:(VSSPublicKey * __nonnull)publicKey {
    self = [super init];
    if (self) {
        _publicKey = publicKey;
        _privateKey = privateKey;
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [(VSSKeyPair *)[[self class] alloc] initWithPrivateKey:self.privateKey publicKey:self.publicKey];
}

@end
