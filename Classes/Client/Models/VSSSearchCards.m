//
//  VSSSearchCards.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSearchCardsPrivate.h"
#import "NSObject+VSSUtils.h"
#import "VSSModelKeys.h"
#import "VSSModelCommonsPrivate.h"

@implementation VSSSearchCards

+ (instancetype)searchCardsWithScope:(VSSCardScope)scope identityType:(NSString *)identityType identities:(NSArray<NSString *> *)identities {
    return [[VSSSearchCards alloc] initWithScope:scope identityType:identityType identities:identities];
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
    dict[kVSSModelIdentities] = [self.identities copy];
    dict[kVSSModelIdentityType] = [self.identityType copy];
    
    switch (self.scope) {
        case VSSCardScopeGlobal:
            dict[kVSSModelCardScope] = vss_getCardScopeString(VSSCardScopeGlobal);
            break;
            
        case VSSCardScopeApplication:
            break;
    }
    
    return dict;
}

@end
