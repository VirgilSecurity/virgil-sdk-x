//
//  VKDeleteUserDataRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKDeleteUserDataRequest.h"

@interface VKDeleteUserDataRequest ()

@property (nonatomic, strong) GUID * __nonnull userDataId;

@end

@implementation VKDeleteUserDataRequest

@synthesize userDataId = _userDataId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url userDataId:(NSString *)userDataId {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }
    
    _userDataId = userDataId;
    
    [self setRequestMethod:DELETE];
    [self setRequestBodyWithObject:@{} useUUID:@YES];
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url {
    return [self initWithBaseURL:url userDataId:@""];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [NSString stringWithFormat:@"user-data/%@", self.userDataId];
}

@end
