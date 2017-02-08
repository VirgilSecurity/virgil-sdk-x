//
//  VSSCreateGlobalCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/24/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequest.h"
#import "VSSCreateCardSnapshotModel.h"

/**
 Virgil Model representing request for Virgil Global Card creation.
 See VSSSignableRequest, VSSCreateCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSCreateGlobalCardRequest : VSSSignableRequest<VSSCreateCardSnapshotModel *>

/**
 Validation token obtained from Virgil Authority Service.
 */
@property (nonatomic, copy, readonly) NSString * __nonnull validationToken;

/**
 Factory method which allocates and initalizes VSSCreateCardRequest instance.

 @param identity NSString with Identity that represents Virgil Card within same Identity Type
 @param identityType NSString with Identity Type (such as Email, Username, Phone number, etc.)
 @param validationToken NSString with validation token obtained from Virgil Authority Service
 @param publicKeyData NSData with Virgil Card public key
 @param data NSDictionary with custom payload
 @return allocated and initialized VSSCreateCardRequest instnace
 */
+ (instancetype __nonnull)createGlobalCardRequestWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType validationToken:(NSString * __nonnull)validationToken publicKeyData:(NSData * __nonnull)publicKeyData data:(NSDictionary<NSString *, NSString *> * __nullable)data;

/**
 Factory method which allocates and initalizes VSSCreateCardRequest instance.

 @param identity NSString with Identity that represents Virgil Card within same Identity Type
 @param identityType NSString with Identity Type (such as Email, Username, Phone number, etc.)
 @param validationToken NSString with validation token obtained from Virgil Authority Service
 @param publicKeyData NSData with Virgil Card public key
 @param data NSDictionary with custom payload
 @param device NSString with device type
 @param deviceName NSString with device name
 @return allocated and initialized VSSCreateCardRequest instnace
 */
+ (instancetype __nonnull)createGlobalCardRequestWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType validationToken:(NSString * __nonnull)validationToken publicKeyData:(NSData * __nonnull)publicKeyData data:(NSDictionary<NSString *, NSString *> * __nullable)data device:(NSString * __nonnull)device deviceName:(NSString * __nonnull)deviceName;

/**
 Factory method which allocates and initalizes VSSCreateCardRequest instance.

 @param identity NSString with Identity that represents Virgil Card within same Identity Type
 @param identityType NSString with Identity Type (such as Email, Username, Phone number, etc.)
 @param validationToken NSString with validation token obtained from Virgil Authority Service
 @param publicKeyData NSData with Virgil Card public key
 @return allocated and initialized VSSCreateCardRequest instnace
 */
+ (instancetype __nonnull)createGlobalCardRequestWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType validationToken:(NSString * __nonnull)validationToken publicKeyData:(NSData * __nonnull)publicKeyData;

@end
