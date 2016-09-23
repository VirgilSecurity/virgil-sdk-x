//
//  VSSSearchCardsCriteria.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/22/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSSearchCardsCriteria.h"
#import "NSObject+VSSUtils.h"

@implementation VSSSearchCardsCriteria

- (instancetype __nonnull)initWithScope:(VSSCardScope)scope identityType:(NSString *)identityType identities:(NSArray<NSString *> *)identities {
    self = [super init];

    if (self) {
        _scope = scope;
        _identityType = [identityType copy];
        _identities = [[NSArray alloc] initWithArray:identities copyItems:YES];
    }

    return self;
}

@end
