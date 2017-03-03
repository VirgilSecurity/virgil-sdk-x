//
//  VSSIdentitiesManager.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSIdentitiesManager.h"
#import "VSSIdentitiesManagerPrivate.h"
#import "VSSVirgilIdentityPrivate.h"
#import "VSSModelCommonsPrivate.h"

@implementation VSSIdentitiesManager

- (instancetype)initWithContext:(VSSVirgilApiContext *)context {
    self = [super init];
    if (self) {
        _context = context;
    }
    
    return self;
}

- (VSSVirgilIdentity *)createIdentityWithValue:(NSString *)value type:(NSString *)type {
    return [[VSSVirgilIdentity alloc] initWithContext:self.context value:value type:type];
}

- (VSSVirgilGlobalIdentity *)createGlobalIdentityWithValue:(NSString *)value type:(VSSGlobalIdentityType)type {
    NSString *identityType = vss_getGlobalIdentityTypeString(type);
    return [[VSSVirgilGlobalIdentity alloc] initWithContext:self.context value:value type:identityType];
}

@end
