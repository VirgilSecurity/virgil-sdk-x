//
//  VSSGetPublicKeyRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSGetPublicKeyRequest.h"
#import "VSSPublicKey.h"
#import <VirgilFrameworkiOS/NSObject+VSSUtils.h>

@interface VSSGetPublicKeyRequest ()

@property (nonatomic, strong, readwrite) VSSPublicKey * __nullable publicKey;
@property (nonatomic, strong) GUID * __nonnull publicKeyId;

@end

@implementation VSSGetPublicKeyRequest

@synthesize publicKey = _publicKey;
@synthesize publicKeyId = _publicKeyId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url publicKeyId:(GUID *)pkId {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }
    
    _publicKeyId = pkId;
    
    [self setRequestMethod:GET];
    
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
    
    self.publicKey = [VSSPublicKey deserializeFrom:[candidate as:[NSDictionary class]]];
    if (![[self.publicKey isValid] boolValue]) {
        self.publicKey = nil;
        return [NSError errorWithDomain:kVKBaseRequestErrorDomain code:kVKBaseRequestErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Public key deserialization from the service response has been unsuccessful." }];
    }
    return nil;
}

@end
