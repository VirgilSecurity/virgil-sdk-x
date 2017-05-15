//
//  VSSObtainTokenResponse.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSObtainTokenResponse.h"
#import "VSSTokenResponsePrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSObtainTokenResponse

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *refreshToken = [candidate[kVSSAModelRefreshToken] vss_as:[NSString class]];
    if (refreshToken.length == 0)
        return nil;
    
    NSString *tokenType = [candidate[kVSSAModelTokenType] vss_as:[NSString class]];
    if (tokenType.length == 0)
        return nil;
    
    self = [super initWithDict:candidate];
    
    if (self) {
        _refreshToken = [refreshToken copy];
        _tokenType = [tokenType copy];
    }
    
    return self;
}

@end
