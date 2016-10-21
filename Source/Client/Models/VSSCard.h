//
//  VSSCard.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSignedData.h"
#import "VSSCardData.h"

/**
 Virgil Model representing Virgil Card.
 See VSSCardData. See VSSClient protocol.
 */
@interface VSSCard : VSSSignedData

/**
 VSSCardData instance with info of the Virgil Card (identity, identity type, public key, etc.).
 */
@property (nonatomic, copy, readonly) VSSCardData * __nonnull data;

/**
 Factory method which allocates and initalizes VSSCard instance.

 @param identity     NSString with Identity that represents Virgil Card within same Identity Type
 @param identityType NSString with Identity Type (such as Email, Username, Phone number, etc.)
 @param publicKey    NSData with Virgil Card public key
 @param data         NSDictionary with custom payload

 @return allocated and initialized VSSCard instnace
 */
+ (instancetype __nonnull)cardWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey data:(NSDictionary<NSString *, NSData *> * __nullable)data;

/**
 Factory method which allocates and initalizes VSSCard instance.

 @param identity     NSString with Identity that represents Virgil Card within same Identity Type
 @param identityType NSString with Identity Type (such as Email, Username, Phone number, etc.)
 @param publicKey    NSData with Virgil Card public key

 @return allocated and initialized VSSCard instnace
 */
+ (instancetype __nonnull)cardWithIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType publicKey:(NSData * __nonnull)publicKey;

//+ (instancetype __nullable)cardGlobalWithIdentity:(NSString * __nonnull)identity publicKey:(NSData * __nonnull)publicKey;
//+ (instancetype __nullable)cardGlobalWithIdentity:(NSString * __nonnull)identity publicKey:(NSData * __nonnull)publicKey data:(NSDictionary * __nullable)data;

/**
 Unavailable initializer inherited from VSSSignedData.
 */
- (instancetype __nonnull)initWithSignatures:(NSDictionary<NSString *, NSData *> * __nullable)signatures cardVersion:(NSString * __nullable)cardVersion createdAt:(NSDate * __nullable)createdAt NS_UNAVAILABLE;

@end
