//
//  VSSCreateCardSnapshotModel.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/26/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "NSObject+VSSUtils.h"
#import "VSSModelKeys.h"
#import "VSSModelCommonsPrivate.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSCreateCardSnapshotModelPrivate.h"
#import "VSSDeviceManager.h"

@implementation VSSCreateCardSnapshotModel

#pragma mark - Lifecycle

- (instancetype)initWithIdentity:(NSString *)identity identityType:(NSString *)identityType scope:(VSSCardScope)scope publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data info:(NSDictionary<NSString *, NSString *> *)info {
    self = [super init];
    if (self) {
        _identity = [identity copy];
        _identityType = [identityType copy];
        _scope = scope;
        _publicKeyData = [publicKeyData copy];
        if (data != nil)
            _data = [[NSDictionary alloc] initWithDictionary:data copyItems:YES];
        if (info != nil)
            _info = [[NSDictionary alloc] initWithDictionary:info copyItems:YES];
    }
    
    return self;
}

+ (instancetype)createCardSnapshotModelWithIdentity:(NSString *)identity identityType:(NSString *)identityType scope:(VSSCardScope)scope publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data {

    id<VSSDeviceManager> deviceManager = [[VSSDeviceManager alloc] init];
    
    NSDictionary *info = @{
        kVSSCModelDevice: [deviceManager getDeviceModel],
        kVSSCModelDeviceName: [deviceManager getDeviceName]
    };
    
    return [[VSSCreateCardSnapshotModel alloc] initWithIdentity:identity identityType:identityType scope:scope publicKeyData:publicKeyData data:data info:info];
}

+ (instancetype)createCardSnapshotModelWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData data:(NSDictionary<NSString *, NSString *> *)data {
    return [VSSCreateCardSnapshotModel createCardSnapshotModelWithIdentity:identity identityType:identityType scope:VSSCardScopeApplication publicKeyData:publicKeyData data:data];
}

+ (instancetype)createCardSnapshotModelWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKeyData:(NSData *)publicKeyData {
    return [VSSCreateCardSnapshotModel createCardSnapshotModelWithIdentity:identity identityType:identityType publicKeyData:publicKeyData data:nil];
}

#pragma mark - VSSSerializable

- (NSDictionary *)serialize {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    dict[kVSSCModelPublicKey] = [self.publicKeyData base64EncodedStringWithOptions:0];
    dict[kVSSCModelIdentityType] = [self.identityType copy];
    dict[kVSSCModelIdentity] = [self.identity copy];
    dict[kVSSCModelCardScope] = vss_getCardScopeString(self.scope);
    
    if (self.data.count > 0) {
        dict[kVSSCModelData] = [self.data copy];
    }
    
    dict[kVSSCModelInfo] = [self.info copy];
    
    return dict;
}

#pragma mark - VSSDeserializable

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *identityTypeStr = [candidate[kVSSCModelIdentityType] as:[NSString class]];
    NSString *identityValueStr = [candidate[kVSSCModelIdentity] as:[NSString class]];
    if (identityTypeStr.length == 0 || identityValueStr.length == 0)
        return nil;
    
    NSString * scopeStr = [candidate[kVSSCModelCardScope] as:[NSString class]];
    if (scopeStr.length == 0)
        return nil;
    
    VSSCardScope scope = vss_getCardScopeFromString(scopeStr);
    
    NSString * publicKeyStr = [candidate[kVSSCModelPublicKey] as:[NSString class]];
    if (publicKeyStr.length == 0)
        return nil;
    
    NSData *publicKeyData = [[NSData alloc]initWithBase64EncodedString:publicKeyStr options:0];
    
    NSDictionary *data = [candidate[kVSSCModelData] as:[NSDictionary class]];
    NSDictionary *info = [candidate[kVSSCModelInfo] as:[NSDictionary class]];
    
    return [self initWithIdentity:identityValueStr identityType:identityTypeStr scope:scope publicKeyData:publicKeyData data:data info:info];
}

#pragma mark - VSSCanonicalRepresentable

+ (instancetype)createFromCanonicalForm:(NSData *)canonicalForm {
    if (canonicalForm.length == 0)
        return nil;
    
    NSError *parseError;
    NSObject *candidate = [NSJSONSerialization JSONObjectWithData:canonicalForm options:NSJSONReadingAllowFragments error:&parseError];
    
    if (parseError != nil)
        return nil;
    
    if ([candidate isKindOfClass:[NSDictionary class]]) {
        return [[VSSCreateCardSnapshotModel alloc] initWithDict:(NSDictionary *)candidate];
    }
    
    return nil;
}

- (NSData *)getCanonicalForm {
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:[self serialize] options:0 error:nil];
    
    return JSONData;
}

@end
