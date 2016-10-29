//
//  VSSRevokeCardSnapshotModel.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/7/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSnapshotModel.h"
#import "VSSModelCommons.h"

/**
 Virgil Model that contains all info needed for Virgil Card revocation. See VSSRevokeCardRequest.
 */
@interface VSSRevokeCardSnapshotModel : VSSSnapshotModel

/**
 Virgil Card unique identifier. See VSSCard
 */
@property (nonatomic, copy, readonly) NSString * __nonnull cardId;

/**
 Revocation reason. See VSSCardRevocationReason
 */
@property (nonatomic, readonly) VSSCardRevocationReason revocationReason;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
