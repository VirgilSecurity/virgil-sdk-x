//
//  VSSGetChallengeMessageHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSGetChallengeMessageHTTPRequest.h"
#import "VSSChallengeMessageResponsePrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSGetChallengeMessageHTTPRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context challengeMessageRequest:(VSSChallengeMessageRequest *)request {
    self = [super initWithContext:context];
    if (self) {
        NSDictionary *body = [request serialize];
        
        [self setRequestBodyWithObject:body];
    }
    
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"authorization-grant/actions/get-challenge-message";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    self.challengeMessageResponse = [[VSSChallengeMessageResponse alloc] initWithDict:[candidate vss_as:[NSDictionary class]]];
    return nil;
}

@end
