//
//  VSSDeletePublicKeyRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSDeletePublicKeyRequest.h"
#import "VSSActionToken.h"
#import <VirgilKit/NSObject+VSSUtils.h>

@interface VSSDeletePublicKeyRequest ()

@property (nonatomic, strong, readwrite) VSSActionToken * __nullable actionToken;
@property (nonatomic, strong) GUID * __nonnull publicKeyId;

@end

@implementation VSSDeletePublicKeyRequest

@synthesize actionToken = _actionToken;
@synthesize publicKeyId = _publicKeyId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url publicKeyId:(NSString *)publicKeyId {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }

    _publicKeyId = publicKeyId;
    
    [self setRequestMethod:DELETE];
    [self setRequestBodyWithObject:@{} useUUID:@YES];
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url {
    return [self initWithBaseURL:url publicKeyId:@""];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [NSString stringWithFormat:@"public-key/%@", self.publicKeyId];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    // In case of request was unsigned - action token will be returned from service.
    // Otherwise - nothing will be returned.
    self.actionToken = [VSSActionToken deserializeFrom:[candidate as:[NSDictionary class]]];
    if (![[self.actionToken isValid] boolValue]) {
        // If nothing is returned - it is OK, probably request was just signed properly.
        self.actionToken = nil;
    }
    
    return nil;
}

@end
