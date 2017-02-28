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

@end
