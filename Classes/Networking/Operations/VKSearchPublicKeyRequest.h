//
//  VKSearchPublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"

@class VKPublicKey;

@interface VKSearchPublicKeyRequest : VKBaseRequest

@property (nonatomic, strong, readonly) VKPublicKey * __nullable publicKey;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url userIdValue:(NSString * __nullable)userIdValue NS_DESIGNATED_INITIALIZER;

@end
