//
//  VSSRemoveCardRelationHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/21/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSRemoveCardRelationHTTPRequest.h"
#import "VSSRemoveCardRelationRequest.h"
#import "VSSSignableRequestPrivate.h"

@interface VSSRemoveCardRelationHTTPRequest ()

@property (nonatomic, copy, readonly) NSString * __nonnull cardId;

@end

@implementation VSSRemoveCardRelationHTTPRequest

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context cardId:(NSString *)cardId removeCardRelationRequest:(VSSRemoveCardRelationRequest *)request {
    self = [super initWithContext:context];
    if (self) {
        _cardId = [cardId copy];
        
        NSDictionary *body = [request serialize];
        
        [self setRequestMethod:DELETE];
        
        [self setRequestBodyWithObject:body];
    }
    
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [[NSString alloc] initWithFormat:@"card/%@/collections/relations", self.cardId];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    return nil;
}

@end
