//
//  VSSPrivateKey.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 1/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSPrivateKey.h"
#import "VSSPrivateKeyPrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSPrivateKey

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
    return [(VSSPrivateKey *)[[self class] alloc] initWithKey:self.key identifier:self.identifier];
}

@end
