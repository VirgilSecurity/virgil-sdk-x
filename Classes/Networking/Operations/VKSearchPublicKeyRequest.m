//
//  VKSearchPublicKeyRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKSearchPublicKeyRequest.h"
#import "VKPublicKey.h"
#import "VKModelCommons.h"
#import <VirgilFrameworkiOS/NSObject+VFUtils.h>
#import <VirgilFrameworkiOS/VFUserData.h>

@interface VKSearchPublicKeyRequest ()

@property (nonatomic, strong, readwrite) VKPublicKey *__nullable publicKey;

@end

@implementation VKSearchPublicKeyRequest

@synthesize publicKey = _publicKey;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url userIdValue:(NSString *)userIdValue {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }
    
    [self setRequestMethod:POST];
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] init];
    if (userIdValue != nil) {
        dto[kVFModelValue] = userIdValue;
    }
    [self setRequestBodyWithObject:dto useUUID:@YES];
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url {
    return [self initWithBaseURL:url userIdValue:nil];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"public-key/actions/grab";
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
