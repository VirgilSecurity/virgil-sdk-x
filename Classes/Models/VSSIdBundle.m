//
//  VSSIdBundle.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSIdBundle.h"
#import "VSSKeysModelCommons.h"
#import <VirgilKit/NSObject+VSSUtils.h>

@interface VSSIdBundle ()

@property (nonatomic, copy, readwrite) GUID * __nullable containerId;
@property (nonatomic, copy, readwrite) GUID * __nullable publicKeyId;
@property (nonatomic, copy, readwrite) GUID * __nullable userDataId;

@end

@implementation VSSIdBundle

@synthesize containerId = _containerId;
@synthesize publicKeyId = _publicKeyId;
@synthesize userDataId = _userDataId;

#pragma mark - Lifecycle

- (instancetype)initWithContainerId:(GUID *)containerId publicKeyId:(GUID *)publicKeyId userDataId:(GUID *)userDataId {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _containerId = [containerId copy];
    _publicKeyId = [publicKeyId copy];
    _userDataId = [userDataId copy];
    return self;
}

- (instancetype)init {
    return [self initWithContainerId:nil publicKeyId:nil userDataId:nil];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithContainerId:self.containerId publicKeyId:self.publicKeyId userDataId:self.userDataId];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    GUID *containerId = [[aDecoder decodeObjectForKey:kVSSKeysModelContainerId] as:[GUID class]];
    GUID *publicKeyId = [[aDecoder decodeObjectForKey:kVSSKeysModelPublicKeyId] as:[GUID class]];
    GUID *userDataId = [[aDecoder decodeObjectForKey:kVSSKeysModelUserDataId] as:[GUID class]];
    
    return [self initWithContainerId:containerId publicKeyId:publicKeyId userDataId:userDataId];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.containerId != nil) {
        [aCoder encodeObject:self.containerId forKey:kVSSKeysModelContainerId];
    }
    if (self.publicKeyId != nil) {
        [aCoder encodeObject:self.publicKeyId forKey:kVSSKeysModelPublicKeyId];
    }
    if (self.userDataId != nil) {
        [aCoder encodeObject:self.userDataId forKey:kVSSKeysModelUserDataId];
    }
}

#pragma mark - VFSerializable

- (NSDictionary *)serialize {
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] initWithDictionary:[super serialize]];
    if (self.containerId != nil) {
        dto[kVSSKeysModelContainerId] = self.containerId;
    }
    if (self.publicKeyId != nil) {
        dto[kVSSKeysModelPublicKeyId] = self.publicKeyId;
    }
    if (self.userDataId != nil) {
        dto[kVSSKeysModelUserDataId] = self.userDataId;
    }
    return dto;
}

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    GUID *containerId = [candidate[kVSSKeysModelContainerId] as:[GUID class]];
    GUID *publicKeyId = [candidate[kVSSKeysModelPublicKeyId] as:[GUID class]];
    GUID *userDataId = [candidate[kVSSKeysModelUserDataId] as:[GUID class]];
    
    return [[self alloc] initWithContainerId:containerId publicKeyId:publicKeyId userDataId:userDataId];
}

#pragma mark - NSObject protocol implementation: Equality

- (BOOL)isEqual:(id)object {
    VSSIdBundle *candidate = [object as:[VSSIdBundle class]];
    if (candidate == nil) {
        return NO;
    }
    
    if (![self.containerId isEqualToString:candidate.containerId]) {
        return NO;
    }
    
    if (![self.publicKeyId isEqualToString:candidate.publicKeyId]) {
        return NO;
    }
    
    if (![self.userDataId isEqualToString:candidate.userDataId]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    NSString *hashable = [NSString stringWithFormat:@"%@%@%@", (self.containerId == nil) ? @"" : self.containerId, (self.publicKeyId == nil) ? @"" : self.publicKeyId, (self.userDataId == nil) ? @"" : self.userDataId];
    return [hashable hash];
}

#pragma mark - Overrides

- (NSNumber *)isValid {
    return [NSNumber numberWithBool:(self.containerId.length > 0)];
}

@end
