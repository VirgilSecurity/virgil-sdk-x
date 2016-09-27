//
//  VSSIdentity.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 1/20/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentity.h"
#import "NSObject+VSSUtils.h"
#import "VSSModelKeys.h"

@implementation VSSIdentity

#pragma mark - Lifecycle

- (instancetype)initWithType:(NSString *)type value:(NSString *)value {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _type = [type copy];
    _value = [value copy];
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithType:self.type value:self.value];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *typ = [[aDecoder decodeObjectForKey:kVSSModelType] as:[NSString class]];
    NSString *val = [[aDecoder decodeObjectForKey:kVSSModelValue] as:[NSString class]];
    return [self initWithType:typ value:val];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];

    if (self.type != nil) {
        [aCoder encodeObject:self.type forKey:kVSSModelType];
    }
    if (self.value != nil) {
        [aCoder encodeObject:self.value forKey:kVSSModelValue];
    }
}

@end
