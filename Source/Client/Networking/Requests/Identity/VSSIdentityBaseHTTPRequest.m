//
//  VSSIdentityBaseHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentityBaseHTTPRequest.h"
#import "VSSIdentityError.h"
#import "NSObject+VSSUtils.h"
#import "VSSError.h"

@implementation VSSIdentityBaseHTTPRequest

#pragma mark - Overrides

- (NSError *)handleError:(NSObject *)candidate code:(NSInteger)code {
    NSError *error = [super handleError:candidate code:code];
    if (error != nil) {
        return error;
    }
    
    VSSIdentityError *viError = [[VSSIdentityError alloc] initWithDict:[candidate as:[NSDictionary class]]];
    return viError.nsError;
}

@end
