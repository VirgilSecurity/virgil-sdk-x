//
//  VSSSignedCardRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequest.h"
#import "VSSCreateCardSnapshotModel.h"

/**
 Virgil Model representing request for Virgil Card Relation creation.
 See VSSSignableRequest, VSSCreateCardSnapshotModel. See VSSClient protocol.
 */
@interface VSSSignedCardRequest: VSSSignableRequest<VSSCreateCardSnapshotModel *>

/**
 Factory method which allocates and initalizes VSSSignedCardRequest instance.

 @param snapshotModel snapshotModel can be obtained from VSSCard using card.response.model getter
 @return allocated and initialized VSSSignedCardRequest instance
 */
+ (instancetype __nonnull)signedCardRequestWithSnapshotModel:(VSSCreateCardSnapshotModel * __nonnull)snapshotModel;

/**
 Overriden function. VSSSignedCardRequest must contain only one signature.

 @param signature NSData with Signature
 @param fingerprint NSString which identifies Signature
 */
- (BOOL)addSignature:(NSData * __nonnull)signature forFingerprint:(NSString * __nonnull)fingerprint;

@end
