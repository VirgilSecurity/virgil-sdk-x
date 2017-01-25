//
//  VSSRevokeGlobalCardHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/25/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeGlobalCardHTTPRequest.h"
#import "VSSRevokeGlobalCardRequest.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSModelKeys.h"

@interface VSSRevokeGlobalCardHTTPRequest ()

@property (nonatomic, copy, readonly) NSString * __nonnull cardId;

@end

@implementation VSSRevokeGlobalCardHTTPRequest

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context revokeCardRequest:(VSSRevokeCardRequest *)request validationToken:(NSString *)validationToken {
    self = [super initWithContext:context];
    if (self) {
        _cardId = [request.snapshotModel.cardId copy];
        
        NSDictionary *body = [request serialize];
        
        NSMutableDictionary *metaDict = body[kVSSCModelMeta];
        metaDict[kVSSCModelValidation] = @{
                                           kVSSCModelToken: validationToken
                                           };
        
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
