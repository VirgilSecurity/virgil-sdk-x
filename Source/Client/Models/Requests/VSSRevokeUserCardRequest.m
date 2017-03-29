//
//  VSSRevokeUserCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/28/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequestPrivate.h"
#import "VSSRevokeUserCardRequest.h"
#import "VSSRevokeCardSnapshotModelPrivate.h"

@implementation VSSRevokeUserCardRequest

+ (instancetype)revokeUserCardRequestWithCardId:(NSString *)cardId reason:(VSSCardRevocationReason)reason {
    VSSRevokeCardSnapshotModel *model = [[VSSRevokeCardSnapshotModel alloc] initWithCardId:cardId revocationReason:reason];
    return [[VSSRevokeUserCardRequest alloc] initWithSnapshotModel:model];
}

@end
