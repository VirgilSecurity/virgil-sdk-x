//
//  VSSRevokeGlobalCardRequestPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/8/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequestPrivate.h"
#import "VSSRevokeGlobalCardRequest.h"

@interface VSSCreateGlobalCardRequest ()

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot snapshotModel:(VSSRevokeCardSnapshotModel * __nonnull)model signatures:(NSDictionary<NSString *, NSData *> * __nullable)signatures NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot signatures:(NSDictionary<NSString *,NSData *> * __nullable)signatures NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshotModel:(VSSRevokeCardSnapshotModel * __nonnull)model signatures:(NSDictionary<NSString *,NSData *> * __nullable)signatures NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot snapshotModel:(VSSRevokeCardSnapshotModel * __nonnull)model NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshotModel:(VSSRevokeCardSnapshotModel * __nonnull)model NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshotModel:(VSSRevokeCardSnapshotModel * __nonnull)model validationToken:(NSString * __nonnull)validationToken;

+ (VSSRevokeCardSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot;

@end
