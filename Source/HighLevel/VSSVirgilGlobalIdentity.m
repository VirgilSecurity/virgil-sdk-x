//
//  VSSVirgilGlobalIdentity.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSVirgilApi.h"
#import "VSSVirgilGlobalIdentity.h"
#import "VSSVirgilGlobalIdentityPrivate.h"
#import "VSSVirgilIdentityPrivate.h"
#import "VSSModelCommonsPrivate.h"

@implementation VSSVirgilGlobalIdentity

- (instancetype)initWithContext:(VSSVirgilApiContext *)context value:(NSString *)value type:(NSString *)type {
    self = [super initWithContext:context value:value type:type];
    if (self) {
        _checkInvoked = NO;
    }
    
    return self;
}

- (void)checkWithOptions:(NSDictionary<NSString *, NSString *> *)options completion:(void (^)(NSError *))callback {
    if (self.checkInvoked) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Check was already invoked on this Identity instance" }]);
        return;
    }
    
    self.checkInvoked = YES;
    [self.context.client verifyIdentity:self.value identityType:self.type extraFields:options completion:^(NSString *actionId, NSError *error) {
        if (error != nil) {
            callback(error);
            return;
        }
        
        self.actionId = actionId;
        callback(nil);
    }];
}

- (void)confirmWithConfirmationCode:(NSString *)code completion:(void (^)(NSError *))callback {
    if (self.actionId.length == 0) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"Cannot confirm identity, invoke check method first" }]);
        return;
    }
    
    if (self.isConfimed) {
        callback([[NSError alloc] initWithDomain:kVSSVirgilApiErrorDomain code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"This Identity instance is already confirmed" }]);
        return;
    }
    
    [self.context.client confirmIdentityWithActionId:self.actionId confirmationCode:code timeToLive:3600 countToLive:1 completion:^(VSSConfirmIdentityResponse *response, NSError *error) {
        if (error != nil) {
            callback(error);
            return;
        }
        
        self.token = response.validationToken;
        callback(nil);
    }];
}

- (BOOL)isConfimed {
    return self.token.length > 0 || [self.type isEqualToString:vss_getGlobalIdentityTypeString(VSSGlobalIdentityTypeApplication)];
}

@end
