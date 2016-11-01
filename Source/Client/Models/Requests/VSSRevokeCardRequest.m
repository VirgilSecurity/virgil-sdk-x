//
//  VSSRevokeCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequestPrivate.h"
#import "VSSRevokeCardRequest.h"
#import "VSSRevokeCardSnapshotModelPrivate.h"

@implementation VSSRevokeCardRequest

+ (instancetype)revokeCardRequestWithCardId:(NSString *)cardId reason:(VSSCardRevocationReason)reason {
    VSSRevokeCardSnapshotModel *model = [[VSSRevokeCardSnapshotModel alloc] initWithCardId:cardId revocationReason:reason];
    return [[VSSRevokeCardRequest alloc] initWithSnapshotModel:model];
}

+ (VSSSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot {
    return [VSSRevokeCardSnapshotModel createFromCanonicalForm:snapshot];
}

@end
