//
//  VSSModelCommons.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"

NSInteger const kVSSNoErrorValue = 0;

NSString * __nonnull vss_getCardScopeString(VSSCardScope scope) {
    switch (scope) {
        case VSSCardScopeGlobal: return @"global";
        case VSSCardScopeApplication: return @"application";
    }
}

VSSCardScope vss_getCardScopeFromString(NSString * __nonnull scope) {
    if ([scope isEqualToString:@"global"])
        return VSSCardScopeGlobal;
    else if ([scope isEqualToString:@"application"])
        return VSSCardScopeApplication;
    
    // default value
    return VSSCardScopeApplication;
}

NSString * __nonnull vss_getRevocationReasonString(VSSCardRevocationReason reason) {
    switch (reason) {
        case VSSCardRevocationReasonCompromised: return @"compromised";
        case VSSCardRevocationReasonUnspecified: return @"unspecified";
    }
}
