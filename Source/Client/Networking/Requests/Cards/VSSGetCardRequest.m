//
//  VSSGetCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSGetCardRequest.h"
#import "VSSCardPrivate.h"
#import "NSObject+VSSUtils.h"

@interface VSSGetCardRequest ()

@property (nonatomic, copy, readonly) NSString * __nonnull cardId;

@property (nonatomic, readwrite) VSSCard * __nullable card;

@end

@implementation VSSGetCardRequest

- (instancetype)initWithContext:(VSSRequestContext *)context cardId:(NSString *)cardId {
    self = [super initWithContext:context];
    if (self) {
        _cardId = [cardId copy];
        
        [self setRequestMethod:GET];
    }
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [[NSString alloc] initWithFormat:@"card/%@", self.cardId];
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
