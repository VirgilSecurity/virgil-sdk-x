//
//  VSSKeysBaseRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSKeysBaseRequest.h"
#import "VSSKeysError.h"

#import <VirgilKit/NSObject+VSSUtils.h>

NSString *const kVSSKeysBaseRequestErrorDomain = @"BaseRequestErrorDomain";
const NSInteger kVSSKeysBaseRequestErrorCode = 100;

@implementation VSSKeysBaseRequest

#pragma mark - Overrides

- (NSError *)handleError:(NSObject *)candidate {
    NSError *error = [super handleError:candidate];
    if (error != nil) {
        return error;
    }
    
    VSSKeysError *vkError = [VSSKeysError deserializeFrom:[candidate as:[NSDictionary class]]];
    return vkError.nsError;
}

@end
