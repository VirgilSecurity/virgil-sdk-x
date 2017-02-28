//
//  VSSRevokeApplicationCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/28/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCardRequest.h"
#import "VSSModelCommons.h"
#import "VSSRevokeCardSnapshotModel.h"

/**
 Virgil Model used for revocation of Virgil Cards.
 See VSSRevokeCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSRevokeApplicationCardRequest: VSSRevokeCardRequest

/**
 Factory method which allocates and initalized VSSRevokeCardRequest instance.
 
 @param cardId Virgil Card unique id. See VSSCard
 @param reason Revocation reason. See VSSCardRevocationReason
 
 @return allocated and initialized VSSRevokeCardRequest instance
 */
+ (instancetype __nonnull)revokeApplicationCardRequestWithCardId:(NSString * __nonnull)cardId reason:(VSSCardRevocationReason)reason;

@end
