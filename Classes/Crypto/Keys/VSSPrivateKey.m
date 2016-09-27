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

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSData *key = [[aDecoder decodeObjectForKey:kVSSModelPrivateKey] as:[NSData class]];
    NSData *identifier = [[aDecoder decodeObjectForKey:kVSSModelId] as:[NSString class]];

    return [self initWithKey:key identifier:identifier];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:self.key forKey:kVSSModelPrivateKey];
    
    [aCoder encodeObject:self.identifier forKey:kVSSModelId];
}

@end
