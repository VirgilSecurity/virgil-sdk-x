//
//  VKResetPublicKeyRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKResetPublicKeyRequest.h"
#import "VKBaseModel.h"
#import "VKActionToken.h"
#import "VKModelCommons.h"
#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

@interface VKResetPublicKeyRequest ()

@property (nonatomic, strong, readwrite) VKActionToken * __nullable actionToken;
@property (nonatomic, strong) GUID * __nonnull publicKeyId;

@end

@implementation VKResetPublicKeyRequest

@synthesize actionToken = _actionToken;
@synthesize publicKeyId = _publicKeyId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url publicKeyId:(NSString *)publicKeyId publicKey:(NSData *)publicKey {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }
    
    _publicKeyId = publicKeyId;
    
    [self setRequestMethod:POST];
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] init];
    if (publicKey != nil) {
        NSString *encodedPk = [publicKey base64EncodedStringWithOptions:0];
        if (encodedPk != nil) {
            dto[kVKModelPublicKey] = encodedPk;
        }
    }
    [self setRequestBodyWithObject:dto useUUID:@YES];
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url {
    return [self initWithBaseURL:url publicKeyId:@"" publicKey:[NSData data]];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [NSString stringWithFormat:@"public-key/%@/actions/reset", self.publicKeyId];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    // Action token always will be returned when Reset Public Key is called.
    self.actionToken = [VKActionToken deserializeFrom:[candidate as:[NSDictionary class]]];
    if (![[self.actionToken isValid] boolValue]) {
        self.actionToken = nil;
        return [NSError errorWithDomain:kVKBaseRequestErrorDomain code:kVKBaseRequestErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Action token deserialization from the service response has been unsuccessful." }];
    }
    
    return nil;
}

@end
