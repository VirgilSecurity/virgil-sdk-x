//
//  VSSCreateCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequest.h"
#import "VSSCreateCardSnapshotModel.h"

/**
 Virgil Model representing request for Virgil Card creation.
 See VSSSignableRequest, VSSCreateCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSCreateCardRequest: VSSSignableRequest<VSSCreateCardSnapshotModel *>

/**
 Factory method which allocates and initalizes VSSCreateCardRequest instance.

 @param identity     NSString with Identity that represents Virgil Card within same Identity Type
 @param identityType NSString with Identity Type (such as Email, Username, Phone number, etc.)
 @param publicKey    NSData with Virgil Card public key
 @param data         NSDictionary with custom payload

 @return allocated and initialized VSSCreateCardRequest instnace
 */
+ (instancetype __nonnull)createCardRequestWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey data:(NSDictionary<NSString *, NSString *> * __nullable)data;

/**
 Factory method which allocates and initalizes VSSCreateCardRequest instance.

 @param identity     NSString with Identity that represents Virgil Card within same Identity Type
 @param identityType NSString with Identity Type (such as Email, Username, Phone number, etc.)
 @param publicKey    NSData with Virgil Card public key

 @return allocated and initialized VSSCreateCardRequest instnace
 */
+ (instancetype __nonnull)createCardRequestWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey;

@end
