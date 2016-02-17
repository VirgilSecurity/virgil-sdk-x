//
//  VSSTypes.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString GUID;

typedef NS_ENUM(NSUInteger, VSSIdentityType) {
    VSSIdentityTypeUnknown,
    VSSIdentityTypeEmail,
    VSSIdentityTypeApplication
};