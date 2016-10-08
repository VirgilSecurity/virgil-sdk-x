//
//  VSSServiceConfig.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/9/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The string identifier for the Virgil Keys Service.
 */
extern NSString * __nonnull const kVSSServiceIDCards;

/**
 * Helper class for services configuration.
 */
@interface VSSServiceConfig : NSObject

/**
 * Convenient constructor.
 */
+ (VSSServiceConfig * __nonnull)serviceConfig;

/**
 * Returns the base URL for each service by the service ID.
 *
 * @param serviceID Identifier of the service.
 *
 * @return String with base URL for the given service.
 */
- (NSString * __nonnull)serviceURLForServiceID:(NSString * __nonnull)serviceID;

@end
