//
//  VSSValidateIdentityRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSValidateIdentityRequest.h"
#import "VSSModelKeys.h"

@implementation VSSValidateIdentityRequest

- (instancetype)initWithIdentityType:(NSString *)identityType identityValue:(NSString *)identityValue validationToken:(NSString *)validationToken {
    self = [super init];
    if (self) {
        _identityType = [identityType copy];
        _identityValue = [identityValue copy];
        _validationToken = [validationToken copy];
    }
    
    return self;
}

- (NSDictionary * __nonnull)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[kVSSIModelIdentityType] = self.identityType;
    dict[kVSSIModelIdentityValue] = self.identityValue;
    dict[kVSSIModelValidationToken] = self.validationToken;
    
    return dict;
}

@end
