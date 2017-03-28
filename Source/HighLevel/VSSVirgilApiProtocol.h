//
//  VSSVirgilApiProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCardsManagerProtocol.h"
#import "VSSKeysManagerProtocol.h"
#import "VSSIdentitiesManagerProtocol.h"

/**
 Entry point for all interactions with VirgilSDK.
 See default implementation in @interface VSSVirgilApi.
 */
@protocol VSSVirgilApi <NSObject>

/**
 Entry point for all interactions with Identities.
 See default implementation: VSSIdentitiesManager.
 */
@property (nonatomic, readonly) id<VSSIdentitiesManager> __nonnull Identities;

/**
 Entry point for all interactions with Virgil Cards.
 See default implementation: VSSCardsManager.
 */
@property (nonatomic, readonly) id<VSSCardsManager> __nonnull Cards;

/**
 Entry point for all interactions with Virgil Keys.
 See default implementation: VSSKeysManager.
 */
@property (nonatomic, readonly) id<VSSKeysManager> __nonnull Keys;

/**
 Encrypts data for given recipients.

 @param data NSData to be encrypted
 @param cards NSArray of Virgil Cards whose owners will be able to decrypt data
 @param errorPtr NSError pointer to return error if needed
 @return NSData with encrypted data
 */
- (NSData * __nullable)encryptData:(NSData * __nonnull)data for:(NSArray<VSSVirgilCard *> * __nonnull)cards error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:for:));

/**
 Encrypts string for given recipients.
 NOTE: while encrypting string is converted to binary representation using UTF8 encoding.

 @param string NSString to be encrypted
 @param cards NSArray of Virgil Cards whose owners will be able to decrypt data
 @param errorPtr NSError pointer to return error if needed
 @return NSData with encrypted string
 */
- (NSData * __nullable)encryptString:(NSString * __nonnull)string for:(NSArray<VSSVirgilCard *> * __nonnull)cards error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:for:));

@end
