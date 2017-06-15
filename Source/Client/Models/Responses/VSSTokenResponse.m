//
//  VSSTokenResponse.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSTokenResponsePrivate.h"
#import "VSSModelKeysPrivate.h"
#import "NSObject+VSSUtils.h"

@implementation VSSTokenResponse

#pragma mark - VSSDeserializable

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *accessToken = [candidate[kVSSAModelAccessToken] vss_as:[NSString class]];
    if (accessToken.length == 0)
        return nil;
    
    NSNumber *expiresInNumber = [candidate[kVSSAModelExpiresIn] vss_as:[NSNumber class]];
    if (expiresInNumber == nil)
        return nil;
    
    NSInteger expiresIn = expiresInNumber.integerValue;
    if (expiresIn == 0)
        return nil;
    
    self = [super init];
    
    if (self) {
        _accessToken = [accessToken copy];
        _expiresIn = expiresIn;
    }
    
    return self;
}

@end
