//
//  VFClient.h
//  VirgilFramework
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define USE_SERVICE_CLIENT_DEBUG 1
#endif

/// Debugging macro
#if USE_SERVICE_CLIENT_DEBUG
#  define VFCLDLog(...) NSLog(__VA_ARGS__)
# else
#  define VFCLDLog(...) /* nothing to log */
#endif

@class VFServiceRequest;

@interface VFClient : NSObject

@property (nonatomic, strong, readonly) NSString *token;

/**
 * Creates instance of VFClient particular class.
 *
 * @param token NSString containing application token received from https://api.virgilsecurity.com
 */
- (instancetype)initWithApplicationToken:(NSString *)token NS_DESIGNATED_INITIALIZER;

/**
 * Getter for Virgil Service URL in form of NSString.
 */
- (NSString *)serviceURL;

/**
 * Adds given request to the execution queue and sends it to service.
 */
- (void)send:(VFServiceRequest *)request;

@end
