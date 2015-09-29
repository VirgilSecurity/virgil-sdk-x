//
//  VFModel.m
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VFModel.h"

@implementation VFModel

#pragma mark - Class logic

- (NSNumber *)isValid {
    // Basic model is just always valid.
    return @YES;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] init];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Nothing to encode.
}

#pragma mark - VFSerializable

- (NSDictionary *)serialize {
    return @{};
}

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
#pragma unused(candidate)
    return [[[self class] alloc] init];
}

@end
