//
//  VSSRevokeCardHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCardHTTPRequest.h"
#import "VSSRevokeCardRequest.h"
#import "VSSSignableRequestPrivate.h"

@interface VSSRevokeCardHTTPRequest ()

@property (nonatomic, copy, readonly) NSString * __nonnull cardId;

@end

@implementation VSSRevokeCardHTTPRequest

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context revokeCardRequest:(VSSRevokeCardRequest *)request {
    self = [super initWithContext:context];
    if (self) {
        _cardId = [request.snapshotModel.cardId copy];
        
        NSDictionary *body = [request serialize];
        
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
