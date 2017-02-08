//
//  VSSCreateGlobalCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/24/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModelKeys.h"
#import "VSSCreateGlobalCardRequest.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSCreateCardSnapshotModelPrivate.h"

@implementation VSSCreateGlobalCardRequest

+ (instancetype)createGlobalCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data {
    VSSCreateCardSnapshotModel *model = [[VSSCreateCardSnapshotModel alloc] initWithIdentity:identity identityType:identityType scope:VSSCardScopeGlobal publicKeyData:publicKeyData data:data info:nil];
    return [[VSSCreateGlobalCardRequest alloc] initWithSnapshotModel:model];
}

+ (instancetype)createGlobalCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data device:(NSString *)device deviceName:(NSString *)deviceName {
    NSDictionary *info = @{
        kVSSCModelDevice: [device copy],
        kVSSCModelDeviceName: [deviceName copy]
    };
    
    VSSCreateCardSnapshotModel *model = [[VSSCreateCardSnapshotModel alloc] initWithIdentity:identity identityType:identityType scope:VSSCardScopeGlobal publicKeyData:publicKeyData data:data info:info];
    
    return [[VSSCreateGlobalCardRequest alloc] initWithSnapshotModel:model];
}

+ (instancetype)createGlobalCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData {
    return [VSSCreateGlobalCardRequest createGlobalCardRequestWithIdentity:identity identityType:identityType publicKeyData:publicKeyData data:nil];
}

+ (VSSSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot {
    return [VSSCreateCardSnapshotModel createFromCanonicalForm:snapshot];
}

@end
