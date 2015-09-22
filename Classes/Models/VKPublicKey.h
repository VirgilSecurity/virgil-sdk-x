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
@property (nonatomic, copy, readonly) NSData *key;
/// The array with user data entities attached to (or associated with) this public key at the Virgil Keys Service.
@property (nonatomic, copy, readonly) NSArray *userDataList;

- (instancetype)initWithIdb:(VKIdBundle *)idb key:(NSData *)key userDataList:(NSArray *)userDataList NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPublicKey:(VKPublicKey *)publicKey;

@end
