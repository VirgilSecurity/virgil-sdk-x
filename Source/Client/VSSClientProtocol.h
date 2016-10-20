//
//  VSSClientProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#ifndef VSSClientProtocol_h
#define VSSClientProtocol_h

#import "VSSSearchCardsCriteria.h"
#import "VSSCard.h"
#import "VSSRevokeCard.h"

/**
 * Protocol for all interactions with Virgil Services.
 */
@protocol VSSClient <NSObject>

- (void)registerCard:(VSSCard * __nonnull)card completion:(void (^ __nonnull)(VSSCard * __nullable, NSError * __nullable))callback NS_SWIFT_NAME(register(_:completion:));

- (void)getCardWithId:(NSString * __nonnull)cardId completion:(void (^ __nonnull)(VSSCard * __nullable, NSError * __nullable))callback NS_SWIFT_NAME(getCard(withId:completion:));

/**
 * Performs search of cards only using search criteria on the Virgil Keys Service.
 * The cards array in callback of this method will not return private cards even if type is the same.
 *
 * @param criteria VSSSearchCardsCriteria search criteria.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)searchCardsUsingCriteria:(VSSSearchCardsCriteria * __nonnull)criteria completion:(void (^ __nonnull)(NSArray<VSSCard *>* __nullable, NSError * __nullable))callback NS_SWIFT_NAME(searchCards(using:completion:));

- (void)revokeCard:(VSSRevokeCard * __nonnull)revokeCard completion:(void (^ __nonnull)(NSError * __nullable))callback NS_SWIFT_NAME(revoke(_:completion:));

@end

#endif /* VSSClientProtocol_h */
