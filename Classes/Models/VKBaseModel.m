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

@property (nonatomic, copy, readwrite) VKIdBundle *Id;

@end

@implementation VKBaseModel

@synthesize Id = _Id;

#pragma mark - Lifecycle

- (instancetype)initWithId:(VKIdBundle *)Id {
    self = [super init];
    if (self == nil) {
        return nil;
    }
 
    _Id = [Id copy];
    return self;
}

- (instancetype)init {
    return [self initWithId:nil];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithId:self.Id];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VKIdBundle *Id = [[aDecoder decodeObjectForKey:kVKModelId] as:[VKIdBundle class]];
    return [self initWithId:Id];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.Id != nil) {
        [aCoder encodeObject:self.Id forKey:kVKModelId];
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
    
    return [self.Id isEqual:candidate.Id];
}

- (NSUInteger)hash {
    return [self.Id hash];
}

@end
