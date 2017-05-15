//
//  VSSVerifyIdentityHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVerifyIdentityHTTPRequest.h"
#import "NSObject+VSSUtils.h"

@interface VSSVerifyIdentityHTTPRequest ()

@property (nonatomic, readwrite) VSSVerifyIdentityResponse * __nullable verifyIdentityResponse;

@end

@implementation VSSVerifyIdentityHTTPRequest

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context verifyIdentityRequest:(VSSVerifyIdentityRequest *)request {
    self = [super initWithContext:context];
    if (self) {
        NSDictionary *body = [request serialize];

        [self setRequestMethod:POST];

        [self setRequestBodyWithObject:body];
    }
    
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"verify";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    self.verifyIdentityResponse = [[VSSVerifyIdentityResponse alloc] initWithDict:[candidate vss_as:[NSDictionary class]]];
    
    return nil;
}

@end
