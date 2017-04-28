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

- (NSError *)handleError:(NSObject *)candidate code:(NSInteger)code {
    NSError *error = [super handleError:candidate code:code];
    if (error != nil) {
        return error;
    }
    
    VSSVraError *vraError = [[VSSVraError alloc] initWithDict:[candidate vss_as:[NSDictionary class]]];
    if (vraError.message.length > 0) {
        error = vraError.nsError;
    }
    else {
        VSSCardsError *cardsError = [[VSSCardsError alloc] initWithDict:[candidate vss_as:[NSDictionary class]]];
        if (cardsError.message.length > 0) {
            error = cardsError.nsError;
        }
        else {
            error = vraError.nsError;
        }
    }
    
    return error;
}

@end
