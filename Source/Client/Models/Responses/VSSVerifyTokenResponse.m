//
//  VSSVerifyTokenResponse.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVerifyTokenResponse.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSVerifyTokenResponse

#pragma mark - VSSDeserializable

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *resourceOwnerVirgilCardId = [candidate[kVSSAModelResourceOwnerCardId] as:[NSString class]];
    if (resourceOwnerVirgilCardId.length == 0)
        return nil;
    
    self = [super init];
    
    if (self) {
        _resourceOwnerVirgilCardId = [resourceOwnerVirgilCardId copy];
    }
    
    return self;
}

@end
