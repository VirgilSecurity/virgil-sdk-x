//
//  VSSSearchCardsCriteriaRequest.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSearchCardsRequest.h"
#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"
#import "VSSSearchCardsCriteriaPrivate.h"
#import "VSSCardPrivate.h"

@interface VSSSearchCardsRequest ()

@property (nonatomic, readwrite) NSArray <VSSCard *>* __nullable cards;

@end

@implementation VSSSearchCardsRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSRequestContext *)context searchCardsCriteria:(VSSSearchCardsCriteria *)criteria {
    self = [super initWithContext:context];
    if (self) {
        [self setRequestBodyWithObject:[criteria serialize]];
    }
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
        VSSCard *card = [[VSSCard alloc] initWithDict:item];
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
