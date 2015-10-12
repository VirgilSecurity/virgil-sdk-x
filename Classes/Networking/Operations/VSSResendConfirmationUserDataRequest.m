//
//  VSSResendConfirmationUserDataRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSResendConfirmationUserDataRequest.h"

@interface VSSResendConfirmationUserDataRequest ()

@property (nonatomic, strong) GUID * __nonnull userDataId;

@end

@implementation VSSResendConfirmationUserDataRequest

@synthesize userDataId = _userDataId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url userDataId:(GUID *)userDataId {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }
    
    _userDataId = userDataId;
    
    [self setRequestMethod:POST];
    [self setRequestBodyWithObject:@{} useUUID:@YES];
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url {
    return [self initWithBaseURL:url userDataId:@""];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [NSString stringWithFormat:@"user-data/%@/actions/resend-confirmation", self.userDataId];
}

@end
