//
//  VSSServiceConfig.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/9/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCardValidatorProtocol.h"

/**
 Class, which stores configuration for VSSClient default implementation.
 */
@interface VSSServiceConfig : NSObject <NSCopying>

/**
 NSString containing application token received from https://developer.virgilsecurity.com/dashboard/
 */
@property (nonatomic, copy) NSString * __nullable token;
/**
 Base URL for the Virgil Cards Service (for Read/Write queries).
 */
@property (nonatomic, copy) NSURL * __nonnull cardsServiceURL;

/**
 Base URL for the Virgil Cards Service (for Read queries only)
 */
@property (nonatomic, copy) NSURL * __nonnull cardsServiceROURL;

/**
 Base URL for the Virgil Identity Service
 */
@property (nonatomic, copy) NSURL * __nonnull identityServiceURL;

/**
 Base URL for the Virgil Registration Authority Service
 */
@property (nonatomic, copy) NSURL * __nonnull registrationAuthorityURL;

/**
 VSSCardValidator instance which validates Virgil Card genuineness on every VSSClient query.
 Default value is nil
 */
@property (nonatomic, copy) id<VSSCardValidator> __nullable cardValidator;

/**
 Factory method which allocates and initializes VSSServiceConfig instance with given token and default values (service URLs, no Card Validator).

 @param token NSString containing application token received from https://developer.virgilsecurity.com/dashboard/

 @return Allocated and Initialized VSSServiceConfig instance
 */
+ (VSSServiceConfig * __nonnull)serviceConfigWithToken:(NSString * __nullable)token;

/**
 Factory method which allocates and initializes VSSServiceConfig instance with default values (default service URLs, no token, no Card Validator).
 
 @return Allocated and Initialized VSSServiceConfig instance
 */
+ (VSSServiceConfig * __nonnull)defaultServiceConfig;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
