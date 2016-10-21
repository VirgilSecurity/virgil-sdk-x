//
//  VSSClientProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSearchCardsCriteria.h"
#import "VSSCard.h"
#import "VSSRevokeCard.h"

/**
 * Protocol for all interactions with Virgil Services.
 */
@protocol VSSClient <NSObject>

/**
 Registers Virgil Card instance on the Virgil Cards Service and associates it with unique identifier.
 Also makes Virgil Cards accessible for search/get/revoke queries from other users.
 VSSCard should be signed at least by Owner (Creator) and Application. Additional signatures may be applied if needed.
 Registered VSSCard will contain all initial signatures and additionaly the Virgil Cards Service's signature.

 @param card     VSSCard to be registered
 @param callback callback with registered VSSCard or NSError instance if error occured
 */
- (void)registerCard:(VSSCard * __nonnull)card completion:(void (^ __nonnull)(VSSCard * __nullable, NSError * __nullable))callback NS_SWIFT_NAME(register(_:completion:));

/**
 Returns Virgil Card with all signatures from the Virgil Cards Service with given ID, if exists.
 
 @param cardId   NSString with unique VSSCard identifier
 @param callback callback with VSSCard with given ID or NSError instance if error occured
 */
- (void)getCardWithId:(NSString * __nonnull)cardId completion:(void (^ __nonnull)(VSSCard * __nullable, NSError * __nullable))callback NS_SWIFT_NAME(getCard(withId:completion:));

/**
 Performs search of Virgil Cards using search criteria on the Virgil Cards Service.
 Returned Virgil Cards will contain all signatures.

 @param criteria VSSSearchCardsCriteria instance with criteria for desired cards
 @param callback callback with array of matched VSSCard instances or NSError instance if error occured
 */
- (void)searchCardsUsingCriteria:(VSSSearchCardsCriteria * __nonnull)criteria completion:(void (^ __nonnull)(NSArray<VSSCard *>* __nullable, NSError * __nullable))callback NS_SWIFT_NAME(searchCards(using:completion:));

/**
 Revokes previously registered cards.
 VSSRevokeCard instance should be signed by Application.

 @param revokeCard VSSRevokeCard created for specific Virgil Card ID
 @param callback   callback with NSError instance if error occured
 */
- (void)revokeCard:(VSSRevokeCard * __nonnull)revokeCard completion:(void (^ __nonnull)(NSError * __nullable))callback NS_SWIFT_NAME(revoke(_:completion:));

@end
