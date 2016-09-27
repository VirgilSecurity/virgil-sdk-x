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

- (instancetype)initWithKey:(NSData *)key password:(NSString *)password publicKey:(VSSPublicKey * __nonnull)publicKey {
    self = [super init];
    if (self) {
        _key = [key copy];
        _password = [password copy];
        _publicKey = [publicKey copy];
    }

    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [(VSSPrivateKey *)[[self class] alloc] initWithKey:self.key password:self.password publicKey:self.publicKey];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSData *key = [[aDecoder decodeObjectForKey:kVSSModelPrivateKey] as:[NSData class]];
    NSString *pass = [[aDecoder decodeObjectForKey:kVSSModelPassword] as:[NSString class]];
    NSData *publicKey = [[aDecoder decodeObjectForKey:kVSSModelPublicKey] as:[NSString class]];

    return [self initWithKey:key password:pass publicKey:publicKey];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:self.key forKey:kVSSModelPrivateKey];
    
    if (self.password != nil)
        [aCoder encodeObject:self.password forKey:kVSSModelPassword];
    
    [aCoder encodeObject:self.publicKey forKey:kVSSModelPublicKey];
}

#pragma mark - VSSDeserializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
#warning fixme
    NSString *keyB64String = [candidate[kVSSModelPrivateKey] as:[NSString class]];
    NSData *key = [[NSData alloc] initWithBase64EncodedString:keyB64String options:0];

    return [[self alloc] initWithKey:key password:nil publicKey:nil];
}

@end
