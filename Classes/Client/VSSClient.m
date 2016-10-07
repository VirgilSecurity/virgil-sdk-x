//
//  VSSClient.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSClient.h"
#import "NSObject+VSSUtils.h"

#import "VSSSearchCards.h"
#import "VSSServiceConfig.h"
#import "VSSBaseClientPrivate.h"

#import "VSSCreateCardRequest.h"
#import "VSSSearchCardsRequest.h"
#import "VSSGetCardRequest.h"
#import "VSSRevokeCardRequest.h"

@implementation VSSClient

#pragma mark - Implementation of VSSClient protocol

- (void)createCard:(VSSCard *)card completion:(void (^)(VSSCard *, NSError *))callback {
    VSSRequestContext *context = [[VSSRequestContext alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDCards]];
    VSSCreateCardRequest *request = [[VSSCreateCardRequest alloc] initWithContext:context card:card];
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSCreateCardRequest *r = [request as:[VSSCreateCardRequest class]];
            callback(r.card, nil);
        }
        return;
    };
    
    request.completionHandler = handler;
    
    [self send:request];
}

- (void)getCardWithId:(NSString *)cardId completion:(void (^)(VSSCard *, NSError *))callback {
    VSSRequestContext *context = [[VSSRequestContext alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDCards]];
    VSSGetCardRequest *request = [[VSSGetCardRequest alloc] initWithContext:context cardId:cardId];
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSGetCardRequest *r = [request as:[VSSGetCardRequest class]];
            callback(r.card, nil);
        }
        return;
    };
    
    request.completionHandler = handler;
    
    [self send:request];
}

- (void)searchCards:(VSSSearchCards *)searchCards completion:(void (^)(NSArray<VSSCard *> *, NSError *))callback {
    VSSRequestContext *context = [[VSSRequestContext alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDCards]];
    VSSSearchCardsRequest *request = [[VSSSearchCardsRequest alloc] initWithContext:context searchCards:searchCards];
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(nil, request.error);
            }
            return;
        }
        
        if (callback != nil) {
            VSSSearchCardsRequest *r = [request as:[VSSSearchCardsRequest class]];
            callback(r.cards, nil);
        }
        return;
    };
    
    request.completionHandler = handler;
    
    [self send:request];
}

- (void)revokeCard:(VSSRevokeCard *)revokeCard completion:(void (^)(NSError *))callback {
    VSSRequestContext *context = [[VSSRequestContext alloc] initWithServiceUrl:[self.serviceConfig serviceURLForServiceID:kVSSServiceIDCards]];
    VSSRevokeCardRequest *request = [[VSSRevokeCardRequest alloc] initWithContext:context revokeCard:revokeCard];
    
    VSSRequestCompletionHandler handler = ^(VSSRequest *request) {
        if (request.error != nil) {
            if (callback != nil) {
                callback(request.error);
            }
            return;
        }
        
        if (callback != nil) {
            callback(nil);
        }
        return;
    };
    
    request.completionHandler = handler;
    
    [self send:request];
}

- (void)send:(VSSRequest *)request {
    /// Before sending any request set proper token value into corresponding header field:
    if (self.token.length > 0) {
        [request setRequestHeaders:@{ kVSSAccessTokenHeader: [NSString stringWithFormat:@"VIRGIL %@", self.token]}];
    }
    
    [super send:request];
}

@end
