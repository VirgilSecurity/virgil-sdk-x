//
//  VKCreatePublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/12/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"

@class VKPublicKey;

@interface VKCreatePublicKeyRequest : VKBaseRequest

@property (nonatomic, strong, readonly) VKPublicKey *publicKey;

- (instancetype)initWithBaseURL:(NSString *)url publicKey:(VKPublicKey *)key NS_DESIGNATED_INITIALIZER;

@end
