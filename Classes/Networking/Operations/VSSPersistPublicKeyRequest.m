//
//  VSSPersistPublicKeyRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSPersistPublicKeyRequest.h"
#import "VSSPublicKey.h"
#import "VSSActionToken.h"
#import <VirgilFrameworkiOS/NSObject+VSSUtils.h>

@interface VSSPersistPublicKeyRequest ()

@property (nonatomic, strong, readwrite) VSSPublicKey * __nullable publicKey;
@property (nonatomic, strong) GUID * __nonnull publicKeyId;

@end

@implementation VSSPersistPublicKeyRequest

@synthesize publicKey = _publicKey;
@synthesize publicKeyId = _publicKeyId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url publicKeyId:(NSString *)publicKeyId actionToken:(VSSActionToken *)actionToken {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }
    
    _publicKeyId = publicKeyId;
    
    [self setRequestMethod:POST];
    if (actionToken != nil) {
        [self setRequestBodyWithObject:[actionToken serialize] useUUID:@NO];
    }
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url {
    return [self initWithBaseURL:url publicKeyId:@"" actionToken:[[VSSActionToken alloc] init]];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [NSString stringWithFormat:@"public-key/%@/persist", self.publicKeyId];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    // In case of previous delete action, there will no be any data in response, except just empty JSON object.
    self.publicKey = [VSSPublicKey deserializeFrom:[candidate as:[NSDictionary class]]];
    if (![[self.publicKey isValid] boolValue]) {
        self.publicKey = nil;
    }
    return nil;
}

@end
