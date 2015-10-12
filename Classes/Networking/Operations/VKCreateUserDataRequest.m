//
//  VKCreateUserDataRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKCreateUserDataRequest.h"
#import "VKUserData.h"
#import "VKModelCommons.h"

#import <VirgilFrameworkiOS/NSObject+VFUtils.h>
#import <VirgilFrameworkiOS/VFUserData.h>

@interface VKCreateUserDataRequest ()

@property (nonatomic, strong, readwrite) VKUserData * __nullable userData;
@property (nonatomic, strong) GUID * __nonnull publicKeyId;

@end

@implementation VKCreateUserDataRequest

@synthesize userData = _userData;
@synthesize publicKeyId = _publicKeyId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url publicKeyId:(GUID *)publicKeyId userData:(VFUserData *)userData {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }
    
    _publicKeyId = publicKeyId;
    
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] init];
    if (_publicKeyId != nil) {
        dto[kVKModelPublicKeyId] = _publicKeyId;
    }
    if (userData != nil) {
        [dto addEntriesFromDictionary:[userData serialize]];
    }
    [self setRequestBodyWithObject:dto useUUID:@YES];
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url {
    return [self initWithBaseURL:url publicKeyId:@"" userData:[[VFUserData alloc] init]];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"user-data";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }

    self.userData = [VKUserData deserializeFrom:[candidate as:[NSDictionary class]]];
    if (![[self.userData isValid] boolValue]) {
        self.userData = nil;
        return [NSError errorWithDomain:kVKBaseRequestErrorDomain code:kVKBaseRequestErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"User data deserialization from the service response has been unsuccessful." }];
    }
    
    return nil;
}

@end
