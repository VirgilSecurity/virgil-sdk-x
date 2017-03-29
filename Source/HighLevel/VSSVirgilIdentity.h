//
//  VSSVirgilIdentity.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/3/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"

/**
 Base class used to represent card owner's identity.
 VSSVirgilIdentity subclass instances can be created using VSSIdentitiesManager via VSSVirgilApi.
 */
@interface VSSVirgilIdentity : NSObject

/**
 NSString with identity value
 */
@property (nonatomic, readonly) NSString * __nonnull value;

/**
 NSString with identity type
 */
@property (nonatomic, readonly) NSString * __nonnull type;

/**
 YES if Identity is confirmed, NO otherwise
 */
@property (nonatomic, readonly) BOOL isConfimed;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
