//
//  VSSCreateCardSnapshotModel.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/26/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSModelCommons.h"
#import "VSSSnapshotModel.h"

/**
 Virgil Model that contains basic Virgil Card data needed for Card Creation. See VSSCreateCardRequest.
 */
@interface VSSCreateCardSnapshotModel : VSSSnapshotModel

/**
 NSString value which represent Virgl Card within same Identity Type
 */
@property (nonatomic, copy, readonly) NSString * __nonnull identity;

/**
 NSString value which represents Identity Type, such as Email, Username, Phone number, etc.
 */
@property (nonatomic, copy, readonly) NSString * __nonnull identityType;

/**
 NSData with public key of Virgil Card
 */
@property (nonatomic, copy, readonly) NSData * __nonnull publicKeyData;

/**
 NSDictionary with any custom payload which will be stored with Virgil Card
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> * __nullable data;

/**
 VSSCreateCardRequestscope. See VSSCardScope
 */
@property (nonatomic, readonly) VSSCardScope scope;

/**
 NSDictionary with info representing Device on which Virgil Card was created
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> * __nullable info;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
