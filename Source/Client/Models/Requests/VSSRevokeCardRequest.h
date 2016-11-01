//
//  VSSRevokeCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequest.h"
#import "VSSModelCommons.h"
#import "VSSRevokeCardSnapshotModel.h"

/**
 Virgil Model used for revocation of Virgil Cards.
 See VSSRevokeCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSRevokeCardRequest: VSSSignableRequest<VSSRevokeCardSnapshotModel *>

/**
 Factory method which allocates and initalized VSSRevokeCardRequest instance.
 
 @param cardId Virgil Card unique id. See VSSCard
 @param reason Revocation reason. See VSSCardRevocationReason

 @return allocated and initialized VSSRevokeCardRequest instance
 */
+ (instancetype __nonnull)revokeCardRequestWithCardId:(NSString * __nonnull)cardId reason:(VSSCardRevocationReason)reason;

@end
