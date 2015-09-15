//
//  VKResetPublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"
#import "VKIdBundle.h"

@class VKActionToken;

@interface VKResetPublicKeyRequest : VKBaseRequest

@property (nonatomic, strong, readonly) VKActionToken *actionToken;

- (instancetype)initWithBaseURL:(NSString *)url publicKeyId:(GUID *)publicKeyId publicKey:(NSData *)publicKey;

@end
