//
//  VKPersistUserDataRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/14/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKPersistUserDataRequest.h"
#import "VKBaseModel.h"

@interface VKPersistUserDataRequest ()

@property (nonatomic, strong) GUID *userDataId;

@end

@implementation VKPersistUserDataRequest

@synthesize userDataId = _userDataId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url userDataId:(GUID *)userDataId confirmationCode:(NSString *)code {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }
    
    _userDataId = userDataId;
    
    [self setRequestMethod:POST];
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] init];
    if (code != nil) {
        dto[kVKModelConfirmationCode] = code;
    }
    
    if (dto.allKeys.count > 0) {
        [self setRequestBodyWithObject:dto useUUID:@NO];
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url {
    return [self initWithBaseURL:url userDataId:nil confirmationCode:nil];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [NSString stringWithFormat:@"user-data/%@/persist", self.userDataId];
}

@end
