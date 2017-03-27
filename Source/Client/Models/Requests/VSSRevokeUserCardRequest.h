//
//  VSSRevokeUserCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/28/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCardRequest.h"
#import "VSSModelCommons.h"
#import "VSSRevokeCardSnapshotModel.h"

/**
 Virgil Model used for revocation of Virgil Cards in application scope.
 See VSSRevokeCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSRevokeUserCardRequest: VSSRevokeCardRequest

/**
 Factory method which allocates and initalized VSSRevokeCardRequest instance.
 
 @param cardId Virgil Card unique id. See VSSCard
 @param reason Revocation reason. See VSSCardRevocationReason
 
 @return allocated and initialized VSSRevokeCardRequest instance
 */
+ (instancetype __nonnull)revokeUserCardRequestWithCardId:(NSString * __nonnull)cardId reason:(VSSCardRevocationReason)reason;

@end
