//
//  VKCreatePublicKeyRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKCreatePublicKeyRequest.h"
#import "VKPublicKey.h"
#import "NSObject+VFUtils.h"

#import "VFServiceRequest.h"

@interface VKCreatePublicKeyRequest ()

@property (nonatomic, strong, readwrite) VKPublicKey *publicKey;

@end

@implementation VKCreatePublicKeyRequest

@synthesize publicKey = _publicKey;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url publicKey:(VKPublicKey *)key {
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
    return [self initWithBaseURL:url publicKey:nil];
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
    
    self.publicKey = [VKPublicKey deserializeFrom:[candidate as:[NSDictionary class]]];
    if (![[self.publicKey isValid] boolValue]) {
        self.publicKey = nil;
        return [NSError errorWithDomain:kVKBaseRequestErrorDomain code:kVKBaseRequestErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Public key deserialization from the service response has been unsuccessful." }];
    }
    
    return nil;
}

@end
