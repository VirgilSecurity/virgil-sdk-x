//
//  VSSCreateCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCreateCardRequest.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSCreateCardSnapshotModelPrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCreateCardRequest

+ (instancetype)createCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKey:(NSData *)publicKey data:(NSDictionary<NSString *, NSString *> *)data {
    VSSCreateCardSnapshotModel *model = [VSSCreateCardSnapshotModel createCardSnapshotModelWithIdentity:identity identityType:identityType publicKey:publicKey data:data];
    return [[VSSCreateCardRequest alloc] initWithSnapshotModel:model];
}

+ (instancetype)createCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKey:(NSData *)publicKey {
    return [VSSCreateCardRequest createCardRequestWithIdentity:identity identityType:identityType publicKey:publicKey data:nil];
}

+ (VSSSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot {
    return [VSSCreateCardSnapshotModel createFromCanonicalForm:snapshot];
}

@end
