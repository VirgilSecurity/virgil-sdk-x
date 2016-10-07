//
//  VSSCreateCardRequest.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/3/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCreateCardRequest.h"
#import "VSSModelCommons.h"
#import "VSSCardData.h"
#import "VSSCardDataPrivate.h"
#import "VSSCard.h"
#import "VSSCardPrivate.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCreateCardRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSRequestContext *)context card:(VSSCard *)card {
    self = [super initWithContext:context];
    if (self) {
        NSDictionary *body = [card serialize];
        
        [self setRequestBodyWithObject:body];
    }
    
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"card";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    /// Deserialize actual card
    self.card = [[VSSCard alloc] initWithDict:[candidate as:[NSDictionary class]]];
    return nil;
}

@end
