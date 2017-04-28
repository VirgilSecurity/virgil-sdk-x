//
//  VSSVerifyIdentityResponse.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVerifyIdentityResponse.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSVerifyIdentityResponse

- (instancetype)initWithActionId:(NSString *)actionId {
    self = [super init];
    
    if (self) {
        _actionId = [actionId copy];
    }
    
    return self;
}

#pragma mark - VSSDeserializable

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *actionId = [candidate[kVSSIModelActionId] vss_as:[NSString class]];
    if (actionId.length == 0)
        return nil;
    
    return [self initWithActionId:actionId];
}

@end
