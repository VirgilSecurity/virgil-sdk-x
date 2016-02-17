//
//  VSSServiceConfigStg.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/17/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSServiceConfigStg.h"

@implementation VSSServiceConfigStg

- (NSString *)serviceURLForServiceID:(NSString *)serviceID {
    if ([serviceID isEqualToString:kVSSServiceIDKeys]) {
        return @"https://keys-stg.virgilsecurity.com/v3";
    }
    else if ([serviceID isEqualToString:kVSSServiceIDPrivateKeys]) {
        return @"https://keys-private-stg.virgilsecurity.com/v3";
    }
    else if ([serviceID isEqualToString:kVSSServiceIDIdentity]) {
        return @"https://identity-stg.virgilsecurity.com/v1";
    }
    
    return @"";
}

- (NSString *)serviceCardValueForServiceID:(NSString *)serviceID {
    if ([serviceID isEqualToString:kVSSServiceIDKeys]) {
        return @"com.virgilsecurity.keys";
    }
    else if ([serviceID isEqualToString:kVSSServiceIDPrivateKeys]) {
        return @"com.virgilsecurity.private-keys";
    }
    else if ([serviceID isEqualToString:kVSSServiceIDIdentity]) {
        return @"com.virgilsecurity.identity";
    }
    
    return @"";
}

@end
