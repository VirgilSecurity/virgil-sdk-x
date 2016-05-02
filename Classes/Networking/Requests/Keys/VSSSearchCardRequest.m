//
//  VSSSearchCardRequest.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 2/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSearchCardRequest.h"
#import "VSSCard.h"
#import "VSSPublicKey.h"
#import "VSSIdentityInfo.h"
#import "NSObject+VSSUtils.h"

@interface VSSSearchCardRequest ()

@property (nonatomic, strong, readwrite) NSArray <VSSCard *>* __nullable cards;

@end

@implementation VSSSearchCardRequest

@synthesize cards = _cards;

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSRequestContext *)context identityInfo:(VSSIdentityInfo *)identityInfo relations:(NSArray <GUID *>*)relations unconfirmed:(BOOL)unconfirmed {
    self = [super initWithContext:context];
    if (self == nil) {
        return nil;
    }
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    if (identityInfo.value.length > 0) {
        body[kVSSModelValue] = identityInfo.value;
    }
    if (identityInfo.type.length > 0) {
        body[kVSSModelType] = identityInfo.type;
    }
    if (relations.count > 0) {
        body[kVSSModelRelations] = relations;
    }
    NSString *str = (unconfirmed) ? kVSSStringValueTrue : kVSSStringValueFalse;
    body[kVSSModelIncludeUnconfirmed] = str;

    [self setRequestBodyWithObject:body];
    return self;
}

- (instancetype)initWithContext:(VSSRequestContext *)context {
    return [self initWithContext:context identityInfo:[[VSSIdentityInfo alloc] init] relations:nil unconfirmed:NO];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"virgil-card/actions/search";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }

    NSMutableArray *cards = [[NSMutableArray alloc] init];
    for (NSDictionary *item in [candidate as:[NSArray class]]) {
        /// Deserialize actual card
        VSSCard *card = [VSSCard deserializeFrom:item];
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
