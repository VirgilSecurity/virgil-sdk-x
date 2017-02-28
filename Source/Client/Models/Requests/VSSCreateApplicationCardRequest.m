//
//  VSSCreateApplicationCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/28/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCreateApplicationCardRequest.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSCreateCardSnapshotModelPrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCreateApplicationCardRequest

+ (instancetype)createApplicationCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data {
    VSSCreateCardSnapshotModel *model = [[VSSCreateCardSnapshotModel alloc] initWithIdentity:identity identityType:identityType scope:VSSCardScopeApplication publicKeyData:publicKeyData data:data info:nil];
    return [[VSSCreateApplicationCardRequest alloc] initWithSnapshotModel:model];
}

+ (instancetype)createApplicationCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data device:(NSString *)device deviceName:(NSString *)deviceName {
    NSDictionary *info = @{
                           kVSSCModelDevice: [device copy],
                           kVSSCModelDeviceName: [deviceName copy]
                           };
    
    VSSCreateCardSnapshotModel *model = [[VSSCreateCardSnapshotModel alloc] initWithIdentity:identity identityType:identityType scope:VSSCardScopeApplication publicKeyData:publicKeyData data:data info:info];
    
    return [[VSSCreateApplicationCardRequest alloc] initWithSnapshotModel:model];
}

+ (instancetype)createApplicationCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData {
    return [VSSCreateApplicationCardRequest createApplicationCardRequestWithIdentity:identity identityType:identityType publicKeyData:publicKeyData data:nil];
}

@end
