//
//  VSSPrivateKey.m
//  VirgilKit
//
//  Created by Pavel Gorb on 10/12/15.
//  Copyright © 2015 VirgilSecurity. All rights reserved.
//

#import "VSSPrivateKey.h"
#import "NSObject+VSSUtils.h"

static NSString *const kVSSPrivateKeyKey = @"key";
static NSString *const kVSSPrivateKeyPassword = @"password";

@implementation VSSPrivateKey

@synthesize key = _key;
@synthesize password = _password;

- (instancetype)initWithKey:(NSData *)key password:(NSString *)password {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    _key = key;
    _password = password;
    return self;
}

- (instancetype)initWithKey:(NSData *)key {
    return [self initWithKey:key password:nil];
}

- (instancetype)init {
    return [self initWithKey:[NSData data] password:nil];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self initWithKey:self.key password:self.password];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSData* keyData = [[aDecoder decodeObjectForKey:kVSSPrivateKeyKey] as:[NSData class]];
    NSString *pwd = [[aDecoder decodeObjectForKey:kVSSPrivateKeyPassword] as:[NSString class]];
    
    return [self initWithKey:keyData password:pwd];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (self.key != nil) {
        [aCoder encodeObject:self.key forKey:kVSSPrivateKeyKey];
    }
    if (self.password != nil) {
        [aCoder encodeObject:self.password forKey:kVSSPrivateKeyPassword];
    }
}

@end
