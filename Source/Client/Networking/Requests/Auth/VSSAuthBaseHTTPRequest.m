//
//  VSSAuthBaseHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/22/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSAuthBaseHTTPRequest.h"
#import "VSSAuthError.h"
#import "NSObject+VSSUtils.h"

@implementation VSSAuthBaseHTTPRequest

#pragma mark - Overrides

- (NSError *)handleError:(NSObject *)candidate code:(NSInteger)code {
    NSError *error = [super handleError:candidate code:code];
    if (error != nil) {
        return error;
    }
    
    VSSAuthError *authError = [[VSSAuthError alloc] initWithDict:[candidate as:[NSDictionary class]]];
    
    return authError.nsError;
}

@end
