//
//  VKKeysClient.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSBaseClient.h"
#import "VSSModelTypes.h"

@class VSSPublicKey;
@class VSSPublicKeyExtended;
@class VSSPrivateKey;
@class VSSCard;
@class VSSSign;

/**
 * Client handles all interactions with Virgil Services.
 */
@interface VSSClient : VSSBaseClient


/**
 * Gets public key instance from the Virgil Keys Service. This method sends unauthenticated request,
 * so the returned public key will contain only id, actual public key data and creation date. There will not be an array 
 * of cards for the key returned. Use authenticated request instead.
 *
 * @param keyId GUID containing the public key id of the key which should be get.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)getPublicKeyWithId:(GUID * __nonnull)keyId completionHandler:(void(^ __nullable)(VSSPublicKey * __nullable key, NSError * __nullable error))completionHandler;

/**
 * Gets public key instance from the Virgil Keys Service. This method sends authenticated request,
 * so the returned public key will contain an array of cards for the public key as well as all other key's data. 
 *
 * @param keyId GUID containing the public key id of the key which should be get.
 * @param card VSSCard which should be used for authenticated request.
 * @param privateKey VSSPrivateKey which will be used to compose the signature for authentication.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)getPublicKeyWithId:(GUID * __nonnull)keyId card:(VSSCard * __nonnull)card privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSPublicKeyExtended * __nullable key, NSError * __nullable error))completionHandler;

/**
 * Deletes public key instance from the Virgil Keys Service. This method sends authenticated request.
 *
 * @param keyId GUID containing the public key id of the key which should be get.
 * @param identities NSArray of NSDictionary objects containing identity type, value and validation_token obtained from the Virgil Identity Service.
 * @param card VSSCard which should be used for authenticated request.
 * @param privateKey VSSPrivateKey which will be used to compose the signature for authentication.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)deletePublicKeyWithId:(GUID * __nonnull)keyId identities:(NSArray <NSDictionary *>* __nonnull)identities card:(VSSCard * __nonnull)card privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

- (void)createCardWithPublicKeyId:(GUID * __nonnull)keyId identity:(NSDictionary * __nonnull)identity data:(NSDictionary * __nullable)data signs:(NSArray <NSDictionary *>* __nullable)signs privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSCard * __nullable card, NSError * __nullable error))completionHandler;

- (void)createCardWithPublicKey:(NSData * __nonnull)key identity:(NSDictionary * __nonnull)identity data:(NSDictionary * __nullable)data signs:(NSArray <NSDictionary *>* __nullable)signs privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSCard * __nullable card, NSError * __nullable error))completionHandler;

- (void)getCardWithCardId:(GUID * __nonnull)cardId completionHandler:(void(^ __nullable)(VSSCard * __nullable card, NSError * __nullable error))completionHandler;

- (void)signCardWithCardId:(GUID * __nonnull)cardId digest:(NSData * __nonnull)digest signerCard:(VSSCard * __nonnull)signerCard privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSSign * __nullable sign, NSError * __nullable error))completionHandler;

- (void)unsignCardWithId:(GUID * __nonnull)cardId signerCard:(VSSCard * __nonnull)signerCard privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

- (void)searchCardWithIdentityValue:(NSString * __nonnull)value type:(VSSIdentityType)type relations:(NSArray <GUID *>* __nullable)relations unconfirmed:(NSNumber * __nullable)unconfirmed completionHandler:(void(^ __nullable)(NSArray <VSSCard *>* __nullable cards, NSError * __nullable error))completionHandler;

- (void)searchAppCardWithIdentityValue:(NSString * __nonnull)value completionHandler:(void(^ __nullable)(NSArray <VSSCard *>* __nullable cards, NSError * __nullable error))completionHandler;

- (void)deleteCardWithCardId:(GUID * __nonnull)cardId identity:(NSDictionary * __nullable)identity privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;





- (void)verifyIdentityWithType:(VSSIdentityType)type value:(NSString * __nonnull)value completionHandler:(void(^ __nullable)(GUID * __nullable actionId, NSError * __nullable error))completionHandler;

- (void)confirmIdentityWithActionId:(GUID * __nonnull)actionId code:(NSString * __nonnull)code ttl:(NSNumber * __nullable)ttl ctl:(NSNumber * __nullable)ctl completionHandler:(void(^ __nullable)(VSSIdentityType type, NSString * __nullable value, NSString * __nullable validationToken, NSError * __nullable error))completionHandler;




- (void)storePrivateKey:(VSSPrivateKey * __nonnull)privateKey cardId:(GUID * __nonnull)cardId completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

- (void)grabPrivateKeyWithIdentity:(NSDictionary * __nonnull)identity cardId:(GUID * __nonnull)cardId password:(NSString * __nullable)password completionHandler:(void(^ __nullable)(NSData * __nullable keyData, GUID * __nullable cardId, NSError * __nullable error))completionHandler;

- (void)deletePrivateKey:(VSSPrivateKey * __nonnull)privateKey cardId:(GUID * __nonnull)cardId completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

@end
