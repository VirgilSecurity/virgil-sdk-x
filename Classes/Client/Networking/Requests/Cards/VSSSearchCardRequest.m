//
//  VSSSearchCardRequest.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSearchCardRequest.h"
#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"
#import "VSSSearchCardsCriteria.h"
#import "VSSCardModelPrivate.h"

@interface VSSSearchCardRequest ()

@property (nonatomic, readwrite) NSArray <VSSCardModel *>* __nullable cards;

@end

@implementation VSSSearchCardRequest

@synthesize cards = _cards;

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSRequestContext *)context searchCriteria:(VSSSearchCardsCriteria *)criteria {
    self = [super initWithContext:context];
    if (self == nil) {
        return nil;
    }

    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    body[@"identities"] = criteria.identities;
    body[@"identity_type"] = criteria.identityType;
    
    switch (criteria.scope) {
        case VSSCardScopeGlobal:
            body[@"scope"] = @"global";
            break;
            
        case VSSCardScopeApplication:
            break;
    }

    [self setRequestBodyWithObject:body];
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"card/actions/search";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }

    NSMutableArray *cards = [[NSMutableArray alloc] init];
    for (NSDictionary *item in [candidate as:[NSArray class]]) {
        /// Deserialize actual card
        VSSCardModel *card = [[VSSCardModel alloc] initWithDict:item];
        if (card != nil) {
            [cards addObject:card];
        }
    }
    if (cards.count > 0) {
        self.cards = cards;
    }
    return nil;
}

@end
