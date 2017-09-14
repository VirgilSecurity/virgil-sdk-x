//
//  VSSFingerprint.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSFingerprint.h"

@implementation VSSFingerprint

@dynamic hexValue;

// FIXME

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
//        _value = [VSCByteArrayUtils dataFromHexString:hex];
    }
    
    return self;
}

- (NSString *)hexValue {
    return @"";
//    return [VSCByteArrayUtils hexStringFromData:self.value];
}

@end
