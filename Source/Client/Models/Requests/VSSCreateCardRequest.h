//
//  VSSCreateCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequest.h"
#import "VSSCreateCardSnapshotModel.h"

/**
 Virgil Model representing request for Virgil Card creation.
 See VSSSignableRequest, VSSCreateCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSCreateCardRequest: VSSSignableRequest<VSSCreateCardSnapshotModel *>

@end
