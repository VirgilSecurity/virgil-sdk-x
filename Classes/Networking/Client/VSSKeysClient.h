//
//  VKKeysClient.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VirgilFrameworkiOS/VSSClient.h>
#import <VirgilFrameworkiOS/VSSTypes.h>

@class VSSPublicKey;
@class VSSPrivateKey;
@class VSSUserData;
@class VSSUserDataExtended;
@class VSSActionToken;
@class VSSKeyPair;

/**
 * Keys Client handles all interactions with Virgil Keys Service. It contains methods to manage Virgil Public Keys, Virgil User Data instances.
 */
@interface VSSKeysClient : VSSClient

/**
 * Sends new public key instance to the Virgil Keys Service. Basically, given public key will be created at server side. After this method is called, service will send confirmation tokens to the user data values (e.g. email address) attached to the public key.
 * @param publicKey VSSPublicKey Model object containing actual public key data and a list of VKUserData instances attached to that public key. The list should contain at least one user data instance with UDCUserId Class.
 * @param privateKey VSSPrivateKey Private key container corresponding the public key which is about to be created. It is necessary to compose X-VIRGIL-REQUEST-SIGN header to make service sure that user is actual owner of the public key.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)createPublicKey:(VSSPublicKey * __nonnull)publicKey privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSPublicKey *__nullable pubKey, NSError * __nullable error))completionHandler;
/**
 * Request for the Virgil Public Key from the Virgil Keys Service.
 * @param publicKeyId GUID NSString containing lowercased UUID of the public key which is necessary to get.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)getPublicKeyId:(GUID * __nonnull)publicKeyId completionHandler:(void(^ __nullable)(VSSPublicKey * __nullable pubKey, NSError * __nullable error))completionHandler;
/**
 * Request for update existing public key instance at the Virgil Keys Service.
 * @param publicKeyId GUID NSString containing lowercased UUID of the public key which is necessary to be updated. 
 * @param privateKey VSSPrivateKey Private key container corresponding the public key which is need to be updated ("old" public key). It is necessary to compose X-VIRGIL-REQUEST-SIGN header to make service sure that user is actual owner of the "old" public key.
 * @param keyPair VSSKeyPair instance containing the public key data which will be used as update for existing "old" public key. Whole key pair is necessary to compose request sign to make service sure that user is actual owner of this key pair.
 * @param newKeyPassword NSString Password which was used to create a key pair object ("new") or nil if key pair was created without a password.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)updatePublicKeyId:(GUID * __nonnull)publicKeyId privateKey:(VSSPrivateKey * __nonnull)privateKey newKeyPair:(VSSKeyPair * __nonnull)keyPair newKeyPassword:(NSString * __nullable)newKeyPassword completionHandler:(void(^ __nullable)(VSSPublicKey * __nullable pubKey, NSError * __nullable error))completionHandler;
/**
 * Request for removing public key from the Virgil Keys Service.
 * @param publicKeyId GUID NSString containing lowercased UUID of the public key which is necessary to be deleted.
 * @param privateKey VSSPrivateKey Private key container corresponding the public key which is about to be deleted. It is necessary to compose X-VIRGIL-REQUEST-SIGN header to make service sure that user is actual owner of the public key.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)deletePublicKeyId:(GUID * __nonnull)publicKeyId privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

/**
 * Request for removing public key from the Virgil Keys Service (Unsigned request which should return action token for further confirmations).
 * @param publicKeyId GUID NSString containing lowercased UUID of the public key which is necessary to be deleted.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information.
 */
