//
//  VSSCreateEmailCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/24/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCreateCardRequest.h"
#import "VSSCreateCardSnapshotModel.h"

extern NSString * __nonnull const kVSSCardIdentityTypeEmail;

/**
 Virgil Model representing request for Virgil Global Card creation. This Card is issued to email.
 See VSSSignableRequest, VSSCreateCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSCreateEmailCardRequest : VSSCreateCardRequest

/**
 Validation token obtained from Virgil Authority Service.
 */
@property (nonatomic, copy, readonly) NSString * __nonnull validationToken;

/**
 Factory method which allocates and initalizes VSSCreateCardRequest instance.

 @param identity NSString with Identity that represents Virgil Card within same Identity Type
 @param validationToken NSString with validation token obtained from Virgil Authority Service
 @param publicKeyData NSData with Virgil Card public key
 @param data NSDictionary with custom payload
 @return allocated and initialized VSSCreateCardRequest instance
 */
+ (instancetype __nonnull)createEmailCardRequestWithIdentity:(NSString * __nonnull)identity validationToken:(NSString * __nonnull)validationToken publicKeyData:(NSData * __nonnull)publicKeyData data:(NSDictionary<NSString *, NSString *> * __nullable)data;

/**
 Factory method which allocates and initalizes VSSCreateCardRequest instance.

 @param identity NSString with Identity that represents Virgil Card within same Identity Type
 @param validationToken NSString with validation token obtained from Virgil Authority Service
 @param publicKeyData NSData with Virgil Card public key
 @param data NSDictionary with custom payload
 @param device NSString with device type
 @param deviceName NSString with device name
 @return allocated and initialized VSSCreateCardRequest instance
 */
+ (instancetype __nonnull)createEmailCardRequestWithIdentity:(NSString * __nonnull)identity validationToken:(NSString * __nonnull)validationToken publicKeyData:(NSData * __nonnull)publicKeyData data:(NSDictionary<NSString *, NSString *> * __nullable)data device:(NSString * __nonnull)device deviceName:(NSString * __nonnull)deviceName;

/**
 Factory method which allocates and initalizes VSSCreateCardRequest instance.

 @param identity NSString with Identity that represents Virgil Card within same Identity Type
 @param validationToken NSString with validation token obtained from Virgil Authority Service
 @param publicKeyData NSData with Virgil Card public key
 @return allocated and initialized VSSCreateCardRequest instance
 */
+ (instancetype __nonnull)createEmailCardRequestWithIdentity:(NSString * __nonnull)identity validationToken:(NSString * __nonnull)validationToken publicKeyData:(NSData * __nonnull)publicKeyData;

@end
