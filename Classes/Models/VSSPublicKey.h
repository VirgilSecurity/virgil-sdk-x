//
//  VSSPublicKey.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSBaseModel.h"

@interface VSSPublicKey : VSSBaseModel

/// Actual public key data.
@property (nonatomic, copy, readonly) NSData * __nonnull key;
/// The array with user data entities attached to (or associated with) this public key at the Virgil Keys Service.
@property (nonatomic, copy, readonly) NSArray * __nonnull userDataList;

- (instancetype __nonnull)initWithIdb:(VSSIdBundle * __nonnull)idb key:(NSData * __nonnull)key userDataList:(NSArray * __nonnull)userDataList NS_DESIGNATED_INITIALIZER;
- (instancetype __nonnull)initWithPublicKey:(VSSPublicKey * __nonnull)publicKey;

@end
