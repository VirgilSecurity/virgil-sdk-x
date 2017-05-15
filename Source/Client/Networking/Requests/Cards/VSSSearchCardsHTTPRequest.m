//
//  VSSSearchCardsHTTPRequest.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSearchCardsHTTPRequest.h"
#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"
#import "VSSSearchCardsCriteriaPrivate.h"
#import "VSSCreateCardRequest.h"
#import "VSSCardResponsePrivate.h"

@interface VSSSearchCardsHTTPRequest ()

@property (nonatomic, readwrite) NSArray <VSSCardResponse *> * __nullable cardResponses;

@end

@implementation VSSSearchCardsHTTPRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context searchCardsCriteria:(VSSSearchCardsCriteria *)criteria {
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

    NSMutableArray *cardResponses = [[NSMutableArray alloc] init];
    for (NSDictionary *item in [candidate vss_as:[NSArray class]]) {
        /// Deserialize actual cards
        VSSCardResponse *cardResponse = [[VSSCardResponse alloc] initWithDict:item];
        if (cardResponse != nil) {
            [cardResponses addObject:cardResponse];
        }
    }
    if (cardResponses.count > 0) {
        self.cardResponses = cardResponses;
    }
    return nil;
}

@end
