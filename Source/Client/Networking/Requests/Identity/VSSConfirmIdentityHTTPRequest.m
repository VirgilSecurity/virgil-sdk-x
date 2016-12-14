//
//  VSSConfirmIdentityHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSConfirmIdentityHTTPRequest.h"
#import "VSSConfirmIdentityResponsePrivate.h"
#import "NSObject+VSSUtils.h"

@interface VSSConfirmIdentityHTTPRequest ()

@property (nonatomic, readwrite) VSSConfirmIdentityResponse * __nullable confirmIdentityResponse;

@end

@implementation VSSConfirmIdentityHTTPRequest

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context confirmIdentityRequest:(VSSConfirmIdentityRequest *)request {
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
    return @"confirm";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    self.confirmIdentityResponse = [[VSSConfirmIdentityResponse alloc] initWithDict:[candidate as:[NSDictionary class]]];
    
    return nil;
}

@end
