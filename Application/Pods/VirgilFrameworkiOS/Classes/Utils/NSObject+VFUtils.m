//
//  NSObject+VFUtils.m
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "NSObject+VFUtils.h"

@implementation NSObject (VFUtils)

- (id)as:(Class)expectedClass {
    if ([self isKindOfClass:expectedClass]) {
        return self;
    }
    return nil;
}

@end
