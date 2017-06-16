//
//  VSSSignableRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSImportable.h"
#import "VSSExportable.h"
#import "VSSSnapshotModel.h"
#import "VSSSignable.h"
#import "VSSSerializable.h"
#import "VSSDeserializable.h"

/**
 Base class for all Virgil Models that can be Signed, Imported and Exported.
 See VSSBaseModel, VSSImportable, VSSExportable, VSSSignable, VSSSnapshotModel.
 */
@interface VSSSignableRequest<__covariant SnapshotType: VSSSnapshotModel *> : VSSBaseModel <VSSImportable, VSSExportable, VSSSignable, VSSSerializable, VSSDeserializable>

/**
 NSDictionary with NSString Key representing Signature id and NSData Value with Signature.
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSData *> * __nonnull signatures;

/**
 NSData with Snapshot - raw serialized representation of payload (VSSCard/VSSRevokeCard) which remains unchanged from the moment of creation
 */
@property (nonatomic, copy, readonly) NSData * __nonnull snapshot;

/**
 Deserialized in appropriate model snapshot. See VSSSnapshotModel
 */
@property (nonatomic, copy, readonly) SnapshotType __nonnull snapshotModel;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshotModel:(SnapshotType __nonnull)model;

/**
 Adds signature to data.

 @param signature   NSData with Signature
 @param fingerprint NSString which identifies Signature
 */
- (BOOL)addSignature:(NSData * __nonnull)signature forFingerprint:(NSString * __nonnull)fingerprint;

@end
