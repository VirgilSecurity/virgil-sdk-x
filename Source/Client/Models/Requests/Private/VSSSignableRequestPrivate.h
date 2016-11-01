//
//  VSSSignableRequestPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequest.h"
#import "VSSSnapshotModelPrivate.h"
#import "VSSSerializable.h"
#import "VSSDeserializable.h"

@interface VSSSignableRequest<__covariant SnapshotType: VSSSnapshotModel *> () <VSSSerializable, VSSDeserializable>

+ (VSSSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot snapshotModel:(SnapshotType __nonnull)model signatures:(NSDictionary<NSString *, NSData *> * __nullable)signatures;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot signatures:(NSDictionary<NSString *,NSData *> * __nullable)signatures;

- (instancetype __nonnull)initWithSnapshotModel:(SnapshotType __nonnull)model signatures:(NSDictionary<NSString *,NSData *> * __nullable)signatures;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot snapshotModel:(SnapshotType __nonnull)model;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot;

- (instancetype __nonnull)initWithSnapshotModel:(SnapshotType __nonnull)model;

@end
