//
//  VSSCreateGlobalCardRequestPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/8/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequestPrivate.h"
#import "VSSCreateGlobalCardRequest.h"

@interface VSSCreateGlobalCardRequest ()

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot snapshotModel:(VSSCreateCardSnapshotModel * __nonnull)model signatures:(NSDictionary<NSString *, NSData *> * __nullable)signatures NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot signatures:(NSDictionary<NSString *,NSData *> * __nullable)signatures NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshotModel:(VSSCreateCardSnapshotModel * __nonnull)model signatures:(NSDictionary<NSString *,NSData *> * __nullable)signatures NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot snapshotModel:(VSSCreateCardSnapshotModel * __nonnull)model NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshotModel:(VSSCreateCardSnapshotModel * __nonnull)model NS_UNAVAILABLE;

- (instancetype __nonnull)initWithSnapshot:(NSData * __nonnull)snapshot snapshotModel:(VSSCreateCardSnapshotModel * __nonnull)model signatures:(NSDictionary<NSString *, NSData *> * __nullable)signatures validationToken:(NSString * __nonnull)validationToken;

- (instancetype __nonnull)initWithSnapshotModel:(VSSCreateCardSnapshotModel * __nonnull)model signatures:(NSDictionary<NSString *,NSData *> * __nullable)signatures validationToken:(NSString * __nonnull)validationToken;

- (instancetype __nonnull)initWithSnapshotModel:(VSSCreateCardSnapshotModel * __nonnull)model validationToken:(NSString * __nonnull)validationToken;

+ (VSSCreateCardSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot;

@end
