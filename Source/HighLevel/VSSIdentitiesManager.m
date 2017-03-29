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
#import "VSSCreateApplicationGlobalCardRequest.h"

@implementation VSSIdentitiesManager

- (instancetype)initWithContext:(VSSVirgilApiContext *)context {
    self = [super init];
    if (self) {
        _context = context;
    }
    
    return self;
}

- (VSSUserIdentity *)createUserIdentityWithValue:(NSString *)value type:(NSString *)type {
    return [[VSSUserIdentity alloc] initWithContext:self.context value:value type:type];
}

- (VSSEmailIdentity *)createEmailIdentityWithEmail:(NSString *)email {
    return [[VSSEmailIdentity alloc] initWithContext:self.context value:email type:kVSSCardIdentityTypeEmail];
}

- (VSSApplicationIdentity *)createApplicationIdentityWithName:(NSString *)name {
    return [[VSSApplicationIdentity alloc] initWithContext:self.context value:name type:kVSSCardIdentityTypeApplication];
}

@end
