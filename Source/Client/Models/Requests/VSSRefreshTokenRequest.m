//
//  VSSRefreshTokenRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSRefreshTokenRequest.h"
#import "VSSModelKeysPrivate.h"

@implementation VSSRefreshTokenRequest

- (instancetype)initWithGrantType:(NSString *)grantType refreshToken:(NSString *)refreshToken {
    self = [super init];
    if (self) {
        _grantType = [grantType copy];
        _refreshToken = [refreshToken copy];
    }
    
    return self;
}

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVSSAModelGrantType] = self.grantType;
    dict[kVSSAModelRefreshToken] = self.refreshToken;
    
    return dict;
}

@end
