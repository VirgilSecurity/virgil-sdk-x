//
//  VSSPublicKey.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSPublicKey.h"
#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"

@interface VSSPublicKey ()

@property (nonatomic, copy, readwrite) NSData * __nonnull key;

@end

@implementation VSSPublicKey

@synthesize key = _key;

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

#pragma mark - VSSSerializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    VSSPublicKey *pkey = [super deserializeFrom:candidate];

    NSString *keyB64String = [candidate[kVSSModelPublicKey] as:[NSString class]];
    pkey.key = [[NSData alloc] initWithBase64EncodedString:keyB64String options:0];
    
    return pkey;
}

@end
