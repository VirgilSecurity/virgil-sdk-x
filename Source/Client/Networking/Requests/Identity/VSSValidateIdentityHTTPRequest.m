//
//  VSSValidateIdentityHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSValidateIdentityHTTPRequest.h"

@implementation VSSValidateIdentityHTTPRequest

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context validateIdentityRequest:(VSSValidateIdentityRequest *)request {
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
    return @"validate";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    return nil;
}

@end
