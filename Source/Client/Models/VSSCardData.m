//
//  VSSCardData.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/26/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "NSObject+VSSUtils.h"
#import "VSSModelKeys.h"
#import "VSSModelCommonsPrivate.h"
#import "VSSSignedData.h"
#import "VSSSignedDataPrivate.h"
#import "VSSCardData.h"
#import "VSSCardDataPrivate.h"
#import "VSSDeviceInfoUtils.h"

@implementation VSSCardData

#pragma mark - Lifecycle

- (instancetype)initWithIdentity:(NSString *)identity identityType:(NSString *)identityType scope:(VSSCardScope)scope publicKey:(NSData *)publicKey data:(NSDictionary<NSString *, NSString *> *)data info:(NSDictionary<NSString *, NSString *> *)info {
    self = [super init];
    if (self) {
        _identity = [identity copy];
        _identityType = [identityType copy];
        _scope = scope;
        _publicKey = [publicKey copy];
        _data = [data copy];
        _info = [info copy];
    }
    
    return self;
}

+ (instancetype)cardDataWithIdentity:(NSString *)identity identityType:(NSString *)identityType scope:(VSSCardScope)scope publicKey:(NSData *)publicKey data:(NSDictionary<NSString *, NSString *> *)data {

    NSDictionary *info = @{
        kVSSModelDevice: [VSSDeviceInfoUtils getDeviceModel],
        kVSSModelDeviceName: [VSSDeviceInfoUtils getDeviceName]
    };
    
    return [[VSSCardData alloc] initWithIdentity:identity identityType:identityType scope:scope publicKey:publicKey data:data info:info];
}

+ (instancetype)cardDataWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKey:(NSData *)publicKey data:(NSDictionary<NSString *, NSString *> *)data {
    return [VSSCardData cardDataWithIdentity:identity identityType:identityType scope:VSSCardScopeApplication publicKey:publicKey data:data];
}

+ (instancetype)cardDataWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKey:(NSData *)publicKey {
    return [VSSCardData cardDataWithIdentity:identity identityType:identityType publicKey:publicKey data:nil];
}

//+ (instancetype)cardDataGlobalWithIdentity:(NSString *)identity publicKey:(NSData *)publicKey {
//    return [VSSCardData cardDataGlobalWithIdentity:identity publicKey:publicKey data:nil];
//}
//
//+ (instancetype)cardDataGlobalWithIdentity:(NSString *)identity publicKey:(NSData *)publicKey data:(NSDictionary<NSString *, NSString *> *)data {
//    return [VSSCardData cardDataWithIdentity:identity identityType:kVSSIdentityTypeEmail scope:VSSCardScopeGlobal publicKey:publicKey data:data];
//}

#pragma mark - VSSSerializable

- (NSDictionary *)serialize {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    dict[kVSSModelPublicKey] = [self.publicKey base64EncodedStringWithOptions:0];
    dict[kVSSModelIdentityType] = [self.identityType copy];
    dict[kVSSModelIdentity] = [self.identity copy];
    dict[kVSSModelCardScope] = vss_getCardScopeString(self.scope);
    
    if (self.data.count > 0) {
        dict[kVSSModelData] = [self.data copy];
    }
    
    dict[kVSSModelInfo] = [self.info copy];
    
    return dict;
}

#pragma mark - VSSDeserializable

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *identityTypeStr = [candidate[kVSSModelIdentityType] as:[NSString class]];
    NSString *identityValueStr = [candidate[kVSSModelIdentity] as:[NSString class]];
    if (identityTypeStr.length == 0 || identityValueStr.length == 0)
        return nil;
    
    NSString * scopeStr = [candidate[kVSSModelCardScope] as:[NSString class]];
    if (scopeStr.length == 0)
        return nil;
    
    VSSCardScope scope = vss_getCardScopeFromString(scopeStr);
    
    NSString * publicKeyStr = [candidate[kVSSModelPublicKey] as:[NSString class]];
    if (publicKeyStr.length == 0)
        return nil;
    
    NSData *publicKey = [[NSData alloc]initWithBase64EncodedString:publicKeyStr options:0];
    
    NSDictionary *data = [candidate[kVSSModelData] as:[NSDictionary class]];
    NSDictionary *info = [candidate[kVSSModelInfo] as:[NSDictionary class]];
    
    return [self initWithIdentity:identityValueStr identityType:identityTypeStr scope:scope publicKey:publicKey data:data info:info];
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
        return [[VSSCardData alloc]initWithDict:(NSDictionary *)candidate];
    }
    
    return nil;
}

- (NSData *)getCanonicalForm {
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:[self serialize] options:0 error:nil];
    
    return JSONData;
}

@end
