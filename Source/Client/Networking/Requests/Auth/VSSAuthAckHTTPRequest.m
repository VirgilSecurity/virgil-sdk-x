//
//  VSSAuthAckHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSAuthAckHTTPRequest.h"
#import "VSSAuthAckResponse.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSAuthAckHTTPRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context authGrantId:(NSString *)authGrantId authAckRequest:(VSSAuthAckRequest *)request {
    self = [super initWithContext:context];
    if (self) {
        _authGrantId = [authGrantId copy];
        
        NSDictionary *body = [request serialize];
        
        [self setRequestBodyWithObject:body];
    }
    
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [[NSString alloc] initWithFormat:@"authorization-grant/%@/actions/acknowledge", self.authGrantId];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    self.authAckResponse = [[VSSAuthAckResponse alloc] initWithDict:[candidate vss_as:[NSDictionary class]]];
    return nil;
}

@end
