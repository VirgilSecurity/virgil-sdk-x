//
//  VSSCreateCardRelationHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCreateCardRelationHTTPRequest.h"
#import "VSSModelCommons.h"
#import "VSSCreateCardSnapshotModelPrivate.h"
#import "VSSCreateCardRequest.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSCardResponsePrivate.h"
#import "NSObject+VSSUtils.h"

@interface VSSCreateCardRelationHTTPRequest ()

@property (nonatomic, copy, readonly) NSString * __nonnull cardId;

@end

@implementation VSSCreateCardRelationHTTPRequest

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context cardId:(NSString *)cardId signedCardRequest:(VSSSignedCardRequest *)request {
    self = [super initWithContext:context];
    if (self) {
        _cardId = [cardId copy];
        
        NSDictionary *body = [request serialize];
        
        [self setRequestBodyWithObject:body];
    }
    
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [[NSString alloc] initWithFormat:@"card/%@/collections/relations", self.cardId];
}

@end
