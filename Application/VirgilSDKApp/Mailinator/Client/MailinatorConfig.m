//
//  MailinatorConfig.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/17/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "MailinatorConfig.h"

NSString *const kMailinatorID = @"MailinatorService";

@implementation MailinatorConfig

#pragma mark - Overrides

- (NSArray <NSString *>*)serviceIDList {
    return @[ kMailinatorID ];
}

- (NSString *)serviceURLForServiceID:(NSString *)serviceID {
    if ([serviceID isEqualToString:kMailinatorID]) {
        return @"https://api.mailinator.com/api";
    }
    return @"";
}

- (NSString *)serviceCardValueForServiceID:(NSString *)serviceID {
    if ([serviceID isEqualToString:kMailinatorID]) {
        return @"com.mailinator";
    }
    return @"";
}

@end
