//
//  VSSCard.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSModelCommons.h"

/**
 Model that represents identities on the Virgil Cards Service.
 Each card has assigned identity of identityType, publicKey (and owner has corresponding private key),
 info about device on which Card was created, custom payload, version, creation date and scope (global or application)
 */
@interface VSSCard: VSSBaseModel

@property (nonatomic, copy, readonly) NSString * __nonnull identifier;

/**
 NSString value which represent VSSCreateCardRequestwithin same Identity Type
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
 VSSCreateCardRequestscope. See VSSCardScope
 */
@property (nonatomic, readonly) VSSCardScope scope;

/**
 NSDictionary with info representing Device on which VSSCreateCardRequestwas created
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> * __nullable info;

/**
 Virgil Card creation date
 */
@property (nonatomic, copy, readonly) NSDate * __nonnull createdAt;

/**
 Virgil card version
 */
@property (nonatomic, copy, readonly) NSString * __nonnull cardVersion;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
