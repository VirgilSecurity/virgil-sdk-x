//
//  VSSVraBaseHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/25/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVraBaseHTTPRequest.h"
#import "VSSVraError.h"
#import "VSSCardsError.h"
#import "NSObject+VSSUtils.h"
#import "VSSError.h"

@implementation VSSVraBaseHTTPRequest

#pragma mark - Overrides

- (NSError *)handleError:(NSObject *)candidate {
    NSError *error = [super handleError:candidate];
    if (error != nil) {
        return error;
    }
    
    VSSVraError *viError = [[VSSVraError alloc] initWithDict:[candidate as:[NSDictionary class]]];
    if (viError != nil) {
        error = viError.nsError;
    }
    else {
        VSSCardsError *viError = [[VSSCardsError alloc] initWithDict:[candidate as:[NSDictionary class]]];
        if (viError != nil) {
            error = viError.nsError;
        }
    }
    
    return error;
}

@end
