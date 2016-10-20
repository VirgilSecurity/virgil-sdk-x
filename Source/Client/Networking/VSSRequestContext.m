//
//  VSSRequestContext.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequestContext.h"

@interface VSSRequestContext ()

@property (nonatomic, readwrite) NSURL * __nonnull serviceUrl;

@end

@implementation VSSRequestContext

- (instancetype)initWithServiceUrl:(NSURL *)serviceUrl {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _serviceUrl = serviceUrl;
    
    return self;
}

@end
