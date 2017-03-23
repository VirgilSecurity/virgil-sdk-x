//
//  VSSTokenRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSTokenRequest.h"
#import "VSSModelKeys.h"

@implementation VSSTokenRequest

- (instancetype)initWithGrantType:(NSString *)grantType authCode:(NSString *)authCode {
    self = [super init];
    if (self) {
        _grantType = [grantType copy];
        _authCode = [authCode copy];
    }
    
    return self;
}

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVSSAModelGrantType] = self.grantType;
    dict[kVSSAModelCode] = self.authCode;
    
    return dict;
}

@end
