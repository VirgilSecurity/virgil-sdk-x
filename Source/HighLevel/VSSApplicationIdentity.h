//
//  VSSApplicationIdentity.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/27/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilIdentity.h"

/**
 VSSVirgilIdentity subclass used for Virgil Cards corresponding to application in Global Scope.
 NOTE: These Identities require confirmation and currently can be confirmed using SDK.
 */
@interface VSSApplicationIdentity : VSSVirgilIdentity

@end
