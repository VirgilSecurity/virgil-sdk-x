//
//  VSSHTTPRequestPrivate.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 1/12/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSHTTPRequest.h"

/**
 * Extension for the properties which should not be completely public, but also can not be readonly 
 * due to necessities to change them in descendants.
 */
@interface VSSHTTPRequest ()

/**
 * Underlying HTTP request.
 */
@property (nonatomic) NSURLRequest * __nonnull request;

/**
 * Underlying HTTP service response.
 */
@property (nonatomic) NSHTTPURLResponse * __nullable response;

/**
 * Error object when some error happen or nil.
 */
@property (nonatomic) NSError * __nullable error;

/**
 * Actual response body.
 */
@property (nonatomic) NSData * __nullable responseBody;

@end
