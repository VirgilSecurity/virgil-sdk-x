//
//  VKPublicKey.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKBaseModel.h"

@interface VKPublicKey : VKBaseModel

/// Actual public key data.
@property (nonatomic, copy, readonly) NSData *Key;
/// The array with user data entities attached to (or associated with) this public key at the Virgil Keys Service.
@property (nonatomic, copy, readonly) NSArray *UserDataList;

- (instancetype)initWithId:(VKIdBundle *)Id Key:(NSData *)Key UserDataList:(NSArray *)UserDataList NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPublicKey:(VKPublicKey *)publicKey;

@end
