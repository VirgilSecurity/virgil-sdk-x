//
//  VKBaseModel.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseModel.h"
#import "VKIdBundle.h"
#import "VKModelCommons.h"
#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

@interface VKBaseModel ()

@property (nonatomic, copy, readwrite) VKIdBundle *idb;

@end

@implementation VKBaseModel

@synthesize idb = _idb;

#pragma mark - Lifecycle

- (instancetype)initWithIdb:(VKIdBundle *)idb {
    self = [super init];
    if (self == nil) {
        return nil;
    }
 
    _idb = [idb copy];
    return self;
}

- (instancetype)init {
    return [self initWithIdb:nil];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithIdb:self.idb];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VKIdBundle *idb = [[aDecoder decodeObjectForKey:kVKModelId] as:[VKIdBundle class]];
    return [self initWithIdb:idb];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.idb != nil) {
        [aCoder encodeObject:self.idb forKey:kVKModelId];
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
    VKBaseModel *candidate = [object as:[VKBaseModel class]];
    if (candidate == nil) {
        return NO;
    }
    
    return [self.idb isEqual:candidate.idb];
}

- (NSUInteger)hash {
    return [self.idb hash];
}

@end
