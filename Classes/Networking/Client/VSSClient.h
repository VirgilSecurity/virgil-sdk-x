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
@class VSSIdentityInfo;

/**
 * Client handles all interactions with Virgil Services.
 */
@interface VSSClient : VSSBaseClient

#pragma mark - Public keys related functionality

/**
 * @brief Gets public key instance from the Virgil Keys Service. This method sends unauthenticated request,
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
 * @deprecated Use -deletePublicKeyWithId:identityInfoList:card:privateKey:completionHandler: instead.
 *
 * @param keyId GUID containing the public key id of the key which should be get.
 * @param identities NSArray of NSDictionary objects with identity info, see VSSIdentityInfo -asDictionary for convenience.
 * @param card VSSCard which should be used for authenticated request.
 * @param privateKey VSSPrivateKey which will be used to compose the signature for authentication.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)deletePublicKeyWithId:(GUID * __nonnull)keyId identities:(NSArray <NSDictionary *>* __nonnull)identities card:(VSSCard * __nonnull)card privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler __attribute__((deprecated("Use -deletePublicKeyWithId:identityInfoList:card:privateKey:completionHandler: instead.")));

/**
 * Deletes public key instance from the Virgil Keys Service. This method sends authenticated request.
 *
 * @param keyId GUID containing the public key id of the key which should be get.
 * @param identityInfoList NSArray of VSSIdentityInfo objects.
 * @param card VSSCard which should be used for authenticated request.
 * @param privateKey VSSPrivateKey which will be used to compose the signature for authentication.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)deletePublicKeyWithId:(GUID * __nonnull)keyId identityInfoList:(NSArray <VSSIdentityInfo *>* __nonnull)identityInfoList card:(VSSCard * __nonnull)card privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

#pragma mark - Virgil Cards related functionality

/**
 * @brief Creates Virgil Card instance on the Virgil Keys Service and associates it with the public key with given ID.
 * @deprecated Use -createCardWithPublicKeyId:identityInfo:data:signs:privateKey:completionHandler: instead.
 *
 * @param keyId GUID public key identifier to associate this card with. 
 * @param identity NSDictionary containing the identity information. See VSSIdentityInfo -asDictionary for convenience.
 * @param data NSDictionary<String, String> object containing the custom key-value pairs associated with this card. May be nil.
 * @param signs NSArray of NSDictionary containing the signatures information for this card. May be nil.
 * @param privateKey VSSPrivateKey container with private key data and password if any.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)createCardWithPublicKeyId:(GUID * __nonnull)keyId identity:(NSDictionary * __nonnull)identity data:(NSDictionary * __nullable)data signs:(NSArray <NSDictionary *>* __nullable)signs privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSCard * __nullable card, NSError * __nullable error))completionHandler __attribute__((deprecated("Use -createCardWithPublicKeyId:identityInfo:data:signs:privateKey:completionHandler: instead.")));

/**
 * @brief Creates Virgil Card instance on the Virgil Keys Service and associates it with the public key with given ID.
 *
 * @param keyId GUID public key identifier to associate this card with.
 * @param identityInfo VSSIdentityInfo containing the identity information.
 * @param data NSDictionary<String, String> object containing the custom key-value pairs associated with this card. May be nil.
 * @param signs NSArray of NSDictionary containing the signatures information for this card. May be nil.
 * @param privateKey VSSPrivateKey container with private key data and password if any.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)createCardWithPublicKeyId:(GUID * __nonnull)keyId identityInfo:(VSSIdentityInfo * __nonnull)identityInfo data:(NSDictionary * __nullable)data signs:(NSArray <NSDictionary *>* __nullable)signs privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSCard * __nullable card, NSError * __nullable error))completionHandler;

/**
 * @brief Creates Virgil Card instance on the Virgil Keys Service with given public key data.
 * @deprecated Use -createCardWithPublicKey:identityInfo:data:signs:privateKey:completionHandler: instead.
 *
 * @param keyId GUID public key identifier to associate this card with.
 * @param identity NSDictionary containing the identity information. See VSSIdentityInfo -asDictionary for convenience.
 * @param data NSDictionary<String, String> object containing the custom key-value pairs associated with this card. May be nil.
 * @param signs NSArray of NSDictionary containing the signatures information for this card. May be nil.
 * @param privateKey VSSPrivateKey container with private key data and password if any.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)createCardWithPublicKey:(NSData * __nonnull)key identity:(NSDictionary * __nonnull)identity data:(NSDictionary * __nullable)data signs:(NSArray <NSDictionary *>* __nullable)signs privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSCard * __nullable card, NSError * __nullable error))completionHandler __attribute__((deprecated("Use -createCardWithPublicKey:identityInfo:data:signs:privateKey:completionHandler: instead.")));

/**
 * @brief Creates Virgil Card instance on the Virgil Keys Service with given public key data.
 *
 * @param keyId GUID public key identifier to associate this card with.
 * @param identityInfo VSSIdentityInfo containing the identity information.
 * @param data NSDictionary<String, String> object containing the custom key-value pairs associated with this card. May be nil.
 * @param signs NSArray of NSDictionary containing the signatures information for this card. May be nil.
 * @param privateKey VSSPrivateKey container with private key data and password if any.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)createCardWithPublicKey:(NSData * __nonnull)key identityInfo:(VSSIdentityInfo * __nonnull)identityInfo data:(NSDictionary * __nullable)data signs:(NSArray <NSDictionary *>* __nullable)signs privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSCard * __nullable card, NSError * __nullable error))completionHandler;

/**
 * @brief Gets Virgil Card with given id from the Virgil Keys Service.
 *
 * @param cardId GUID identifier of the card.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)getCardWithCardId:(GUID * __nonnull)cardId completionHandler:(void(^ __nullable)(VSSCard * __nullable card, NSError * __nullable error))completionHandler;

/**
 * @brief Allows to sign the Card with given Id by the other card, so that other card entrust the card with given Id.
 *
 * @param cardId GUID identifier of the card which needs to be entrusted.
 * @param digest NSData with signature digest.
 * @param signerCard VSSCard object with card which trust the card with id given in cardId parameter.
 * @param privateKey VSSPrivateKey container with private key data and password if any.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)signCardWithCardId:(GUID * __nonnull)cardId digest:(NSData * __nonnull)digest signerCard:(VSSCard * __nonnull)signerCard privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSSign * __nullable sign, NSError * __nullable error))completionHandler;

/**
 * @brief Allows to revoke trust of the Card with given Id by the other card.
 *
 * @param cardId GUID identifier of the card which needs to not be trusted any more.
 * @param signerCard VSSCard object with card which don't want to trust the card with id given in cardId parameter.
 * @param privateKey VSSPrivateKey container with private key data and password if any.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)unsignCardWithId:(GUID * __nonnull)cardId signerCard:(VSSCard * __nonnull)signerCard privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

/**
 * @brief Performs search of the cards with given parameters on the Virgil Keys Service.
 * @deprecated Use -searchCardWithIdentityInfo:relations:unconfirmed:completionHandler: instead.
 *
 * @param value NSString value of the identity associated with required Virgil Card.
 * @param type VSSIdentityType type of the identity.
 * @param relations NSArray <GUID> with IDs of Virgil Cards related to the required card.
 * @param unconfirmed NSNumber wrapper on BOOL value. In case of NO - unconfirmed cards will not be returned in the array of cards in callback.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)searchCardWithIdentityValue:(NSString * __nonnull)value type:(VSSIdentityType)type relations:(NSArray <GUID *>* __nullable)relations unconfirmed:(NSNumber * __nullable)unconfirmed completionHandler:(void(^ __nullable)(NSArray <VSSCard *>* __nullable cards, NSError * __nullable error))completionHandler __attribute__((deprecated("Use -searchCardWithIdentityInfo:relations:unconfirmed:completionHandler: instead.")));

/**
 * @brief Performs search of the cards with given parameters on the Virgil Keys Service.
 *
 * @param identityInfo VSSIdentityInfo containing the identity information.
 * @param relations NSArray <GUID> with IDs of Virgil Cards related to the required card.
 * @param unconfirmed BOOL In case of NO - unconfirmed cards will not be returned in the array of cards in callback.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)searchCardWithIdentityInfo:(VSSIdentityInfo * __nonnull)identityInfo relations:(NSArray <GUID *>* __nullable)relations unconfirmed:(BOOL)unconfirmed completionHandler:(void(^ __nullable)(NSArray <VSSCard *>* __nullable cards, NSError * __nullable error))completionHandler;

/**
 * @brief Performs search of the cards only with type VSSIdentityTypeApplication with given parameters on the Virgil Keys Service.
 *
 * @param value NSString value of the identity associated with required Virgil Card.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)searchAppCardWithIdentityValue:(NSString * __nonnull)value completionHandler:(void(^ __nullable)(NSArray <VSSCard *>* __nullable cards, NSError * __nullable error))completionHandler;

/**
 * @brief Deletes the Virgil Card with given cardId and identity from the Virgil Keys Service.
 * @deprecated Use -deleteCardWithCardId:identityInfo:privateKey:completionHandler: instead.
 *
 * @param cardId GUID identifier of the card which is needs to be deleted.
 * @param identity NSDictionary containing the identity information. See VSSIdentityInfo -asDictionary for convenience. May be nil for unconfirmed Virgil Cards.
 * @param privateKey VSSPrivateKey container with private key data and password if any.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)deleteCardWithCardId:(GUID * __nonnull)cardId identity:(NSDictionary * __nullable)identity privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler __attribute__((deprecated("Use -deleteCardWithCardId:identityInfo:privateKey:completionHandler: instead.")));

/**
 * @brief Deletes the Virgil Card with given cardId and identity from the Virgil Keys Service.
 *
 * @param cardId GUID identifier of the card which is needs to be deleted.
 * @param identityInfo VSSIdentityInfo containing the identity information. May be nil for unconfirmed Virgil Cards.
 * @param privateKey VSSPrivateKey container with private key data and password if any.
 * @param completionHandler Callback handler which will be called after request completed.
 *
 */
