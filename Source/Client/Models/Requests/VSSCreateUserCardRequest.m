//
//  VSSCreateUserCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/28/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCreateUserCardRequest.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSCreateCardSnapshotModelPrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCreateUserCardRequest

+ (instancetype)createUserCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data {
    VSSCreateCardSnapshotModel *model = [[VSSCreateCardSnapshotModel alloc] initWithIdentity:identity identityType:identityType scope:VSSCardScopeApplication publicKeyData:publicKeyData data:data info:nil];
    return [[VSSCreateUserCardRequest alloc] initWithSnapshotModel:model];
}

+ (instancetype)createUserCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data device:(NSString *)device deviceName:(NSString *)deviceName {
    NSDictionary *info = @{
                           kVSSCModelDevice: [device copy],
                           kVSSCModelDeviceName: [deviceName copy]
                           };
    
    VSSCreateCardSnapshotModel *model = [[VSSCreateCardSnapshotModel alloc] initWithIdentity:identity identityType:identityType scope:VSSCardScopeApplication publicKeyData:publicKeyData data:data info:info];
    
    return [[VSSCreateUserCardRequest alloc] initWithSnapshotModel:model];
}

+ (instancetype)createUserCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData {
    return [VSSCreateUserCardRequest createUserCardRequestWithIdentity:identity identityType:identityType publicKeyData:publicKeyData data:nil];
}

@end
