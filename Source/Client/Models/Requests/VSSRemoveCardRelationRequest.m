//
//  VSSRemoveCardRelationRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/21/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSSignableRequestPrivate.h"
#import "VSSRemoveCardRelationRequest.h"
#import "VSSRevokeCardSnapshotModelPrivate.h"

@implementation VSSRemoveCardRelationRequest

+ (instancetype)removeCardRelationRequestWithCardId:(NSString *)cardId reason:(VSSCardRevocationReason)reason {
    VSSRevokeCardSnapshotModel *model = [[VSSRevokeCardSnapshotModel alloc] initWithCardId:cardId revocationReason:reason];
    return [[VSSRemoveCardRelationRequest alloc] initWithSnapshotModel:model];
}

+ (VSSSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot {
    return [VSSRevokeCardSnapshotModel createFromCanonicalForm:snapshot];
}

- (BOOL)addSignature:(NSData *)signature forFingerprint:(NSString *)fingerprint {
    if (self.signatures.count != 0) {
        return NO;
    }
    
    return [super addSignature:signature forFingerprint:fingerprint];
}

@end
