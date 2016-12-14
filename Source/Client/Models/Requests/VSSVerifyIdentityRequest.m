//
//  VSSVerifyEmailRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVerifyIdentityRequest.h"
#import "VSSModelKeys.h"

@implementation VSSVerifyIdentityRequest

- (instancetype)initWithIdentity:(NSString *)identity identityType:(NSString *)identityType extraFields:(NSDictionary<NSString *, NSString *> *)extraFields {
    self = [super init];
    if (self) {
        _identity = [identity copy];
        _identityType = [identityType copy];
        if (extraFields != nil)
            _extraFields = [[NSDictionary alloc] initWithDictionary:extraFields copyItems:YES];
    }
    
    return self;
}

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVSSIModelIdentityType] = [self.identityType copy];
    dict[kVSSIModelIdentityValue] = [self.identity copy];
    
    if (self.extraFields != nil) {
        dict[kVSSIModelExtraFields] = [self.extraFields copy];
    }
    
    return dict;
}

@end
