//
//  VSSConfirmIdentityResponse.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 12/14/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSConfirmIdentityResponsePrivate.h"
#import "VSSModelKeys.h"
#import "NSObject+VSSUtils.h"

@implementation VSSConfirmIdentityResponse

#pragma mark - VSSDeserializable

- (instancetype)initWithDict:(NSDictionary *)candidate {
    NSString *identityType = [candidate[kVSSIModelIdentityType] as:[NSString class]];
    if (identityType.length == 0)
        return nil;
    
    NSString *identityValue = [candidate[kVSSIModelIdentityValue] as:[NSString class]];
    if (identityValue.length == 0)
        return nil;
    
    NSString *validationToken = [candidate[kVSSIModelValidationToken] as:[NSString class]];
    if (validationToken.length == 0)
        return nil;
    
    self = [super init];
    
    if (self) {
        _identityType = [identityType copy];
        _identityValue = [identityValue copy];
        _validationToken = [validationToken copy];
    }
    
    return self;
}

@end