- (void)deletePublicKeyId:(GUID * __nonnull)publicKeyId completionHandler:(void(^ __nullable)(VSSActionToken *__nullable actionToken, NSError * __nullable error))completionHandler;
/**
 * Request for reseting the public key at the Virgil Keys Service. It might be useful in case when user lost his/her private key, so he/she can not sign any requests and can not prove that he/she is owner of the public key. In case of successful request the Virgil Keys Service will return VKActionToken instance via the first parameter of the completionHandler. This Action Token should be used to prove that user is actual owner of the all user data objects (e.g. email addresses) attached to the public key which is about to be reset.
 * @param publicKeyId GUID NSString containing lowercased UUID of the public key which is necessary to be reset.
 * @param keyPair VSSKeyPair instance containing the new public key data which will be used as new user's public key. Also the new private key is necessary to compose request sign to make service sure that user is actual owner of this key pair.
 * @param keyPassword NSString Password which was used to create a key pair object or nil if key pair was created without a password.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)resetPublicKeyId:(GUID * __nonnull)publicKeyId keyPair:(VSSKeyPair * __nonnull)keyPair keyPassword:(NSString * __nullable)keyPassword completionHandler:(void(^ __nullable)(VSSActionToken * __nullable actionToken, NSError * __nullable error))completionHandler;
/**
 * Request for confirmation of the public key's ownership. This request should be made as a part of procedure of reseting the public key.
 * @param publicKeyId GUID NSString containing lowercased UUID of the public key which is necessary to be confirmed.
 * @param actionToken VSSActionToken Data structure containing confirmation codes for all requested by the Service user data objects. This is necessary to make Service sure that user is actual owner of the all user data attached to the public key.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)persistPublicKeyId:(GUID * __nonnull)publicKeyId actionToken:(VSSActionToken * __nonnull)actionToken completionHandler:(void(^ __nullable)(VSSPublicKey *__nullable pubKey, NSError * __nullable error))completionHandler;

/**
 * Performs search for the Virgil Public Key instance at the Virgil Keys Service. Call to this method will send signed version of the request. Basically, this is useful to get own public key. If you need unsigned version see -searchPublicKeyUserIdValue:completionHandler: below;
 * @param publicKeyId GUID NSString containing lowercased UUID of the public key which is necessary to be get.  
 * @param privateKey VFPrivateKey Private key container corresponding the public key which is need to be get. It is necessary to compose X-VIRGIL-REQUEST-SIGN header to make service sure that user is actual owner of the public key.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)searchPublicKeyId:(GUID * __nonnull)publicKeyId privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSPublicKey *__nullable pubKey, NSError * __nullable error))completionHandler;
/**
 * Performs search for the Virgil Public Key instance at the Virgil Keys Service. Call to this method will send unsigned version of the request. Basically, this is useful to get public key by the user data value (e.g. by the user's email). If you need signed version see -searchPublicKeyId:privateKey:keyPassword:completionHandler: above;
 * @param value NSString Value of the user data associated with the public key which is necessary to be get.  
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)searchPublicKeyUserIdValue:(NSString * __nonnull)value completionHandler:(void(^ __nullable)(VSSPublicKey * __nullable pubKey, NSError * __nullable error))completionHandler;

/**
 * Sends new user data instance to the Virgil Keys Service. This new user data instance will be attached to the public key which id is set as a second paramete to this call.
 * @param userData VSSUserData Model object containing actual new user data instance.
 * @param publicKeyId GUID NSString containing lowercased UUID of the public key the user data will be associated with.
 * @param privateKey VFPrivateKey Private key container corresponding the public key. It is necessary to compose X-VIRGIL-REQUEST-SIGN header to make service sure that user is actual owner of the public key.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)createUserData:(VSSUserData * __nonnull)userData publicKeyId:(GUID * __nonnull)publicKeyId privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(VSSUserDataExtended * __nullable uData, NSError * __nullable error))completionHandler;

/**
 * Request for deletion of the user data instance from the Virgil Keys Service.
 * @param userDataId GUID NSString containing lowercased UUID of the user data which is about to be deleted.
 * @param publicKeyId GUID NSString containing lowercased UUID of the public key the user data is associated with.
 * @param privateKey VSSPrivateKey Private key container corresponding the public key. It is necessary to compose X-VIRGIL-REQUEST-SIGN header to make service sure that user is actual owner of the public key.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)deleteUserDataId:(GUID * __nonnull)userDataId publicKeyId:(GUID * __nonnull)publicKeyId privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;
/**
 * Confirmation request for particular user data instance to the Virgil Keys Service. This is necessary to make the Service sure that user is actual owner of this user data.
 * @param userDataId GUID NSString containing lowercased UUID of the user data which is necessary to confirm ownership.
 * @param confirmationCode NSString Confirmation token which was sent by the Service to that user data (e.g. to the email address).
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)persistUserDataId:(GUID * __nonnull)userDataId confirmationCode:(NSString * __nonnull)code completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;
/**
 * Request for re-sending confirmation code of the user data instance from the Virgil Keys Service.
 * @param userDataId GUID NSString containing lowercased UUID of the user data which is need to be confermed.
 * @param publicKeyId GUID NSString containing lowercased UUID of the public key the user data is associated with.
 * @param privateKey VSSPrivateKey Private key container corresponding the public key. It is necessary to compose X-VIRGIL-REQUEST-SIGN header to make service sure that user is actual owner of the public key.
 * @param completionHandler Block with callback code which should be called in case of request completion due to success or error. In case of success NSError parameter of the callback will be nil. Otherwise it will contain error information. 
 */
- (void)resendConfirmationUserDataId:(GUID * __nonnull)userDataId publicKeyId:(GUID * __nonnull)publicKeyId privateKey:(VSSPrivateKey * __nonnull)privateKey completionHandler:(void(^ __nullable)(NSError * __nullable error))completionHandler;

@end
