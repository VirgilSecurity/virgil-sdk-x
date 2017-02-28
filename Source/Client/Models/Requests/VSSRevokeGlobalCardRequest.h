//
//  VSSRevokeGlobalCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/25/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeCardRequest.h"
#import "VSSModelCommons.h"
#import "VSSRevokeCardSnapshotModel.h"

/**
 Virgil Model used for revocation of Global Virgil Cards.
 See VSSRevokeCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSRevokeGlobalCardRequest : VSSRevokeCardRequest

/**
 Validation token obtained from Virgil Authority Service.
 */
@property (nonatomic, copy, readonly) NSString * __nonnull validationToken;

/**
 Factory method which allocates and initalized VSSRevokeCardRequest instance.
 
 @param cardId Virgil Card unique id. See VSSCard
 @param reason Revocation reason. See VSSCardRevocationReason
 
 @return allocated and initialized VSSRevokeCardRequest instance
 */
+ (instancetype __nonnull)revokeGlobalCardRequestWithCardId:(NSString * __nonnull)cardId validationToken:(NSString * __nonnull)validationToken reason:(VSSCardRevocationReason)reason;

@end
