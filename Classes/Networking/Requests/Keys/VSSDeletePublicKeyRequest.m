//
//  VSSDeletePublicKeyRequest.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSDeletePublicKeyRequest.h"
#import "NSObject+VSSUtils.h"
#import "VSSModelCommons.h"
#import "VSSIdentityInfo.h"

@interface VSSDeletePublicKeyRequest ()

@property (nonatomic, strong) GUID * __nonnull publicKeyId;

@end

@implementation VSSDeletePublicKeyRequest

@synthesize publicKeyId = _publicKeyId;

#pragma mark - Lifecycle

- (instancetype)initWithContext:(VSSRequestContext *)context publicKeyId:(GUID *)publicKeyId identities:(NSArray <NSDictionary*>*)identities {
    self = [super initWithContext:context];
    if (self == nil) {
        return nil;
    }

    _publicKeyId = publicKeyId;
    
    [self setRequestMethod:DELETE];
    if (identities.count > 0) {
        NSDictionary *idtts = @{ kVSSModelIdentities: identities };
        [self setRequestBodyWithObject:idtts];
    }
    return self;
}

- (instancetype)initWithContext:(VSSRequestContext *)context publicKeyId:(GUID *)publicKeyId identityInfoList:(NSArray <VSSIdentityInfo*>*)identityInfoList {
    NSMutableArray *identities = [NSMutableArray array];
    for (VSSIdentityInfo *identity in identityInfoList) {
        [identities addObject:[identity asDictionary]];
    }
    if (identities.count == 0) {
        identities = nil;
    }
    
    return [self initWithContext:context publicKeyId:publicKeyId identities:identities];
}

- (instancetype)initWithContext:(VSSRequestContext *)context {
    return [self initWithContext:context publicKeyId:@"" identities:@[]];
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
    
    return nil;
}

@end
