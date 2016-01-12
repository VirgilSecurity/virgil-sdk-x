//
//  VSSBaseModel.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSIdBundle.h"
#import "VSSKeysModelCommons.h"
#import <VirgilKit/NSObject+VSSUtils.h>

@interface VSSBaseModel ()

@property (nonatomic, copy, readwrite) VSSIdBundle * __nonnull idb;

@end

@implementation VSSBaseModel

@synthesize idb = _idb;

#pragma mark - Lifecycle

- (instancetype)initWithIdb:(VSSIdBundle *)idb {
    self = [super init];
    if (self == nil) {
        return nil;
    }
 
    _idb = [idb copy];
    return self;
}

- (instancetype)init {
    return [self initWithIdb:[[VSSIdBundle alloc] init]];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithIdb:self.idb];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VSSIdBundle *idb = [[aDecoder decodeObjectForKey:kVSSKeysModelId] as:[VSSIdBundle class]];
    return [self initWithIdb:idb];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.idb != nil) {
        [aCoder encodeObject:self.idb forKey:kVSSKeysModelId];
    }
}

#pragma mark - VFSerializable

- (NSDictionary *)serialize {
    return [super serialize];
}

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    return [[self alloc] init];
}

#pragma mark - NSObject protocol implementation: Equality

- (BOOL)isEqual:(id)object {
    VSSBaseModel *candidate = [object as:[VSSBaseModel class]];
    if (candidate == nil) {
        return NO;
    }
    
    return [self.idb isEqual:candidate.idb];
}

- (NSUInteger)hash {
    return [self.idb hash];
}

@end
