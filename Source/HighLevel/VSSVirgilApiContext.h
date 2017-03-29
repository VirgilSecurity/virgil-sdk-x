//
//  VSSVirgilApiContext.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCredentialsProtocol.h"
#import "VSSClient.h"
#import "VSSCryptoProtocol.h"
#import "VSSDeviceManagerProtocol.h"
#import "VSSKeyStorageProtocol.h"
#import "VSSRequestSignerProtocol.h"
#import "VSSCardVerifierInfo.h"

/**
 Class which aggregates all dependencies for working with VSSVirgilApi.
 */
@interface VSSVirgilApiContext : NSObject

/**
 VSSCrypto protocol implementation.
 Used for crypto operations.
 Default implementation is in VSSCrypto class.
 */
@property (nonatomic, readonly) id<VSSCrypto> __nonnull crypto;

/**
 VSSCredentials protocol implementation.
 Used to identify application on Virgil Services.
 Default implementation is in VSSCredentials class.
 */
@property (nonatomic) id<VSSCredentials> __nullable credentials;

/**
 VSSClient.
 Used for interactions with Virgil Services.
 */
@property (nonatomic) VSSClient * __nonnull client;

/**
 VSSDeviceManager protocol implementation.
 Used for adding info about device to created Virgil Cards.
 Default implementation is in VSSDeviceManager class.
 */
@property (nonatomic) id<VSSDeviceManager> __nonnull deviceManager;

/**
 VSSKeyStorage implementation.
 Used for storing keys.
 Default implementation is in VSSKeyStorage class.
 */
@property (nonatomic) id<VSSKeyStorage> __nonnull keyStorage;

/**
 VSSRequestSigner implementation.
 Used for signing Create/Revoke requests for Virgil Cards.
 Default implementation is in VSSRequestSigner class.
 */
@property (nonatomic) id<VSSRequestSigner> __nonnull requestSigner;

/**
 Initializes instance with token and all default values;

 @param token access token to Virgil Service which can be obtained here https://developer.virgilsecurity.com/dashboard/
 @return initialized VSSVirgilApiContext instance
 */
- (instancetype __nonnull)initWithToken:(NSString * __nullable)token;

/**
 Initialized instance with crypto implementation, access token, credentials and additional list of card verifiers.

 @param crypto VSSCrypto protocol implementation
 @param token access token to Virgil Service which can be obtained here https://developer.virgilsecurity.com/dashboard/
 @param credentials VSSCredentials protocol implementation used to identify application on Virgil Services.
 @param cardVerifiers list VSSCardVerifierInfo instances used to verify cards received from Virgil Service or imported used VSSCardsManager
 @return initialized VSSVirgilApiContext instance
 */
- (instancetype __nonnull)initWithCrypto:(id<VSSCrypto> __nullable)crypto token:(NSString * __nullable)token credentials:(id<VSSCredentials> __nullable)credentials cardVerifiers:(NSArray<VSSCardVerifierInfo *> * __nullable)cardVerifiers NS_DESIGNATED_INITIALIZER;

@end
