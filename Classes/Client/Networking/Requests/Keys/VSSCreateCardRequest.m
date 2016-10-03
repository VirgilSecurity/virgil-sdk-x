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
#import "VSSCardModel.h"
#import "VSSCardModelPrivate.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCreateCardRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSRequestContext *)context card:(VSSCardData *)card {
    self = [super initWithContext:context];
    if (self == nil) {
        return nil;
    }
    
    NSDictionary *body = [card serialize];
    
    [self setRequestBodyWithObject:body];
    
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"virgil-card";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    /// Deserialize actual card
    self.cardModel = [VSSCardModel deserializeFrom:[candidate as:[NSDictionary class]]];
    return nil;
}

@end
