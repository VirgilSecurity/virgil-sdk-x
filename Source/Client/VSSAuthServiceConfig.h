//
//  VSSAuthServiceConfig.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 5/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

/**
 Class, which stores configuration for VSSClient default implementation.
 */
@interface VSSAuthServiceConfig : NSObject <NSCopying>

/**
 NSString containing application token received from https://developer.virgilsecurity.com/dashboard/
 */
@property (nonatomic, readonly, copy) NSData * __nonnull servicePublicKey;

/**
 Base URL for the Virgil Auth Service
 */
@property (nonatomic, readonly, copy) NSURL * __nonnull serviceURL;

/**
 Initializes VSSAuthServiceConfig instance with Virgil Auth Service URL and public key.

 @param serviceURL Virgil Auth Service URL
 @param servicePublicKey Virgil Auth Service public key
 @return Initialized VSSAuthService instnace
 */
- (instancetype __nonnull)initWithServiceURL:(NSURL * __nonnull)serviceURL servicePublicKey:(NSData * __nonnull)servicePublicKey NS_DESIGNATED_INITIALIZER;

/**
 Initializes VSSAuthServiceConfig instance with default values (default service URLs, default public keys).

 @return Initialized VSSAuthService instnace
 */
- (instancetype __nonnull)init;

@end
