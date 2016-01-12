//
//  VSSSearchPublicKeyRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSSearchPublicKeyRequest.h"
#import "VSSPublicKey.h"
#import "VSSKeysModelCommons.h"
#import <VirgilKit/NSObject+VSSUtils.h>
#import <VirgilKit/VSSUserData.h>

@interface VSSSearchPublicKeyRequest ()

@property (nonatomic, strong, readwrite) VSSPublicKey *__nullable publicKey;

@end

@implementation VSSSearchPublicKeyRequest

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
        dto[kVSSModelValue] = userIdValue;
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
    
    self.publicKey = [VSSPublicKey deserializeFrom:[candidate as:[NSDictionary class]]];
    if (![[self.publicKey isValid] boolValue]) {
        self.publicKey = nil;
        return [NSError errorWithDomain:kVSSKeysBaseRequestErrorDomain code:kVSSKeysBaseRequestErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Public key deserialization from the service response has been unsuccessful." }];
    }
    return nil;
}

@end
