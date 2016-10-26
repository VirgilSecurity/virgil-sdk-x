//
//  VSSHTTPRequestContext.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSHTTPRequestContext.h"

@interface VSSHTTPRequestContext ()

@property (nonatomic, readwrite) NSURL * __nonnull serviceUrl;

@end

@implementation VSSHTTPRequestContext

- (instancetype)initWithServiceUrl:(NSURL *)serviceUrl {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _serviceUrl = serviceUrl;
    
    return self;
}

@end
