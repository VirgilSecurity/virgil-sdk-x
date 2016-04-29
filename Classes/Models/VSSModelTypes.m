//
//  VSSModelTypes.m
//  VirgilSDK
//
//  Created by Pavel Gorb on 4/28/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSModelTypes.h"
#import "VSSModelCommons.h"

@implementation VSSIdentityTypeHelper

+ (VSSIdentityType)fromString:(NSString *)source {
    VSSIdentityType itype = VSSIdentityTypeUnknown;
    
    if ([source isEqualToString:kVSSIdentityTypeCustom]) {
        itype = VSSIdentityTypeCustom;
    }
    else if ([source isEqualToString:kVSSIdentityTypeEmail]) {
        itype = VSSIdentityTypeEmail;
    }
    else if ([source isEqualToString:kVSSIdentityTypeApplication]) {
        itype = VSSIdentityTypeApplication;
    }
    return itype;
}

+ (NSString *)toString:(VSSIdentityType)source {
    NSString *itString = kVSSIdentityTypeUnknown;
    switch (source) {
        case VSSIdentityTypeCustom:
            itString = kVSSIdentityTypeCustom;
            break;
        case VSSIdentityTypeEmail:
            itString = kVSSIdentityTypeEmail;
            break;
        case VSSIdentityTypeApplication:
            itString = kVSSIdentityTypeApplication;
        default:
            break;
    }
    return itString;
}

@end