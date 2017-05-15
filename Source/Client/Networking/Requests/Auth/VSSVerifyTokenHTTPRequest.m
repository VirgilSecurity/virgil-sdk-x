//
//  VSSVerifyTokenHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVerifyTokenHTTPRequest.h"
#import "VSSVerifyTokenResponse.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSVerifyTokenHTTPRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context verifyTokenRequest:(VSSVerifyTokenRequest *)request {
    self = [super initWithContext:context];
    if (self) {
        NSDictionary *body = [request serialize];
        
        [self setRequestBodyWithObject:body];
    }
    
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"authorization/actions/verify";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    self.verifyTokenResponse = [[VSSVerifyTokenResponse alloc] initWithDict:[candidate vss_as:[NSDictionary class]]];
    return nil;
}

@end
