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

- (instancetype __nonnull)initWithPrivateKey:(VSSPrivateKey * __nonnull)privateKey andPublicKey:(VSSPublicKey * __nonnull)publicKey {
    self = [super init];
    if (self) {
        _publicKey = publicKey;
        _privateKey = privateKey;
    }
    return self;
}

@end
