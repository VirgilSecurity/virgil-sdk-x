//
//  VSSVerifyTokenRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVerifyTokenRequest.h"
#import "VSSModelKeys.h"

@implementation VSSVerifyTokenRequest

- (instancetype)initWithAccessToken:(NSString *)accessToken {
    self = [super init];
    if (self) {
        _accessToken = [accessToken copy];
    }
    
    return self;
}

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVSSAModelAccessToken] = self.accessToken;
    
    return dict;
}

@end
