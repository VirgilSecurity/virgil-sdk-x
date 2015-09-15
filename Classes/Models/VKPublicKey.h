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

@property (nonatomic, copy, readonly) NSData *Key;
@property (nonatomic, copy, readonly) NSArray *UserDataList;

- (instancetype)initWithId:(VKIdBundle *)Id Key:(NSData *)Key UserDataList:(NSArray *)UserDataList NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPublicKey:(VKPublicKey *)publicKey;

@end
