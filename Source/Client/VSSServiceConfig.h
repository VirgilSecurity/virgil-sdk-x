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
@property (nonatomic, copy) NSString * __nonnull token;
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
 VSSCardValidator instance which validates Virgil Card genuineness on every VSSClient query.
 Default value is nil
 */
@property (nonatomic, copy) id<VSSCardValidator> __nullable cardValidator;

/**
 Factory method which allocates and initializes VSSServiceConfig instance with given token and default values (service URLs, no Card Validator).

 @param token NSString containing application token received from https://developer.virgilsecurity.com/dashboard/

 @return Allocated and Initialized VSSServiceConfig instance
 */
+ (VSSServiceConfig * __nonnull)serviceConfigWithToken:(NSString * __nonnull)token;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