- (void)deleteCardWithCardId:(GUID * __nonnull)cardId identityInfo:(VSSIdentityInfo * __nullable)identityInfo privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

#pragma mark - Identities related functionality

/**
 * @brief Initiates identity verification flow for given identity.
 *
 * @param type VSSIdentityType type of the identity which have to be verified.
 * @param value NSString identity value.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)verifyIdentityWithType:(VSSIdentityType)type value:(NSString * __nonnull)value completionHandler:(void(^ __nullable)(GUID * __nullable actionId, NSError * __nullable error))completionHandler;

/**
 * @brief Initiates identity verification flow for given identity with extra information.
 *
 * @param type VSSIdentityType type of the identity which have to be verified.
 * @param value NSString identity value.
 * @param extraFields NSDictionary<NSString, NSString> containing required extra key-value pairs to be used in verification process.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)verifyIdentityWithType:(VSSIdentityType)type value:(NSString * __nonnull)value extraFields:(NSDictionary * __nullable)extraFields completionHandler:(void(^ __nullable)(GUID * __nullable actionId, NSError * __nullable error))completionHandler;

/**
 * @brief Initiates identity verification flow for given identity with extra information.
 *
 * @param identityInfo VSSIdentityInfo of the identity which have to be verified.
 * @param extraFields NSDictionary<NSString, NSString> containing required extra key-value pairs to be used in verification process.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)verifyIdentityWithInfo:(VSSIdentityInfo * __nonnull)identityInfo extraFields:(NSDictionary * __nullable)extraFields completionHandler:(void(^ __nullable)(GUID * __nullable actionId, NSError * __nullable error))completionHandler;

/**
 * @brief Completes identity verification flow by Id and using confirmation code.
 *
 * @param actionId GUID identifier of the verification identity flow returned in callback of -verifyIdentity...
 * @param code NSString Confirmation code received from the user.
 * @param ttl NSNumber with token's 'time to live' parameter for the limitations of the token's lifetime in seconds (maximum value is 60 * 60 * 24 * 365 = 1 year). Default value is 3600. In case of ttl is nil - default value will be used by the SDK.
 * @param ctl NSNumber with token's 'count to live' parameter to restrict the number of token usages (maximum value is 100). Default value is 1. In case when ctl is nil - default value will be used by the SDK.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)confirmIdentityWithActionId:(GUID * __nonnull)actionId code:(NSString * __nonnull)code ttl:(NSNumber * __nullable)ttl ctl:(NSNumber * __nullable)ctl completionHandler:(void(^ __nullable)(VSSIdentityType type, NSString * __nullable value, NSString * __nullable validationToken, NSError * __nullable error))completionHandler;

/**
 * @brief Completes identity verification flow by Id and using confirmation code.
 *
 * @param actionId GUID identifier of the verification identity flow returned in callback of -verifyIdentity...
 * @param code NSString Confirmation code received from the user.
 * @param tokenTtl NSUInteger with token's 'time to live' parameter for the limitations of the token's lifetime in seconds (maximum value is 60 * 60 * 24 * 365 = 1 year). Default value is 3600. In case of 0 - default value will be used by the SDK.
 * @param tokenCtl NSUInteger with token's 'count to live' parameter to restrict the number of token usages (maximum value is 100). Default value is 1. In case of 0 - default value will be used by the SDK.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)confirmIdentityWithActionId:(GUID * __nonnull)actionId code:(NSString * __nonnull)code tokenTtl:(NSUInteger)tokenTtl tokenCtl:(NSUInteger)tokenCtl completionHandler:(void(^ __nullable)(VSSIdentityInfo * __nullable identityInfo, NSError * __nullable error))completionHandler;


#pragma mark - Private keys related functionality

/**
 * @brief Stores the private key instance on the Virgil Private Keys Service.
 *
 * @param privateKey VSSPrivateKey containing the private key data and password if any.
 * @param cardId GUID identifier of the correspondent Virgil Card stored on the Virgil Keys Service.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)storePrivateKey:(VSSPrivateKey * __nonnull)privateKey cardId:(GUID * __nonnull)cardId completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

/**
 * @brief Gets the private key instance from the Virgil Private Keys Service.
 * @deprecated Use -getPrivateKeyWithCardId:identityInfo:password:completionHandler: instead.
 *
 * @param identity NSDictionary containing the identity information. See VSSIdentityInfo -asDictionary for convenience.
 * @param cardId GUID identifier of the correspondent Virgil Card stored on the Virgil Keys Service.
 * @param password NSString password which will be used by the Virgil Private Keys Service for response encryption. If password is nil then random password will be generated by the SDK for this single request.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)grabPrivateKeyWithIdentity:(NSDictionary * __nonnull)identity cardId:(GUID * __nonnull)cardId password:(NSString * __nullable)password completionHandler:(void(^ __nullable)(NSData * __nullable keyData, GUID * __nullable cardId, NSError * __nullable error))completionHandler __attribute__((deprecated("Use -getPrivateKeyWithCardId:identityInfo:password:completionHandler: instead.")));

/**
 * @brief Gets the private key instance from the Virgil Private Keys Service.
 *
 * @param cardId GUID identifier of the correspondent Virgil Card stored on the Virgil Keys Service.
 * @param identityInfo VSSIdentityInfo containing the identity information.
 * @param password NSString password which will be used by the Virgil Private Keys Service for response encryption. If password is nil then random password will be generated by the SDK for this single request.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)getPrivateKeyWithCardId:(GUID * __nonnull)cardId identityInfo:(VSSIdentityInfo * __nonnull)identityInfo password:(NSString * __nullable)password completionHandler:(void(^ __nullable)(NSData * __nullable keyData, GUID * __nullable cardId, NSError * __nullable error))completionHandler;

/**
 * @brief Deletes the private key instance from the Virgil Private Keys Service.
 *
 * @param privateKey VSSPrivateKey containing the private key data and password if any.
 * @param cardId GUID identifier of the correspondent Virgil Card stored on the Virgil Keys Service.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)deletePrivateKey:(VSSPrivateKey * __nonnull)privateKey cardId:(GUID * __nonnull)cardId completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

@end
