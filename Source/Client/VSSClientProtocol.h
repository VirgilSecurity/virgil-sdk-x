//
//  VSSClientProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSearchCardsCriteria.h"
#import "VSSCreateCardRequest.h"
#import "VSSSignedCardRequest.h"
#import "VSSRemoveCardRelationRequest.h"
#import "VSSCreateEmailCardRequest.h"
#import "VSSRevokeCardRequest.h"
#import "VSSRevokeEmailCardRequest.h"
#import "VSSConfirmIdentityResponse.h"
#import "VSSChallengeMessageResponse.h"
#import "VSSObtainTokenResponse.h"
#import "VSSCard.h"

/**
 * Protocol for all interactions with Virgil Services.
 */
@protocol VSSClient <NSObject>

/**
 Creates Virgil Card instance on the Virgil Cards Service and associates it with unique identifier.
 Also makes the Card accessible for search/get/revoke queries from other users.
 VSSCreateCardRequest should be signed at least by Owner (Creator) and Application. Additional signatures may be applied if needed.

 @param request VSSCreateCardRequest instance with Card data and signatures
 @param callback callback with registered VSSCard or NSError instance if error occured
 */
- (void)createCardWithRequest:(VSSCreateCardRequest * __nonnull)request completion:(void (^ __nonnull)(VSSCard * __nullable, NSError * __nullable))callback NS_SWIFT_NAME(createCard(with:completion:));

/**
 Creates trusted one-way relation between two virgil cards.

 @param request VSSSignedRequest with snapshot of card that is trusted and signed by card that trusts
 @param callback callback with NSError instance if error occured
 */
- (void)createCardRelationWithSignedCardRequest:(VSSSignedCardRequest * __nonnull)request completion:(void (^ __nonnull)(NSError * __nullable))callback;

/**
 Removes relation from one card to another.

 @param request VSSRemoveCardRelationRequest created for card which is removing from relation
 @param callback callback with NSError instance if error occured
 */
- (void)removeCardRelationWithRequest:(VSSRemoveCardRelationRequest * __nonnull)request completion:(void (^ __nonnull)(NSError * __nullable))callback;

/**
 Returns Virgil Card from the Virgil Cards Service with given ID, if exists.
 
 @param cardId   NSString with unique Virgil Card identifier
 @param callback callback with VSSCard with given ID or NSError instance if error occured
 */
- (void)getCardWithId:(NSString * __nonnull)cardId completion:(void (^ __nonnull)(VSSCard * __nullable, NSError * __nullable))callback NS_SWIFT_NAME(getCard(withId:completion:));

/**
 Performs search of Virgil Cards using search criteria on the Virgil Cards Service.

 @param criteria VSSSearchCardsCriteria instance with criteria for desired cards
 @param callback callback with array of matched VSSCard instances or NSError if error occured
 */
- (void)searchCardsUsingCriteria:(VSSSearchCardsCriteria * __nonnull)criteria completion:(void (^ __nonnull)(NSArray<VSSCard *>* __nullable, NSError * __nullable))callback NS_SWIFT_NAME(searchCards(using:completion:));

/**
 Revokes previously registered card.
 VSSRevokeCardRequest instance should be signed by Application.

 @param request VSSRevokeCardRequest created with specific Virgil Card ID
 @param callback callback with NSError instance if error occured
 */
- (void)revokeCardWithRequest:(VSSRevokeCardRequest * __nonnull)request completion:(void (^ __nonnull)(NSError * __nullable))callback NS_SWIFT_NAME(revokeCardWith(_:completion:));

/**
 Sends the request for identity verification, that's will be processed depending of specified type.

 @param identity NSString unique string that represents identity
 @param identityType NSString with type of identity
 @param extraFields NSDictionary with values which will be passed with verification message
 @param callback callback with NSString with action ID, or NSError instance if error occured
 */
- (void)verifyIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType extraFields:(NSDictionary<NSString *, NSString *> * __nullable)extraFields completion:(void (^ __nonnull)(NSString * __nullable, NSError * __nullable))callback;

/**
 Confirms the identity using confirmation code, that has been generated to confirm an identity.

 @param actionId NSString action identifier that was obtained on verification step
 @param confirmationCode NSString confirmation code that was recived on email box
 @param timeToLive NSInteger TTL is used to limit the lifetime of the token in seconds (maximum value is 60 * 60 * 24 * 365 = 1 year)
 @param countToLive NSInteger CTL is used to restrict the number of usages (maximum value is 100)
 @param callback callback with VSSConfirmIdentityResponse object, or NSError instance if error occured
 */
- (void)confirmIdentityWithActionId:(NSString * __nonnull)actionId confirmationCode:(NSString * __nonnull)confirmationCode timeToLive:(NSInteger)timeToLive countToLive:(NSInteger)countToLive completion:(void (^ __nonnull)(VSSConfirmIdentityResponse * __nullable, NSError * __nullable))callback;

/**
 Returns without error if validation token is valid

 @param identity NSString unique string that represents identity
 @param identityType NSString with type of identity
 @param validationToken NSString with validation token obtained during confirmation step
 @param callback callback with NSError instance if error occured, or nil if validation succeeded
 */
- (void)validateIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType validationToken:(NSString * __nonnull)validationToken completion:(void (^ __nonnull)(NSError * __nullable))callback;

/**
 Requests challenge message from Virgil Auth Service to obtain access token.

 @param virgilCardId NSString with id of virgil card for which token will be granted
 @param callback callback with VSSChallengeMessageResponse object, or NSError instance if error occured
 */
- (void)getChallengeMessageForVirgilCardWithId:(NSString * __nonnull)virgilCardId completion:(void (^ __nonnull)(VSSChallengeMessageResponse * __nullable, NSError * __nullable))callback;

/**
 Acknowledges using auth grant id and reencrypted message. Message should be reencrypted for Virgil Auth Service whose public key can be found in VSSClient.m.

 @param authGrantId NSString auth grant id which can be found in VSSChallengeMessageResponse
 @param encryptedMessage Reencrypted for Virgil Auth Service message. Original message can be found inside VSSChallengeMessageResponse
 @param callback callback with access code, or NSError instance if error occured
 */
- (void)ackChallengeMessageWithAuthGrantId:(NSString * __nonnull)authGrantId encryptedMessage:(NSData * __nonnull)encryptedMessage completion:(void (^ __nonnull)(NSString * __nullable, NSError * __nullable))callback;

/**
 Obtaines access and refresh tokens using access code.

 @param accessCode NSString with access code
 @param callback callback with VSSObtainTokenResponse object, or NSError instance if error occured
 */
- (void)obtainAccessTokenWithAccessCode:(NSString * __nonnull)accessCode completion:(void (^ __nonnull)(VSSObtainTokenResponse * __nullable, NSError * __nullable))callback;

/**
 Refreshes access token using refresh token

 @param refreshToken NSString with refresh token
 @param callback callback with VSSTokenResponse object, or NSError instance if error occured
 */
- (void)refreshAccessTokenWithRefreshToken:(NSString * __nonnull)refreshToken completion:(void (^ __nonnull)(VSSTokenResponse * __nullable, NSError * __nullable))callback;

/**
 Verifies access token.

 @param accessToken NSString with access token
 @param callback callback with virgil card id of token owner, or NSError instance if error occured
 */
- (void)verifyAccessToken:(NSString * __nonnull)accessToken completion:(void (^ __nonnull)(NSString * __nullable, NSError * __nullable))callback;

@end
