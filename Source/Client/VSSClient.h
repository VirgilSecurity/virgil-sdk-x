//
//  VKKeysClient.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModelCommons.h"
#import "VSSClientProtocol.h"

#ifdef DEBUG
#define USE_SERVICE_CLIENT_DEBUG 1
#endif

/// Debugging macro
#if USE_SERVICE_CLIENT_DEBUG
#  define VSSCLDLog(...) NSLog(__VA_ARGS__)
# else
#  define VSSCLDLog(...) /* nothing to log */
#endif

#import "VSSServiceConfig.h"

/**
  NSString with Error Domain used for VSSClient-related errors (Card Validation for example)
  */
extern NSString * __nonnull const kVSSClientErrorDomain;

/**
 Default implementation of VSSClient protocol used for all interactions with Virgil Services.
 */
@interface VSSClient : NSObject <VSSClient>

/**
 VSSServiceConfig instance, which contains the information needed to interract with Virgil Services such as service URLs, token, CardValidator.
 */
@property (nonatomic, copy, readonly) VSSServiceConfig * __nonnull serviceConfig;

/**
 Designated constructor.

 @param serviceConfig VSSServiceConfig instance containing the service configuration.

 @return initialized VSSClient instance
 */
- (instancetype __nonnull)initWithServiceConfig:(VSSServiceConfig * __nonnull)serviceConfig NS_DESIGNATED_INITIALIZER;

/**
 Convenient constructor.
 This constructor initialized VSSClient instance with given token and default VSSServiceConfig value (default service urls, no Card Validator).

 @param token NSString containing application token received from https://developer.virgilsecurity.com/dashboard/

 @return initialized VSSClient instance
 */
- (instancetype __nonnull)initWithApplicationToken:(NSString * __nonnull)token;

/**
 Unavailable no-argument initializer inherited from NSObject.
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
