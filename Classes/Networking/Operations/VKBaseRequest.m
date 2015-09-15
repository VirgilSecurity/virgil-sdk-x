//
//  VKBaseRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"
#import "VKError.h"

#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

NSString *const kVKBaseRequestErrorDomain = @"BaseRequestErrorDomain";
const NSInteger kVKBaseRequestErrorCode = 100;

@implementation VKBaseRequest

#pragma mark - Overrides

- (NSError *)handleError:(NSObject *)candidate {
    NSError *error = [super handleError:candidate];
    if (error != nil) {
        return error;
    }
    
    VKError *vkError = [VKError deserializeFrom:[candidate as:[NSDictionary class]]];
    return vkError.nsError;
}

@end
