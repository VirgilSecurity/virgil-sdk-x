//
//  VKCreateUserDataRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKCreateUserDataRequest.h"
#import "VKUserData.h"
#import "NSObject+VFUtils.h"

@interface VKCreateUserDataRequest ()

@property (nonatomic, strong, readwrite) VKUserData *userData;
@property (nonatomic, strong) GUID *publicKeyId;

@end

@implementation VKCreateUserDataRequest

@synthesize userData = _userData;
@synthesize publicKeyId = _publicKeyId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url publicKeyId:(GUID *)publicKeyId userData:(VKUserData *)userData {
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
    return [self initWithBaseURL:url publicKeyId:nil userData:nil];
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
