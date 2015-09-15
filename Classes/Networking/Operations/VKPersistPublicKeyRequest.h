//
//  VKPersistPublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"
#import "VKIdBundle.h"

@class VKPublicKey;
@class VKActionToken;

@interface VKPersistPublicKeyRequest : VKBaseRequest

@property (nonatomic, strong, readonly) VKPublicKey *publicKey;

- (instancetype)initWithBaseURL:(NSString *)url publicKeyId:(GUID *)publicKeyId actionToken:(VKActionToken *)actionToken NS_DESIGNATED_INITIALIZER;

@end
