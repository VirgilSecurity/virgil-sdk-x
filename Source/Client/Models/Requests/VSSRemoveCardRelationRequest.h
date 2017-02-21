//
//  VSSRemoveCardRelationRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/21/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequest.h"
#import "VSSModelCommons.h"
#import "VSSRevokeCardSnapshotModel.h"

/**
 Virgil Model used for removal of Virgil Cards Relations.
 See VSSRevokeCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSRemoveCardRelationRequest: VSSSignableRequest<VSSRevokeCardSnapshotModel *>

/**
 Factory method which allocates and initalized VSSRemoveCardRelationRequest instance.
 
 @param cardId Id for card from which relation is removing. See VSSCard
 @param reason Revocation reason. See VSSCardRevocationReason
 
 @return allocated and initialized VSSRemoveCardRelationRequest instance
 */
+ (instancetype __nonnull)removeCardRelationRequestWithCardId:(NSString * __nonnull)cardId reason:(VSSCardRevocationReason)reason;

@end
