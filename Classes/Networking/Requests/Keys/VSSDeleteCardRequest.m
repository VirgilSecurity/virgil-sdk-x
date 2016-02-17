//
//  VSSDeleteCardRequest.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/4/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSDeleteCardRequest.h"
#import "VSSModelCommons.h"

@interface VSSDeleteCardRequest ()

@property (nonatomic, strong) GUID * __nonnull cardId;

@end

@implementation VSSDeleteCardRequest

@synthesize cardId = _cardId;

- (instancetype)initWithContext:(VSSRequestContext *)context cardId:(GUID *)cardId identity:(NSDictionary *)identity {
    self = [super initWithContext:context];
    if (self == nil) {
        return nil;
    }
    
    _cardId = cardId;
    [self setRequestMethod:DELETE];
    if (identity.count > 0) {
        [self setRequestBodyWithObject:@{ kVSSModelIdentity: identity }];
    }
    return self;
}

- (instancetype)initWithContext:(VSSRequestContext *)context {
    return [self initWithContext:context cardId:@"" identity:@{}];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [NSString stringWithFormat:@"virgil-card/%@", self.cardId];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    return nil;
}

@end
