//
//  VSSHTTPRequestContext.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Request context contains all the utility information about the request.
 *
 * Actual requests use the context objects to get the service URL and unique identifier, if it is necessary.
 */
@interface VSSHTTPRequestContext : NSObject

/**
 * Contains base (service) url which will be used by the request.
 */
@property (nonatomic, readonly) NSURL * __nonnull serviceUrl;

///------------------------------------------
/// @name Lifecycle
///------------------------------------------

/**
 * Designated constructor.
 *
 * @param serviceUrl Base (service) url which will be used by the request.
 *
 * @return Instance of the Request context wrapper object.
 */
- (instancetype __nonnull)initWithServiceUrl:(NSURL * __nonnull)serviceUrl NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
