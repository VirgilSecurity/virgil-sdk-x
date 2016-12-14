//
//  VSSIdentityBaseHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSIdentityBaseHTTPRequest.h"
#import "VSSCardsError.h"
#import "NSObject+VSSUtils.h"
#import "VSSError.h"

// FIXME
@implementation VSSIdentityBaseHTTPRequest

#pragma mark - Overrides

- (NSError *)handleError:(NSObject *)candidate {
    NSError *error = [super handleError:candidate];
    if (error != nil) {
        return error;
    }
    
    VSSCardsError *vcError = [[VSSCardsError alloc] initWithDict:[candidate as:[NSDictionary class]]];
    return vcError.nsError;
}

@end
