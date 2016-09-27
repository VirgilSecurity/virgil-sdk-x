//
//  VSSPublicKey.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSPublicKey.h"
#import "VSSPublicKeyPrivate.h"
#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"

@implementation VSSPublicKey

#pragma mark - Lifecycle

- (instancetype)initWithKey:(NSData *)key {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _key = [key copy];
    return self;
}

#pragma mark - NSCopying protocol implementation

- (instancetype)copyWithZone:(NSZone *)zone {
    return [(VSSPublicKey *) [[self class] alloc] initWithKey:self.key];
}

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSData *key = [[aDecoder decodeObjectForKey:kVSSModelPublicKey] as:[NSData class]];
    
    return [self initWithKey:key];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.key != nil) {
        [aCoder encodeObject:self.key forKey:kVSSModelPublicKey];
    }
}

#pragma mark - VSSStringRepresentable

+ (instancetype)initWithStringValue:(NSString *)string {
    VSSPublicKey * publicKey = [[VSSPublicKey alloc] initWithKey:[[NSData alloc] initWithBase64EncodedString:string options:0]];
    
    return publicKey;
}

- (NSString * __nonnull)getStringValue {
    return [self.key base64EncodedStringWithOptions:0];
}

@end
