//
//  VSSModelCommons.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VSSCardScope) {
    VSSCardScopeApplication,
    VSSCardScopeGlobal
};

typedef NS_ENUM(NSInteger, VSSCardRevocationReason) {
    VSSCardRevocationReasonUnspecified,
    VSSCardRevocationReasonCompromised
};
