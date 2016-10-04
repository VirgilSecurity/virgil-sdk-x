//
//  VSSCardsBaseRequest.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSCardsBaseRequest.h"
#import "VSSCardsError.h"
#import "NSObject+VSSUtils.h"
#import "VSSErrorPrivate.h"

@implementation VSSCardsBaseRequest

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
