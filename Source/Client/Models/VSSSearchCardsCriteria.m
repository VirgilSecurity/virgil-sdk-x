//
//  VSSSearchCardsCriteria.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSearchCardsCriteriaPrivate.h"
#import "NSObject+VSSUtils.h"
#import "VSSModelKeys.h"
#import "VSSModelCommonsPrivate.h"

@implementation VSSSearchCardsCriteria

+ (instancetype)searchCardsCriteriaWithScope:(VSSCardScope)scope identityType:(NSString *)identityType identities:(NSArray<NSString *> *)identities {
    return [[VSSSearchCardsCriteria alloc] initWithScope:scope identityType:identityType identities:identities];
}

+ (instancetype)searchCardsCriteriaWithScope:(VSSCardScope)scope identityType:(NSString *)identityType identity:(NSString *)identity {
    return [[VSSSearchCardsCriteria alloc] initWithScope:scope identityType:identityType identities:@[identity]];
}

+ (instancetype)searchCardsCriteriaWithIdentityType:(NSString *)identityType identities:(NSArray<NSString *>*)identities {
    return [[VSSSearchCardsCriteria alloc] initWithScope:VSSCardScopeApplication identityType:identityType identities:identities];
}

+ (instancetype)searchCardsCriteriaWithIdentityType:(NSString *)identityType identity:(NSString *)identity {
    return [[VSSSearchCardsCriteria alloc] initWithScope:VSSCardScopeApplication identityType:identityType identities:@[identity]];
}

+ (instancetype)searchCardsCriteriaWithIdentities:(NSArray<NSString *>*)identities {
    return [[VSSSearchCardsCriteria alloc] initWithScope:VSSCardScopeApplication identityType:nil identities:identities];
}

+ (instancetype)searchCardsCriteriaWithIdentity:(NSString *)identity {
    return [[VSSSearchCardsCriteria alloc] initWithScope:VSSCardScopeApplication identityType:nil identities:@[identity]];
}

+ (instancetype)searchCardsCriteriaWithAppBundleName:(NSString *)appBundleName {
    return [[VSSSearchCardsCriteria alloc] initWithScope:VSSCardScopeGlobal identityType:@"application" identities:@[appBundleName]];
}

- (instancetype)initWithScope:(VSSCardScope)scope identityType:(NSString *)identityType identities:(NSArray<NSString *> *)identities {
    self = [super init];

    if (self) {
        _scope = scope;
        _identityType = [identityType copy];
        _identities = [[NSArray alloc] initWithArray:identities copyItems:YES];
    }

    return self;
}

- (NSDictionary *)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVSSCModelIdentities] = [self.identities copy];
    if (self.identityType != nil)
        dict[kVSSCModelIdentityType] = [self.identityType copy];
    
    switch (self.scope) {
        case VSSCardScopeGlobal:
            dict[kVSSCModelCardScope] = vss_getCardScopeString(self.scope);
            break;
            
        case VSSCardScopeApplication:
            dict[kVSSCModelCardScope] = vss_getCardScopeString(self.scope);
            break;
    }
    
    return dict;
}

@end
