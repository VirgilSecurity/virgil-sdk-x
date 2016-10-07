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

@implementation VSSSearchCards

+ (instancetype __nonnull)createWithScope:(VSSCardScope)scope identityType:(NSString *)identityType identities:(NSArray<NSString *> *)identities {
    return [[VSSSearchCards alloc] initWithScope:scope identityType:identityType identities:identities];
}

- (instancetype __nonnull)initWithScope:(VSSCardScope)scope identityType:(NSString *)identityType identities:(NSArray<NSString *> *)identities {
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
    dict[@"identities"] = [self.identities copy];
    dict[@"identity_type"] = [self.identityType copy];
    
    switch (self.scope) {
        case VSSCardScopeGlobal:
            dict[@"scope"] = @"global";
            break;
            
        case VSSCardScopeApplication:
            break;
    }
    
    return dict;
}

@end
