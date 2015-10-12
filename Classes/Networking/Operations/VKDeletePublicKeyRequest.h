//
//  VKDeletePublicKeyRequest.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKBaseRequest.h"
#import <VirgilFrameworkiOS/VFTypes.h>

@class VKActionToken;

@interface VKDeletePublicKeyRequest : VKBaseRequest

@property (nonatomic, strong, readonly) VKActionToken * __nullable actionToken;

- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url publicKeyId:(GUID * __nonnull)publicKeyId NS_DESIGNATED_INITIALIZER;

@end
