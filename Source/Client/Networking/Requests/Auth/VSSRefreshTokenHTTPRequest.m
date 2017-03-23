//
//  VSSRefreshTokenHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSRefreshTokenHTTPRequest.h"
#import "VSSTokenResponsePrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSRefreshTokenHTTPRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context refreshTokenRequest:(VSSRefreshTokenRequest *)request {
    self = [super initWithContext:context];
    if (self) {
        NSDictionary *body = [request serialize];
        
        [self setRequestBodyWithObject:body];
    }
    
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"authorization/actions/refresh-access-token";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    self.tokenResponse = [[VSSTokenResponse alloc] initWithDict:[candidate as:[NSDictionary class]]];
    return nil;
}

@end
