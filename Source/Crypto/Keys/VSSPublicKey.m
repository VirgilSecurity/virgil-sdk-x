//
//  VSSPublicKey.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSPublicKey.h"
#import "VSSPublicKeyPrivate.h"
#import "NSObject+VSSUtils.h"
#import "VSSModelKeys.h"

@implementation VSSPublicKey

#pragma mark - Lifecycle

- (instancetype)initWithKey:(NSData *)key identifier:(NSData * __nonnull)identifier {
    self = [super init];
    if (self) {
        _key = [key copy];
        _identifier = [identifier copy];
    }
    
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [(VSSPublicKey *) [[self class] alloc] initWithKey:self.key identifier:self.identifier];
}

@end
