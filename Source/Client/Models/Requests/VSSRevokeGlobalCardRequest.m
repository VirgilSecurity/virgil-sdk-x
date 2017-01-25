//
//  VSSRevokeGlobalCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/25/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeGlobalCardRequest.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSRevokeCardSnapshotModelPrivate.h"

@implementation VSSRevokeGlobalCardRequest

+ (instancetype)revokeCardRequestWithCardId:(NSString *)cardId reason:(VSSCardRevocationReason)reason {
    VSSRevokeCardSnapshotModel *model = [[VSSRevokeCardSnapshotModel alloc] initWithCardId:cardId revocationReason:reason];
    return [[VSSRevokeGlobalCardRequest alloc] initWithSnapshotModel:model];
}

@end

