//
//  VSSFingerprint.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSFingerprint.h"

@import VirgilCrypto;

@implementation VSSFingerprint

@dynamic hexValue;

- (instancetype)initWithValue:(NSData *)value {
    self = [super init];
    if (self) {
        _value = [value copy];
    }
    
    return self;
}

- (instancetype)initWithHex:(NSString *)hex {
    self = [super init];
    if (self) {
        _value = [VSCByteArrayUtils dataFromHexString:hex];
    }
    
    return self;
}

- (NSString *)hexValue {
    return [VSCByteArrayUtils hexStringFromData:self.value];
}

@end
