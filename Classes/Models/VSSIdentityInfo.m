//
//  VSSIdentityInfo.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 4/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentityInfo.h"

#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"

@implementation VSSIdentityInfo

@synthesize type = _type;
@synthesize value = _value;
@synthesize validationToken = _validationToken;

- (instancetype)initWithType:(VSSIdentityType)type value:(NSString *)value validationToken:(NSString *)validationToken {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _type = type;
    _value = (value == nil) ? @"" : [value copy];
    _validationToken = [validationToken copy];
    return self;
}

- (instancetype)Type:(VSSIdentityType)type value:(NSString *)value {
    return [self initWithType:type value:value validationToken:nil];
}

- (instancetype)init {
    return [self initWithType:VSSIdentityTypeUnknown value:@"" validationToken:nil];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithType:self.type value:self.value validationToken:self.validationToken];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VSSIdentityType typ = (VSSIdentityType)[[[aDecoder decodeObjectForKey:kVSSModelType] as:[NSNumber class]] integerValue];
    NSString *val = [[aDecoder decodeObjectForKey:kVSSModelValue] as:[NSString class]];
    NSString *token = [[aDecoder decodeObjectForKey:kVSSModelValidationToken] as:[NSString class]];
    return [self initWithType:typ value:val validationToken:token];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    NSNumber *t = [NSNumber numberWithInteger:(NSInteger)self.type];
    if (t != nil) {
        [aCoder encodeObject:t forKey:kVSSModelType];
    }
    
    if (self.value != nil) {
        [aCoder encodeObject:self.value forKey:kVSSModelValue];
    }
    if (self.validationToken != nil) {
        [aCoder encodeObject:self.validationToken forKey:kVSSModelValidationToken];
    }
}

#pragma mark - VSSSerializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    VSSIdentityInfo *identityInfo = [super deserializeFrom:candidate];
    
    VSSIdentityType type = [VSSIdentityTypeHelper fromString:[candidate[kVSSModelType] as:[NSString class]]];
    identityInfo.type = type;
    
    NSString *value = [candidate[kVSSModelValue] as:[NSString class]];
    identityInfo.value = value;
    
    NSString *token = [candidate[kVSSModelValidationToken] as:[NSString class]];
    identityInfo.validationToken = token;
    
    return identityInfo;
}

#pragma mark - Public class logic

- (NSDictionary *)asDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVSSModelType] = [VSSIdentityTypeHelper toString:self.type];
    if (self.value != nil) {
        dict[kVSSModelValue] = self.value;
    }
    if (self.validationToken != nil) {
        dict[kVSSModelValidationToken] = self.validationToken;
    }
    return dict;
}

#pragma mark - NSObject protocol implementation: Equality

- (BOOL)isEqual:(id)object {
    VSSIdentityInfo *candidate = [object as:[VSSIdentityInfo class]];
    if (candidate == nil) {
        return NO;
    }
    /// The same value and the same type.
    return ([self.value isEqualToString:candidate.value] && (self.type == candidate.type));
    
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@-%@", [VSSIdentityTypeHelper toString:self.type], self.value] hash];
}


@end
