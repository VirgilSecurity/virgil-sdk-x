//
//  VSSRevokeApplicationRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/28/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequestPrivate.h"
#import "VSSRevokeApplicationCardRequest.h"
#import "VSSRevokeCardSnapshotModelPrivate.h"

@implementation VSSRevokeApplicationCardRequest

+ (instancetype)revokeApplicationCardRequestWithCardId:(NSString *)cardId reason:(VSSCardRevocationReason)reason {
    VSSRevokeCardSnapshotModel *model = [[VSSRevokeCardSnapshotModel alloc] initWithCardId:cardId revocationReason:reason];
    return [[VSSRevokeApplicationCardRequest alloc] initWithSnapshotModel:model];
}

@end
