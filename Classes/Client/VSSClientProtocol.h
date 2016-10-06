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
#import "VSSCardData.h"
#import "VSSCardModel.h"

/**
 * Protocol for all interactions with Virgil Services.
 */
@protocol VSSClient <NSObject>

/**
 * Performs search of cards only using search criteria on the Virgil Keys Service.
 * The cards array in callback of this method will not return private cards even if type is the same.
 *
 * @param criteria VSSSearchCardsCriteria search criteria.
 * @param completionHandler Callback handler which will be called after request completed.
 */
- (void)searchCardsUsingCriteria:(VSSSearchCardsCriteria * __nonnull)criteria completion:(void (^ __nonnull)(NSArray<VSSCardModel *>* __nullable, NSError * __nullable))callback;

- (void)createCardWithModel:(VSSCardModel * __nonnull)model completion:(void (^ __nonnull)(VSSCardModel * __nullable, NSError * __nullable))callback;

//- (void)beginGlobalCardCreationWithRequest:(VSSCreationRequest * __nonnull)request completion:(void (^ __nonnull)(VSSCreationRequest * __nullable, NSError * __nullable))callback;

//- (void)completeGlobalCardCreationWithDetails:(VSSRegistrationDetails * __nonnull)details andConfirmation: (NSString * __nonnull)string completion:(void (^ __nonnull)())callback;

//- (void)revokeCardWithRequest:(VSSRevocationRequest * __nonnull)request completion:(void (^ __nonnull)())callback;

//- (void)getCardWithId:(NSString * __nonnull)cardId completion:(void (^ __nonnull)())callback;

@end

#endif /* VSSClientProtocol_h */
