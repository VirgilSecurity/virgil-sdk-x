//
//  VSSError.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSModelCommons.h"
#import "VSSDeserializable.h"

/**
 * Wrapper object for managing errors returned by the Virgil Services.
 */
@interface VSSError : VSSBaseModel <VSSDeserializable>

- (instancetype __nonnull)initWithCode:(NSInteger)code NS_DESIGNATED_INITIALIZER;

- (instancetype __nonnull)init NS_UNAVAILABLE;

/**
 * Error code returned by the Virgil Service.
 */
@property (nonatomic, readonly) NSInteger code;

///------------------------------------------
/// @name Utility
///------------------------------------------

/**
 * Convenient method for getting the actual error message based on the current error code.
 *
 * @return String meaning of the error code.
 */
- (NSString * __nullable)message;

/**
 * Convenient method for getting the NSError object from the VSSError.
 *
 * @return NSError representation of the current error.
 */
- (NSError * __nullable)nsError;

@end
