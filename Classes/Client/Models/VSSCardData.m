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

@implementation VSSCardData

#pragma mark - Lifecycle

- (instancetype)initWithIdentity:(NSString *)identity identityType:(NSString *)identityType scope:(VSSCardScope)scope publicKey:(NSData *)publicKey data:(NSDictionary *)data info:(NSDictionary *)info {
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

+ (instancetype)createWithIdentity:(NSString *)identity identityType:(NSString *)identityType scope:(VSSCardScope)scope publicKey:(NSData *)publicKey data:(NSDictionary *)data {
#warning fixme
    NSDictionary *info = [[NSDictionary alloc] init];
    
    return [[VSSCardData alloc] initWithIdentity:identity identityType:identityType scope:scope publicKey:publicKey data:data info:info];
}

+ (instancetype)createWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKey:(NSData *)publicKey data:(NSDictionary *)data {
    return [VSSCardData createWithIdentity:identity identityType:identityType scope:VSSCardScopeApplication publicKey:publicKey data:data];
}

+ (instancetype)createWithIdentity:(NSString *)identity identityType:(NSString *)identityType publicKey:(NSData *)publicKey {
    return [VSSCardData createWithIdentity:identity identityType:identityType publicKey:publicKey data:nil];
}

+ (instancetype)createGlobalWithIdentity:(NSString *)identity publicKey:(NSData *)publicKey {
    return [VSSCardData createGlobalWithIdentity:identity publicKey:publicKey data:nil];
}

+ (instancetype)createGlobalWithIdentity:(NSString *)identity publicKey:(NSData *)publicKey data:(NSDictionary *)data {
    return [VSSCardData createWithIdentity:identity identityType:kVSSIdentityTypeEmail scope:VSSCardScopeGlobal publicKey:publicKey data:data];
}

#pragma mark - VSSSerializable

- (NSDictionary *)serialize {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    dict[kVSSModelPublicKey] = [self.publicKey base64EncodedStringWithOptions:0];
    dict[kVSSModelIdentityType] = self.identityType;
    dict[kVSSModelIdentity] = self.identity;
    dict[kVSSModelCardScope] = vss_getCardScopeString(self.scope);
    
    if (self.data != nil && [self.data count] > 0) {
        dict[kVSSModelData] = self.data;
    }
    
    dict[kVSSModelInfo] = self.info;
    
    return dict;
}

#pragma mark - VSSDeserializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSString *identityTypeStr = [candidate[kVSSModelIdentity] as:[NSString class]];
    NSString *identityValueStr = [candidate[kVSSModelIdentity] as:[NSString class]];
    if (identityTypeStr == nil || [identityTypeStr length] == 0 || identityValueStr == nil || [identityValueStr length] == 0)
        return nil;
    
    NSString * scopeStr = [candidate[kVSSModelCardScope] as:[NSString class]];
    if (scopeStr == nil || [scopeStr length] == 0)
        return nil;
    
    VSSCardScope scope = vss_getCardScopeFromString(scopeStr);
    
    NSString * publicKeyStr = [candidate[kVSSModelPublicKey] as:[NSString class]];
    if (publicKeyStr == nil && [publicKeyStr length] == 0)
        return nil;
    
    NSData *publicKey = [[NSData alloc]initWithBase64EncodedString:publicKeyStr options:0];
    
    NSDictionary *data = [candidate[kVSSModelData] as:[NSDictionary class]];
    NSDictionary *info = [candidate[kVSSModelInfo] as:[NSDictionary class]];
    
    if (info == nil)
        return nil;
    
    return [[VSSCardData alloc] initWithIdentity:identityValueStr identityType:identityTypeStr scope:scope publicKey:publicKey data:data info:info];
}

#pragma mark - VSSCanonicalRepresentable

+ (instancetype)createFromCanonicalForm:(NSData *)canonicalForm {
    if (canonicalForm == nil || [canonicalForm length] == 0)
        return nil;
    
    NSError *parseError;
    NSObject *candidate = [NSJSONSerialization JSONObjectWithData:canonicalForm options:NSJSONReadingAllowFragments error:&parseError];
    
    if (parseError != nil)
        return nil;
    
    if ([candidate isKindOfClass:[NSDictionary class]]) {
        return [VSSCardData deserializeFrom:(NSDictionary *)candidate];
    }
    
    return nil;
}

- (NSData *)getCanonicalForm {
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:[self serialize] options:0 error:nil];
    
    return JSONData;
}

@end
