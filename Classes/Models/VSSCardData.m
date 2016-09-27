//
//  VSSCardData.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/26/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSCardData.h"
#import "NSObject+VSSUtils.h"
#import "VSSPublicKey.h"
#import "VSSPublicKeyPrivate.h"

@implementation VSSCardData

#pragma mark - Lifecycle

- (instancetype)initWithIdentity:(VSSIdentity *)identity scope:(VSSCardScope)scope publicKey:(VSSPublicKey *)publicKey data:(NSDictionary *)data info:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _identity = [identity copy];
        _scope = scope;
        _publicKey = [publicKey copy];
        _data = [data copy];
        _info = [info copy];
    }
    return self;
}

#pragma mark - VSSSerializable

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    dict[kVSSModelPublicKey] = [self.publicKey getStringValue];
    dict[kVSSModelIdentityType] = self.identity.type;
    dict[kVSSModelIdentity] = self.identity.value;
    dict[kVSSModelCardScope] = vss_getCardScopeString(self.scope);
    
    if (self.data != nil && [self.data count] > 0) {
        dict[kVSSModelData] = self.data;
    }
    
    dict[kVSSModelInfo] = self.info;
    
    return dict;
}

#pragma mark - VSSDeserializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSString * identityTypeStr = [candidate[kVSSModelIdentity] as:[NSString class]];
    NSString * identityValueStr = [candidate[kVSSModelIdentity] as:[NSString class]];
    if (identityTypeStr == nil || [identityTypeStr length] == 0 || identityValueStr == nil || [identityValueStr length] == 0)
        return nil;
    
    VSSIdentity * identity = [[VSSIdentity alloc] initWithType:identityTypeStr value:identityValueStr];
    
    NSString * scopeStr = [candidate[kVSSModelCardScope] as:[NSString class]];
    if (scopeStr == nil || [scopeStr length] == 0)
        return nil;
    
    VSSCardScope scope = vss_getCardScopeFromString(scopeStr);
    
    NSString * publicKeyStr = [candidate[kVSSModelPublicKey] as:[NSString class]];
    if (publicKeyStr == nil && [publicKeyStr length] == 0)
        return nil;
    
    VSSPublicKey * publicKey = [VSSPublicKey initWithStringValue:publicKeyStr];
    
    NSDictionary * data = [candidate[kVSSModelData] as:[NSDictionary class]];
    
    NSDictionary * info = [candidate[kVSSModelInfo] as:[NSDictionary class]];
    
    if (info == nil)
        return nil;
    
    return [[VSSCardData alloc] initWithIdentity:identity scope:scope publicKey:publicKey data:data info:info];
}

#pragma mark - VSSCanonicalRepresentable

+ (instancetype __nullable)createFromCanonicalForm:(NSString * __nonnull)canonicalForm {
    NSData * jsonData = [canonicalForm dataUsingEncoding:NSUTF8StringEncoding];
    NSError * parseError;
    NSObject * candidate = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&parseError];
    
    if (parseError != nil)
        return nil;
    
    if ([candidate isKindOfClass:[NSDictionary class]])
        return [VSSCardData deserializeFrom:(NSDictionary *)candidate];
    
    return nil;
}

- (NSString * __nonnull)getCanonicalForm {
    NSData * JSONData = [NSJSONSerialization dataWithJSONObject:[self serialize] options:0 error:nil];
    NSString * base64EncodedJSONString = [JSONData base64EncodedStringWithOptions:0];
    
    return base64EncodedJSONString;
}

@end
