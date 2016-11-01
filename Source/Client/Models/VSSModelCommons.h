//
//  VSSModelCommons.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Enum which represents VSSCreateCardRequestscope.

 - VSSCardScopeApplication: Scope visible only inside application
 - VSSCardScopeGlobal:      Scope visible to all after designated confirmation process
 */
typedef NS_ENUM(NSInteger, VSSCardScope) {
    VSSCardScopeApplication,
    VSSCardScopeGlobal
};

/**
 Enum which represents reason of VSSCreateCardRequestrevocation.

 - VSSCardRevocationReasonUnspecified: No reason was specified
 - VSSCardRevocationReasonCompromised: Private Key of the card was compromised
 */
typedef NS_ENUM(NSInteger, VSSCardRevocationReason) {
    VSSCardRevocationReasonUnspecified,
    VSSCardRevocationReasonCompromised
};
