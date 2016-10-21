//
//  VSSCardData.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/26/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModelCommons.h"
#import "VSSBaseModel.h"

/**
 Virgil Model that contains all VSSCard data.
 */
@interface VSSCardData : VSSBaseModel

/**
 NSString value which represent VSSCard within same Identity Type
 */
@property (nonatomic, copy, readonly) NSString * __nonnull identity;

/**
 NSString value which represents Identity Type, such as Email, Username, Phone number, etc.
 */
@property (nonatomic, copy, readonly) NSString * __nonnull identityType;

/**
 NSData with public key of VSSCard
 */
@property (nonatomic, copy, readonly) NSData * __nonnull publicKey;

/**
 NSDictionary with any custom payload which will be stored with VSSCard
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> * __nullable data;

/**
 VSSCard scope. See VSSCardScope
 */
@property (nonatomic, readonly) VSSCardScope scope;

/**
 NSDictionary with info representing Device on which VSSCard was created
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> * __nonnull info;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
