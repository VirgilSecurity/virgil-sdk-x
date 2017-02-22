//
//  VSSSignedCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/20/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSignedCardRequest.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSCreateCardSnapshotModelPrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSSignedCardRequest

+ (instancetype)signedCardRequestWithSnapshotModel:(VSSCreateCardSnapshotModel *)snapshotModel {
    return [[VSSSignedCardRequest alloc] initWithSnapshotModel:snapshotModel];
}

+ (VSSSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot {
    return [VSSCreateCardSnapshotModel createFromCanonicalForm:snapshot];
}

- (BOOL)addSignature:(NSData *)signature forFingerprint:(NSString *)fingerprint {
    if (self.signatures.count != 0) {
        return NO;
    }
    
    return [super addSignature:signature forFingerprint:fingerprint];
}

@end
