//
//  VSSCardsManagerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSVirgilCard.h"
#import "VSSVirgilKey.h"
#import "VSSVirgilIdentity.h"
#import "VSSEmailIdentity.h"

/**
 Entry point for all interaction with Virgil Cards.
 */
@protocol VSSCardsManager <NSObject>

/**
 Creates (but doesn't publish) new Virgil Card.

 @param identity confirmed VSSVirgilIdentity instance describing identity of Virgil Card owner. See VSSIdentitiesManager.
 @param ownerKey VSSVirgilKey instance with Virgil Card owner's key
 @param customFields NSDictionary with custom payload if needed
 @param errorPtr NSError pointer to return error if needed
 @return allocated and initialized VSSVirgilCard instance
 */
- (VSSVirgilCard * __nullable)createCardWithIdentity:(VSSVirgilIdentity * __nonnull)identity ownerKey:(VSSVirgilKey * __nonnull)ownerKey customFields:(NSDictionary<NSString *, NSString *> * __nullable)customFields error:(NSError * __nullable * __nullable)errorPtr;

/**
 Creates (but doesn't publish) new Virgil Card.

 @param identity VSSVirgilIdentity instance describing identity of Virgil Card owner. See VSSIdentitiesManager
 @param ownerKey VSSVirgilKey instance with Virgil Card owner's key
 @param errorPtr NSError pointer to return error if needed
 @return allocated and initialized VSSVirgilCard instance
 */
- (VSSVirgilCard * __nullable)createCardWithIdentity:(VSSVirgilIdentity * __nonnull)identity ownerKey:(VSSVirgilKey * __nonnull)ownerKey error:(NSError * __nullable * __nullable)errorPtr;

/**
 Imports Virgil Card from NSString representation.
 To export Virgil Card use VSSExportable protocol which VSSVirgilCard conforms to.
 
 @param data NSString representation of VSSVirgilCard
 @return allocated and initialized VSSVirgilCard instance
 */
- (VSSVirgilCard * __nullable)importVirgilCardFromData:(NSString * __nonnull)data;

/**
 Publishes Virgil Card on the Virgil Service.

 @param card VSSVirgilCard instance representing Virgil Card to be published
 @param callback callback with NSError instance if error occured
 */
- (void)publishCard:(VSSVirgilCard * __nonnull)card completion:(void (^ __nonnull)(NSError * __nullable))callback NS_SWIFT_NAME(publish(_:completion:));

/**
 Performs search of Virgil Cards using list of identities on the Virgil Service.
 NOTE: Search is perfomed in Application scope.

 @param identities NSArray with identity values
 @param callback callback with list of found VSSVirgilCard instance, or NSError instance if error occured
 */
- (void)searchCardsWithIdentities:(NSArray<NSString *> * __nonnull)identities completion:(void (^ __nonnull)(NSArray<VSSVirgilCard *> * __nullable, NSError * __nullable))callback;

/**
 Performs search of Virgil Cards using list of identities on the Virgil Service.
 NOTE: Search is perfomed in Application scope.

 @param identityType NSString with identity type
 @param identities NSArray with identity values
 @param callback callback with list of found VSSVirgilCard instance, or NSError instance if error occured
 */
- (void)searchCardsWithIdentityType:(NSString * __nonnull)identityType identities:(NSArray<NSString *> * __nonnull)identities completion:(void (^ __nonnull)(NSArray<VSSVirgilCard *> * __nullable, NSError * __nullable))callback;

/**
 Performs search of Virgil Cards using list of identities on the Virgil Service.
 NOTE: Search is perfomed in Global scope.

 @param identities NSArray with identity values
 @param callback callback with list of found VSSVirgilCard instance, or NSError instance if error occured
 */
- (void)searchGlobalCardsWithIdentities:(NSArray<NSString *> * __nonnull)identities completion:(void (^ __nonnull)(NSArray<VSSVirgilCard *> * __nullable, NSError * __nullable))callback;

/**
 Performs search of Virgil Cards using list of identities on the Virgil Service.
 NOTE: Search is perfomed in Global scope.

 @param identityType NSString with identity type
 @param identities NSArray with identity values
 @param callback callback with list of found VSSVirgilCard instance, or NSError instance if error occured
 */
- (void)searchGlobalCardsWithIdentityType:(NSString * __nonnull)identityType identities:(NSArray<NSString *> * __nonnull)identities completion:(void (^ __nonnull)(NSArray<VSSVirgilCard *> * __nullable, NSError * __nullable))callback;

/**
 Pulls Virgil Card from the Virgil Service by id.

 @param cardId NSString with Virgil Card identifier
 @param callback callback with VSSVirgilCard instance, or NSError instance if error occured
 */
- (void)getCardWithId:(NSString * __nonnull)cardId completion:(void (^ __nonnull)(VSSVirgilCard * __nullable, NSError * __nullable))callback;

/**
 Revokes Virgil Card.
 NOTE: This method revokes only Virgil Cards in application scope, to revoke email card use revokeEmailCard:identity:ownerKey:completion: method.

 @param card VSSVirgilCard to be revoked
 @param callback callback with NSError instance if error occured
 */
- (void)revokeCard:(VSSVirgilCard * __nonnull)card completion:(void (^ __nonnull)(NSError * __nullable))callback NS_SWIFT_NAME(revoke(_:completion:));

/**
 Revokes Virgil Card.
 NOTE: This method revokes only Virgil Cards with identity type = "email" in global scope, to revoke cards in application scope use revokeCard:completion: method.

 @param card VSSVirgilCard to be revoked
 @param identity confirmed VSSEmailIdentity instance which should correpond to VSSVirgilCard identity
 @param ownerKey VSSVirgilKey with Virgil Card owner's key
 @param callback callback with NSError instance if error occured
 */
- (void)revokeEmailCard:(VSSVirgilCard * __nonnull)card identity:(VSSEmailIdentity * __nonnull)identity ownerKey:(VSSVirgilKey * __nonnull)ownerKey completion:(void (^ __nonnull)(NSError * __nullable))callback NS_SWIFT_NAME(revokeEmail(_:identity:ownerKey:completion:));

@end
