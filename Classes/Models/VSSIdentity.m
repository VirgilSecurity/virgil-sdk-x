//
//  VSSIdentity.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 1/20/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentity.h"
#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"

@interface VSSIdentity ()

@property (nonatomic, assign, readwrite) VSSIdentityType type;
@property (nonatomic, copy, readwrite) NSString * __nonnull value;
@property (nonatomic, copy, readwrite) NSNumber * __nonnull isConfirmed;

@end

@implementation VSSIdentity

@synthesize type = _type;
@synthesize value = _value;
@synthesize isConfirmed = _isConfirmed;

#pragma mark - Lifecycle

- (instancetype)initWithId:(GUID *)Id createdAt:(NSDate *)createdAt type:(VSSIdentityType)type value:(NSString *)value isConfirmed:(NSNumber *)isConfirmed {
    self = [super initWithId:Id createdAt:createdAt];
    if (self == nil) {
        return nil;
    }
    
    _type = type;
    _value = [value copy];
    _isConfirmed = [isConfirmed copy];
    return self;
}

- (instancetype)initWithId:(GUID *)Id createdAt:(NSDate *)createdAt typeString:(NSString *)typeString value:(NSString *)value isConfirmed:(NSNumber *)isConfirmed {
    return [self initWithId:Id createdAt:createdAt type:[[self class] identityTypeFromString:typeString] value:value isConfirmed:isConfirmed];
}

- (instancetype)initWithId:(GUID *)Id createdAt:(NSDate *)createdAt {
    return [self initWithId:Id createdAt:createdAt type:VSSIdentityTypeUnknown value:@"" isConfirmed:@NO];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithId:self.Id createdAt:self.createdAt type:self.type value:self.value isConfirmed:self.isConfirmed];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    GUID *gid = [[aDecoder decodeObjectForKey:kVSSModelId] as:[GUID class]];
    NSDate *cat = [[aDecoder decodeObjectForKey:kVSSModelCreatedAt] as:[NSDate class]];
    VSSIdentityType typ = (VSSIdentityType)[[[aDecoder decodeObjectForKey:kVSSModelType] as:[NSNumber class]] integerValue];
    NSString *val = [[aDecoder decodeObjectForKey:kVSSModelValue] as:[NSString class]];
    NSNumber *isConf = [[aDecoder decodeObjectForKey:kVSSModelIsConfirmed] as:[NSNumber class]];
    return [self initWithId:gid createdAt:cat type:typ value:val isConfirmed:isConf];
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
    if (self.isConfirmed != nil) {
        [aCoder encodeObject:self.isConfirmed forKey:kVSSModelIsConfirmed];
    }
}

#pragma mark - VSSSerializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    VSSIdentity *identity = [super deserializeFrom:candidate];
    
    VSSIdentityType type = [self identityTypeFromString:[candidate[kVSSModelType] as:[NSString class]]];
    identity.type = type;
    
    NSString *value = [candidate[kVSSModelValue] as:[NSString class]];
    identity.value = value;
    
    NSNumber *confirmed = [candidate[kVSSModelIsConfirmed] as:[NSNumber class]];
    identity.isConfirmed = confirmed;
    
    return identity;
}

#pragma mark - Public class logic

// Convenient methods for converting enums to strings and vice-versa.
+ (NSString * __nonnull)stringFromIdentityType:(VSSIdentityType)identityType {
    NSString *itString = kVSSIdentityTypeUnknown;
    switch (identityType) {
        case VSSIdentityTypeEmail:
            itString = kVSSIdentityTypeEmail;
            break;
        case VSSIdentityTypeApplication:
            itString = kVSSIdentityTypeApplication;
        default:
            break;
    }
    return itString;
}

+ (VSSIdentityType)identityTypeFromString:(NSString * __nullable)itCandidate {
    VSSIdentityType itype = VSSIdentityTypeUnknown;
    if ([itCandidate isEqualToString:kVSSIdentityTypeEmail]) {
        itype = VSSIdentityTypeEmail;
    }
    else if ([itCandidate isEqualToString:kVSSIdentityTypeApplication]) {
        itype = VSSIdentityTypeApplication;
    }
    return itype;
}

@end
