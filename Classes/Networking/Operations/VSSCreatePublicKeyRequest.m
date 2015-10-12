//
//  VSSCreatePublicKeyRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSCreatePublicKeyRequest.h"
#import "VSSPublicKey.h"
#import <VirgilFrameworkiOS/NSObject+VSSUtils.h>
#import <VirgilFrameworkiOS/VSSServiceRequest.h>

@interface VSSCreatePublicKeyRequest ()

@property (nonatomic, strong, readwrite) VSSPublicKey * __nullable publicKey;

@end

@implementation VSSCreatePublicKeyRequest

@synthesize publicKey = _publicKey;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url publicKey:(VSSPublicKey *)key {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }

    [self setRequestMethod:POST];
    NSDictionary *dto = [key serialize];
    [self setRequestBodyWithObject:dto useUUID:@YES];
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url {
    return [self initWithBaseURL:url publicKey:[[VSSPublicKey alloc] init]];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"public-key";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    self.publicKey = [VSSPublicKey deserializeFrom:[candidate as:[NSDictionary class]]];
    if (![[self.publicKey isValid] boolValue]) {
        self.publicKey = nil;
        return [NSError errorWithDomain:kVSSKeysBaseRequestErrorDomain code:kVSSKeysBaseRequestErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Public key deserialization from the service response has been unsuccessful." }];
    }
    
    return nil;
}

@end
