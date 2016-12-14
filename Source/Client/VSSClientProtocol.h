//
//  VSSClientProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSearchCardsCriteria.h"
#import "VSSCreateCardRequest.h"
#import "VSSRevokeCardRequest.h"
#import "VSSConfirmIdentityResponse.h"
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
- (void)createCardWithRequest:(VSSCreateCardRequest * __nonnull)request completion:(void (^ __nonnull)(VSSCard * __nullable, NSError * __nullable))callback NS_SWIFT_NAME(createCardWith(_:completion:));

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
 Starts email verification process

 @param identity NSString with identity value
 @param identityType NSString with identity type
 @param extraFields NSDictionary with values passed with verification message
 @param callback callback with NSString with action ID, or NSError instance if error occured
 */
- (void)verifyIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType extraFields:(NSDictionary<NSString *, NSString *> * __nullable)extraFields completion:(void (^ __nonnull)(NSString * __nullable, NSError * __nullable))callback;

- (void)confirmIdentityWithActionId:(NSString * __nonnull)actionId confirmationCode:(NSString * __nonnull)confirmationCode timeToLive:(NSInteger)timeToLive countToLive:(NSInteger)countToLive completion:(void (^ __nonnull)(VSSConfirmIdentityResponse * __nullable, NSError * __nullable))callback;

- (void)validateIdentity:(NSString * __nonnull)identity identityType:(NSString * __nonnull)identityType validationToken:(NSString * __nonnull)validationToken completion:(void (^ __nonnull)(NSError * __nullable))callback;


@end
