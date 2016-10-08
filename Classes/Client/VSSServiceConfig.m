//
//  VSSServiceConfig.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/9/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSServiceConfig.h"

NSString *const kVSSServiceIDCards = @"VSSServiceIDCards";

@implementation VSSServiceConfig

+ (VSSServiceConfig *)serviceConfig {
    return [[self alloc] init];
}

- (NSString *)serviceURLForServiceID:(NSString *)serviceID {
    if ([serviceID isEqualToString:kVSSServiceIDCards]) {
        return @"https://cards.virgilsecurity.com/v4";
    }
    
    return @"";
}

@end
