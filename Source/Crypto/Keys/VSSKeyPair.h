//
//  VSSKeyPair.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSBaseModel.h"
#import "VSSPublicKey.h"
#import "VSSPrivateKey.h"

/**
 Class which wraps pair of VSSPublicKey and VSSPrivateKey.
 See VSSPublicKey, VSSPrivateKey.
 */
@interface VSSKeyPair : NSObject

- (instancetype __nonnull)initWithPrivateKey:(VSSPrivateKey * __nonnull)privateKey publicKey:(VSSPublicKey * __nonnull)publicKey;

/**
 VSSPublicKey of key pair
 */
@property (nonatomic, copy, readonly) VSSPublicKey * __nonnull publicKey;

/**
 VSSPrivateKey of key pair
 */
@property (nonatomic, copy, readonly) VSSPrivateKey * __nonnull privateKey;

/**
 Unavailable no-argument initializer inherited from NSObject
 */
- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
