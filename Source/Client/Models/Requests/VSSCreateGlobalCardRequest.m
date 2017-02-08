//
//  VSSCreateGlobalCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/24/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModelKeys.h"
#import "VSSCreateGlobalCardRequestPrivate.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSCreateCardSnapshotModelPrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSCreateGlobalCardRequest

+ (instancetype)createGlobalCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType validationToken:(NSString *)validationToken publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data {
    VSSCreateCardSnapshotModel *model = [[VSSCreateCardSnapshotModel alloc] initWithIdentity:identity identityType:identityType scope:VSSCardScopeGlobal publicKeyData:publicKeyData data:data info:nil];
    return [[VSSCreateGlobalCardRequest alloc] initWithSnapshotModel:model validationToken:validationToken];
}

+ (instancetype)createGlobalCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType validationToken:(NSString *)validationToken publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data device:(NSString *)device deviceName:(NSString *)deviceName {
    NSDictionary *info = @{
        kVSSCModelDevice: [device copy],
        kVSSCModelDeviceName: [deviceName copy]
    };
    
    VSSCreateCardSnapshotModel *model = [[VSSCreateCardSnapshotModel alloc] initWithIdentity:identity identityType:identityType scope:VSSCardScopeGlobal publicKeyData:publicKeyData data:data info:info];
    
    return [[VSSCreateGlobalCardRequest alloc] initWithSnapshotModel:model validationToken:validationToken];
}

+ (instancetype)createGlobalCardRequestWithIdentity:(NSString *)identity identityType:(NSString *)identityType validationToken:(NSString *)validationToken publicKeyData:(NSData *)publicKeyData {
    return [VSSCreateGlobalCardRequest createGlobalCardRequestWithIdentity:identity identityType:identityType validationToken:validationToken publicKeyData:publicKeyData data:nil];
}

+ (VSSCreateCardSnapshotModel * __nullable)buildSnapshotModelFromSnapshot:(NSData * __nonnull)snapshot {
    return [VSSCreateCardSnapshotModel createFromCanonicalForm:snapshot];
}

- (instancetype)initWithSnapshot:(NSData *)snapshot snapshotModel:(VSSCreateCardSnapshotModel *)model signatures:(NSDictionary<NSString *, NSData *> *)signatures validationToken:(NSString *)validationToken {
    self = [super initWithSnapshot:snapshot snapshotModel:model signatures:signatures];
    if (self) {
        _validationToken = [validationToken copy];
    }
    
    return self;
}

- (instancetype)initWithSnapshotModel:(VSSCreateCardSnapshotModel *)model signatures:(NSDictionary<NSString *,NSData *> *)signatures validationToken:(NSString *)validationToken {
    NSData *snapshot = [model getCanonicalForm];
    return [self initWithSnapshot:snapshot snapshotModel:model signatures:signatures validationToken:validationToken];
}

- (instancetype)initWithSnapshotModel:(VSSCreateCardSnapshotModel *)model validationToken:(NSString *)validationToken {
    return [self initWithSnapshotModel:model signatures:nil validationToken:validationToken];
}

- (NSDictionary *)serialize {
    NSMutableDictionary *dict = (NSMutableDictionary *)[super serialize];
    
    NSMutableDictionary *metaDict = dict[kVSSCModelMeta];
    metaDict[kVSSCModelValidation] = @{
        kVSSCModelToken: self.validationToken
    };
    
    return dict;
}

- (instancetype)initWithDict:(NSDictionary *)candidate {
    self = [super initWithDict:candidate];
    
    if (self) {
        NSDictionary *metaDict = [candidate[kVSSCModelMeta] as:[NSDictionary class]];
        NSString *validationToken = [metaDict[kVSSCModelMeta][kVSSCModelValidation][kVSSCModelToken] as:[NSString class]];
        
        if (validationToken.length == 0)
            return nil;
        
        _validationToken = [validationToken copy];
    }
    
    return self;
}

@end
