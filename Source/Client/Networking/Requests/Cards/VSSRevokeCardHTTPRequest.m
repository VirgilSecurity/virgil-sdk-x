//
//  VSSRevokeCardHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCardHTTPRequest.h"
#import "VSSRevokeCard.h"
#import "VSSRevokeCardPrivate.h"
#import "VSSSignedDataPrivate.h"

@interface VSSRevokeCardHTTPRequest ()

@property (nonatomic, copy, readonly) NSString * __nonnull cardId;

@end

@implementation VSSRevokeCardHTTPRequest

- (instancetype __nonnull)initWithContext:(VSSHTTPRequestContext *)context revokeCard:(VSSRevokeCard *)revokeCard {
    self = [super initWithContext:context];
    if (self) {
        _cardId = [revokeCard.data.cardId copy];
        
        NSDictionary *body = [revokeCard serialize];
        
        [self setRequestMethod:DELETE];
        
        [self setRequestBodyWithObject:body];
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
    
    return nil;
}


@end
