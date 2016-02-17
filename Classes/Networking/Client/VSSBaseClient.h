//
//  VSSClient.h
//  VirgilSDK
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
#  define VSSCLDLog(...) NSLog(__VA_ARGS__)
# else
#  define VSSCLDLog(...) /* nothing to log */
#endif

extern NSString * __nonnull const kVSSClientErrorDomain;

@class VSSRequest;
@class VSSCard;
@class VSSPrivateKey;

@class VSSServiceConfig;

@interface VSSBaseClient : NSObject

@property (nonatomic, strong, readonly) NSString * __nonnull token;
@property (nonatomic, strong, readonly) VSSServiceConfig * __nonnull serviceConfig;

/**
 * Creates instance of VSSClient particular class.
 *
 * @param token NSString containing application token received from https://api.virgilsecurity.com
 */
- (instancetype __nonnull)initWithApplicationToken:(NSString * __nonnull)token serviceConfig:(VSSServiceConfig * __nullable)serviceConfig NS_DESIGNATED_INITIALIZER;
- (instancetype __nonnull)initWithApplicationToken:(NSString * __nonnull)token;

- (void)setupClientWithCompletionHandler:(void(^ __nullable)(NSError * __nullable))completionHandler;

/**
 * Adds given request to the execution queue and sends it to service.
 */
- (void)send:(VSSRequest * __nonnull)request;

@end
