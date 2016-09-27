//
//  VSSModelCommonsPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger const kVSSNoErrorValue;

NSString * __nonnull vss_getCardScopeString(VSSCardScope scope);
VSSCardScope vss_getCardScopeFromString(NSString * __nonnull scope);
